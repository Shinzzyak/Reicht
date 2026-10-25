if not game:IsLoaded() then
game.Loaded:Wait()
end
local UNIVERSE_ID = 3647333358
local PLACE_ID = 9872472334
if game.GameId ~= UNIVERSE_ID and game.GameId ~= PLACE_ID and game.PlaceId ~= PLACE_ID then
game:GetService("Players").LocalPlayer:Kick("Reicht: this script is for Evade only")
return
end
local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local UserInputService = game:GetService("UserInputService")
local RunService = game:GetService("RunService")
local StarterGui = game:GetService("StarterGui")
local LocalPlayer = Players.LocalPlayer
local UI_URL = "https://raw.githubusercontent.com/Shinzzyak/Reicht/refs/heads/main/ui.lua"
local SAVE_FOLDER = "Reicht/Evade"
local UI_EMBEDDED = [[local TweenService = game:GetService("TweenService")
local UserInputService = game:GetService("UserInputService")
local RunService = game:GetService("RunService")
local Players = game:GetService("Players")
local HttpService = game:GetService("HttpService")
local TextService = game:GetService("TextService")
local CoreGui = game:GetService("CoreGui")
local Stats = game:GetService("Stats")
local Workspace = game:GetService("Workspace")
local LocalPlayer = Players.LocalPlayer
local Library = {
Version = "1.0",
Options = {},
Buttons = {},
Toggles = {},
Unloaded = false,
Window = nil,
}
local Config = {
GuiAttribute = "MarioHubUI",
Root = "mariohub",
AssetDir = "mariohub/assets",
ConfigRoot = "mariohub/configs",
DefaultAssets = {
},
SeasonTheme = "Halloween",
FontDir = "mariohub/fonts",
HttpTimeout = 8,
FontTimeout = 20,
PreloadTimeout = 5,
ThaiFont = {
Family = "MarioKanit",
Source = "https://raw.githubusercontent.com/google/fonts/main/ofl/kanit/Kanit-%s.ttf",
Weights = { [400] = "Regular", [500] = "Medium", [600] = "SemiBold" },
},
ThaiSizeBonus = { Body = 2, Desc = 2, Display = 1, Strong = 1 },
Text = { Title = 26, Header = 22, Group = 16, Label = 15, Desc = 13, Small = 12, Button = 15, Watermark = 13, Section = 13 },
Window = {
Width = 820, Height = 560, MinWidth = 520, MinHeight = 360,
TouchMinWidth = 320, TouchMinHeight = 260,
Topbar = 56, Sidebar = 196, SidebarCompact = 64, Header = 62, Ground = 24, UserCard = 58,
CompactBreakpoint = 640, TwoColumnMin = 540, Margin = 24, TouchMargin = 10,
Radius = 12, Stroke = 3, Shadow = 6,
},
Metrics = {
Desktop = { Row = 32, Box = 32, Item = 30, Track = 10, Knob = 18, Switch = Vector2.new(42, 22), SwitchKnob = 16, Tab = 38, Check = 22, Icon = 18, Depth = 4, Radius = 8 },
Touch = { Row = 38, Box = 36, Item = 36, Track = 12, Knob = 24, Switch = Vector2.new(50, 26), SwitchKnob = 20, Tab = 44, Check = 26, Icon = 20, Depth = 4, Radius = 8 },
},
Motion = {
Speed = { Fast = 28, Normal = 20, Soft = 14, Slow = 10 },
Damping = 0.72,
BounceDamping = 0.46,
SquashDamping = 0.44,
},
Selectable = { PadX = 10, Bar = 4, BarWidth = 4, Radius = 8, HoverAlpha = 0.35 },
Button = { PadX = 14, IconGap = 6, Depth = 4, HoverLighten = 0.14 },
Group = { Header = 36, PadX = 12, PadY = 10, Shadow = 4, Radius = 12, Stroke = 2 },
Gap = { X = 8, Y = 6, Column = 12 },
Page = { Pad = 14, ScrollBar = 6 },
Dropdown = { MaxVisible = 7, SearchThreshold = 8, MinWidth = 170 },
ColorPicker = { Field = 150, Hue = 14 },
Notify = { Width = 300, TouchWidth = 260, Duration = 4, Gap = 8 },
Tween = { Fast = 0.15, Normal = 0.2, Slide = 0.28, Pop = 0.32, Collapse = 0.24, Notify = 0.42 },
Ease = {
Out = { Enum.EasingStyle.Quint, Enum.EasingDirection.Out },
Back = { Enum.EasingStyle.Back, Enum.EasingDirection.Out },
In = { Enum.EasingStyle.Quad, Enum.EasingDirection.In },
Sine = { Enum.EasingStyle.Sine, Enum.EasingDirection.InOut },
Linear = { Enum.EasingStyle.Linear, Enum.EasingDirection.InOut },
Bounce = { Enum.EasingStyle.Bounce, Enum.EasingDirection.Out },
},
Layer = { Window = 10, Watermark = 30, Float = 40, Overlay = 50, Modal = 52, Tooltip = 55, Notify = 60, Intro = 70 },
LayoutPasses = 12,
MeasureCacheLimit = 4000,
DragThreshold = 6,
DragSlop = 10,
ConfirmWindow = 2,
TooltipDelay = 0.45,
TitleWaveInterval = 9,
ScaleRange = { Min = 0.7, Max = 1.4 },
Particles = { Count = 10, MinTime = 7, MaxTime = 13 },
MouseNames = {
[Enum.UserInputType.MouseButton1] = "MB1",
[Enum.UserInputType.MouseButton2] = "MB2",
[Enum.UserInputType.MouseButton3] = "MB3",
},
TitleColors = { "Accent", "Coin", "Good", "Blue" },
}
local function rgb(hex)
return Color3.fromRGB(tonumber(hex:sub(1, 2), 16), tonumber(hex:sub(3, 4), 16), tonumber(hex:sub(5, 6), 16))
end
local function Palette(spec)
local palette = {}
for token, value in pairs(spec) do
if token == "Logo" then
palette.Logo = value
elseif token == "Particle" then
local glyphs = type(value[1]) == "table" and value[1] or { value[1] }
palette.ParticleGlyph, palette.ParticleGlyphs, palette.ParticleFall, palette.ParticleColor = glyphs[1], glyphs, value[2], rgb(value[3])
elseif token == "Decor" then
palette.Decor, palette.DecorGlyph, palette.DecorColor = value[1], value[2] or "✦", rgb(value[3] or "FFFFFF")
elseif type(value) == "string" then
palette[token] = rgb(value)
else
palette[token] = value
end
end
return palette
end
local Themes = {
Order = { "Overworld", "Halloween", "Light", "Dark", "Underground", "Castle", "Ghost House", "Star Road", "Desert", "Ice Land", "Jungle", "Sky World" },
Overworld = Palette({
Backdrop = "C4D6EC", BackdropAlt = "E2E9F2", Topbar = "7092CC", Sidebar = "96563E", SidebarAlt = "804834",
SidebarText = "FCF2E6", SidebarMuted = "E2C4B0", TabActive = "FAF4E9", TabActiveText = "B84034",
Panel = "FAF6EE", PanelHeader = "F1E7D4", Element = "FFFCF6", Hover = "EEE2CA",
Outline = "3E384A", Shadow = "7880A0", Text = "3A3028", SubText = "76685A", Muted = "A09484", Track = "DED4C4",
Cloud = "FFFFFF", CloudAlpha = 0.25, Accent = "D64C40", AccentDark = "A0342C", Grass = "74B45C", GrassDark = "4E8840", Brick = "A46042", BrickDark = "683A28", Decor = { "Clouds" },
Particle = { "✦", false, "F6D878" },
}),
Halloween = Palette({
Backdrop = "1A1226", BackdropAlt = "2A1838", Topbar = "2B1A3E", Sidebar = "3A2150", SidebarAlt = "2C1840",
SidebarText = "FFF1E2", SidebarMuted = "C9A9D8", TabActive = "F28A2E", TabActiveText = "1E1024",
Panel = "241830", PanelHeader = "301F40", Element = "2E2140", Hover = "3C2A52",
Outline = "0B0610", Shadow = "0B0610", Text = "FFF1E2", SubText = "D7BFD9", Muted = "9C85A8", Track = "4A3460",
Cloud = "B98CFF", CloudAlpha = 0.85, Accent = "F28A2E", AccentDark = "B85E14", Grass = "7A3FA8", GrassDark = "4E2470", Brick = "4A2E60", BrickDark = "1E1028", Decor = { "Halloween", "✦", "FFB347" },
Glow = "F28A2E", Fog = "8E5CD0", Logo = "logo_halloween",
Particle = { { "✦", "✦", "•", "✧" }, false, "FFB347" },
}),
Light = Palette({
Backdrop = "F2EEE6", BackdropAlt = "FAF8F3", Topbar = "EDE4D4", TopbarText = "4A3F35", Sidebar = "EAE2D4", SidebarAlt = "DDD3C2",
SidebarText = "4A3F35", SidebarMuted = "9B8E7E", TabActive = "D64C40", TabActiveText = "FFFFFF",
Panel = "FFFFFF", PanelHeader = "F6F1E8", Element = "FBF9F5", Hover = "F0E8DA",
Outline = "4A4458", Shadow = "CFC7BA", Text = "3A3028", SubText = "7C6E60", Muted = "ABA092", Track = "E6DED2",
Cloud = "C8D8EC", CloudAlpha = 0, Accent = "D64C40", AccentDark = "A0342C", Grass = "8CC47A", GrassDark = "62A052", Brick = "D8B48E", BrickDark = "AE8A64", Decor = { "Clouds" },
Particle = { "•", false, "D64C40" },
}),
Dark = Palette({
Backdrop = "1E1F26", BackdropAlt = "25262F", Topbar = "17181E", Sidebar = "22232B", SidebarAlt = "1B1C22",
SidebarText = "E8E6F0", SidebarMuted = "8D8A9C", TabActive = "D64C40", TabActiveText = "FFFFFF",
Panel = "2A2B34", PanelHeader = "31323C", Element = "353743", Hover = "3E404D",
Outline = "0E0E12", Shadow = "0E0E12", Text = "ECEAF4", SubText = "A9A6B8", Muted = "7B788C", Track = "454756",
Cloud = "FFFFFF", CloudAlpha = 0.9, Accent = "E0584C", AccentDark = "A83A30", Grass = "5A5C6E", GrassDark = "3E3F4C", Brick = "2E2F39", BrickDark = "17181E", Decor = { "Stars", "✦", "F0C448" },
Particle = { "✦", false, "F0C448" },
}),
Underground = Palette({
Backdrop = "141A36", BackdropAlt = "1E2750", Topbar = "0E1330", Sidebar = "22327A", SidebarAlt = "1A2762",
SidebarText = "ECF0FF", SidebarMuted = "98A8E0", TabActive = "F0C448", TabActiveText = "1E1B2E",
Panel = "1F2749", PanelHeader = "27305A", Element = "2C3666", Hover = "36417A",
Outline = "05060F", Shadow = "05060F", Text = "F2F4FF", SubText = "AEB6E2", Muted = "7C86B8", Track = "3C4780",
Cloud = "96AAFF", CloudAlpha = 0.8, Accent = "5B8CF0", AccentDark = "3A62C0", Grass = "3A5BC8", GrassDark = "2A469E", Brick = "2F4AA8", BrickDark = "142058", Decor = { "Stars", "✦", "8FA8FF" },
Particle = { "✦", false, "8FA8FF" },
}),
Castle = Palette({
Backdrop = "1E1818", BackdropAlt = "33201C", Topbar = "150F0F", Sidebar = "4A4040", SidebarAlt = "3A3232",
SidebarText = "FFF1E6", SidebarMuted = "C8B0A4", TabActive = "E8703A", TabActiveText = "FFFFFF",
Panel = "2B2323", PanelHeader = "352B2B", Element = "3D3232", Hover = "4A3D3D",
Outline = "0A0707", Shadow = "0A0707", Text = "FFF1E6", SubText = "D9BFB0", Muted = "9F8579", Track = "524242",
Cloud = "FF8A50", CloudAlpha = 0.85, Accent = "E8703A", AccentDark = "B04A1E", Grass = "FF7A2E", GrassDark = "C8481A", Brick = "5A5050", BrickDark = "2A2222", Decor = { "Stars", "•", "FF8A3C" },
Particle = { "•", false, "FF8A3C" },
}),
["Ghost House"] = Palette({
Backdrop = "1C2226", BackdropAlt = "232B30", Topbar = "151A1E", Sidebar = "2C3A3A", SidebarAlt = "223030",
SidebarText = "E6F2EE", SidebarMuted = "8FB0A8", TabActive = "B8E0D2", TabActiveText = "1C2126",
Panel = "242C31", PanelHeader = "2B353B", Element = "303B42", Hover = "39454D",
Outline = "0B0E10", Shadow = "0B0E10", Text = "EAF4F1", SubText = "A3BDB6", Muted = "71898A", Track = "3E4B52",
Cloud = "CFF5E7", CloudAlpha = 0.85, Accent = "4FB89C", AccentDark = "348A72", Grass = "6B5040", GrassDark = "4A362A", Brick = "5A4334", BrickDark = "2E2219", Decor = { "Stars", "•", "B8F0DC" },
Particle = { "•", false, "9FE8D0" },
}),
["Star Road"] = Palette({
Backdrop = "1C1236", BackdropAlt = "2D1C54", Topbar = "130B28", Sidebar = "3B2475", SidebarAlt = "2D1A5C",
SidebarText = "FFF7FF", SidebarMuted = "CDB9F2", TabActive = "F0C448", TabActiveText = "26144A",
Panel = "251749", PanelHeader = "2E1D5A", Element = "34225F", Hover = "412A72",
Outline = "07030F", Shadow = "07030F", Text = "FFF7FF", SubText = "CDB9F2", Muted = "9580C4", Track = "4A3480",
Cloud = "FFE680", CloudAlpha = 0.8, Accent = "E85CA8", AccentDark = "B03C7E", Grass = "F0C448", GrassDark = "BA8C28", Brick = "5A38A8", BrickDark = "2A1858", Decor = { "Stars", "★", "FFD95A" },
Particle = { "★", false, "FFD95A" },
}),
Desert = Palette({
Backdrop = "E8DABD", BackdropAlt = "F4EBD8", Topbar = "C99A62", Sidebar = "B07E4E", SidebarAlt = "966A40",
SidebarText = "FFF6E8", SidebarMuted = "EED4B2", TabActive = "FFF8EC", TabActiveText = "B0502C",
Panel = "FFF9EE", PanelHeader = "F4E6CC", Element = "FFFCF6", Hover = "F0DFC0",
Outline = "5A4632", Shadow = "C2A07A", Text = "4A3828", SubText = "86705A", Muted = "B09A80", Track = "E6D6BC",
Cloud = "FFFFFF", CloudAlpha = 0.3, Accent = "C8643A", AccentDark = "964626", Grass = "EACB8C", GrassDark = "C9A866", Brick = "C08A5A", BrickDark = "8A5E38", Decor = { "Clouds" },
Particle = { "•", false, "C9964E" },
}),
["Ice Land"] = Palette({
Backdrop = "D8E8F4", BackdropAlt = "EDF4FA", Topbar = "86B0D2", Sidebar = "6A96BA", SidebarAlt = "5A82A4",
SidebarText = "F4FAFF", SidebarMuted = "CFE3F2", TabActive = "F6FBFF", TabActiveText = "3A78A8",
Panel = "F8FCFF", PanelHeader = "E6F0F8", Element = "FFFFFF", Hover = "DCEAF5",
Outline = "3E4F63", Shadow = "A6BACE", Text = "2E3D4D", SubText = "62788E", Muted = "95A8BA", Track = "D4E1EC",
Cloud = "FFFFFF", CloudAlpha = 0.2, Accent = "3A8AC8", AccentDark = "2A6698", Grass = "FFFFFF", GrassDark = "CFE3F2", Brick = "7FA8CC", BrickDark = "4F7699", Decor = { "Clouds" },
Particle = { "❄", true, "FFFFFF" },
}),
Jungle = Palette({
Backdrop = "1F2E23", BackdropAlt = "293C2D", Topbar = "17231A", Sidebar = "2F4A33", SidebarAlt = "253B29",
SidebarText = "EEF7EA", SidebarMuted = "A3C29C", TabActive = "F0C84A", TabActiveText = "1F2A1F",
Panel = "26382A", PanelHeader = "2E4332", Element = "334A37", Hover = "3D5641",
Outline = "0C120D", Shadow = "0C120D", Text = "EEF6EA", SubText = "AFC6A8", Muted = "7E957A", Track = "445C47",
Cloud = "D8F5C8", CloudAlpha = 0.85, Accent = "E08A3A", AccentDark = "A86024", Grass = "5AAE4E", GrassDark = "3A7A34", Brick = "5A4A32", BrickDark = "30261A", Decor = { "Stars", "•", "D8F07A" },
Particle = { "•", false, "D8F07A" },
}),
["Sky World"] = Palette({
Backdrop = "E6EEFC", BackdropAlt = "F6F9FF", Topbar = "A4BEEA", Sidebar = "8AA4D6", SidebarAlt = "7A92C4",
SidebarText = "FFFFFF", SidebarMuted = "E3EBFA", TabActive = "FFFFFF", TabActiveText = "4A6FB5",
Panel = "FFFFFF", PanelHeader = "EEF3FC", Element = "FFFFFF", Hover = "E4ECFA",
Outline = "46506A", Shadow = "B6C2DA", Text = "333C52", SubText = "6A7590", Muted = "9AA4BC", Track = "DCE3F0",
Cloud = "FFFFFF", CloudAlpha = 0.1, Accent = "4A6FB5", AccentDark = "34528A", Grass = "FFFFFF", GrassDark = "DCE6F8", Brick = "C4D4F0", BrickDark = "98AED8", Decor = { "Clouds" },
Particle = { "✦", false, "FFFFFF" },
}),
Shared = Palette({
Accent = "D64C40", AccentDark = "A0342C", OnAccent = "FFFFFF", Danger = "D64C40", DangerDark = "A0342C",
Blue = "468AC4", BlueDark = "326496", Good = "60AA62", GoodDark = "427E46",
Coin = "F0C448", CoinDark = "BA8C28", Risky = "E28046", RiskyDark = "A8562C",
Brick = "A46042", BrickDark = "683A28", Grass = "74B45C", GrassDark = "4E8840",
Knob = "FFFFFF", Ink = "2E2838", White = "FFFFFF", Black = "000000",
}),
}
local State = {
Gui = nil,
Overlay = nil,
Window = nil,
Popup = nil,
Drag = nil,
Binding = nil,
MenuKey = "LeftControl",
ThemeName = "Overworld",
Language = "EN",
UserScale = 1,
Touch = false,
KeyPickers = {},
Connections = {},
Tasks = {},
UnloadHooks = {},
Fps = 60,
StartTime = os.clock(),
}
local Util = {}
local Anim = {}
local Motion = {}
local Fx = {}
local Reactive = {}
local Tailwind = {}
local Draw = {}
local Sprite = {}
local Assets = { Overrides = {}, Cache = {} }
local Fonts = { Texts = {}, Thai = nil }
local Particles = { Pool = {}, Enabled = true }
local Lang = { Bound = {}, Listeners = setmetatable({}, { __mode = "k" }), InstanceListeners = {} }
local Theme = { Colors = {}, Bound = {}, Renderers = setmetatable({}, { __mode = "k" }), InstanceRenderers = {} }
local Layout = { Dirty = {}, All = setmetatable({}, { __mode = "k" }), Measured = {}, MeasuredCount = 0 }
local Icons = {}
local Creator = {}
local Gui = { Stack = {} }
local Popup = {}
local Dialog = {}
local Sheet = {}
local Tooltip = {}
local Notify = {}
local Watermark = {}
local Float = {}
local Keybinds = {}
local Configs = { Folder = Config.ConfigRoot .. "/default" }
local Intro = {}
local Widget = {}
local Row = {}
local Container = {}
Container.__index = Container
local Toggle = setmetatable({}, { __index = Widget })
Toggle.__index = Toggle
local Slider = setmetatable({}, { __index = Widget })
Slider.__index = Slider
local Dropdown = setmetatable({}, { __index = Widget })
Dropdown.__index = Dropdown
local Input = setmetatable({}, { __index = Widget })
Input.__index = Input
local Button = {}
Button.__index = Button
local KeyPicker = setmetatable({}, { __index = Widget })
KeyPicker.__index = KeyPicker
local ColorPicker = setmetatable({}, { __index = Widget })
ColorPicker.__index = ColorPicker
local Label = {}
Label.__index = Label
local Selectable = setmetatable({}, { __index = Widget })
Selectable.__index = Selectable
local ListBox = setmetatable({}, { __index = Widget })
ListBox.__index = ListBox
local Progress = setmetatable({}, { __index = Widget })
Progress.__index = Progress
local Stepper = setmetatable({}, { __index = Widget })
Stepper.__index = Stepper
local RangeSlider = setmetatable({}, { __index = Widget })
RangeSlider.__index = RangeSlider
local Segmented = setmetatable({}, { __index = Widget })
Segmented.__index = Segmented
local MultiChips = setmetatable({}, { __index = Widget })
MultiChips.__index = MultiChips
local StatWidget = setmetatable({}, { __index = Widget })
StatWidget.__index = StatWidget
local StatusWidget = setmetatable({}, { __index = Widget })
StatusWidget.__index = StatusWidget
local TableWidget = setmetatable({}, { __index = Widget })
TableWidget.__index = TableWidget
local Window = {}
Window.__index = Window
local Tab = {}
Tab.__index = Tab
local Groupbox = setmetatable({}, { __index = Container })
Groupbox.__index = Groupbox
Reactive.Stack = {}
Reactive.BatchDepth = 0
Reactive.Pending = {}
Reactive.Disposers = {}
function Reactive.Track(subscribers)
local active = Reactive.Stack[#Reactive.Stack]
if not active then
return
end
subscribers[active] = true
active.Deps[subscribers] = true
end
function Reactive.Trigger(subscribers)
for effect in pairs(subscribers) do
if Reactive.BatchDepth > 0 then
Reactive.Pending[effect] = true
else
Reactive.RunEffect(effect)
end
end
end
function Reactive.CleanupEffect(effect)
if effect.Cleanup then
pcall(effect.Cleanup)
effect.Cleanup = nil
end
for dep in pairs(effect.Deps) do
dep[effect] = nil
end
table.clear(effect.Deps)
end
function Reactive.RunEffect(effect)
if effect.Disposed or Library.Unloaded then
return
end
Reactive.CleanupEffect(effect)
table.insert(Reactive.Stack, effect)
local ok, cleanup = pcall(effect.Runner)
table.remove(Reactive.Stack)
if ok and type(cleanup) == "function" then
effect.Cleanup = cleanup
end
end
function Reactive.Effect(runner)
local effect = { Runner = runner, Deps = {}, Disposed = false, Cleanup = nil }
local function Dispose()
if effect.Disposed then
return
end
effect.Disposed = true
Reactive.CleanupEffect(effect)
end
table.insert(Reactive.Disposers, Dispose)
Reactive.RunEffect(effect)
return Dispose
end
function Reactive.Batch(callback)
Reactive.BatchDepth += 1
pcall(callback)
Reactive.BatchDepth -= 1
if Reactive.BatchDepth > 0 then
return
end
local queued = {}
for effect in pairs(Reactive.Pending) do
table.insert(queued, effect)
end
table.clear(Reactive.Pending)
for _, effect in ipairs(queued) do
Reactive.RunEffect(effect)
end
end
local RefMethods = {}
function RefMethods:Get()
Reactive.Track(self._subs)
return self._current
end
function RefMethods:Set(nextValue)
if self._current == nextValue and type(nextValue) ~= "table" then
return
end
local previous = self._current
self._current = nextValue
Reactive.Trigger(self._subs)
for _, listener in ipairs(self._listeners) do
pcall(listener, nextValue, previous)
end
end
function RefMethods:Update(transform)
self:Set(transform(self._current))
end
function RefMethods:Subscribe(listener, immediate)
table.insert(self._listeners, listener)
if immediate then
pcall(listener, self._current, nil)
end
return function()
local index = table.find(self._listeners, listener)
if index then
table.remove(self._listeners, index)
end
end
end
local RefMeta = {
__index = function(self, key)
if key == "Value" then
Reactive.Track(self._subs)
return self._current
end
return RefMethods[key]
end,
__newindex = function(self, key, nextValue)
if key == "Value" then
RefMethods.Set(self, nextValue)
return
end
rawset(self, key, nextValue)
end,
}
function Reactive.IsRef(candidate)
return type(candidate) == "table" and rawget(candidate, "_isRef") == true
end
function Reactive.Ref(initial)
return setmetatable({
_isRef = true,
_current = initial,
_subs = {},
_listeners = {},
}, RefMeta)
end
function Reactive.Computed(getter)
local derived = Reactive.Ref(nil)
Reactive.Effect(function()
local ok, evaluated = pcall(getter)
if ok then
derived:Set(evaluated)
end
end)
return derived
end
function Reactive.Watch(source, callback, options)
options = options or {}
if type(source) == "string" and Library.Options[source] then
source = Library.Options[source]
end
if type(source) == "table" and source.Ref then
return source.Ref:Subscribe(callback, options.Immediate)
end
if Reactive.IsRef(source) then
return source:Subscribe(callback, options.Immediate)
end
if type(source) == "function" then
local computed = Reactive.Computed(source)
return computed:Subscribe(callback, options.Immediate)
end
return function() end
end
local StoreProto = {}
StoreProto.__index = StoreProto
function StoreProto:Ref(key)
local slot = self._refs[key]
if not slot then
slot = Reactive.Ref(nil)
self._refs[key] = slot
end
return slot
end
function StoreProto:Get(key)
return self:Ref(key):Get()
end
function StoreProto:Set(key, nextValue)
self:Ref(key):Set(nextValue)
end
function StoreProto:Update(key, transform)
local slot = self:Ref(key)
slot:Set(transform(slot:Get()))
end
function StoreProto:Watch(key, callback, immediate)
return self:Ref(key):Subscribe(callback, immediate)
end
function Reactive.Store(initialState)
local store = setmetatable({ _refs = {}, State = {} }, StoreProto)
for key, initial in pairs(initialState or {}) do
store._refs[key] = Reactive.Ref(initial)
end
setmetatable(store.State, {
__index = function(_, key)
return store:Get(key)
end,
__newindex = function(_, key, nextValue)
store:Set(key, nextValue)
end,
})
return store
end
function Reactive.DisposeAll()
for _, dispose in ipairs(Reactive.Disposers) do
pcall(dispose)
end
table.clear(Reactive.Disposers)
table.clear(Reactive.Pending)
table.clear(Reactive.Stack)
end
function Util.Try(callback, ...)
if type(callback) ~= "function" then
return false
end
local ok, message = pcall(callback, ...)
if not ok then
warn("[Reicht] " .. tostring(message))
end
return ok, message
end
function Util.Connect(signal, callback)
local connection = signal:Connect(callback)
table.insert(State.Connections, connection)
return connection
end
function Util.Every(interval, callback)
table.insert(State.Tasks, { Interval = interval, Elapsed = 0, Run = callback })
end
function Util.Metric(name)
return Config.Metrics[State.Touch and "Touch" or "Desktop"][name]
end
function Util.TextSize(kind)
return Config.Text[kind] + (State.Touch and 1 or 0)
end
function Util.IsPointer(input)
return input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch
end
function Util.IsMove(input)
return input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch
end
function Util.InputName(input)
if input.UserInputType == Enum.UserInputType.Keyboard then
return input.KeyCode.Name
end
return Config.MouseNames[input.UserInputType]
end
function Util.KeyName(key)
if typeof(key) == "EnumItem" then
return key.Name
end
return type(key) == "string" and key or nil
end
function Util.Inside(guiObject, position)
local origin, size = guiObject.AbsolutePosition, guiObject.AbsoluteSize
return position.X >= origin.X and position.X <= origin.X + size.X and position.Y >= origin.Y and position.Y <= origin.Y + size.Y
end
function Util.GuiParent()
if type(gethui) == "function" then
local ok, hidden = pcall(gethui)
if ok and typeof(hidden) == "Instance" then
return hidden
end
end
local ok = pcall(function()
local probe = Instance.new("Folder")
probe.Parent = CoreGui
probe:Destroy()
end)
return ok and CoreGui or LocalPlayer:WaitForChild("PlayerGui", 10) or LocalPlayer:FindFirstChildOfClass("PlayerGui")
end
function Util.Await(timeout, callback, ...)
local box = { done = false }
local args = table.pack(...)
task.spawn(function()
box.values = table.pack(pcall(callback, table.unpack(args, 1, args.n)))
box.done = true
end)
local started = os.clock()
while not box.done and os.clock() - started < timeout do
task.wait(0.05)
end
if not box.done or not box.values[1] then
return false
end
return true, table.unpack(box.values, 2, box.values.n)
end
local function FetchBody(url)
local ok, body = pcall(game.HttpGet, game, url)
if ok and type(body) == "string" then
return body
end
local requester = (type(request) == "function" and request) or (type(http_request) == "function" and http_request) or (syn and syn.request)
if not requester then
return nil
end
local sent, response = pcall(requester, { Url = url, Method = "GET" })
return sent and type(response) == "table" and response.Body or nil
end
function Util.HttpGet(url)
local finished, body = Util.Await(Config.HttpTimeout, FetchBody, url)
return finished and type(body) == "string" and body or nil
end
function Util.CustomAsset(path)
if type(getcustomasset) ~= "function" then
return nil
end
local ok, asset = pcall(getcustomasset, path)
return ok and type(asset) == "string" and asset:find("^rbxasset") and asset or nil
end
function Util.Exists(path)
if type(isfile) ~= "function" then
return false
end
local ok, value = pcall(isfile, path)
return ok and value == true
end
local function SafeFile(fn, ...)
if type(fn) ~= "function" then
return nil
end
local ok, value = pcall(fn, ...)
if not ok then
return nil
end
return value == nil and true or value
end
function Util.Clipboard(text)
local setter = setclipboard or toclipboard or (syn and syn.write_clipboard)
if type(setter) ~= "function" then
return false
end
return (pcall(setter, text))
end
function Util.FileApi()
return type(writefile) == "function" and type(readfile) == "function" and type(isfile) == "function"
end
function Util.EnsureFolder(path)
if type(makefolder) ~= "function" or type(isfolder) ~= "function" then
return
end
local built = ""
for part in path:gmatch("[^/]+") do
built = built == "" and part or built .. "/" .. part
local okCheck, exists = pcall(isfolder, built)
if not (okCheck and exists == true) and not pcall(makefolder, built) then
return false
end
end
return true
end
function Util.Sanitize(name)
local clean = tostring(name):gsub('[%c/\\:%*%?"<>|]', ""):gsub("^%s+", ""):gsub("%s+$", "")
return clean ~= "" and clean or "config"
end
function Util.Round(value, decimals)
local factor = 10 ^ (decimals or 0)
return math.floor(value * factor + 0.5) / factor
end
function Util.ToSet(value)
local set = {}
if type(value) ~= "table" then
return set
end
for key, entry in pairs(value) do
if type(key) == "number" then
set[entry] = true
elseif entry then
set[key] = true
end
end
return set
end
function Util.PlayerNames()
local names = {}
for _, player in ipairs(Players:GetPlayers()) do
if player ~= LocalPlayer then
table.insert(names, player.Name)
end
end
table.sort(names)
return names
end
function Util.Lighten(color, amount)
return color:Lerp(Color3.new(1, 1, 1), amount)
end
function Util.Hex(color)
return string.format("#%02X%02X%02X", math.floor(color.R * 255 + 0.5), math.floor(color.G * 255 + 0.5), math.floor(color.B * 255 + 0.5))
end
function Util.FromHex(text)
local hex = tostring(text):gsub("#", "")
if not hex:match("^%x%x%x%x%x%x$") then
return nil
end
return Color3.fromRGB(tonumber(hex:sub(1, 2), 16), tonumber(hex:sub(3, 4), 16), tonumber(hex:sub(5, 6), 16))
end
Anim.Loops = {}
Anim.GroupState = {}
Anim.NoopSignal = {
Once = function(_, fn)
if type(fn) == "function" then
task.defer(fn)
end
end,
}
Anim.NoopTween = { Completed = Anim.NoopSignal, Cancel = function() end, Pause = function() end, Play = function() end }
function Anim.Info(duration, ease, repeatCount, reverses, delay)
local style = Config.Ease[ease or "Out"]
return TweenInfo.new(duration or Config.Tween.Normal, style[1], style[2], repeatCount or 0, reverses or false, delay or 0)
end
function Anim.Tween(inst, goal, duration, ease, repeatCount, reverses, delay)
if duration == 0 and (repeatCount or 0) == 0 and (delay or 0) == 0 then
for prop, val in pairs(goal) do
inst[prop] = val
end
return Anim.NoopTween
end
local tween = TweenService:Create(inst, Anim.Info(duration, ease, repeatCount, reverses, delay), goal)
tween:Play()
if repeatCount == -1 then
inst.Destroying:Once(function()
tween:Cancel()
end)
end
return tween
end
function Anim.Loop(group, inst, goal, duration, ease, reverses, delay)
local tween = TweenService:Create(inst, Anim.Info(duration, ease, -1, reverses, delay), goal)
local list = Anim.Loops[group]
if not list then
list = {}
Anim.Loops[group] = list
end
local active = Anim.GroupState[group] ~= false
local entry = { Tween = tween, Inst = inst, Playing = active }
table.insert(list, entry)
if active then
tween:Play()
end
inst.Destroying:Once(function()
tween:Cancel()
entry.Dead = true
end)
return tween
end
function Anim.SetGroupActive(group, active)
active = active == true
if Anim.GroupState[group] == active then
return
end
Anim.GroupState[group] = active
local list = Anim.Loops[group]
if not list then
return
end
for index = #list, 1, -1 do
local entry = list[index]
if entry.Dead or not entry.Inst or not entry.Inst.Parent then
table.remove(list, index)
elseif active and not entry.Playing then
entry.Playing = true
entry.Tween:Play()
elseif not active and entry.Playing then
entry.Playing = false
entry.Tween:Pause()
end
end
end
function Anim.Pop(scale, from)
scale.Scale = from or 0.85
return Anim.Tween(scale, { Scale = 1 }, Config.Tween.Pop, "Back")
end
function Anim.Bump(frame, rise)
if frame:GetAttribute("Bumping") then
return
end
frame:SetAttribute("Bumping", true)
local base = frame.Position
local tween = Anim.Tween(frame, { Position = base - UDim2.fromOffset(0, rise or 6) }, 0.09, "Out", 0, true)
tween.Completed:Once(function()
frame.Position = base
frame:SetAttribute("Bumping", nil)
end)
end
function Anim.Shake(frame)
local base = frame.Position
task.spawn(function()
for _, offset in ipairs({ -7, 6, -4, 3, 0 }) do
if not frame.Parent then
return
end
Anim.Tween(frame, { Position = base + UDim2.fromOffset(offset, 0) }, 0.04, "Linear")
task.wait(0.04)
end
frame.Position = base
end)
end
function Anim.Fade(root, alpha, duration)
local targets = root:GetDescendants()
table.insert(targets, root)
for _, inst in ipairs(targets) do
if inst:IsA("GuiObject") and inst.BackgroundTransparency < 1 then
Anim.Tween(inst, { BackgroundTransparency = alpha }, duration)
end
if inst:IsA("TextLabel") or inst:IsA("TextButton") then
Anim.Tween(inst, { TextTransparency = alpha }, duration)
elseif inst:IsA("ImageLabel") then
Anim.Tween(inst, { ImageTransparency = alpha }, duration)
elseif inst:IsA("UIStroke") then
Anim.Tween(inst, { Transparency = alpha }, duration)
end
end
end
function Anim.CoinPop(parent, origin, size)
local coin = Sprite.New(parent, "coin", size or 20)
coin.AnchorPoint = Vector2.new(0.5, 1)
coin.Position = origin
coin.ZIndex = 5
local rise = Anim.Tween(coin, { Position = origin - UDim2.fromOffset(0, 42) }, 0.35, "Out")
Anim.Tween(coin, { Size = UDim2.fromOffset(2, coin.Size.Y.Offset) }, 0.12, "Sine", 3, true)
rise.Completed:Once(function()
Anim.Fade(coin, 1, 0.18)
task.delay(0.2, function()
coin:Destroy()
end)
end)
end
function Theme.Apply(name)
if name == "Order" or name == "Shared" or not Themes[name] then
name = "Overworld"
end
local palette = Themes[name]
State.ThemeName = name
Theme.Colors.Logo, Theme.Colors.Glow, Theme.Colors.Fog, Theme.Colors.ParticleGlyphs = nil, nil, nil, nil
Theme.Colors.TopbarText = Themes.Shared.White
for token, color in pairs(Themes.Shared) do
Theme.Colors[token] = color
end
for token, color in pairs(palette) do
Theme.Colors[token] = color
end
for inst, map in pairs(Theme.Bound) do
if inst.Parent then
Theme.Paint(inst, map)
else
Theme.Bound[inst] = nil
end
end
for owner, render in pairs(Theme.Renderers) do
Util.Try(render)
end
for inst, render in pairs(Theme.InstanceRenderers) do
if inst.Parent then
Util.Try(render)
else
Theme.InstanceRenderers[inst] = nil
end
end
end
function Theme.Prune()
for _, registry in ipairs({ Theme.Bound, Theme.InstanceRenderers, Lang.Bound, Lang.InstanceListeners, Fonts.Texts }) do
for inst in pairs(registry) do
if not inst.Parent then
registry[inst] = nil
end
end
end
end
function Theme.UnbindTree(root)
if not root then
return
end
local list = root:GetDescendants()
table.insert(list, root)
for _, inst in ipairs(list) do
Theme.Bound[inst] = nil
Theme.InstanceRenderers[inst] = nil
Lang.Bound[inst] = nil
Lang.InstanceListeners[inst] = nil
Fonts.Texts[inst] = nil
end
end
function Theme.Paint(inst, map)
for property, token in pairs(map) do
local color = Theme.Colors[token]
if color ~= nil and inst[property] ~= color then
inst[property] = color
end
end
end
function Theme.Bind(inst, map)
local existing = Theme.Bound[inst]
if existing then
for property, token in pairs(map) do
existing[property] = token
end
else
Theme.Bound[inst] = map
end
Theme.Paint(inst, map)
return inst
end
function Theme.OnRender(owner, render)
local registry = typeof(owner) == "Instance" and Theme.InstanceRenderers or Theme.Renderers
registry[owner] = render
Util.Try(render)
end
Lang.Strings = {
Search = { EN = "Search...", TH = "ค้นหา..." },
Confirm = { EN = "Click again to confirm", TH = "กดอีกครั้งเพื่อยืนยัน" },
None = { EN = "None", TH = "ไม่มี" },
NoResults = { EN = "No matches", TH = "ไม่พบรายการ" },
Settings = { EN = "Settings", TH = "ตั้งค่า" },
SettingsDesc = { EN = "Interface, language and configs", TH = "หน้าตา ภาษา และคอนฟิก" },
Interface = { EN = "Interface", TH = "หน้าตา" },
Language = { EN = "Language", TH = "ภาษา" },
ThemeName = { EN = "Theme", TH = "ธีม" },
Scale = { EN = "UI scale", TH = "ขนาด UI" },
MenuKey = { EN = "Menu key", TH = "ปุ่มเปิดเมนู" },
Watermark = { EN = "Watermark", TH = "วอเตอร์มาร์ก" },
WatermarkDesc = { EN = "Hub name, FPS, ping and play time", TH = "ชื่อฮับ FPS ปิง และเวลาที่เล่น" },
FloatButton = { EN = "Mobile button", TH = "ปุ่มลอยมือถือ" },
FloatDesc = { EN = "Floating block that opens the menu", TH = "กล่อง ? ลอยสำหรับเปิดปิดเมนู" },
Configs = { EN = "Configs", TH = "คอนฟิก" },
ConfigName = { EN = "Config name", TH = "ชื่อคอนฟิก" },
SavedConfigs = { EN = "Saved configs", TH = "คอนฟิกที่บันทึกไว้" },
Save = { EN = "Save", TH = "บันทึก" },
Load = { EN = "Load", TH = "โหลด" },
Delete = { EN = "Delete", TH = "ลบ" },
Refresh = { EN = "Refresh", TH = "รีเฟรช" },
SetAutoload = { EN = "Load on start", TH = "โหลดอัตโนมัติ" },
Autoload = { EN = "Autoload: %s", TH = "โหลดอัตโนมัติ: %s" },
PickConfig = { EN = "Type or select a config name first", TH = "พิมพ์หรือเลือกชื่อคอนฟิกก่อน" },
NoFileApi = { EN = "This executor cannot save files", TH = "executor นี้บันทึกไฟล์ไม่ได้" },
ConfigMissing = { EN = "Config not found", TH = "ไม่พบคอนฟิก" },
ConfigBroken = { EN = "Config file is damaged", TH = "ไฟล์คอนฟิกเสีย" },
About = { EN = "About", TH = "เกี่ยวกับ" },
Unload = { EN = "Unload hub", TH = "ปิดสคริปต์" },
Rejoin = { EN = "Rejoin", TH = "เข้าเซิร์ฟใหม่" },
IntroSteps = {
EN = { "Warming up the warp pipe...", "Collecting coins...", "Building the castle...", "Let's-a go!" },
TH = { "กำลังอุ่นท่อวาร์ป...", "กำลังเก็บเหรียญ...", "กำลังสร้างปราสาท...", "ลุยกันเลย!" },
},
Ready = { EN = "Ready. Press %s to toggle the menu.", TH = "พร้อมแล้ว กด %s เพื่อเปิดปิดเมนู" },
ReadyTouch = { EN = "Ready. Tap the ? block to toggle the menu.", TH = "พร้อมแล้ว แตะกล่อง ? เพื่อเปิดปิดเมนู" },
Hidden = { EN = "Menu hidden. Press %s to open.", TH = "ซ่อนเมนูแล้ว กด %s เพื่อเปิด" },
Session = { EN = "TIME", TH = "เวลา" },
Empty = { EN = "Nothing here yet", TH = "ยังไม่มีรายการ" },
Particles = { EN = "Ambient particles", TH = "ละอองตกแต่ง" },
ParticlesDesc = { EN = "Floating sparkles behind the menu", TH = "ประกายลอยด้านหลังเมนู" },
Device = { EN = "Device: %s", TH = "อุปกรณ์: %s" },
}
function Lang.HasThai(text)
return text:find("\224[\184\185]") ~= nil
end
function Lang.Resolve(spec)
if type(spec) == "table" then
return spec[State.Language] or spec.EN or spec.TH or ""
end
if type(spec) ~= "string" then
return spec == nil and "" or tostring(spec)
end
local english, thai = spec:match("^(.-)%s+·%s+(.+)$")
if english and Lang.HasThai(thai) then
return State.Language == "TH" and thai or english
end
return spec
end
function Lang.Get(key, ...)
local text = Lang.Resolve(Lang.Strings[key] or key)
if select("#", ...) > 0 then
return string.format(text, ...)
end
return text
end
function Lang.SearchText(spec)
if type(spec) == "table" then
return (tostring(spec.EN or "") .. " " .. tostring(spec.TH or "")):lower()
end
return tostring(spec or ""):lower()
end
function Lang.Bind(inst, spec, property, transform)
local binding = { Spec = spec, Property = property or "Text", Transform = transform }
Lang.Bound[inst] = binding
Lang.Apply(inst, binding)
end
function Lang.Apply(inst, binding)
local text = Lang.Resolve(binding.Spec)
inst[binding.Property] = binding.Transform and binding.Transform(text) or text
end
function Lang.OnChange(owner, callback)
local registry = typeof(owner) == "Instance" and Lang.InstanceListeners or Lang.Listeners
registry[owner] = callback
end
function Lang.Set(code)
if code ~= "EN" and code ~= "TH" then
return
end
State.Language = code
if code == "TH" then
Fonts.LoadThaiAsync()
end
Theme.Prune()
for inst, binding in pairs(Lang.Bound) do
Lang.Apply(inst, binding)
end
Fonts.ApplyAll()
for _, registry in ipairs({ Lang.Listeners, Lang.InstanceListeners }) do
for _, callback in pairs(registry) do
Util.Try(callback, code)
end
end
Layout.MarkAll()
end
Fonts.Latin = {
Display = Enum.Font.LuckiestGuy, Body = Enum.Font.FredokaOne, Desc = Enum.Font.BuilderSansMedium,
Strong = Enum.Font.BuilderSansBold, Logo = Enum.Font.LuckiestGuy, Glyph = Enum.Font.BuilderSansBold,
}
Fonts.ThaiWeights = { Display = Enum.FontWeight.SemiBold, Body = Enum.FontWeight.Medium, Desc = Enum.FontWeight.Regular, Strong = Enum.FontWeight.SemiBold }
Fonts.ThaiFallback = { Display = Enum.Font.BuilderSansBold, Body = Enum.Font.BuilderSansBold, Desc = Enum.Font.BuilderSansMedium, Strong = Enum.Font.BuilderSansBold }
Fonts.Faces = {}
function Fonts.Face(kind)
local thai = State.Language == "TH" and Fonts.ThaiWeights[kind] ~= nil
local key = (thai and (Fonts.Thai and "TH" or "THF") or "EN") .. kind
local cached = Fonts.Faces[key]
if cached then
return cached
end
local face
if thai and Fonts.Thai then
face = Font.new(Fonts.Thai, Fonts.ThaiWeights[kind])
elseif thai then
face = Font.fromEnum(Fonts.ThaiFallback[kind])
else
face = Font.fromEnum(Fonts.Latin[kind] or Fonts.Latin.Body)
end
Fonts.Faces[key] = face
return face
end
function Fonts.Size(kind, base)
return base + (State.Language == "TH" and Config.ThaiSizeBonus[kind] or 0)
end
function Fonts.Style(label, kind, base)
Fonts.Texts[label] = { Kind = kind, Base = base }
label.FontFace = Fonts.Face(kind)
label.TextSize = Fonts.Size(kind, base)
end
function Fonts.ApplyAll()
table.clear(Layout.Measured)
Layout.MeasuredCount = 0
for label, style in pairs(Fonts.Texts) do
label.FontFace = Fonts.Face(style.Kind)
label.TextSize = Fonts.Size(style.Kind, style.Base)
end
end
function Fonts.FetchFace(weight, name)
local path = Config.FontDir .. "/kanit-" .. weight .. ".ttf"
local cached = Util.Exists(path) and SafeFile(readfile, path)
if type(cached) ~= "string" or cached:sub(1, 4) ~= "\0\1\0\0" then
local body = Util.HttpGet(string.format(Config.ThaiFont.Source, name))
if type(body) ~= "string" or body:sub(1, 4) ~= "\0\1\0\0" then
return nil
end
SafeFile(writefile, path, body)
local check = SafeFile(readfile, path)
if type(check) ~= "string" or #check ~= #body then
Fonts.Disable("binary write")
return nil
end
end
local asset = Util.CustomAsset(path)
if not asset then
Fonts.Disable("getcustomasset ttf")
return nil
end
return string.format('{"name":"W%d","weight":%d,"style":"normal","assetId":"%s"}', weight, weight, asset)
end
function Fonts.Disable(reason)
Fonts.Broken = true
SafeFile(writefile, Config.FontDir .. "/disabled", tostring(reason))
warn("[Reicht] Thai font off: " .. tostring(reason))
end
function Fonts.LoadThai()
if Fonts.Thai or Fonts.Broken or not Util.FileApi() or type(getcustomasset) ~= "function" then
return Fonts.Thai ~= nil
end
if Util.Exists(Config.FontDir .. "/disabled") then
Fonts.Broken = true
return false
end
Util.EnsureFolder(Config.FontDir)
local faces = {}
for weight, name in pairs(Config.ThaiFont.Weights) do
if Fonts.Broken or Library.Unloaded then
return false
end
table.insert(faces, Fonts.FetchFace(weight, name))
end
if #faces == 0 then
return false
end
local descriptor = Config.FontDir .. "/kanit.font"
if Util.Exists(descriptor) then
SafeFile(delfile, descriptor)
end
SafeFile(writefile, descriptor, '{"name":"' .. Config.ThaiFont.Family .. '","faces":[' .. table.concat(faces, ",") .. "]}")
local family = Util.CustomAsset(descriptor)
if not family then
Fonts.Disable("getcustomasset family")
return false
end
Fonts.Thai = family
table.clear(Fonts.Faces)
if State.Language == "TH" and State.Gui then
Fonts.ApplyAll()
Layout.MarkAll()
end
task.spawn(Fonts.Preload)
return true
end
function Fonts.LoadThaiAsync()
if Fonts.Thai or Fonts.Broken or Fonts.Loading then
return
end
Fonts.Loading = true
task.spawn(function()
local finished = Util.Await(Config.FontTimeout, Fonts.LoadThai)
Fonts.Loading = false
if not finished and not Fonts.Thai and not Fonts.Broken and not Library.Unloaded then
Fonts.Disable("timeout")
end
end)
end
function Fonts.Preload()
local provider = game:GetService("ContentProvider")
local probes = {}
for _, weight in pairs(Fonts.ThaiWeights) do
table.insert(probes, Draw.New("TextLabel", { Text = "ก", FontFace = Font.new(Fonts.Thai, weight) }))
end
Util.Await(Config.PreloadTimeout, provider.PreloadAsync, provider, probes)
for _, probe in ipairs(probes) do
probe:Destroy()
end
end
function Draw.New(className, props)
local inst = Instance.new(className)
local parent = props and props.Parent
if props then
for property, value in pairs(props) do
if property ~= "Parent" then
inst[property] = value
end
end
end
if inst:IsA("GuiObject") then
inst.BorderSizePixel = 0
end
inst.Parent = parent
return inst
end
function Draw.Corner(parent, radius)
return Draw.New("UICorner", { CornerRadius = typeof(radius) == "UDim" and radius or UDim.new(0, radius or 8), Parent = parent })
end
function Draw.Stroke(parent, token, thickness, border)
local stroke = Draw.New("UIStroke", {
Thickness = thickness or 2,
ApplyStrokeMode = border and Enum.ApplyStrokeMode.Border or Enum.ApplyStrokeMode.Contextual,
LineJoinMode = Enum.LineJoinMode.Round,
Parent = parent,
})
Theme.Bind(stroke, { Color = token or "Outline" })
return stroke
end
function Draw.Padding(parent, top, right, bottom, left)
return Draw.New("UIPadding", {
PaddingTop = UDim.new(0, top or 0),
PaddingRight = UDim.new(0, right or top or 0),
PaddingBottom = UDim.new(0, bottom or top or 0),
PaddingLeft = UDim.new(0, left or right or top or 0),
Parent = parent,
})
end
function Draw.List(parent, gap, horizontal, alignX, alignY)
return Draw.New("UIListLayout", {
Padding = UDim.new(0, gap or 0),
FillDirection = horizontal and Enum.FillDirection.Horizontal or Enum.FillDirection.Vertical,
HorizontalAlignment = alignX or Enum.HorizontalAlignment.Left,
VerticalAlignment = alignY or Enum.VerticalAlignment.Top,
SortOrder = Enum.SortOrder.LayoutOrder,
Parent = parent,
})
end
function Draw.Text(props, font, size, token, spec)
props.BackgroundTransparency = 1
props.Text = props.Text or ""
props.TextXAlignment = props.TextXAlignment or Enum.TextXAlignment.Left
props.RichText = props.RichText or false
local className = props.ClassName or "TextLabel"
props.ClassName = nil
local label = Draw.New(className, props)
Fonts.Style(label, font or "Body", size or Util.TextSize("Label"))
Theme.Bind(label, { TextColor3 = token or "Text" })
if spec ~= nil then
Lang.Bind(label, spec)
end
return label
end
function Draw.Box(className, props, fill, stroke, radius, thickness)
local box = Draw.New(className, props)
if fill then
Theme.Bind(box, { BackgroundColor3 = fill })
elseif props.BackgroundTransparency == nil then
box.BackgroundTransparency = 1
end
if radius then
Draw.Corner(box, radius)
end
if stroke then
Draw.Stroke(box, stroke, thickness or 2, true)
end
if box:IsA("GuiButton") then
box.AutoButtonColor = false
if box:IsA("TextButton") then
box.Text = ""
end
end
return box
end
function Draw.Block(parent, faceToken, shadeToken, radius, depth)
depth = depth or 4
local holder = Draw.New("Frame", { BackgroundTransparency = 1, Parent = parent })
local shade = Draw.Box("Frame", {
Position = UDim2.fromOffset(0, depth),
Size = UDim2.new(1, 0, 1, -depth),
Parent = holder,
}, shadeToken, "Outline", radius, 2)
local face = Draw.Box("Frame", { Size = UDim2.new(1, 0, 1, -depth), Parent = holder }, faceToken, "Outline", radius, 2)
return holder, face, shade, depth
end
function Draw.Cloud(parent, width, token)
local cloud = Draw.New("Frame", { BackgroundTransparency = 1, Size = UDim2.fromOffset(width, width * 0.5), Parent = parent })
local puffs = { { 0, 0.35, 0.42 }, { 0.24, 0, 0.55 }, { 0.55, 0.18, 0.45 } }
for _, puff in ipairs(puffs) do
local ball = Draw.New("Frame", {
Position = UDim2.fromScale(puff[1], puff[2]),
Size = UDim2.fromScale(puff[3], puff[3] * 2),
Parent = cloud,
})
Draw.Corner(ball, UDim.new(1, 0))
Theme.Bind(ball, { BackgroundColor3 = token or "Cloud" })
Theme.OnRender(ball, function()
ball.BackgroundTransparency = Theme.Colors.CloudAlpha or 0
end)
end
local base = Draw.New("Frame", { Position = UDim2.fromScale(0.08, 0.6), Size = UDim2.fromScale(0.86, 0.4), Parent = cloud })
Draw.Corner(base, UDim.new(1, 0))
Theme.Bind(base, { BackgroundColor3 = token or "Cloud" })
Theme.OnRender(base, function()
base.BackgroundTransparency = Theme.Colors.CloudAlpha or 0
end)
return cloud
end
function Draw.Emblem(parent, size)
local holder = Draw.New("Frame", { BackgroundTransparency = 1, Size = UDim2.fromOffset(size, size), Parent = parent })
local picture = Draw.New("ImageLabel", { BackgroundTransparency = 1, AnchorPoint = Vector2.new(0.5, 0.5), Position = UDim2.fromScale(0.5, 0.5), Size = UDim2.fromScale(1, 1), ScaleType = Enum.ScaleType.Fit, Visible = false, Parent = holder })
local drawn = Draw.DrawnEmblem(holder, size)
Theme.OnRender(holder, function()
local content = (Theme.Colors.Logo and Assets.Resolve(Theme.Colors.Logo)) or Assets.Resolve("logo")
picture.Image = content or ""
picture.Visible = content ~= nil
drawn.Visible = content == nil
picture.Size = UDim2.fromScale(Theme.Colors.Logo and 1.25 or 1, Theme.Colors.Logo and 1.25 or 1)
end)
Anim.Loop("Emblem", picture, { Rotation = 6 }, 1.6, "Sine", true)
return holder
end
function Draw.DrawnEmblem(parent, size)
local emblem = Draw.Box("Frame", { Size = UDim2.fromOffset(size, size), Parent = parent }, "Accent", "Outline", UDim.new(1, 0), 2)
local ring = Draw.New("Frame", {
AnchorPoint = Vector2.new(0.5, 0.5),
Position = UDim2.fromScale(0.5, 0.5),
Size = UDim2.fromScale(0.7, 0.7),
Parent = emblem,
})
Draw.Corner(ring, UDim.new(1, 0))
Theme.Bind(ring, { BackgroundColor3 = "White" })
local letter = Draw.Text({
Text = "M",
Size = UDim2.fromScale(1, 1),
TextXAlignment = Enum.TextXAlignment.Center,
Position = UDim2.fromOffset(0, 1),
Parent = ring,
}, "Logo", math.floor(size * 0.5), "Accent")
letter.TextScaled = false
return emblem
end
function Draw.Bricks(parent, columns, token)
local mortar = {}
for row = 0, 1 do
local shift = row == 0 and 0 or 0.5 / columns
for column = 1, columns - 1 do
local xScale = column / columns + shift
if xScale > 0.02 and xScale < 0.98 then
table.insert(mortar, Draw.New("Frame", {
Position = UDim2.new(xScale, 0, row * 0.5, 0),
Size = UDim2.new(0, 2, 0.5, 0),
Parent = parent,
}))
end
end
end
local seam = Draw.New("Frame", { Position = UDim2.new(0, 0, 0.5, -1), Size = UDim2.new(1, 0, 0, 2), Parent = parent })
table.insert(mortar, seam)
for _, line in ipairs(mortar) do
Theme.Bind(line, { BackgroundColor3 = token or "BrickDark" })
end
end
function Assets.Configure(map)
if type(map) ~= "table" then
return
end
for name, source in pairs(map) do
Assets.Overrides[tostring(name):lower()] = source
Assets.Cache[tostring(name):lower()] = nil
end
end
function Assets.Download(name, url)
if type(getcustomasset) ~= "function" or not Util.FileApi() then
return nil
end
local path = Config.AssetDir .. "/" .. Util.Sanitize(name) .. ".png"
if not Util.Exists(path) then
local body = Util.HttpGet(url)
if type(body) ~= "string" or #body < 8 then
return nil
end
Util.EnsureFolder(Config.AssetDir)
SafeFile(writefile, path, body)
end
return Util.CustomAsset(path)
end
function Assets.Resolve(name)
local key = tostring(name):lower()
local cached = Assets.Cache[key]
if cached ~= nil then
return cached or nil
end
local source = Assets.Overrides[key]
local content
if type(source) == "number" then
content = "rbxassetid://" .. source
elseif type(source) == "string" and source:find("^rbxasset") then
content = source
elseif type(source) == "string" and source:match("^https?://") then
content = Assets.Download(key, source)
elseif type(source) == "string" and Util.Exists(source) then
content = Util.CustomAsset(source)
end
Assets.Cache[key] = content or false
return content
end
Sprite.Palette = {
k = Color3.fromRGB(24, 20, 30), w = Color3.fromRGB(255, 255, 255), r = Color3.fromRGB(229, 37, 33),
s = Color3.fromRGB(252, 216, 168), y = Color3.fromRGB(252, 208, 0), Y = Color3.fromRGB(196, 132, 0),
q = Color3.fromRGB(248, 184, 0), Q = Color3.fromRGB(184, 104, 0), o = Color3.fromRGB(255, 140, 26),
g = Color3.fromRGB(67, 176, 71), G = Color3.fromRGB(38, 116, 44), l = Color3.fromRGB(150, 226, 122),
n = Color3.fromRGB(154, 160, 166), N = Color3.fromRGB(46, 46, 58), B = Color3.fromRGB(200, 86, 28),
m = Color3.fromRGB(90, 42, 14), b = Color3.fromRGB(4, 156, 216),
p = Color3.fromRGB(156, 92, 220), P = Color3.fromRGB(96, 44, 150),
}
Sprite.Art = {
pumpkin = {
".....mm.....", "....kmGk....", "..kkkkkkkk..", ".koooBBooook",
"kooyyooyyook", "koyyyooyyyok", "koooooooooBk", "kooyoyyoyook",
"koooyyyyoook", ".kooooBoook.", "..kkkkkkkk..", "............",
},
bat = {
"............", "............", "k..........k", "kk...kk...kk",
"kpk.kppk.kpk", "kppkpyypkppk", "kppppppppppk", ".kppppppppk.",
"..kpk..kpk..", "...k....k...", "............", "............",
},
spider = {
"............", "............", "k...kkkk...k", ".k.knnnnk.k.",
"..knynnynk..", "kkknnnnnnkkk", "..knnnnnnk..", ".k.knnnnk.k.",
"k...kkkk...k", "............", "............", "............",
},
candy = {
"............", ".....kk.....", "....kwwk....", "....kwwk....",
"...kooook...", "...kooook...", "..kooooook..", "..kyyyyyyk..",
".kyyyyyyyyk.", ".kyyyyyyyyk.", "..kkkkkkkk..", "............",
},
mushroom = {
"....kkkk....", "..kkrrwwkk..", ".krrrrwwwrk.", ".kwwrrwwrrk.",
"kwwwwrrrrrrk", "kwwwwrrrwwrk", "krwwrrrwwwwk", "krrrrrrwwwrk",
"kkkkkkkkkkkk", ".kssksskssk.", ".kssksskssk.", "..kkkkkkkk..",
},
star = {
".....kk.....", "....kyyk....", "....kyyk....", "kkkkkyykkkkk",
"kyyyyyyyyyyk", ".kyykyykyyk.", "..kykyykyk..", "...kyyyyk...",
"..kyyyyyyk..", "..kyykkyyk..", ".kyyk..kyyk.", ".kkk....kkk.",
},
coin = {
"....kkkk....", "...kyyyyk...", "..kyywwyyk..", "..kywyyYyk..",
".kywyyyYyyk.", ".kywyyyYyyk.", ".kywyyyYyyk.", ".kywyyyYyyk.",
"..kyyyyYyk..", "..kyyYYYyk..", "...kyyyyk...", "....kkkk....",
},
qblock = {
"kkkkkkkkkkkk", "kqqqqqqqqqqk", "kqkqqqqqqkQk", "kqqqwwwwqqQk",
"kqqwwQQwwqQk", "kqqQQqqwwqQk", "kqqqqqwwQqQk", "kqqqqwwQqqQk",
"kqqqqQQqqqQk", "kqkqqwwqqkQk", "kqQQQQQQQQQk", "kkkkkkkkkkkk",
},
brick = {
"BBBBBmBBBBBm", "BBBBBmBBBBBm", "mmmmmmmmmmmm", "BBmBBBBBmBBB",
"BBmBBBBBmBBB", "mmmmmmmmmmmm", "BBBBBmBBBBBm", "BBBBBmBBBBBm",
"mmmmmmmmmmmm", "BBmBBBBBmBBB", "BBmBBBBBmBBB", "mmmmmmmmmmmm",
},
pipe = {
"kkkkkkkkkkkk", "klgggggggGGk", "klgggggggGGk", "klgggggggGGk",
"kkkkkkkkkkkk", ".klggggggGk.", ".klggggggGk.", ".klggggggGk.",
".klggggggGk.", ".klggggggGk.", ".klggggggGk.", ".kkkkkkkkkk.",
},
flower = {
"...kkkkkk...", "..krrrrrrk..", ".krryyyyrrk.", ".kryywwyyrk.",
".krryyyyrrk.", "..krrrrrrk..", "...kkggkk...", ".kgk.gg.kgk.",
".kggkggkggk.", "..kggggggk..", "...kkggkk...", ".....kk.....",
},
shell = {
"....kkkk....", "..kkggggkk..", ".kggGGGGggk.", ".kgGggggGgk.",
"kggGggggGggk", "kggGGGGGGggk", "kggggggggggk", "kwwwwwwwwwwk",
"kwkwwkkwwkwk", ".kyyyyyyyyk.", "..kyyyyyyk..", "...kkkkkk...",
},
boo = {
"....kkkk....", "..kkwwwwkk..", ".kwwwwwwwwk.", ".kwwkwwkwwk.",
"kwwwkwwkwwwk", "kwwwwwwwwwwk", "kwwkrrrrkwwk", "kwwwkrrkwwwk",
"kwwwwkkwwwwk", "kwwwwwwwwwwk", "kwwwkwwkwwwk", "kkk.kkkk.kkk",
},
flag = {
".yy.........", ".yy.........", "..nkkkkkkk..", "..nkgggggk..",
"..nkggwggk..", "..nkgwwwgk..", "..nkggggk...", "..nkgggk....",
"..nkkkk.....", "..n.........", "..n.........", "kkkkk.......",
},
key = {
"...kkkk.....", "..kyyyyk....", ".kyykkyyk...", ".kyk..kyk...",
".kyykkyyk...", "..kyyyyk....", "...kyyk.....", "...kyyk.....",
"...kyykk....", "...kyyyyk...", "...kyykk....", "...kkkk.....",
},
gear = {
"....kkkk....", ".kk.knnk.kk.", ".knkknnkknk.", "..knnnnnnk..",
"kkknnkknnkkk", "knnnk..knnnk", "knnnk..knnnk", "kkknnkknnkkk",
"..knnnnnnk..", ".knkknnkknk.", ".kk.knnk.kk.", "....kkkk....",
},
heart = {
"............", ".kkk....kkk.", "kwrrrkkrrrrk", "kwrrrrrrrrrk",
"krrrrrrrrrrk", ".krrrrrrrrk.", "..krrrrrrk..", "...krrrrk...",
"....krrk....", ".....kk.....", "............", "............",
},
bomb = {
"........o.y.", ".......n.o..", "......n.....", "...kkkkkk...",
"..kNNNNNNk..", ".kNwwNNNNNk.", ".kNwNNwNwNk.", ".kNNNNwNwNk.",
".kNNNNNNNNk.", "..kNNNNNNk..", "..kyykkyyk..", "..kkk..kkk..",
},
used = {
"kkkkkkkkkkkk", "kBBBBBBBBBBk", "kBmBBBBBBmBk", "kBBBBBBBBBBk",
"kBBBBBBBBBBk", "kBBBBBBBBBBk", "kBBBBBBBBBBk", "kBBBBBBBBBBk",
"kBBBBBBBBBBk", "kBmBBBBBBmBk", "kBBBBBBBBBBk", "kkkkkkkkkkkk",
},
castle = {
"....B..B....", "....BBBB....", "....BkkB....", "B.B.BBBB.B.B",
"BBBBBBBBBBBB", "BBBBBBBBBBBB", "mmmmmmmmmmmm", "BBBBBkkBBBBB",
"BBBBkkkkBBBB", "mmmmkkkkmmmm", "BBBBkkkkBBBB", "BBBBkkkkBBBB",
},
}
Sprite.Alias = {
house = "castle", home = "castle", user = "oneup", player = "oneup", globe = "pipe", map = "pipe",
teleport = "pipe", eye = "boo", visuals = "boo", swords = "flower", combat = "flower", target = "bomb",
crosshair = "bomb", shield = "shell", zap = "star", settings = "gear", ["sliders-horizontal"] = "gear",
bell = "coin", shop = "coin", code = "qblock", info = "qblock", key = "key", play = "flag",
quest = "flag", heart = "heart", cookie = "mushroom", ["trash-2"] = "bomb", terminal = "brick",
["refresh-cw"] = "pipe", link = "pipe", copy = "brick", check = "star", save = "qblock",
download = "qblock", upload = "qblock", search = "boo", misc = "qblock", troll = "shell",
}
Sprite.Swaps = {
oneup = { base = "mushroom", swap = { r = "g" } },
}
Sprite.Templates = {}
function Sprite.Resolve(name)
name = tostring(name or "qblock"):lower():gsub("^lucide%-", "")
name = Sprite.Alias[name] or name
if Sprite.Art[name] or Sprite.Swaps[name] then
return name
end
return "qblock"
end
function Sprite.Template(name)
if Sprite.Templates[name] then
return Sprite.Templates[name]
end
local swap = Sprite.Swaps[name]
local rows = Sprite.Art[swap and swap.base or name]
local recolor = swap and swap.swap or {}
local height, width = #rows, #rows[1]
local holder = Draw.New("Frame", { Name = "Sprite", BackgroundTransparency = 1 })
local freq, colors = {}, {}
for y = 1, height do
local line = rows[y]
for x = 1, width do
local ch = line:sub(x, x)
if ch ~= "." then
if not freq[ch] then
freq[ch] = 0
table.insert(colors, ch)
end
freq[ch] += 1
end
end
end
table.sort(colors, function(a, b)
if (a == "k") ~= (b == "k") then
return a == "k"
end
if freq[a] ~= freq[b] then
return freq[a] > freq[b]
end
return a < b
end)
local order = {}
for idx, ch in ipairs(colors) do
order[ch] = idx
end
local painted = {}
for layerIdx, col in ipairs(colors) do
local fill = Sprite.Palette[recolor[col] or col] or Sprite.Palette.k
for y = 1, height do
local line = rows[y]
for x = 1, width do
local cellIdx = (y - 1) * width + x
if line:sub(x, x) == col and painted[cellIdx] ~= col then
local stopX = x
while stopX < width do
local nextCh = line:sub(stopX + 1, stopX + 1)
if nextCh == col or (order[nextCh] and order[nextCh] > layerIdx) then
stopX += 1
else
break
end
end
while stopX > x and line:sub(stopX, stopX) ~= col do
stopX -= 1
end
local stopY = y
while stopY < height do
local nextLine = rows[stopY + 1]
local okRow = true
for cx = x, stopX do
local nextCh = nextLine:sub(cx, cx)
if nextCh ~= col and not (order[nextCh] and order[nextCh] > layerIdx) then
okRow = false
break
end
end
if not okRow then
break
end
stopY += 1
end
while stopY > y do
local checkLine = rows[stopY]
local hasCol = false
for cx = x, stopX do
if checkLine:sub(cx, cx) == col and painted[(stopY - 1) * width + cx] ~= col then
hasCol = true
break
end
end
if hasCol then
break
end
stopY -= 1
end
for cy = y, stopY do
local base = (cy - 1) * width
for cx = x, stopX do
painted[base + cx] = col
end
end
Draw.New("Frame", {
BackgroundColor3 = fill,
Position = UDim2.fromScale((x - 1) / width, (y - 1) / height),
Size = UDim2.fromScale((stopX - x + 1) / width, (stopY - y + 1) / height),
ZIndex = layerIdx,
Parent = holder,
})
end
end
end
end
Sprite.Templates[name] = holder
return holder
end
function Sprite.New(parent, name, size)
local key = Sprite.Resolve(name)
local image = Assets.Resolve(tostring(name):lower()) or Assets.Resolve(key)
local sprite
if image then
sprite = Draw.New("ImageLabel", { BackgroundTransparency = 1, Image = image, ScaleType = Enum.ScaleType.Fit, ResampleMode = Enum.ResamplerMode.Pixelated })
else
sprite = Sprite.Template(key):Clone()
end
sprite.Size = UDim2.fromOffset(size, size)
sprite.Parent = parent
return sprite
end
local ExtraSprites = {
sword = {
".........kkk", "........kwwk", ".......kwwwk", "......kwwwk.",
".....kwwwk..", ".kk.kwwwk...", "kyykwwwk....", ".kyyyyk.....",
"..kyykll....", ".kmmkyk.....", "kmmk.kk.....", "kkk.........",
},
crosshair = {
"....kkkk....", "..kkrrrrkk..", ".kr..kk..rk.", ".kr..rr..rk.",
"krr.krrk.rrk", "kkkkryyrkkkk", "kkkkryyrkkkk", "krr.krrk.rrk",
".kr..rr..rk.", ".kr..kk..rk.", "..kkrrrrkk..", "....kkkk....",
},
crown = {
"............", ".kk..kk..kk.", "kyykkyykkyyk", "kyyyyyyyyyyk",
"kyrrybbyrryk", "kyyyyyyyyyyk", "kyyyyyyyyyyk", ".kyyyyyyyyk.",
".kYYYYYYYYk.", ".kkkkkkkkkk.", "............", "............",
},
gem = {
"............", "...kkkkkk...", "..kbbbbbbk..", ".kbwwbbbbbk.",
"kbwwbbbbbbbk", "kbbbbbbbbbbk", ".kbbbbbbbbk.", "..kbbbbbbk..",
"...kbbbbk...", "....kbbk....", ".....kk.....", "............",
},
dice = {
".kkkkkkkkkk.", "kwwwwwwwwwwk", "kwkkwwwwkkwk", "kwkkwwwwkkwk",
"kwwwwwwwwwwk", "kwwwwkkwwwwk", "kwwwwkkwwwwk", "kwwwwwwwwwwk",
"kwkkwwwwkkwk", "kwkkwwwwkkwk", "kwwwwwwwwwwk", ".kkkkkkkkkk.",
},
paw = {
"............", ".kk..kk..kk.", "kmmkkmk.kmmk", "kmmkkmk.kmmk",
".kk..kk..kk.", "...kkkkkk...", "..kmmmmmmk..", ".kmmssssmmk.",
".kmssssssmk.", ".kmmmmmmmmk.", "..kkkkkkkk..", "............",
},
egg = {
"....kkkk....", "...kwwwwk...", "..kwwggwwk..", ".kwwggggwwk.",
".kwwwwwwwwk.", "kwwggwwggwwk", "kwwggwwggwwk", "kwwwwwwwwwwk",
".kwwwwwwwwk.", ".kwwggggwwk.", "..kkwwwwkk..", "....kkkk....",
},
hammer = {
"..kkkkkkkk..", ".knnnnnnnnk.", ".knwwnnnnnk.", ".knnnnnnnnk.",
"..kkkkmmkk..", ".....kmmk...", ".....kmmk...", ".....kmmk...",
".....kmmk...", ".....kmmk...", ".....kmmk...", ".....kkkk...",
},
car = {
"............", "...kkkkkk...", "..krrrrrrk..", ".krrbbbbwwk.",
"krrrrrrrrrrk", "krrrrrrrryyk", "kkkkkkkkkkkk", ".knnkkkkknn.",
".knwk..knwk.", "..kk....kk..", "............", "............",
},
chest = {
".kkkkkkkkkk.", "kBBBBBBBBBBk", "kByyyyyyyyBk", "kBBBBBBBBBBk",
"kkkkkyykkkkk", "kBBBkyykBBBk", "kBBBkyykBBBk", "kBBBBBBBBBBk",
"kBmmmmmmmmBk", "kBBBBBBBBBBk", ".kkkkkkkkkk.", "............",
},
lightning = {
"......kkkk..", ".....kyyyk..", "....kyyyk...", "...kyyyk....",
"..kyyyyykkkk", ".kyyyyyyyyyk", "....kkkkkyyk", "....kyyykyk.",
"...kyyyk....", "..kyyyk.....", ".kyyk.......", ".kkk........",
},
magnet = {
".kkkk..kkkk.", "krrrrk.krrrk", "krwwrk.krwrk", "knnnnk.knnnk",
"knnnnk.knnnk", "krrrrk.krrrk", "krrrrkkrrrrk", ".krrrrrrrrk.",
".krrrrrrrrk.", "..kkkkkkkk..", "............", "............",
},
skull = {
"...kkkkkk...", "..kwwwwwwk..", ".kwwwwwwwwk.", "kwwkkwwkkwwk",
"kwwkkwwkkwwk", "kwwwwwwwwwwk", ".kwwwkkwwwk.", "..kwwwwwwk..",
"..kwkwkwkwk.", "...kkkkkk...", "............", "............",
},
feather = {
"........kkk.", "......kkwwwk", ".....kwwwwwk", "....kwwbbwwk",
"...kwwbbwwk.", "..kwwbbwwk..", "..kwbbwwk...", ".kwwbwwk....",
".kwbwwk.....", ".kyyyk......", "kyyk........", "kkk.........",
},
trophy = {
".kkkkkkkkkk.", "kyyyyyyyyyyk", "kykkyyyykkyk", "kykkywwykkyk",
".kyyyyyyyyk.", "..kyyyyyyk..", "...kyyyyk...", "....kyyk....",
"....kyyk....", "..kkyyyykk..", ".kkkkkkkkkk.", "............",
},
}
for spriteName, grid in pairs(ExtraSprites) do
Sprite.Art[spriteName] = grid
end
Sprite.Swaps.blueshell = { base = "shell", swap = { g = "b", G = "P" } }
Sprite.Swaps.iceflower = { base = "flower", swap = { r = "b", y = "w" } }
Sprite.Swaps.goldmushroom = { base = "mushroom", swap = { r = "y", w = "q" } }
local ExtraAliases = {
main = "mushroom", home = "castle", general = "qblock", hub = "star",
combat = "sword", sword = "sword", swords = "sword", weapon = "sword", knife = "sword",
aimbot = "crosshair", aim = "crosshair", sniper = "crosshair", target = "crosshair", crosshair = "crosshair", gun = "crosshair",
visuals = "boo", esp = "boo", eye = "boo", camera = "boo", radar = "crosshair",
player = "feather", user = "oneup", users = "oneup", movement = "feather", speed = "lightning",
zap = "lightning", bolt = "lightning", fly = "feather", jump = "feather", run = "lightning",
shield = "shell", defense = "shell", god = "star", armor = "blueshell", safe = "shell",
teleport = "pipe", warp = "pipe", compass = "pipe", map = "pipe", globe = "pipe",
auto = "star", farm = "star", sparkles = "star", wand = "star", bot = "gear",
coin = "coin", money = "coin", cash = "coin", shop = "coin", bag = "chest", cart = "chest",
gem = "gem", diamond = "gem", crown = "crown", vip = "crown", rank = "trophy", trophy = "trophy",
gift = "chest", crate = "chest", chest = "chest", box = "qblock", package = "qblock", airdrop = "chest",
loot = "magnet", magnet = "magnet", collect = "magnet",
pet = "paw", paw = "paw", animal = "paw", mount = "paw",
egg = "egg", hatch = "egg",
dice = "dice", roll = "dice", luck = "star", spin = "dice",
hammer = "hammer", forge = "hammer", craft = "hammer", build = "brick", pickaxe = "hammer",
car = "car", vehicle = "car", drive = "car", race = "flag",
skull = "skull", kill = "skull", murder = "skull", danger = "bomb", bomb = "bomb",
heart = "heart", health = "heart", heal = "oneup",
key = "key", lock = "key", unlock = "key",
flag = "flag", quest = "flag", play = "flag",
settings = "gear", cog = "gear", sliders = "gear", config = "qblock",
palette = "flower", theme = "flower",
info = "qblock", bell = "coin", warning = "bomb", alert = "bomb",
check = "star", save = "qblock", refresh = "pipe", trash = "bomb",
search = "boo", terminal = "brick", code = "qblock", chart = "trophy", stats = "trophy",
}
for aliasKey, targetSprite in pairs(ExtraAliases) do
Sprite.Alias[aliasKey] = targetSprite
end
Icons.Rules = {
{ "aimbot|silent|sniper|crosshair|shoot|gun|ยิง|ปืน|เล็ง", "crosshair" },
{ "combat|sword|weapon|knife|kill|murder|sheriff|hit|attack|fight|ต่อสู้|ฆ่า|อาวุธ|ดาบ", "sword" },
{ "visual|esp|chams|wallhack|highlight|tracer|fov|camera|see|มอง|แสง|เรดาร์", "boo" },
{ "teleport|warp|island|location|place|spawn|zone|map|วาร์ป|เกาะ|สถานที่|แมพ", "pipe" },
{ "pet|animal|mount|ride|สัตว์|ขี่", "paw" },
{ "egg|hatch|ไข่|สุ่มไข่", "egg" },
{ "dice|roll|spin|gacha|ลูกเต๋า|ทอย|สุ่ม", "dice" },
{ "forge|craft|upgrade|mine|dig|ตีบวก|หลอม|ขุด|อัพเกรด", "hammer" },
{ "build|pyramid|brick|สร้าง|พีระมิด", "brick" },
{ "car|vehicle|drive|race|drift|รถ|ขับ|แข่ง", "car" },
{ "shop|buy|sell|merchant|market|store|trade|coin|cash|money|ร้าน|ซื้อ|ขาย|เงิน", "coin" },
{ "loot|magnet|collect|grab|ดูด|เก็บ", "magnet" },
{ "airdrop|crate|chest|drop|gift|กล่อง|แอร์ดรอป", "chest" },
{ "speed|dash|bolt|zap|ความเร็ว|พุ่ง", "lightning" },
{ "player|movement|walk|jump|fly|noclip|stamina|ผู้เล่น|วิ่ง|กระโดด|บิน", "feather" },
{ "defense|shield|god|anti|safe|guard|bypass|ป้องกัน|อมตะ|กันแบน", "shell" },
{ "rank|vip|king|boss|crown|ยศ", "crown" },
{ "stat|status|leaderboard|score|trophy|สถานะ|อันดับ|คะแนน", "trophy" },
{ "quest|mission|flag|start|เควส|ภารกิจ", "flag" },
{ "theme|color|palette|style|ธีม|สี", "flower" },
{ "setting|config|ui|menu|keybind|language|ตั้งค่า|เมนู|ภาษา", "gear" },
{ "auto|farm|grind|loop|bot|ออโต้|ฟาร์ม|บอท", "star" },
{ "main|home|general|hub|หลัก|ทั่วไป", "mushroom" },
}
local function DrawVectorLine(parent, pos, size, rot, token)
return Draw.Box("Frame", {
AnchorPoint = Vector2.new(0.5, 0.5),
Position = pos,
Size = size,
Rotation = rot or 0,
Parent = parent,
}, token or "Text", nil, UDim.new(1, 0))
end
local function DrawLCorner(parent, pos, size, rot, thickness, token)
local pivot = Draw.New("Frame", {
BackgroundTransparency = 1,
AnchorPoint = Vector2.new(0.5, 0.5),
Position = pos,
Size = size,
Rotation = rot,
Parent = parent,
})
Draw.Box("Frame", {
Position = UDim2.fromScale(0, 0),
Size = UDim2.new(0, thickness, 1, 0),
Parent = pivot,
}, token or "Text", nil, UDim.new(1, 0))
Draw.Box("Frame", {
AnchorPoint = Vector2.new(0, 1),
Position = UDim2.fromScale(0, 1),
Size = UDim2.new(1, 0, 0, thickness),
Parent = pivot,
}, token or "Text", nil, UDim.new(1, 0))
return pivot
end
Icons.Vectors = {
search = function(box, token)
local ring = Draw.New("Frame", {
BackgroundTransparency = 1,
AnchorPoint = Vector2.new(0.5, 0.5),
Position = UDim2.fromScale(0.42, 0.42),
Size = UDim2.fromScale(0.54, 0.54),
Parent = box,
})
Draw.Corner(ring, UDim.new(1, 0))
Draw.Stroke(ring, token or "SubText", 2)
DrawVectorLine(box, UDim2.fromScale(0.73, 0.73), UDim2.new(0.32, 0, 0, 2), 45, token or "SubText")
end,
close = function(box, token)
DrawVectorLine(box, UDim2.fromScale(0.5, 0.5), UDim2.new(0.68, 0, 0, 2), 45, token)
DrawVectorLine(box, UDim2.fromScale(0.5, 0.5), UDim2.new(0.68, 0, 0, 2), -45, token)
end,
check = function(box, token)
local w = box.Size.X.Offset
local thick = (w >= 16) and 3 or 2
DrawLCorner(box, UDim2.fromScale(0.5, 0.44), UDim2.fromScale(0.62, 0.36), -45, thick, token or "Good")
end,
plus = function(box, token)
DrawVectorLine(box, UDim2.fromScale(0.5, 0.5), UDim2.new(0.64, 0, 0, 2), 0, token)
DrawVectorLine(box, UDim2.fromScale(0.5, 0.5), UDim2.new(0, 2, 0.64, 0), 0, token)
end,
minus = function(box, token)
DrawVectorLine(box, UDim2.fromScale(0.5, 0.5), UDim2.new(0.64, 0, 0, 2), 0, token)
end,
chevron_down = function(box, token)
DrawLCorner(box, UDim2.fromScale(0.5, 0.42), UDim2.fromScale(0.42, 0.42), -45, 2, token)
end,
chevron_up = function(box, token)
DrawLCorner(box, UDim2.fromScale(0.5, 0.58), UDim2.fromScale(0.42, 0.42), 135, 2, token)
end,
chevron_right = function(box, token)
DrawLCorner(box, UDim2.fromScale(0.42, 0.5), UDim2.fromScale(0.42, 0.42), -135, 2, token)
end,
grip = function(box, token)
DrawVectorLine(box, UDim2.fromScale(0.62, 0.62), UDim2.new(0.66, 0, 0, 2), -45, token or "White")
DrawVectorLine(box, UDim2.fromScale(0.78, 0.78), UDim2.new(0.36, 0, 0, 2), -45, token or "White")
end,
}
function Icons.NormalizeKey(rawName)
if type(rawName) ~= "string" then
return ""
end
return rawName:lower():gsub("^lucide:", ""):gsub("^lucide%-", ""):gsub("^icon:", ""):gsub("[%-%s]+", "_")
end
function Icons.FromTitle(titleSpec, defaultSprite)
local text = Lang.SearchText(titleSpec)
if text ~= "" then
for _, rule in ipairs(Icons.Rules) do
if text:find(rule[1]) then
return rule[2]
end
end
end
return defaultSprite or "qblock"
end
function Icons.Vector(parent, vectorName, size, colorToken)
size = size or 16
local key = Icons.NormalizeKey(vectorName)
local builder = Icons.Vectors[key]
local holder = Draw.New("Frame", {
Name = "VectorIcon",
BackgroundTransparency = 1,
Size = UDim2.fromOffset(size, size),
Parent = parent,
})
if builder then
builder(holder, colorToken or "Text")
end
return holder
end
function Icons.Create(parent, iconSpec, size, colorToken, fallbackTitle)
size = size or Util.Metric("Icon")
if type(iconSpec) == "number" or (type(iconSpec) == "string" and (iconSpec:find("^rbxassetid://") or iconSpec:match("^%d+$"))) then
local assetId = type(iconSpec) == "number" and ("rbxassetid://" .. iconSpec) or (iconSpec:match("^%d+$") and ("rbxassetid://" .. iconSpec) or iconSpec)
local img = Draw.New("ImageLabel", {
Name = "Icon",
BackgroundTransparency = 1,
Image = assetId,
ScaleType = Enum.ScaleType.Fit,
Size = UDim2.fromOffset(size, size),
Parent = parent,
})
if colorToken then
Theme.Bind(img, { ImageColor3 = colorToken })
end
return img
end
local key = Icons.NormalizeKey(iconSpec)
if Icons.Vectors[key] then
return Icons.Vector(parent, key, size, colorToken)
end
local spriteName = (key ~= "" and Sprite.Resolve(key)) or Icons.FromTitle(fallbackTitle or iconSpec, "qblock")
local spriteSize = math.max(12, math.floor((size + 2) / 2) * 2)
return Sprite.New(parent, spriteName, spriteSize)
end
function Icons.Badge(parent, iconSpec, size, colorToken, fallbackTitle)
size = size or 24
local box = Draw.Box("Frame", {
Name = "IconBadge",
Size = UDim2.fromOffset(size, size),
BackgroundTransparency = 0.25,
Parent = parent,
}, "Element", "Outline", 6, 1.5)
local inner = Icons.Create(box, iconSpec, math.max(12, size - 6), colorToken, fallbackTitle)
inner.AnchorPoint = Vector2.new(0.5, 0.5)
inner.Position = UDim2.fromScale(0.5, 0.5)
return box, inner
end
Motion.Springs = {}
Motion.ByInst = {}
Motion.Free = {}
Motion.Tickers = {}
Motion.Sizes = { number = 1, Vector2 = 2, Color3 = 3, UDim2 = 4 }
function Motion.Pack(kind, current, out)
if kind == "number" then
out[1] = current
elseif kind == "UDim2" then
out[1], out[2], out[3], out[4] = current.X.Scale, current.X.Offset, current.Y.Scale, current.Y.Offset
elseif kind == "Vector2" then
out[1], out[2] = current.X, current.Y
else
out[1], out[2], out[3] = current.R, current.G, current.B
end
end
function Motion.Unpack(kind, components)
if kind == "number" then
return components[1]
elseif kind == "UDim2" then
return UDim2.new(components[1], components[2], components[3], components[4])
elseif kind == "Vector2" then
return Vector2.new(components[1], components[2])
end
return Color3.new(
math.clamp(components[1], 0, 1),
math.clamp(components[2], 0, 1),
math.clamp(components[3], 0, 1)
)
end
function Motion.SpeedOf(speedKey)
if type(speedKey) == "number" then
return speedKey
end
local speeds = Config.Motion.Speed
return speeds[speedKey or "Normal"] or speeds.Normal
end
function Motion.Get(inst, prop)
local props = Motion.ByInst[inst]
return props and props[prop]
end
function Motion.Create(inst, prop, kind)
local spring = table.remove(Motion.Free) or { Pos = {}, Vel = {}, Goal = {} }
spring.Inst, spring.Prop, spring.Kind, spring.Count = inst, prop, kind, Motion.Sizes[kind]
Motion.Pack(kind, inst[prop], spring.Pos)
for index = 1, spring.Count do
spring.Vel[index] = 0
end
local props = Motion.ByInst[inst]
if not props then
props = {}
Motion.ByInst[inst] = props
end
props[prop] = spring
table.insert(Motion.Springs, spring)
spring.Index = #Motion.Springs
return spring
end
function Motion.Remove(spring, fireCallback)
local springs = Motion.Springs
local last = springs[#springs]
if last then
springs[spring.Index] = last
last.Index = spring.Index
springs[#springs] = nil
end
local props = Motion.ByInst[spring.Inst]
if props then
props[spring.Prop] = nil
if next(props) == nil then
Motion.ByInst[spring.Inst] = nil
end
end
local onDone, inst = spring.OnDone, spring.Inst
spring.Inst, spring.OnDone = nil, nil
table.insert(Motion.Free, spring)
if fireCallback and onDone then
Util.Try(onDone, inst)
end
end
function Motion.Wake()
if Motion.Connection or Library.Unloaded then
return
end
Motion.Connection = Util.Connect(RunService.RenderStepped, Motion.Step)
end
function Motion.Spring(inst, prop, target, speedKey, options)
local kind = typeof(target)
if not Motion.Sizes[kind] then
inst[prop] = target
return
end
local spring = Motion.Get(inst, prop) or Motion.Create(inst, prop, kind)
Motion.Pack(kind, target, spring.Goal)
spring.Speed = Motion.SpeedOf(speedKey)
spring.Damping = options and options.Damping or Config.Motion.Damping
spring.OnDone = options and options.OnDone
Motion.Wake()
end
function Motion.Impulse(inst, prop, velocity, speedKey, damping)
local kind = typeof(inst[prop])
if not Motion.Sizes[kind] then
return
end
local spring = Motion.Get(inst, prop)
if not spring then
spring = Motion.Create(inst, prop, kind)
Motion.Pack(kind, inst[prop], spring.Goal)
spring.OnDone = nil
end
for index = 1, spring.Count do
spring.Vel[index] += velocity[index] or 0
end
spring.Speed = Motion.SpeedOf(speedKey)
spring.Damping = damping or Config.Motion.BounceDamping
Motion.Wake()
end
function Motion.Set(inst, prop, target)
local spring = Motion.Get(inst, prop)
if spring then
Motion.Remove(spring, false)
end
inst[prop] = target
end
function Motion.Advance(spring, step, substeps)
local speed = spring.Speed
local damp = 2 * spring.Damping * speed
local stiffness = speed * speed
local settled = true
for _ = 1, substeps do
for index = 1, spring.Count do
local displacement = spring.Pos[index] - spring.Goal[index]
local accel = -stiffness * displacement - damp * spring.Vel[index]
spring.Vel[index] += accel * step
spring.Pos[index] += spring.Vel[index] * step
end
end
for index = 1, spring.Count do
if math.abs(spring.Pos[index] - spring.Goal[index]) > 0.002 or math.abs(spring.Vel[index]) > 0.01 then
settled = false
break
end
end
if settled then
for index = 1, spring.Count do
spring.Pos[index] = spring.Goal[index]
spring.Vel[index] = 0
end
end
return settled
end
function Motion.Step(deltaTime)
local clamped = math.min(deltaTime, 0.05)
local substeps = clamped > 0.018 and 2 or 1
local step = clamped / substeps
for index = #Motion.Springs, 1, -1 do
local spring = Motion.Springs[index]
if not spring.Inst or not spring.Inst.Parent then
Motion.Remove(spring, false)
else
local settled = Motion.Advance(spring, step, substeps)
pcall(function()
spring.Inst[spring.Prop] = Motion.Unpack(spring.Kind, spring.Pos)
end)
if settled then
Motion.Remove(spring, true)
end
end
end
Motion.StepTickers(clamped)
if #Motion.Springs == 0 and next(Motion.Tickers) == nil and Motion.Connection then
Motion.Connection:Disconnect()
Motion.Connection = nil
end
end
function Motion.StepTickers(deltaTime)
for owner, ticker in pairs(Motion.Tickers) do
ticker.Elapsed += deltaTime
local alpha = math.clamp(ticker.Elapsed / ticker.Duration, 0, 1)
local eased = 1 - (1 - alpha) ^ 3
local current = ticker.From + (ticker.To - ticker.From) * eased
pcall(ticker.OnTick, current, alpha >= 1)
if alpha >= 1 then
Motion.Tickers[owner] = nil
end
end
end
function Fx.ScaleOf(frame)
local scale = frame:FindFirstChild("FxScale")
if not scale then
scale = Draw.New("UIScale", { Name = "FxScale", Parent = frame })
end
return scale
end
function Fx.Squash(frame, impulseScale)
local scale = Fx.ScaleOf(frame)
Motion.Impulse(scale, "Scale", { impulseScale or 2.4 }, "Fast", Config.Motion.SquashDamping)
end
function Fx.Bump(frame, velocity)
Motion.Impulse(frame, "Position", { 0, 0, 0, -(velocity or 110) }, "Fast", Config.Motion.BounceDamping)
end
function Fx.Ripple(parent, screenPos, token)
if not parent or not parent.Parent then
return
end
local pointer = screenPos or UserInputService:GetMouseLocation()
local localPos = pointer - parent.AbsolutePosition
local maxDim = math.max(parent.AbsoluteSize.X, parent.AbsoluteSize.Y) * 2.1
local circle = Draw.Box("Frame", {
Name = "Ripple",
AnchorPoint = Vector2.new(0.5, 0.5),
Position = UDim2.fromOffset(localPos.X, localPos.Y),
Size = UDim2.fromOffset(4, 4),
BackgroundTransparency = 0.55,
ZIndex = 8,
Parent = parent,
}, token or "White", nil, UDim.new(1, 0))
local tween = Anim.Tween(circle, { Size = UDim2.fromOffset(maxDim, maxDim), BackgroundTransparency = 1 }, 0.36, "Out")
tween.Completed:Once(function()
circle:Destroy()
end)
end
function Fx.CountUp(owner, fromValue, toValue, duration, onTick)
if math.abs(toValue - fromValue) < 1e-4 then
pcall(onTick, toValue, true)
return
end
local existing = Motion.Tickers[owner]
local startValue = existing and (existing.From + (existing.To - existing.From) * math.clamp(existing.Elapsed / existing.Duration, 0, 1)) or fromValue
Motion.Tickers[owner] = {
From = startValue,
To = toValue,
Elapsed = 0,
Duration = duration or 0.22,
OnTick = onTick,
}
Motion.Wake()
end
function Fx.Shimmer(target, colorToken)
if target:FindFirstChild("FxShimmer") then
return
end
local gradient = Draw.New("UIGradient", {
Name = "FxShimmer",
Rotation = 25,
Offset = Vector2.new(-1, 0),
Parent = target,
})
Theme.OnRender(gradient, function()
local base = Theme.Colors[colorToken or "Text"] or Color3.new(1, 1, 1)
local highlight = Util.Lighten(base, 0.45)
gradient.Color = ColorSequence.new({
ColorSequenceKeypoint.new(0, base),
ColorSequenceKeypoint.new(0.45, base),
ColorSequenceKeypoint.new(0.5, highlight),
ColorSequenceKeypoint.new(0.55, base),
ColorSequenceKeypoint.new(1, base),
})
end)
Anim.Tween(gradient, { Offset = Vector2.new(1, 0) }, 2.6, "Sine", -1, false, 0.8)
end
function Fx.Spotlight(card)
return card
end
function Fx.StaggerRise(cards)
for index, card in ipairs(cards) do
if card and card.Parent then
local scale = Fx.ScaleOf(card)
scale.Scale = 0.96
task.delay((index - 1) * 0.028, function()
if card.Parent then
Motion.Spring(scale, "Scale", 1, "Normal", { Damping = 0.62 })
end
end)
end
end
end
Tailwind.Cache = {}
Tailwind.TokenMap = {
panel = "Panel", header = "PanelHeader", element = "Element", hover = "Hover",
accent = "Accent", ["accent-dark"] = "AccentDark", good = "Good", ["good-dark"] = "GoodDark",
danger = "Danger", ["danger-dark"] = "DangerDark", coin = "Coin", ["coin-dark"] = "CoinDark",
blue = "Blue", ["blue-dark"] = "BlueDark", risky = "Risky", track = "Track",
outline = "Outline", shadow = "Shadow", text = "Text", sub = "SubText",
muted = "Muted", white = "White", black = "Black", ink = "Ink",
topbar = "Topbar", sidebar = "Sidebar", ["sidebar-alt"] = "SidebarAlt",
}
Tailwind.RadiusMap = { none = 0, sm = 6, md = 8, lg = 10, xl = 12 }
Tailwind.FontMap = { display = "Display", body = "Body", desc = "Desc", strong = "Strong", logo = "Logo", glyph = "Glyph" }
Tailwind.SizeMap = { xs = 12, sm = 13, base = 15, lg = 18, xl = 22, ["2xl"] = 26 }
Tailwind.AlignXMap = { left = Enum.TextXAlignment.Left, center = Enum.TextXAlignment.Center, right = Enum.TextXAlignment.Right }
Tailwind.FlexXMap = { start = Enum.HorizontalAlignment.Left, center = Enum.HorizontalAlignment.Center, ["end"] = Enum.HorizontalAlignment.Right }
Tailwind.FlexYMap = { start = Enum.VerticalAlignment.Top, center = Enum.VerticalAlignment.Center, ["end"] = Enum.VerticalAlignment.Bottom }
function Tailwind.ParseToken(raw)
return Tailwind.TokenMap[raw] or raw
end
function Tailwind.ApplyLayoutRule(inst, rule, state)
if rule == "flex-row" or rule == "flex-col" then
state.Flex = rule == "flex-row" and "row" or "col"
elseif rule:sub(1, 6) == "items-" then
state.Items = rule:sub(7)
elseif rule:sub(1, 8) == "justify-" then
state.Justify = rule:sub(9)
elseif rule:sub(1, 4) == "gap-" then
state.Gap = (tonumber(rule:sub(5)) or 2) * 4
elseif rule == "w-full" then
inst.Size = UDim2.new(1, 0, inst.Size.Y.Scale, inst.Size.Y.Offset)
elseif rule == "h-full" then
inst.Size = UDim2.new(inst.Size.X.Scale, inst.Size.X.Offset, 1, 0)
elseif rule == "w-1/2" then
inst.Size = UDim2.new(0.5, 0, inst.Size.Y.Scale, inst.Size.Y.Offset)
elseif rule == "clip" then
inst.ClipsDescendants = true
elseif rule == "auto-x" then
inst.AutomaticSize = Enum.AutomaticSize.X
elseif rule == "auto-y" then
inst.AutomaticSize = Enum.AutomaticSize.Y
end
end
function Tailwind.ApplyBoxRule(inst, rule, state)
local padAll = rule:match("^p%-(%d+)$")
local padX = rule:match("^px%-(%d+)$")
local padY = rule:match("^py%-(%d+)$")
local widthPx = rule:match("^w%-%[(%d+)%]$") or rule:match("^w%-(%d+)$")
local heightPx = rule:match("^h%-%[(%d+)%]$") or rule:match("^h%-(%d+)$")
if padAll then
local px = tonumber(padAll) * 4
state.Pad = { px, px, px, px }
elseif padX then
local px = tonumber(padX) * 4
state.Pad = state.Pad or { 0, 0, 0, 0 }
state.Pad[2], state.Pad[4] = px, px
elseif padY then
local px = tonumber(padY) * 4
state.Pad = state.Pad or { 0, 0, 0, 0 }
state.Pad[1], state.Pad[3] = px, px
elseif widthPx then
inst.Size = UDim2.new(0, tonumber(widthPx), inst.Size.Y.Scale, inst.Size.Y.Offset)
elseif heightPx then
inst.Size = UDim2.new(inst.Size.X.Scale, inst.Size.X.Offset, 0, tonumber(heightPx))
end
end
function Tailwind.ApplySurfaceRule(inst, rule, state)
if rule == "rounded-full" then
Draw.Corner(inst, UDim.new(1, 0))
elseif rule:sub(1, 8) == "rounded-" then
local key = rule:sub(9)
Draw.Corner(inst, Tailwind.RadiusMap[key] or tonumber(key) or 8)
elseif rule:sub(1, 11) == "bg-opacity-" then
inst.BackgroundTransparency = 1 - math.clamp((tonumber(rule:sub(12)) or 100) / 100, 0, 1)
elseif rule:sub(1, 3) == "bg-" then
inst.BackgroundTransparency = inst.BackgroundTransparency == 1 and 0 or inst.BackgroundTransparency
Theme.Bind(inst, { BackgroundColor3 = Tailwind.ParseToken(rule:sub(4)) })
elseif rule == "border" or rule == "border-2" or rule == "border-3" then
state.BorderWidth = tonumber(rule:match("%d+")) or 1
elseif rule:sub(1, 7) == "border-" then
state.BorderToken = Tailwind.ParseToken(rule:sub(8))
elseif rule == "spotlight" then
state.Spotlight = true
end
end
function Tailwind.ApplyTextRule(inst, rule, state)
if not inst:IsA("TextLabel") and not inst:IsA("TextButton") and not inst:IsA("TextBox") then
return
end
if rule:sub(1, 5) == "font-" then
state.Font = Tailwind.FontMap[rule:sub(6)] or "Body"
elseif rule:sub(1, 5) == "text-" then
local suffix = rule:sub(6)
if Tailwind.SizeMap[suffix] then
state.TextSize = Tailwind.SizeMap[suffix]
elseif Tailwind.AlignXMap[suffix] then
inst.TextXAlignment = Tailwind.AlignXMap[suffix]
else
Theme.Bind(inst, { TextColor3 = Tailwind.ParseToken(suffix) })
end
elseif rule == "truncate" then
inst.TextTruncate = Enum.TextTruncate.AtEnd
elseif rule == "wrap" then
inst.TextWrapped = true
elseif rule == "shimmer" then
Fx.Shimmer(inst)
end
end
function Tailwind.FinalizeState(inst, state)
if state.Pad then
Draw.Padding(inst, state.Pad[1], state.Pad[2], state.Pad[3], state.Pad[4])
end
if state.Flex then
local alignX = state.Flex == "row" and Tailwind.FlexXMap[state.Justify or "start"] or Tailwind.FlexXMap[state.Items or "start"]
local alignY = state.Flex == "row" and Tailwind.FlexYMap[state.Items or "center"] or Tailwind.FlexYMap[state.Justify or "start"]
local list = Draw.List(inst, state.Gap or 0, state.Flex == "row", alignX, alignY)
if state.Justify == "between" then
list.HorizontalFlex = state.Flex == "row" and Enum.UIFlexAlignment.SpaceBetween or Enum.UIFlexAlignment.None
end
end
if state.BorderWidth or state.BorderToken then
Draw.Stroke(inst, state.BorderToken or "Outline", state.BorderWidth or 2, true)
end
if state.Font or state.TextSize then
Fonts.Style(inst, state.Font or "Body", state.TextSize or Util.TextSize("Label"))
end
if state.Spotlight then
Fx.Spotlight(inst)
end
end
function Tailwind.Apply(inst, classString)
if type(classString) ~= "string" or classString == "" then
return inst
end
local state = {}
for rule in classString:gmatch("%S+") do
Tailwind.ApplyLayoutRule(inst, rule, state)
Tailwind.ApplyBoxRule(inst, rule, state)
Tailwind.ApplySurfaceRule(inst, rule, state)
Tailwind.ApplyTextRule(inst, rule, state)
end
Tailwind.FinalizeState(inst, state)
return inst
end
function Tailwind.BindProp(inst, property, target)
if property == "Class" or property == "class" then
if Reactive.IsRef(target) or type(target) == "function" then
Reactive.Effect(function()
Tailwind.Apply(inst, Reactive.IsRef(target) and target.Value or target())
end)
else
Tailwind.Apply(inst, target)
end
return
end
if property == "Text" and (type(target) == "table" and not Reactive.IsRef(target)) then
Lang.Bind(inst, target)
return
end
if Reactive.IsRef(target) or type(target) == "function" then
Reactive.Effect(function()
local resolved = Reactive.IsRef(target) and target.Value or target()
if property == "Text" then
Lang.Bind(inst, resolved)
else
inst[property] = resolved
end
end)
return
end
if property == "Text" then
Lang.Bind(inst, target)
elseif property ~= "Parent" and property ~= "Children" then
inst[property] = target
end
end
function Tailwind.CreateElement(tag, props, children)
props = props or {}
local classMap = { Card = "Frame", Box = "Frame", Row = "Frame", Col = "Frame", Text = "TextLabel", Button = "TextButton", Input = "TextBox" }
local robloxClass = classMap[tag] or tag
local inst = Draw.New(robloxClass, { BackgroundTransparency = robloxClass == "Frame" and 1 or 1 })
if tag == "Card" then
Tailwind.Apply(inst, "bg-panel rounded-xl border-2 border-outline p-3 flex-col gap-2 spotlight")
elseif tag == "Text" then
Fonts.Style(inst, "Body", Util.TextSize("Label"))
Theme.Bind(inst, { TextColor3 = "Text" })
end
for property, value in pairs(props) do
if type(property) == "string" and property:sub(1, 2) == "On" and type(value) == "function" then
local signalName = property:sub(3)
if signalName == "Click" and inst:IsA("GuiButton") then
inst.Activated:Connect(value)
elseif inst[signalName] then
inst[signalName]:Connect(value)
end
else
Tailwind.BindProp(inst, property, value)
end
end
for index, child in ipairs(children or props.Children or {}) do
if typeof(child) == "Instance" then
child.LayoutOrder = index
child.Parent = inst
end
end
if props.Parent then
inst.Parent = props.Parent
end
return inst
end
function Tailwind.Component(renderFn)
return function(props, children)
return renderFn(props or {}, children)
end
end
function Tailwind.Show(whenSource, renderTrue, renderFalse)
local holder = Draw.New("Frame", { Name = "ShowSlot", BackgroundTransparency = 1, AutomaticSize = Enum.AutomaticSize.XY })
Reactive.Effect(function()
for _, child in ipairs(holder:GetChildren()) do
child:Destroy()
end
local active = Reactive.IsRef(whenSource) and whenSource.Value or (type(whenSource) == "function" and whenSource() or whenSource)
local builder = active and renderTrue or renderFalse
if builder then
local built = builder()
if typeof(built) == "Instance" then
built.Parent = holder
end
end
end)
return holder
end
function Tailwind.For(listSource, renderEntry)
local holder = Draw.New("Frame", { Name = "ForSlot", BackgroundTransparency = 1, AutomaticSize = Enum.AutomaticSize.Y, Size = UDim2.fromScale(1, 0) })
Draw.List(holder, 6, false)
Reactive.Effect(function()
for _, child in ipairs(holder:GetChildren()) do
if not child:IsA("UIListLayout") then
child:Destroy()
end
end
local entries = Reactive.IsRef(listSource) and listSource.Value or (type(listSource) == "function" and listSource() or listSource or {})
for index, entry in ipairs(entries) do
local node = renderEntry(entry, index)
if typeof(node) == "Instance" then
node.LayoutOrder = index
node.Parent = holder
end
end
end)
return holder
end
function Container.New(host, options)
options = options or {}
local self = setmetatable({
Host = host,
Items = {},
Parent = nil,
Depth = 0,
PadX = options.PadX or 0,
PadY = options.PadY or 0,
GapX = options.GapX or Config.Gap.X,
GapY = options.GapY or Config.Gap.Y,
Width = 0,
ContentHeight = 0,
Scroll = host:IsA("ScrollingFrame"),
OnHeight = options.OnHeight,
IndentX = 0,
PendingSameLine = nil,
Window = options.Window,
Tab = options.Tab,
}, Container)
if options.Parent then
self:SetParent(options.Parent)
end
Layout.All[self] = true
return self
end
function Container:SetParent(parent)
self.Parent = parent
self.Depth = parent and parent.Depth + 1 or 0
self.Window = self.Window or (parent and parent.Window)
self.Tab = self.Tab or (parent and parent.Tab)
end
function Container:MarkDirty()
Layout.Dirty[self] = true
Layout.Schedule()
end
function Container:SetWidth(width)
width = math.max(0, math.floor(width))
if width == self.Width then
return
end
self.Width = width
self:MarkDirty()
end
function Container:Add(frame, spec)
spec = spec or {}
local item = {
Frame = frame,
Width = spec.Width,
Height = spec.Height or Util.Metric("Row"),
Indent = self.IndentX,
Child = spec.Child,
ChildInset = spec.ChildInset,
OnLayout = spec.OnLayout,
AutoWidth = spec.AutoWidth,
Fill = spec.Fill,
Search = spec.Search,
Hidden = false,
Filtered = false,
}
if self.PendingSameLine then
item.SameLine = true
item.Gap = self.PendingSameLine.Gap
self.PendingSameLine = nil
end
frame.Parent = self.Host
self:Insert(item, spec.After)
if spec.Child then
spec.Child:SetParent(self)
end
self:MarkDirty()
return item
end
function Container:Insert(item, after)
for index, existing in ipairs(self.Items) do
if existing == after then
table.insert(self.Items, index + 1, item)
return
end
end
table.insert(self.Items, item)
end
function Container:Remove(item)
local index = table.find(self.Items, item)
if index then
table.remove(self.Items, index)
end
if item.Child then
item.Child:Destroy()
end
Theme.UnbindTree(item.Frame)
item.Frame:Destroy()
self:MarkDirty()
end
function Container:Clear()
for index = #self.Items, 1, -1 do
self:Remove(self.Items[index])
end
end
function Container:Destroy()
self.Destroyed = true
Layout.All[self] = nil
Layout.Dirty[self] = nil
end
function Container:SameLine(gap)
self.PendingSameLine = { Gap = gap }
return self
end
function Container:NewLine()
self.PendingSameLine = nil
return self:Spacing(0)
end
function Container:Spacing(height)
local spacer = Draw.New("Frame", { Name = "Spacing", BackgroundTransparency = 1 })
self:Add(spacer, { Height = height or Config.Gap.Y })
return self
end
function Container:Indent(width)
self.IndentX += width or 16
return self
end
function Container:Unindent(width)
self.IndentX = math.max(0, self.IndentX - (width or 16))
return self
end
local function ResolveWidth(spec, available, used, gap)
local remaining = math.max(0, available - used)
if spec == nil or spec == 0 then
return remaining
end
if spec < 0 then
return math.max(0, remaining + spec)
end
if spec <= 1 then
return math.min(remaining, math.floor((available + gap) * spec - gap + 0.5))
end
return math.min(spec, remaining)
end
local function ItemWidth(item, joined, available, used, gap)
if item.Width == nil and item.AutoWidth and not item.Fill and (joined or item.SameLine) then
return math.min(item.AutoWidth(), math.max(0, available - used))
end
return ResolveWidth(item.Width, available, used, gap)
end
function Container:Place(entry, cursor, available, joined)
if entry.SameLine and cursor.EndX then
cursor.X = cursor.EndX + (entry.Gap or self.GapX)
else
if cursor.EndX then
cursor.Y += cursor.LineHeight + self.GapY
end
cursor.LineIndent = entry.Indent or 0
cursor.X = self.PadX + cursor.LineIndent
cursor.LineHeight = 0
end
local lineIndent = cursor.LineIndent or 0
local lineAvailable = math.max(0, available - lineIndent)
local used = math.max(0, cursor.X - self.PadX - lineIndent)
local width = ItemWidth(entry, joined, lineAvailable, used, self.GapX)
local height = type(entry.Height) == "function" and entry.Height(width) or entry.Height
if entry.LastX ~= cursor.X or entry.LastY ~= cursor.Y then
entry.LastX, entry.LastY = cursor.X, cursor.Y
entry.Frame.Position = UDim2.fromOffset(cursor.X, cursor.Y)
end
if entry.LastW ~= width or entry.LastH ~= height then
entry.LastW, entry.LastH = width, height
entry.Frame.Size = UDim2.fromOffset(width, height)
end
if entry.Child then
entry.Child:SetWidth(width - (entry.ChildInset or 0))
end
if entry.OnLayout then
entry.OnLayout(width, height)
end
cursor.EndX = cursor.X + width
cursor.LineHeight = math.max(cursor.LineHeight, height)
end
function Container:Layout()
Layout.Dirty[self] = nil
if self.Destroyed or self.Width <= 0 then
return
end
local available = math.max(0, self.Width - self.PadX * 2)
local cursor = { X = self.PadX, Y = self.PadY, LineHeight = 0, EndX = nil }
local visible = {}
for _, item in ipairs(self.Items) do
local shown = not item.Hidden and not item.Filtered
if item.LastShown ~= shown then
item.LastShown = shown
item.Frame.Visible = shown
end
if shown then
table.insert(visible, item)
end
end
for index, item in ipairs(visible) do
local following = visible[index + 1]
self:Place(item, cursor, available, following ~= nil and following.SameLine == true)
end
local height = cursor.EndX and (cursor.Y + cursor.LineHeight + self.PadY) or 0
self:Commit(height)
end
function Container:Commit(height)
if self.Scroll and self.LastCanvasHeight ~= height then
self.LastCanvasHeight = height
self.Host.CanvasSize = UDim2.fromOffset(0, height)
end
if height == self.ContentHeight then
return
end
self.ContentHeight = height
if self.OnHeight then
Util.Try(self.OnHeight, height)
end
if self.Parent then
self.Parent:MarkDirty()
end
end
function Layout.Schedule()
if Layout.Scheduled or Library.Unloaded then
return
end
Layout.Scheduled = true
RunService.RenderStepped:Once(Layout.Flush)
end
function Layout.Flush()
Layout.Scheduled = false
for _ = 1, Config.LayoutPasses do
if next(Layout.Dirty) == nil then
return
end
local batch = {}
for container in pairs(Layout.Dirty) do
table.insert(batch, container)
end
table.sort(batch, function(left, right)
return left.Depth < right.Depth
end)
for _, container in ipairs(batch) do
if Layout.Dirty[container] then
container:Layout()
end
end
end
if next(Layout.Dirty) ~= nil then
Layout.Schedule()
end
end
function Layout.MarkAll()
for container in pairs(Layout.All) do
container:MarkDirty()
end
end
function Layout.Measure(text, size, fontKind, width)
width = math.max(1, math.floor(width))
local key = table.concat({ text, size, fontKind, width, State.Language }, "\0")
local cached = Layout.Measured[key]
if cached then
return cached
end
if Layout.MeasuredCount > Config.MeasureCacheLimit then
table.clear(Layout.Measured)
Layout.MeasuredCount = 0
end
local probe = Layout.Probe()
probe.FontFace = Fonts.Face(fontKind)
probe.TextSize = size
probe.Size = UDim2.fromOffset(width, 100000)
probe.Text = text
local bounds = probe.TextBounds
Layout.Measured[key] = bounds
Layout.MeasuredCount += 1
return bounds
end
function Layout.Probe()
local probe = Layout.ProbeLabel
if probe and probe.Parent then
return probe
end
probe = Draw.New("TextLabel", {
Name = "Probe",
BackgroundTransparency = 1,
TextTransparency = 1,
TextWrapped = true,
Position = UDim2.fromOffset(-20000, -20000),
Parent = State.Gui or Util.GuiParent(),
})
Layout.ProbeLabel = probe
return probe
end
function Layout.ScrollFrame(props)
props.BackgroundTransparency = 1
props.ScrollBarThickness = Config.Page.ScrollBar
props.VerticalScrollBarInset = Enum.ScrollBarInset.Always
props.ScrollingDirection = Enum.ScrollingDirection.Y
props.CanvasSize = UDim2.new()
props.ElasticBehavior = Enum.ElasticBehavior.WhenScrollable
local frame = Draw.New("ScrollingFrame", props)
Theme.Bind(frame, { ScrollBarImageColor3 = "Muted" })
return frame
end
function Container:Columns(count, gap)
count = math.max(1, math.floor(tonumber(count) or 2))
gap = gap or self.GapX
local cols = {}
local colWidth = 1 / count
for index = 1, count do
if index > 1 then
self:SameLine(gap)
end
local subFrame = Draw.New("Frame", {
BackgroundTransparency = 1,
Parent = self.Host,
})
local subContainer = Container.New(subFrame, {
Parent = self,
PadX = 0,
PadY = 0,
GapX = self.GapX,
GapY = self.GapY,
})
local entry = self:Add(subFrame, {
Width = colWidth,
Height = 0,
Child = subContainer,
})
subContainer.OnHeight = function(nextHeight)
entry.Height = nextHeight
self:MarkDirty()
end
cols[index] = subContainer
end
return table.unpack(cols)
end
function Container:Mount(element, spec)
spec = spec or {}
local frame = (type(element) == "table" and element.Frame) or element
if not frame then
return nil
end
frame.Parent = self.Host
return self:Add(frame, {
Width = spec.Width,
Height = spec.Height or frame.Size.Y.Offset or Util.Metric("Row"),
After = spec.After,
Search = spec.Search,
Fill = spec.Fill,
})
end
function Container:EndChild()
Gui.EndChild()
return self.Parent or self
end
function Container:AddBadge(text, spec)
spec = spec or {}
spec.Text = text or spec.Text
spec.Container = self
return Gui.Badge(self, spec)
end
function Container:AddKbd(keys, spec)
spec = spec or {}
spec.Keys = keys or spec.Keys
spec.Container = self
return Gui.Kbd(self, spec)
end
function Container:AddMarquee(text, spec)
spec = spec or {}
spec.Text = text or spec.Text
spec.Container = self
return Gui.Marquee(self, spec)
end
function Container:tw(target, classes)
return Tailwind.Apply(target, classes)
end
function Container:h(tag, props, children)
local inst = Tailwind.CreateElement(tag, props, children)
if inst then
self:Mount(inst, props)
end
return inst
end
Gui.Press = { Active = false, Token = 0 }
function Gui.Lookup(container, id)
local registry = container and container.Ids
return id ~= nil and registry and registry[id] or nil
end
function Gui.Remember(container, id, handle)
if not container or id == nil then
return
end
container.Ids = container.Ids or {}
container.Ids[id] = handle
end
function Gui.Current()
return Gui.Stack[#Gui.Stack]
end
function Gui.BeginChild(parent, id, options)
if type(id) == "table" and options == nil then
options, id = id, id.Id
end
local existing = Gui.Lookup(parent, id)
if existing then
table.insert(Gui.Stack, existing)
return existing
end
options = options or {}
local holder = Draw.New("Frame", { Name = tostring(id or "Child"), BackgroundTransparency = 1 })
local hasBorder = options.Border ~= false and options.Fill ~= false
local fillToken = options.Fill or (hasBorder and "Element" or nil)
local strokeToken = options.Stroke or (hasBorder and "Track" or nil)
local radius = options.Radius or 10
local surface = Draw.Box("Frame", { Size = UDim2.fromScale(1, 1), ClipsDescendants = options.Clip == true, Parent = holder }, fillToken, strokeToken, radius, options.Thickness or 2)
if hasBorder and not options.Fill then
surface.BackgroundTransparency = 0.4
end
local useScroll = options.Scroll == true or options.Height ~= nil and options.Scroll ~= false
local host = useScroll and Layout.ScrollFrame({ Size = UDim2.fromScale(1, 1), Parent = surface }) or Draw.New("Frame", { BackgroundTransparency = 1, Size = UDim2.fromScale(1, 1), Parent = surface })
local child = Container.New(host, {
PadX = options.PadX or 8,
PadY = options.PadY or 8,
GapX = options.GapX,
GapY = options.GapY,
Parent = parent,
})
child.Frame, child.Surface = holder, surface
local inset = useScroll and Config.Page.ScrollBar or 0
if parent and parent.Add then
child.Item = parent:Add(holder, {
Width = options.Width,
Height = options.Height or function()
return child.ContentHeight
end,
Child = child,
ChildInset = inset,
})
end
Gui.Remember(parent, id, child)
table.insert(Gui.Stack, child)
return child
end
function Gui.EndChild()
Gui.Stack[#Gui.Stack] = nil
return Gui.Current()
end
function Gui.Badge(parent, spec, token, shiny)
local textSpec = spec
local container = type(parent) == "table" and parent.Add and parent or nil
local host = (type(parent) == "userdata" and parent) or (container and container.Host) or nil
if type(spec) == "table" and (spec.Text ~= nil or spec.Color ~= nil) then
textSpec = spec.Text or ""
token = spec.Color or token
shiny = spec.Shiny
container = spec.Container or container
end
token = token or "Danger"
local shade = token .. "Dark"
local pill = Draw.Box("Frame", {
Name = "Badge",
AutomaticSize = Enum.AutomaticSize.X,
Size = UDim2.fromOffset(0, 18),
Parent = host,
}, token, Themes.Shared[shade] and shade or "Outline", 5, 1.5)
Draw.Padding(pill, 0, 6, 0, 6)
local label = Draw.Text({
AutomaticSize = Enum.AutomaticSize.X,
Size = UDim2.fromScale(0, 1),
TextXAlignment = Enum.TextXAlignment.Center,
Parent = pill,
}, "Strong", 11, token == "Coin" and "Ink" or "OnAccent", textSpec)
if shiny ~= false then
Fx.Shimmer(label, token == "Coin" and "Ink" or "White")
end
local width = Layout.Measure(label.Text, 11, "Strong", 400).X + 14
local badgeObj = {
Frame = pill,
Label = label,
Width = width,
SetText = function(_, nextText)
Lang.Bind(label, nextText)
end,
SetColor = function(_, nextToken)
Theme.Bind(pill, { BackgroundColor3 = nextToken })
end,
}
if container then
badgeObj.Item = container:Add(pill, { Width = width, Height = 20 })
end
return badgeObj, label
end
function Gui.Kbd(parent, keySpec)
local container = type(parent) == "table" and parent.Add and parent or nil
local host = (type(parent) == "userdata" and parent) or (container and container.Host) or nil
local keyText = type(keySpec) == "table" and (keySpec.Keys or keySpec.Text or keySpec[1]) or keySpec
local holder, face = Draw.Block(host, "Element", "Track", 5, 2)
holder.AutomaticSize = Enum.AutomaticSize.X
holder.Size = UDim2.fromOffset(0, 20)
face.AutomaticSize = Enum.AutomaticSize.X
Draw.Padding(face, 0, 6, 0, 6)
local shortText = Keybinds.Short and Keybinds.Short(tostring(keyText or "")) or tostring(keyText or "")
local label = Draw.Text({
Text = shortText,
AutomaticSize = Enum.AutomaticSize.X,
Size = UDim2.fromScale(0, 1),
TextXAlignment = Enum.TextXAlignment.Center,
Parent = face,
}, "Strong", 11, "SubText")
local width = Layout.Measure(shortText, 11, "Strong", 400).X + 16
if container then
container:Add(holder, { Width = width, Height = 22 })
end
return holder, label
end
function Gui.Marquee(container, spec, speed)
local textSpec = type(spec) == "table" and spec.Text or spec
speed = (type(spec) == "table" and spec.Speed) or speed or 55
local height = Util.Metric("Row") - 4
local clip = Draw.Box("Frame", { Name = "Marquee", ClipsDescendants = true }, "Element", "Outline", 8, 2)
local track = Draw.Text({
Position = UDim2.fromOffset(10, 0),
AutomaticSize = Enum.AutomaticSize.X,
Size = UDim2.fromScale(0, 1),
Parent = clip,
}, "Body", Util.TextSize("Label"), "Text", textSpec)
local entry = container:Add(clip, {
Height = height,
Search = Lang.SearchText(textSpec),
OnLayout = function(width)
local textW = Layout.Measure(track.Text, track.TextSize, "Body", 4000).X
if textW > width - 20 then
track.Position = UDim2.fromOffset(width, 0)
local duration = math.max(4, (width + textW) / speed)
Anim.Tween(track, { Position = UDim2.fromOffset(-textW, 0) }, duration, "Linear", -1, false)
else
track.Position = UDim2.fromOffset(10, 0)
end
end,
})
return {
Frame = clip,
Label = track,
Item = entry,
SetText = function(_, nextSpec)
Lang.Bind(track, nextSpec)
container:MarkDirty()
end,
}
end
Gui.ButtonStyles = {
Default = { Face = "Element", Shade = "Track", Text = "Text" },
Primary = { Face = "Blue", Shade = "BlueDark", Text = "White" },
Success = { Face = "Good", Shade = "GoodDark", Text = "White" },
Danger = { Face = "Danger", Shade = "DangerDark", Text = "White" },
Warning = { Face = "Coin", Shade = "CoinDark", Text = "Ink" },
Ghost = { Face = nil, Shade = nil, Text = "Text" },
}
function Gui.BuildButtonFace(options)
local styleName = options.Style or "Default"
local style = Gui.ButtonStyles[styleName] or Gui.ButtonStyles.Default
local radius = options.Radius or Config.Metrics.Desktop.Radius
if not style.Face then
local holder = Draw.New("Frame", { Name = "GhostButton", BackgroundTransparency = 1 })
local face = Draw.Box("Frame", { Size = UDim2.fromScale(1, 1), BackgroundTransparency = 1, ClipsDescendants = true, Parent = holder }, "Hover", nil, radius)
return holder, face, nil, 0, style
end
local depth = options.Depth or Config.Button.Depth
local holder, face, shade = Draw.Block(nil, style.Face, style.Shade, radius, depth)
face.ClipsDescendants = true
return holder, face, shade, depth, style
end
function Gui.BuildButtonContent(face, options, style)
local content = Draw.New("Frame", { BackgroundTransparency = 1, Size = UDim2.fromScale(1, 1), ZIndex = 3, Parent = face })
Draw.List(content, Config.Button.IconGap, true, Enum.HorizontalAlignment.Center, Enum.VerticalAlignment.Center)
Draw.Padding(content, 0, 8, 0, 8)
if options.Icon then
local icon = Icons.Create(content, options.Icon, Util.Metric("Icon"), style.Text, options.Text)
icon.LayoutOrder = 1
end
local label = Draw.Text({
LayoutOrder = 2,
AutomaticSize = Enum.AutomaticSize.X,
Size = UDim2.fromScale(0, 1),
TextXAlignment = Enum.TextXAlignment.Center,
TextTruncate = Enum.TextTruncate.AtEnd,
Parent = content,
}, "Body", Util.TextSize("Button"), style.Text, options.Text or "")
return label
end
function Gui.BindButtonInput(handle)
local face, hit, style = handle.Face, handle.Hit, handle.Style
hit.MouseEnter:Connect(function()
if State.Touch or handle.Disabled then
return
end
if not style.Face then
Motion.Spring(face, "BackgroundTransparency", 0.35, "Fast")
else
local base = Theme.Colors[style.Face] or Color3.new(1, 1, 1)
Motion.Spring(face, "BackgroundColor3", Util.Lighten(base, Config.Button.HoverLighten), "Fast")
end
end)
hit.MouseLeave:Connect(function()
if not style.Face then
Motion.Spring(face, "BackgroundTransparency", 1, "Fast")
else
Motion.Spring(face, "BackgroundColor3", Theme.Colors[style.Face] or Color3.new(1, 1, 1), "Fast")
end
Motion.Spring(face, "Position", UDim2.new(), "Fast")
end)
hit.MouseButton1Down:Connect(function()
if not handle.Disabled and handle.Depth > 0 then
Motion.Spring(face, "Position", UDim2.fromOffset(0, handle.Depth - 1), "Fast")
end
end)
hit.MouseButton1Up:Connect(function()
if handle.Depth > 0 then
Motion.Spring(face, "Position", UDim2.new(), "Normal", { Damping = 0.52 })
end
end)
hit.Activated:Connect(function(inputObject)
if handle.Disabled then
return
end
local pos = inputObject and inputObject.Position or UserInputService:GetMouseLocation()
Fx.Ripple(face, Vector2.new(pos.X, pos.Y), style.Text)
Fx.Squash(handle.Holder, 1.4)
if handle.OnActivate then
handle:OnActivate()
end
end)
end
function Gui.Button(container, options)
options = options or {}
local holder, face, shade, depth, style = Gui.BuildButtonFace(options)
local label = Gui.BuildButtonContent(face, options, style)
local hit = Draw.New("TextButton", { Text = "", BackgroundTransparency = 1, Size = UDim2.fromScale(1, 1), ZIndex = 5, Parent = holder })
local handle = {
Container = container,
Holder = holder,
Face = face,
Shade = shade,
Depth = depth,
Style = style,
Label = label,
Hit = hit,
Disabled = options.Disabled == true,
OnActivate = options.OnActivate,
}
Gui.BindButtonInput(handle)
local iconExtra = options.Icon and (Util.Metric("Icon") + Config.Button.IconGap) or 0
if container and container.Add then
handle.Item = container:Add(holder, {
Width = options.Width,
Height = (options.Height or Util.Metric("Box")) + depth,
After = options.After,
Search = Lang.SearchText(options.Text),
AutoWidth = function()
return Layout.Measure(label.Text, label.TextSize, "Body", 1000).X + iconExtra + 32
end,
})
end
if options.Tooltip then
Tooltip.Attach(holder, options.Tooltip)
end
return handle
end
local function BuildSelectableVisuals(row, spec, height)
local token = spec.Color or "Accent"
local bar = Draw.Box("Frame", {
AnchorPoint = Vector2.new(0, 0.5),
Position = UDim2.new(0, 3, 0.5, 0),
Size = UDim2.fromOffset(Config.Selectable.BarWidth, 0),
Parent = row,
}, token, nil, 2)
local thumbSize = height - 8
local thumb
if spec.Image or spec.Icon then
thumb = Draw.Thumb(row, spec.Image or spec.Icon, spec.Tint, thumbSize, UDim2.new(0, 10, 0.5, 0))
end
return bar, thumb, thumbSize
end
function Gui.Selectable(parent, spec)
spec = spec or {}
local container = spec.Container or (type(parent) == "table" and parent.Add and parent or nil)
local host = (type(parent) == "userdata" and parent) or (container and container.Host) or nil
local height = spec.Height or Util.Metric("Item")
local row = Draw.Box("TextButton", {
Name = "Selectable",
BackgroundTransparency = 1,
ClipsDescendants = true,
Size = UDim2.new(spec.Width or 1, 0, 0, height),
Parent = host,
}, "Hover", nil, Config.Selectable.Radius)
local bar, thumb, thumbSize = BuildSelectableVisuals(row, spec, height)
local hasMedia = thumb ~= nil
local textOffset = hasMedia and (thumbSize + 18) or 12
local label = Draw.Text({
Position = UDim2.fromOffset(textOffset, 0),
Size = UDim2.new(1, -(textOffset + (spec.RightPadding or 26)), 1, 0),
TextTruncate = Enum.TextTruncate.AtEnd,
Parent = row,
}, "Body", Util.TextSize("Label"), "Text", spec.Text or spec.Label or "Item")
local mark = Icons.Vector(row, "check", 15, "OnAccent")
mark.AnchorPoint = Vector2.new(1, 0.5)
mark.Position = UDim2.new(1, -8, 0.5, 0)
local markScale = Draw.New("UIScale", { Scale = spec.Selected and 1 or 0, Parent = mark })
local handle = { Frame = row, Button = row, Label = label, Thumb = thumb, Bar = bar, Mark = mark, MarkScale = markScale, Selected = spec.Selected == true, Hovered = false }
function handle.Render(instant)
local isSel = handle.Selected
local duration = instant and 0 or Config.Tween.Fast
local fill = isSel and Theme.Colors.Accent or Theme.Colors.Hover
local alpha = isSel and 0 or (handle.Hovered and 0.45 or 1)
Anim.Tween(row, { BackgroundColor3 = fill, BackgroundTransparency = alpha }, duration)
Anim.Tween(label, { TextColor3 = Theme.Colors[isSel and "OnAccent" or "Text"] }, duration)
if instant then
Motion.Set(markScale, "Scale", isSel and 1 or 0)
else
Motion.Spring(markScale, "Scale", isSel and 1 or 0, "Fast", { Damping = 0.6 })
end
Motion.Spring(bar, "Size", UDim2.fromOffset(Config.Selectable.BarWidth, isSel and (height - 8) or 0), "Fast")
end
function handle.SetSelected(active, instant)
handle.Selected = active == true
handle.Render(instant)
end
if not State.Touch then
row.MouseEnter:Connect(function()
handle.Hovered = true
handle.Render()
end)
row.MouseLeave:Connect(function()
handle.Hovered = false
handle.Render()
end)
end
row.Activated:Connect(function()
Fx.Ripple(row, nil, spec.Color or "White")
if spec.Toggle ~= false then
handle.SetSelected(not handle.Selected)
end
if type(spec.Callback) == "function" then
Util.Try(spec.Callback, handle.Selected, handle)
end
end)
Theme.OnRender(row, function()
handle.Render(true)
end)
handle.Render(true)
if container and container.Add then
handle.Item = container:Add(row, {
Width = spec.Width,
Height = height,
After = spec.After,
Search = Lang.SearchText(spec.Text or spec.Label),
})
end
return handle
end
function Widget.Normalize(idx, info)
if type(idx) == "table" and info == nil then
info = idx
idx = info.Idx or info.Flag
end
return idx, info or {}
end
local function BindWidgetReactivity(option, spec)
local boundRef = (spec.Bind and Reactive.IsRef(spec.Bind)) and spec.Bind or Reactive.Ref(option.Value)
option.Ref = boundRef
if spec.Bind and Reactive.IsRef(spec.Bind) and spec.Bind:Get() ~= nil then
option.Value = spec.Bind:Get()
end
Reactive.Watch(boundRef, function(nextVal)
if not option._syncingRef and option.SetValue and nextVal ~= option.Value then
option:SetValue(nextVal)
end
end)
if spec.Visible ~= nil then
if Reactive.IsRef(spec.Visible) then
Reactive.Effect(function()
option:SetVisible(spec.Visible:Get() == true)
end)
elseif type(spec.Visible) == "boolean" then
option:SetVisible(spec.Visible)
end
end
if spec.Disabled ~= nil then
if Reactive.IsRef(spec.Disabled) then
Reactive.Effect(function()
option:SetDisabled(spec.Disabled:Get() == true)
end)
elseif type(spec.Disabled) == "boolean" then
option:SetDisabled(spec.Disabled)
end
end
if spec.DependsOn then
local depKey = type(spec.DependsOn) == "table" and spec.DependsOn[1] or spec.DependsOn
local expected = type(spec.DependsOn) == "table" and spec.DependsOn[2] or true
task.defer(function()
local target = Library.Options[depKey] or Library.Toggles[depKey]
if target and target.OnChanged then
local function CheckDep(currentVal)
option:SetVisible(currentVal == expected)
end
CheckDep(target.Value)
target:OnChanged(CheckDep)
end
end)
end
end
function Widget.Register(option, idx, spec)
option.Idx = idx
option.Callback = spec.Callback or spec.Func
option.Changed = {}
option.NoSave = spec.NoSave == true or idx == nil
if idx ~= nil then
if Library.Options[idx] then
warn("[Reicht] duplicate widget id: " .. tostring(idx))
end
Library.Options[idx] = option
end
if spec.Tooltip and option.Row then
Tooltip.Attach(option.Row.Holder, spec.Tooltip)
end
if spec.Badge and option.SetBadge then
option:SetBadge(spec.Badge, spec.BadgeColor)
end
BindWidgetReactivity(option, spec)
end
function Widget:OnChanged(callback)
table.insert(self.Changed, callback)
return self
end
function Widget:AddGuard(guard)
self.Guards = self.Guards or {}
table.insert(self.Guards, guard)
return self
end
function Widget:PassGuards(value)
for _, guard in ipairs(self.Guards or {}) do
local ok, allowed = pcall(guard, value)
if ok and allowed == false then
return false
end
end
return true
end
function Widget:Fire()
if self.Disabled then
return
end
if not self:PassGuards(self.Value) then
return
end
if self.Ref then
self._syncingRef = true
self.Ref:Set(self.Value)
self._syncingRef = false
end
Util.Try(self.Callback, self.Value)
for _, callback in ipairs(self.Changed) do
Util.Try(callback, self.Value)
end
end
function Widget:Serialize()
return self.Value
end
function Widget:Deserialize(saved)
self:SetValue(saved)
end
function Widget:SetVisible(visible)
if not self.Item then
return self
end
self.Item.Hidden = not visible
self.Container:MarkDirty()
return self
end
function Widget:SetDisabled(disabled)
self.Disabled = disabled == true
local holder = (self.Row and self.Row.Holder) or (self.Item and self.Item.Frame)
if holder then
if not self.DisableMask and self.Disabled then
self.DisableMask = Draw.Box("TextButton", {
Text = "",
AutoButtonColor = false,
BackgroundTransparency = 0.45,
Size = UDim2.fromScale(1, 1),
ZIndex = 15,
Parent = holder,
}, "Panel", nil, 8)
end
if self.DisableMask then
self.DisableMask.Visible = self.Disabled
end
end
return self
end
function Widget:Flash(colorToken)
local row = self.Row
if not row or not row.Holder then
return self
end
if not row.Hover then
row.Hover = Draw.Box("Frame", { BackgroundTransparency = 1, Position = UDim2.fromOffset(-4, 0), Size = UDim2.new(1, 8, 1, 0), ZIndex = 1, Parent = row.Holder }, "Hover", nil, 6)
end
local hover = row.Hover
hover.BackgroundColor3 = Theme.Colors[colorToken or "Coin"] or Theme.Colors.Coin
hover.BackgroundTransparency = 0.25
Anim.Tween(hover, { BackgroundTransparency = 1, BackgroundColor3 = Theme.Colors.Hover }, 0.55)
return self
end
function Widget:SetBadge(text, colorToken)
if not self.Row then
return self
end
if not self.BadgePill then
self.BadgePill = Gui.Badge(self.Row.Right, { Text = text, Color = colorToken or "Coin" })
self.Row:AddRight(self.BadgePill.Frame, self.BadgePill.Width)
else
self.BadgePill:SetText(text)
if colorToken then
self.BadgePill:SetColor(colorToken)
end
end
return self
end
function Widget:AddKeyPicker(idx, spec)
KeyPicker.New(self.Row, idx, spec or {}, self.Type == "Toggle" and self or nil)
return self
end
function Widget:AddColorPicker(idx, spec)
ColorPicker.New(self.Row, idx, spec or {})
return self
end
function Row.LineHeight(kind)
return Fonts.Size("Body", Util.TextSize(kind or "Label")) + 8
end
function Row.SearchText(info)
local parts = { Lang.SearchText(info.Text or info.Title), Lang.SearchText(info.Description) }
if type(info.Values) == "table" then
for _, v in ipairs(info.Values) do
table.insert(parts, Lang.SearchText(Dropdown and Dropdown.FormatValue and Dropdown.FormatValue(v) or v))
end
end
return table.concat(parts, " ")
end
function Row.New(container, spec, options)
options = options or {}
local holder = Draw.New("Frame", { Name = "Row", BackgroundTransparency = 1 })
local row = setmetatable({ Holder = holder, Container = container, RightWidth = 0, RightCount = 0, TitleFont = options.TitleFont or "Body", IconOffset = 0 }, { __index = Row })
if spec.Icon then
row.Icon = Icons.Create(holder, spec.Icon, 16, nil, spec.Text or spec.Title)
row.Icon.AnchorPoint = Vector2.new(0, 0.5)
row.Icon.ZIndex = 3
row.IconOffset = 22
end
row.Title = Draw.Text({ TextWrapped = true, TextYAlignment = Enum.TextYAlignment.Top, ZIndex = 3, Parent = holder }, row.TitleFont, options.TitleSize or Util.TextSize("Label"), options.TitleToken or "Text", spec.Text or spec.Title or "")
if spec.Description then
row.Desc = Draw.Text({ TextWrapped = true, TextYAlignment = Enum.TextYAlignment.Top, ZIndex = 3, Parent = holder }, "Desc", Util.TextSize("Desc"), "SubText", spec.Description)
end
row.Right = Draw.New("Frame", { BackgroundTransparency = 1, AnchorPoint = Vector2.new(1, 0.5), Position = UDim2.new(1, 0, 0.5, 0), ZIndex = 4, Parent = holder })
Draw.List(row.Right, 6, true, Enum.HorizontalAlignment.Right, Enum.VerticalAlignment.Center)
if options.Clickable then
row.Hit = Draw.New("TextButton", { Text = "", BackgroundTransparency = 1, Size = UDim2.fromScale(1, 1), ZIndex = 2, Parent = holder })
end
row.Item = container:Add(holder, {
Height = function(width)
return row:Measure(width)
end,
OnLayout = function(width, height)
row:Arrange(width, height)
end,
Search = Row.SearchText(spec),
})
return row
end
function Row.BindHover()
end
function Row:Measure(width)
local textWidth = math.max(20, width - self.IconOffset - self.RightWidth - (self.RightWidth > 0 and 10 or 0))
local titleHeight = Layout.Measure(self.Title.Text, self.Title.TextSize, self.TitleFont, textWidth).Y
local descHeight = self.Desc and Layout.Measure(self.Desc.Text, self.Desc.TextSize, "Desc", textWidth).Y or 0
self.TextWidth, self.TitleHeight, self.DescHeight = textWidth, titleHeight, descHeight
local content = titleHeight + (self.Desc and descHeight + 2 or 0)
return math.max(self.MinHeight or Util.Metric("Row"), content + 8)
end
function Row:Arrange(_, height)
local content = self.TitleHeight + (self.Desc and self.DescHeight + 2 or 0)
local top = math.floor((height - content) / 2)
if self.Icon then
self.Icon.Position = UDim2.new(0, 0, 0.5, 0)
end
self.Title.Position = UDim2.fromOffset(self.IconOffset, top)
self.Title.Size = UDim2.fromOffset(self.TextWidth, self.TitleHeight)
if self.Desc then
self.Desc.Position = UDim2.fromOffset(self.IconOffset, top + self.TitleHeight + 2)
self.Desc.Size = UDim2.fromOffset(self.TextWidth, self.DescHeight)
end
self.Right.Size = UDim2.new(0, self.RightWidth, 1, 0)
end
function Row:AddRight(frame, width)
self.RightCount += 1
frame.LayoutOrder = -self.RightCount
frame.Parent = self.Right
frame:SetAttribute("RightWidth", width)
self:RecalcRight()
end
function Row:RecalcRight()
local total, count = 0, 0
for _, child in ipairs(self.Right:GetChildren()) do
local width = child:GetAttribute("RightWidth")
if width then
total += width
count += 1
end
end
self.RightWidth = total + math.max(0, count - 1) * 6
self.Container:MarkDirty()
end
function Row:SetTitle(text)
Lang.Bind(self.Title, text)
self.Container:MarkDirty()
end
function Row.Stack(container, spec, controlHeight)
local holder = Draw.New("Frame", { Name = "Stack", BackgroundTransparency = 1 })
local stack = setmetatable({ Holder = holder, Container = container, ControlHeight = controlHeight, IconOffset = 0 }, { __index = Row })
if spec.Icon then
stack.Icon = Icons.Create(holder, spec.Icon, 16, nil, spec.Text or spec.Title)
stack.IconOffset = 22
end
stack.Title = Draw.Text({ TextTruncate = Enum.TextTruncate.AtEnd, Parent = holder }, "Body", Util.TextSize("Label"), spec.Risky and "Risky" or "Text", spec.Text or spec.Title or "")
stack.Aside = Draw.Text({ AnchorPoint = Vector2.new(1, 0), Position = UDim2.fromScale(1, 0), TextXAlignment = Enum.TextXAlignment.Right, Parent = holder }, "Body", Util.TextSize("Label"), "SubText")
if spec.Description then
stack.Desc = Draw.Text({ TextWrapped = true, TextYAlignment = Enum.TextYAlignment.Top, Parent = holder }, "Desc", Util.TextSize("Desc"), "SubText", spec.Description)
end
stack.Control = Draw.New("Frame", { Name = "Control", BackgroundTransparency = 1, Parent = holder })
stack.Item = container:Add(holder, {
Height = function(width)
return stack:MeasureStack(width)
end,
OnLayout = function(width)
stack:ArrangeStack(width)
end,
Search = Row.SearchText(spec),
})
return stack
end
function Row:MeasureStack(width)
self.StackWidth = width
local titled = self.Title.Text ~= "" or self.Aside.Text ~= "" or self.AsideWidth ~= nil
self.LineHeight = titled and Row.LineHeight() or 0
self.DescHeight = self.Desc and Layout.Measure(self.Desc.Text, self.Desc.TextSize, "Desc", width).Y or 0
self.ControlTop = self.LineHeight + (self.Desc and self.DescHeight + 2 or 0) + 4
return self.ControlTop + self.ControlHeight + 2
end
function Row:ArrangeStack(width)
local asideWidth = self.AsideWidth or (self.Aside.Text ~= "" and (Layout.Measure(self.Aside.Text, self.Aside.TextSize, "Body", width).X + 8) or 0)
if self.Icon then
self.Icon.Position = UDim2.fromOffset(0, math.max(0, math.floor((self.LineHeight - 16) / 2)))
end
self.Title.Position = UDim2.fromOffset(self.IconOffset, 0)
self.Title.Size = UDim2.fromOffset(math.max(10, width - self.IconOffset - asideWidth), self.LineHeight)
self.Aside.Size = UDim2.fromOffset(asideWidth, self.LineHeight)
if self.Desc then
self.Desc.Position = UDim2.fromOffset(0, self.LineHeight)
self.Desc.Size = UDim2.fromOffset(width, self.DescHeight)
end
self.Control.Position = UDim2.fromOffset(0, self.ControlTop)
self.Control.Size = UDim2.new(1, 0, 0, self.ControlHeight)
if self.OnArranged then
self.OnArranged(width)
end
end
function Container:AddToggle(idx, info)
idx, info = Widget.Normalize(idx, info)
local toggle = setmetatable({ Type = "Toggle", Value = info.Default == true, Style = info.Style or "Switch", Container = self }, Toggle)
toggle.Row = Row.New(self, info, { Clickable = true, TitleToken = info.Risky and "Risky" or nil })
toggle.Item = toggle.Row.Item
if toggle.Style == "Checkbox" then
toggle:BuildCheckbox()
else
toggle:BuildSwitch()
end
toggle.Row.Hit.Activated:Connect(function()
toggle:SetValue(not toggle.Value)
if toggle.Value then
Anim.CoinPop(toggle.Row.Holder, UDim2.new(1, -toggle.Track.Size.X.Offset / 2, 0, 6), 18)
end
end)
Widget.Register(toggle, idx, info)
if idx ~= nil then
Library.Toggles[idx] = toggle
end
Theme.OnRender(toggle, function()
toggle:Render(true)
end)
return toggle
end
function Container:AddCheckbox(idx, info)
idx, info = Widget.Normalize(idx, info)
info.Style = "Checkbox"
return self:AddToggle(idx, info)
end
function Toggle:BuildSwitch()
local size, knobSize = Util.Metric("Switch"), Util.Metric("SwitchKnob")
self.KnobSize = knobSize
self.Track = Draw.Box("Frame", { Size = UDim2.fromOffset(size.X, size.Y) }, "Track", "Outline", UDim.new(1, 0), 2)
self.Knob = Draw.Box("Frame", {
AnchorPoint = Vector2.new(0, 0.5),
Position = UDim2.new(0, 3, 0.5, 0),
Size = UDim2.fromOffset(knobSize, knobSize),
Parent = self.Track,
}, "Knob", "Outline", UDim.new(1, 0), 2)
self.Mark = Icons.Vector(self.Knob, "check", knobSize - 2, "Good")
self.Mark.AnchorPoint = Vector2.new(0.5, 0.5)
self.Mark.Position = UDim2.fromScale(0.5, 0.5)
self.MarkScale = Draw.New("UIScale", { Scale = self.Value and 1 or 0, Parent = self.Mark })
self.Row:AddRight(self.Track, size.X)
end
function Toggle:BuildCheckbox()
local size = Util.Metric("Check")
self.Track = Draw.Box("Frame", { Size = UDim2.fromOffset(size, size) }, "Element", "Outline", 6, 2)
self.Mark = Icons.Vector(self.Track, "check", size - 4, "Ink")
self.Mark.AnchorPoint = Vector2.new(0.5, 0.5)
self.Mark.Position = UDim2.fromScale(0.5, 0.5)
self.MarkScale = Draw.New("UIScale", { Scale = self.Value and 1 or 0, Parent = self.Mark })
self.Row:AddRight(self.Track, size)
end
function Toggle:Render(instant)
local on = self.Value
local duration = instant and 0 or Config.Tween.Normal
if self.Knob then
local travel = self.Track.Size.X.Offset - self.KnobSize - 3
local targetPos = UDim2.new(0, on and travel or 3, 0.5, 0)
Anim.Tween(self.Track, { BackgroundColor3 = Theme.Colors[on and "Good" or "Track"] }, duration)
if instant then
Motion.Set(self.Knob, "Position", targetPos)
else
Motion.Spring(self.Knob, "Position", targetPos, "Fast", { Damping = 0.58 })
Fx.Squash(self.Knob, 1.9)
end
else
Anim.Tween(self.Track, { BackgroundColor3 = Theme.Colors[on and "Coin" or "Element"] }, duration)
end
if self.MarkScale then
if instant then
Motion.Set(self.MarkScale, "Scale", on and 1 or 0)
else
Motion.Spring(self.MarkScale, "Scale", on and 1 or 0, "Fast", { Damping = 0.58 })
end
end
end
function Toggle:SetValue(value)
value = value == true
if value == self.Value then
return
end
self.Value = value
self:Render(false)
self:Fire()
end
function Container:AddSlider(idx, info)
idx, info = Widget.Normalize(idx, info)
local knob = Util.Metric("Knob")
local slider = setmetatable({
Type = "Slider",
Min = info.Min or 0,
Max = info.Max or 100,
Rounding = info.Rounding or 0,
Prefix = info.Prefix or "",
Suffix = info.Suffix or "",
FinishedOnly = info.Finished == true,
Container = self,
}, Slider)
slider.Value = Util.Round(math.clamp(tonumber(info.Default) or slider.Min, slider.Min, slider.Max), slider.Rounding)
slider.Row = Row.Stack(self, info, knob + 4)
slider.Item = slider.Row.Item
slider:Build(knob)
Widget.Register(slider, idx, info)
slider:MeasureAside()
slider:Render(false)
Lang.OnChange(slider, function()
slider:MeasureAside()
slider:Render(false)
slider.Container:MarkDirty()
end)
return slider
end
function Slider:Build(knob)
local control = self.Row.Control
local trackHeight = Util.Metric("Track")
self.Track = Draw.Box("Frame", {
AnchorPoint = Vector2.new(0, 0.5),
Position = UDim2.new(0, knob / 2, 0.5, 0),
Size = UDim2.new(1, -knob, 0, trackHeight),
Parent = control,
}, "Track", "Outline", UDim.new(1, 0), 2)
self.Fill = Draw.Box("Frame", { Size = UDim2.fromScale(0, 1), Parent = self.Track }, "Accent", nil, UDim.new(1, 0))
self.Knob = Draw.Box("Frame", { AnchorPoint = Vector2.new(0.5, 0.5), Size = UDim2.fromOffset(knob, knob), Position = UDim2.fromScale(0, 0.5), ZIndex = 3, Parent = self.Track }, "Coin", "Outline", UDim.new(1, 0), 2)
local slit = Draw.Box("Frame", { AnchorPoint = Vector2.new(0.5, 0.5), Position = UDim2.fromScale(0.5, 0.5), Size = UDim2.new(0, 3, 0.5, 0), Parent = self.Knob }, "CoinDark", nil, 2)
slit.ZIndex = 4
self.KnobScale = Draw.New("UIScale", { Parent = self.Knob })
self:BuildValueBox()
local hit = Draw.New("TextButton", { Text = "", BackgroundTransparency = 1, Size = UDim2.new(1, 0, 1, 6), Position = UDim2.fromOffset(0, -3), ZIndex = 5, Parent = control })
hit.InputBegan:Connect(function(input)
if Util.IsPointer(input) then
self:BeginDrag(input)
end
end)
end
function Slider:MeasureAside()
local widest = 0
local mid = Util.Round((self.Min + self.Max) / 2, self.Rounding)
for _, sample in ipairs({ self.Min, self.Max, mid }) do
widest = math.max(widest, Layout.Measure(self:Format(sample), self.Row.Aside.TextSize, "Body", 400).X)
end
self.Row.AsideWidth = widest + 14
end
function Slider:BuildValueBox()
local aside = self.Row.Aside
self.ValueBox = Draw.Text({
ClassName = "TextBox",
ClearTextOnFocus = false,
Size = UDim2.fromScale(1, 1),
TextXAlignment = Enum.TextXAlignment.Right,
Parent = aside,
}, "Body", Util.TextSize("Label"), "Accent")
aside.TextTransparency = 1
self.ValueBox.Focused:Connect(function()
self.ValueBox.Text = tostring(self.Value)
end)
self.ValueBox.FocusLost:Connect(function()
local typed = tonumber(self.ValueBox.Text)
if typed then
self:SetValue(typed)
end
self:Render(false)
end)
end
function Slider:BeginDrag(input)
Motion.Spring(self.KnobScale, "Scale", 1.24, "Fast", { Damping = 0.52 })
self.Dragging = true
self:SetFromX(input.Position.X)
State.Drag = {
Move = function(move)
self:SetFromX(move.Position.X)
end,
Stop = function()
Motion.Spring(self.KnobScale, "Scale", 1, "Fast", { Damping = 0.58 })
self.Dragging = false
if self.PendingFire then
self.PendingFire = false
self:Fire()
end
end,
}
end
function Slider:SetFromX(screenX)
local left, width = self.Track.AbsolutePosition.X, self.Track.AbsoluteSize.X
local fraction = width > 0 and math.clamp((screenX - left) / width, 0, 1) or 0
self:SetValue(self.Min + (self.Max - self.Min) * fraction)
end
function Slider:Format(targetVal)
local num = Util.Round(targetVal ~= nil and targetVal or self.Value, self.Rounding)
local formatted = self.Rounding > 0 and string.format("%." .. self.Rounding .. "f", num) or tostring(math.floor(num + 0.5))
local pre = Lang.Resolve(self.Prefix or "")
local suf = Lang.Resolve(self.Suffix or "")
return pre .. formatted .. suf
end
function Slider:Render(animated)
local span = self.Max - self.Min
local fraction = span > 0 and (self.Value - self.Min) / span or 0
if animated then
Motion.Spring(self.Fill, "Size", UDim2.fromScale(fraction, 1), "Fast")
Motion.Spring(self.Knob, "Position", UDim2.fromScale(fraction, 0.5), "Fast", { Damping = 0.68 })
else
Motion.Set(self.Fill, "Size", UDim2.fromScale(fraction, 1))
Motion.Set(self.Knob, "Position", UDim2.fromScale(fraction, 0.5))
end
local text = self:Format(self.Value)
self.Row.Aside.Text = text
if not self.ValueBox:IsFocused() then
self.ValueBox.Text = text
end
end
function Slider:SetValue(value)
value = tonumber(value)
if not value then
return
end
value = Util.Round(math.clamp(value, self.Min, self.Max), self.Rounding)
if value == self.Value then
return
end
self.Value = value
self:Render(true)
if self.FinishedOnly and self.Dragging then
self.PendingFire = true
return
end
self:Fire()
end
function Slider:SetRange(min, max)
self.Min, self.Max = min, max
local clamped = math.clamp(self.Value, min, max)
local changed = clamped ~= self.Value
self.Value = clamped
self:MeasureAside()
self:Render(false)
self.Container:MarkDirty()
if changed then
self:Fire()
end
end
function Slider:SetMax(max)
self:SetRange(self.Min, max)
end
function Slider:SetMin(min)
self:SetRange(min, self.Max)
end
function Draw.Field(parent, className)
local field = Draw.Box(className or "TextButton", { Size = UDim2.fromScale(1, 1), Parent = parent }, "Element", "Outline", 8, 2)
return field
end
function Container:AddDropdown(idx, info)
idx, info = Widget.Normalize(idx, info)
local dropdown = setmetatable({
Type = "Dropdown",
Multi = info.Multi == true,
AllowNull = info.AllowNull == true,
Searchable = info.Searchable,
Placeholder = info.Placeholder,
SpecialType = info.SpecialType,
Values = info.Values or {},
Images = info.Images,
Colors = info.Colors,
Container = self,
}, Dropdown)
if dropdown.SpecialType == "Player" then
dropdown.Values = Util.PlayerNames()
end
dropdown.Value = dropdown.Multi and {} or nil
dropdown.Row = Row.Stack(self, info, Util.Metric("Box"))
dropdown.Item = dropdown.Row.Item
dropdown:Build()
Widget.Register(dropdown, idx, info)
dropdown:ApplyDefault(info.Default)
dropdown:WatchPlayers()
Lang.OnChange(dropdown, function()
dropdown:Render()
end)
return dropdown
end
function Dropdown:Build()
local field = Draw.Field(self.Row.Control)
self.Field = field
self.Display = Draw.Text({ Position = UDim2.fromOffset(10, 0), Size = UDim2.new(1, -44, 1, 0), TextTruncate = Enum.TextTruncate.AtEnd, Parent = field }, "Body", Util.TextSize("Label"), "Text")
self:EnsureThumb()
local cap = Draw.Box("Frame", { AnchorPoint = Vector2.new(1, 0.5), Position = UDim2.new(1, -4, 0.5, 0), Size = UDim2.new(0, 26, 1, -8), Parent = field }, "Accent", "Outline", 6, 2)
self.Chevron = Icons.Vector(cap, "chevron_down", 14, "White")
self.Chevron.AnchorPoint = Vector2.new(0.5, 0.5)
self.Chevron.Position = UDim2.fromScale(0.5, 0.5)
field.MouseEnter:Connect(function()
if not State.Touch then
Anim.Tween(field, { BackgroundColor3 = Theme.Colors.Hover }, Config.Tween.Fast)
end
end)
field.MouseLeave:Connect(function()
Anim.Tween(field, { BackgroundColor3 = Theme.Colors.Element }, Config.Tween.Fast)
end)
field.Activated:Connect(function()
self:Open()
end)
end
function Dropdown:ApplyDefault(default)
if self.Multi then
self.Value = Util.ToSet(default)
elseif type(default) == "number" then
self.Value = self.Values[default]
elseif default ~= nil then
self.Value = default
elseif not self.AllowNull then
self.Value = self.Values[1]
end
self:Render()
end
function Dropdown:WatchPlayers()
if self.SpecialType ~= "Player" then
return
end
local function Refresh()
self:SetValues(Util.PlayerNames())
end
Util.Connect(Players.PlayerAdded, Refresh)
Util.Connect(Players.PlayerRemoving, function()
task.defer(Refresh)
end)
end
function Dropdown:IsSelected(value)
if self.Multi then
return self.Value[value] == true
end
return self.Value == value
end
function Dropdown:GetActiveValues()
local active = {}
if not self.Multi then
return self.Value ~= nil and { self.Value } or active
end
for _, value in ipairs(self.Values) do
if self.Value[value] then
table.insert(active, value)
end
end
return active
end
function Dropdown.FormatValue(entry)
if type(entry) == "table" then
if entry.EN or entry.TH then
return Lang.Resolve(entry)
end
return Lang.Resolve(entry.Text or entry.Label or entry.Value or "")
end
return tostring(entry or "")
end
function Dropdown:Render()
local active = self:GetActiveValues()
local labels = {}
for _, entry in ipairs(active) do
table.insert(labels, tostring(Dropdown.FormatValue(entry)))
end
local text = #labels > 0 and table.concat(labels, ", ") or Lang.Resolve(self.Placeholder or Lang.Strings.None)
self.Display.Text = text
Theme.Bind(self.Display, { TextColor3 = #labels > 0 and "Text" or "Muted" })
if self.Thumb then
self.Thumb.Image = self.Images[self.Value] or ""
local tint = self.Colors and self.Colors[self.Value]
if tint then self.ThumbStroke.Color = tint end
end
end
function Dropdown:SetImages(images, colors)
self.Images = images
self.Colors = colors
self:EnsureThumb()
self:Render()
end
function Dropdown:EnsureThumb()
if self.Thumb or not self.Images or self.Multi then
return
end
local size = Util.Metric("Box") - 10
self.Thumb, self.ThumbStroke = Draw.Thumb(self.Field, nil, nil, size)
self.Display.Position = UDim2.fromOffset(size + 12, 0)
self.Display.Size = UDim2.new(1, -(size + 46), 1, 0)
end
function Dropdown:SetValue(value)
if self.Multi then
self.Value = Util.ToSet(value)
else
self.Value = value
end
self:Render()
self:Fire()
end
function Dropdown:SetValues(values)
self.Values = values or {}
if not self.Multi and self.Value ~= nil and not table.find(self.Values, self.Value) and not self.AllowNull then
self.Value = self.Values[1]
end
self:Render()
if self.List then
self.List.Rebuild(self.Values)
end
end
function Dropdown:Serialize()
if self.Multi then
return self:GetActiveValues()
end
return self.Value
end
function Dropdown:Pick(value)
if self.Multi then
self.Value[value] = not self.Value[value] or nil
elseif self.Value == value and self.AllowNull then
self.Value = nil
else
self.Value = value
end
self:Render()
self:Fire()
end
function Dropdown:Open()
Anim.Tween(self.Chevron, { Rotation = 180 }, Config.Tween.Normal)
self.List = Popup.List({
Anchor = self.Field,
Values = self.Values,
Multi = self.Multi,
Images = self.Images,
Colors = self.Colors,
Search = self.Searchable ~= false and (self.Searchable or #self.Values > Config.Dropdown.SearchThreshold),
IsSelected = function(value)
return self:IsSelected(value)
end,
OnPick = function(value)
self:Pick(value)
return not self.Multi
end,
OnClose = function()
self.List = nil
Anim.Tween(self.Chevron, { Rotation = 0 }, Config.Tween.Normal)
end,
})
end
function Container:AddInput(idx, info)
idx, info = Widget.Normalize(idx, info)
local input = setmetatable({ Type = "Input", Value = tostring(info.Default or ""), Numeric = info.Numeric, Finished = info.Finished, MaxLength = info.MaxLength, Container = self }, Input)
input.Row = Row.Stack(self, info, Util.Metric("Box"))
input.Item = input.Row.Item
local field = Draw.Field(input.Row.Control, "Frame")
input.Box = Draw.Text({
ClassName = "TextBox",
Text = input.Value,
ClearTextOnFocus = info.ClearTextOnFocus == true,
Position = UDim2.fromOffset(10, 0),
Size = UDim2.new(1, -20, 1, 0),
TextTruncate = Enum.TextTruncate.AtEnd,
Parent = field,
}, "Body", Util.TextSize("Label"), "Text")
Lang.Bind(input.Box, info.Placeholder or "", "PlaceholderText")
Theme.Bind(input.Box, { PlaceholderColor3 = "Muted" })
input:Bind(field)
Widget.Register(input, idx, info)
return input
end
function Input:Bind(field)
local stroke = field:FindFirstChildOfClass("UIStroke")
self.Box.Focused:Connect(function()
Anim.Tween(stroke, { Color = Theme.Colors.Blue }, Config.Tween.Fast)
end)
self.Box:GetPropertyChangedSignal("Text"):Connect(function()
local clean = self:Sanitize(self.Box.Text)
if clean ~= self.Box.Text then
self.Box.Text = clean
return
end
if not self.Finished then
self:Commit(clean)
end
end)
self.Box.FocusLost:Connect(function()
Anim.Tween(stroke, { Color = Theme.Colors.Outline }, Config.Tween.Fast)
self:Commit(self.Box.Text)
end)
end
function Input:Sanitize(text)
if self.Numeric then
text = text:gsub("[^%d%.%-]", "")
end
if self.MaxLength and #text > self.MaxLength then
text = text:sub(1, self.MaxLength)
end
return text
end
function Input:Commit(text)
if text == self.Value then
return
end
self.Value = text
self:Fire()
end
function Input:SetValue(text)
text = self:Sanitize(tostring(text or ""))
self.Box.Text = text
self:Commit(text)
end
Button.Styles = {
Default = { Face = "Element", Shade = "Track", Text = "Text" },
Primary = { Face = "Blue", Shade = "BlueDark", Text = "White" },
Success = { Face = "Good", Shade = "GoodDark", Text = "White" },
Danger = { Face = "Danger", Shade = "DangerDark", Text = "White" },
Warning = { Face = "Coin", Shade = "CoinDark", Text = "Ink" },
}
function Container:AddButton(info, callback)
return Button.Create(self, info, callback)
end
function Button.Create(container, info, callback, after)
if type(info) ~= "table" then
info = { Text = info, Func = callback }
end
local style = Button.Styles[info.Style or "Default"] or Button.Styles.Default
local button = setmetatable({ Container = container, Info = info, Func = info.Func or info.Callback or callback, Style = style, Armed = false }, Button)
table.insert(Library.Buttons, button)
local holder, face, _, depth = Draw.Block(nil, style.Face, style.Shade, 10, 4)
face.ClipsDescendants = true
button.Holder, button.Face, button.Depth = holder, face, depth
local content = Draw.New("Frame", { BackgroundTransparency = 1, Size = UDim2.fromScale(1, 1), ZIndex = 3, Parent = face })
Draw.List(content, 6, true, Enum.HorizontalAlignment.Center, Enum.VerticalAlignment.Center)
Draw.Padding(content, 0, 8, 0, 8)
local iconExtra = 0
if info.Icon then
local icon = Icons.Create(content, info.Icon, 16, style.Text, info.Text)
icon.LayoutOrder = 1
iconExtra = 22
end
button.Label = Draw.Text({ LayoutOrder = 2, AutomaticSize = Enum.AutomaticSize.X, Size = UDim2.fromScale(0, 1), TextXAlignment = Enum.TextXAlignment.Center, TextTruncate = Enum.TextTruncate.AtEnd, Parent = content }, "Body", Util.TextSize("Button"), style.Text, info.Text or info.Title or "")
button.Hit = Draw.New("TextButton", { Text = "", BackgroundTransparency = 1, Size = UDim2.fromScale(1, 1), ZIndex = 5, Parent = holder })
button:BindPress()
button.Group = { button }
button.Item = container:Add(holder, {
Height = Util.Metric("Box") + depth,
After = after,
Search = Lang.SearchText(info.Text or info.Title),
AutoWidth = function()
return Layout.Measure(button.Label.Text, button.Label.TextSize, "Body", 1000).X + iconExtra + 36
end,
})
if info.Tooltip then
Tooltip.Attach(holder, info.Tooltip)
end
return button
end
function Button:BindPress()
local face, hit = self.Face, self.Hit
local faceColor = function()
return Theme.Colors[self.Style.Face]
end
hit.MouseEnter:Connect(function()
if not State.Touch then
Anim.Tween(face, { BackgroundColor3 = Util.Lighten(faceColor(), 0.14) }, Config.Tween.Fast)
end
end)
hit.MouseLeave:Connect(function()
Anim.Tween(face, { BackgroundColor3 = faceColor() }, Config.Tween.Fast)
Motion.Spring(face, "Position", UDim2.new(), "Fast")
end)
hit.MouseButton1Down:Connect(function()
Motion.Spring(face, "Position", UDim2.fromOffset(0, self.Depth - 1), "Fast")
end)
hit.MouseButton1Up:Connect(function()
Motion.Spring(face, "Position", UDim2.new(), "Fast", { Damping = 0.56 })
end)
hit.Activated:Connect(function()
Fx.Ripple(face, nil, "White")
self:Click()
end)
end
function Button:Click()
if self.Info.DoubleClick and not self.Armed then
self.Armed = true
local token = {}
self.ArmToken = token
Lang.Bind(self.Label, Lang.Strings.Confirm)
Anim.Shake(self.Face)
task.delay(Config.ConfirmWindow, function()
if self.ArmToken == token then
self:Disarm()
end
end)
return
end
self:Disarm()
Util.Try(self.Func)
end
function Button:Disarm()
if not self.Armed then
return
end
self.Armed = false
Lang.Bind(self.Label, self.Info.Text or "")
end
function Button:AddButton(info, callback)
local last = self.Group[#self.Group]
self.Container:SameLine()
local sibling = Button.Create(self.Container, info, callback, last.Item)
sibling.Group = self.Group
table.insert(self.Group, sibling)
local count = #self.Group
for index, member in ipairs(self.Group) do
member.Item.Width = index < count and 1 / count or nil
member.Item.Fill = true
end
self.Container:MarkDirty()
return sibling
end
function Button:SetText(text)
self.Info.Text = text
Lang.Bind(self.Label, text)
end
function Button:SetVisible(visible)
self.Item.Hidden = not visible
self.Container:MarkDirty()
end
function Container:AddLabel(text, wrap)
local info = type(text) == "table" and text.Text and text or { Text = text }
local label = setmetatable({ Type = "Label", Container = self, Wrap = wrap }, Label)
label.Row = Row.New(self, info, { TitleFont = "Desc", TitleSize = Util.TextSize("Label") - 1, TitleToken = "SubText" })
label.Row.MinHeight = Row.LineHeight()
label.Item = label.Row.Item
return label
end
function Label:SetText(text)
self.Row:SetTitle(text)
end
Label.SetVisible = Widget.SetVisible
Label.AddColorPicker = Widget.AddColorPicker
Label.AddKeyPicker = Widget.AddKeyPicker
function Container:AddParagraph(info)
local paragraph = setmetatable({ Type = "Label", Container = self }, Label)
paragraph.Row = Row.New(self, { Text = info.Title, Description = info.Content or info.Description or "" })
paragraph.Item = paragraph.Row.Item
function paragraph.SetContent(_, text)
Lang.Bind(paragraph.Row.Desc, text)
self:MarkDirty()
end
function paragraph.SetTitle(_, text)
paragraph.Row:SetTitle(text)
end
return paragraph
end
function Container:AddDivider()
local holder = Draw.New("Frame", { Name = "Divider", BackgroundTransparency = 1 })
local line = Draw.Box("Frame", { AnchorPoint = Vector2.new(0, 0.5), Position = UDim2.fromScale(0, 0.5), Size = UDim2.new(1, 0, 0, 2) }, "Track", nil, 1)
line.Parent = holder
self:Add(holder, { Height = 10 })
return self
end
Container.Separator = Container.AddDivider
function Container:AddSeparatorText(text)
local holder = Draw.New("Frame", { Name = "SeparatorText", BackgroundTransparency = 1 })
local caption = Draw.Text({ TextXAlignment = Enum.TextXAlignment.Center, Parent = holder }, "Body", Util.TextSize("Desc"), "Muted", text)
local left = Draw.Box("Frame", { AnchorPoint = Vector2.new(0, 0.5), Position = UDim2.fromScale(0, 0.5), Parent = holder }, "Track", nil, 1)
local right = Draw.Box("Frame", { AnchorPoint = Vector2.new(1, 0.5), Position = UDim2.fromScale(1, 0.5), Parent = holder }, "Track", nil, 1)
self:Add(holder, {
Height = Row.LineHeight("Desc"),
OnLayout = function(width, height)
local textWidth = Layout.Measure(caption.Text, caption.TextSize, "Body", width).X + 12
left.Size = UDim2.fromOffset(12, 2)
caption.Position = UDim2.fromOffset(14, 0)
caption.Size = UDim2.fromOffset(textWidth, height)
right.Size = UDim2.fromOffset(math.max(0, width - textWidth - 16), 2)
end,
})
return self
end
function Draw.Thumb(parent, image, tint, size, position)
local tile = Draw.Box("ImageLabel", {
Name = "Thumb",
Image = image or "",
ScaleType = Enum.ScaleType.Fit,
AnchorPoint = Vector2.new(0, 0.5),
Position = position or UDim2.new(0, 4, 0.5, 0),
Size = UDim2.fromOffset(size, size),
Parent = parent,
}, "Element", nil, 6)
Draw.Padding(tile, 2)
local stroke
if tint then
stroke = Draw.New("UIStroke", { Thickness = 2, Color = tint, ApplyStrokeMode = Enum.ApplyStrokeMode.Border, LineJoinMode = Enum.LineJoinMode.Round, Parent = tile })
else
stroke = Draw.Stroke(tile, "Outline", 2, true)
end
return tile, stroke
end
function Selectable.Build(text, options)
options = options or {}
local textSpec = text
local iconSpec = options.Icon
if type(text) == "table" and not text.EN and not text.TH then
textSpec = text.Text or text.Label or text.Value or ""
iconSpec = iconSpec or text.Icon
end
local button = Draw.Box("TextButton", { Name = "Selectable", BackgroundTransparency = 1, ClipsDescendants = true }, "Hover", nil, 8)
local bar = Draw.Box("Frame", {
AnchorPoint = Vector2.new(0, 0.5),
Position = UDim2.new(0, 3, 0.5, 0),
Size = UDim2.fromOffset(3, 0),
Parent = button,
}, "Coin", nil, 2)
local inset = 12
if options.Image then
local size = Util.Metric("Item") - 6
Draw.Thumb(button, options.Image, options.Tint, size, UDim2.new(0, 8, 0.5, 0))
inset = size + 16
elseif iconSpec then
local icon = Icons.Create(button, iconSpec, 16, nil, textSpec)
icon.AnchorPoint = Vector2.new(0, 0.5)
icon.Position = UDim2.new(0, 10, 0.5, 0)
inset = 32
elseif options.Tint then
Draw.Box("Frame", { AnchorPoint = Vector2.new(0, 0.5), Position = UDim2.new(0, 8, 0.5, 0), Size = UDim2.new(0, 4, 1, -10), BackgroundColor3 = options.Tint, Parent = button }, nil, nil, 2)
inset = 18
end
local label = Draw.Text({ Position = UDim2.fromOffset(inset, 0), Size = UDim2.new(1, -(inset + 26), 1, 0), TextTruncate = Enum.TextTruncate.AtEnd, Parent = button }, "Body", Util.TextSize("Label"), "Text", textSpec)
local mark = Icons.Vector(button, "check", 15, "OnAccent")
mark.AnchorPoint = Vector2.new(1, 0.5)
mark.Position = UDim2.new(1, -8, 0.5, 0)
local markScale = Draw.New("UIScale", { Scale = 0, Parent = mark })
local parts = { Button = button, Label = label, Mark = mark, MarkScale = markScale, Bar = bar, Selected = false, Hovered = false }
function parts.Render(instant)
local duration = instant and 0 or Config.Tween.Fast
local fill = parts.Selected and Theme.Colors.Accent or Theme.Colors.Hover
local alpha = parts.Selected and 0 or (parts.Hovered and 0.45 or 1)
Anim.Tween(button, { BackgroundColor3 = fill, BackgroundTransparency = alpha }, duration)
Anim.Tween(label, { TextColor3 = Theme.Colors[parts.Selected and "OnAccent" or "Text"] }, duration)
if instant then
Motion.Set(markScale, "Scale", parts.Selected and 1 or 0)
else
Motion.Spring(markScale, "Scale", parts.Selected and 1 or 0, "Fast", { Damping = 0.6 })
end
local barHeight = parts.Selected and (Util.Metric("Item") - 10) or 0
if instant then
Motion.Set(bar, "Size", UDim2.fromOffset(3, barHeight))
else
Motion.Spring(bar, "Size", UDim2.fromOffset(3, barHeight), "Fast")
end
end
function parts.SetSelected(selected, instant)
parts.Selected = selected
parts.Render(instant)
end
if not State.Touch then
button.MouseEnter:Connect(function()
parts.Hovered = true
parts.Render()
end)
button.MouseLeave:Connect(function()
parts.Hovered = false
parts.Render()
end)
end
Theme.OnRender(button, function()
parts.Render(true)
end)
return parts
end
function Container:AddSelectable(idx, info)
idx, info = Widget.Normalize(idx, info)
local selectable = setmetatable({ Type = "Selectable", Value = info.Default == true or info.Selected == true, Container = self }, Selectable)
selectable.Parts = Selectable.Build(info.Text or "", info)
selectable.Item = self:Add(selectable.Parts.Button, { Height = Util.Metric("Item"), Search = Row.SearchText(info) })
selectable.Parts.SetSelected(selectable.Value, true)
selectable.Parts.Button.Activated:Connect(function()
selectable:SetValue(not selectable.Value)
end)
Widget.Register(selectable, idx, info)
return selectable
end
function Selectable:SetValue(value)
value = value == true
if value == self.Value then
return
end
self.Value = value
self.Parts.SetSelected(value)
self:Fire()
end
function Container:AddListBox(idx, info)
idx, info = Widget.Normalize(idx, info)
local rows = info.Height or 5
local itemHeight = Util.Metric("Item")
local listbox = setmetatable({ Type = "Dropdown", Multi = info.Multi == true, AllowNull = info.AllowNull ~= false, Values = info.Values or {}, Container = self, Entries = {} }, ListBox)
listbox.Value = listbox.Multi and Util.ToSet(info.Default) or info.Default
listbox.Row = Row.Stack(self, info, rows * (itemHeight + 2) + 10)
listbox.Item = listbox.Row.Item
local frame = Draw.Box("Frame", { Size = UDim2.fromScale(1, 1), Parent = listbox.Row.Control }, "Element", "Outline", 10, 2)
local scroll = Layout.ScrollFrame({ Size = UDim2.fromScale(1, 1), Parent = frame })
listbox.List = Container.New(scroll, { PadX = 4, PadY = 4, GapY = 2 })
listbox.List:SetParent(self)
listbox.Row.OnArranged = function(width)
listbox.List:SetWidth(width - Config.Page.ScrollBar - 4)
end
Widget.Register(listbox, idx, info)
listbox:Rebuild()
return listbox
end
function ListBox:Rebuild()
self.List:Clear()
table.clear(self.Entries)
for _, value in ipairs(self.Values) do
local parts = Selectable.Build(value, { Multi = self.Multi })
parts.SetSelected(Dropdown.IsSelected(self, value), true)
parts.Button.Activated:Connect(function()
Dropdown.Pick(self, value)
end)
self.Entries[value] = parts
self.List:Add(parts.Button, { Height = Util.Metric("Item") })
end
if #self.Values == 0 then
self.List:AddLabel(Lang.Strings.Empty)
end
end
function ListBox:Render()
for value, parts in pairs(self.Entries) do
parts.SetSelected(Dropdown.IsSelected(self, value))
end
end
ListBox.IsSelected = Dropdown.IsSelected
ListBox.GetActiveValues = Dropdown.GetActiveValues
ListBox.Serialize = Dropdown.Serialize
function ListBox:SetValue(value)
self.Value = self.Multi and Util.ToSet(value) or value
self:Render()
self:Fire()
end
function ListBox:SetValues(values)
self.Values = values or {}
if not self.Multi and self.Value ~= nil and not table.find(self.Values, self.Value) then
self.Value = nil
end
self:Rebuild()
end
function Container:AddProgressBar(idx, info)
idx, info = Widget.Normalize(idx, info)
local progress = setmetatable({ Type = "Progress", Value = 0, Max = info.Max or 1, Suffix = info.Suffix, Container = self }, Progress)
progress.Row = Row.Stack(self, info, 16)
progress.Item = progress.Row.Item
local bar = Draw.Box("Frame", { Size = UDim2.fromScale(1, 1), Parent = progress.Row.Control }, "Track", "Outline", UDim.new(1, 0), 2)
progress.Fill = Draw.Box("Frame", { Size = UDim2.fromScale(0, 1), Parent = bar }, "Good", nil, UDim.new(1, 0))
local shine = Draw.Box("Frame", { Position = UDim2.new(0, 4, 0, 2), Size = UDim2.new(1, -8, 0, 3), BackgroundTransparency = 0.55, Parent = progress.Fill }, "White", nil, UDim.new(1, 0))
shine.ZIndex = 2
progress:SetValue(info.Default or info.Value or 0)
if idx ~= nil then
Library.Options[idx] = progress
progress.NoSave = true
end
return progress
end
function Progress:SetValue(value)
self.Value = math.clamp(tonumber(value) or 0, 0, self.Max)
local fraction = self.Max > 0 and self.Value / self.Max or 0
Anim.Tween(self.Fill, { Size = UDim2.fromScale(fraction, 1) }, Config.Tween.Slide)
local text = self.Suffix and (tostring(Util.Round(self.Value, 2)) .. self.Suffix) or (math.floor(fraction * 100 + 0.5) .. "%")
local resized = #text ~= #self.Row.Aside.Text
self.Row.Aside.Text = text
if resized then
self.Container:MarkDirty()
end
end
function Progress:SetText(text)
self.Row:SetTitle(text)
end
Progress.SetVisible = Widget.SetVisible
function Container:AddChild(id, info)
if Gui and Gui.BeginChild then
return Gui.BeginChild(self, id, info)
end
if type(id) == "table" and info == nil then
info, id = id, nil
end
info = info or {}
local holder = Draw.New("Frame", { Name = tostring(id or "Child"), BackgroundTransparency = 1 })
local frame = Draw.Box("Frame", { Size = UDim2.fromScale(1, 1), Parent = holder }, info.Border ~= false and "Element" or nil, info.Border ~= false and "Track" or nil, 10, 2)
if info.Border ~= false then
frame.BackgroundTransparency = 0.4
end
local host = info.Height and Layout.ScrollFrame({ Size = UDim2.fromScale(1, 1), Parent = frame }) or Draw.New("Frame", { BackgroundTransparency = 1, Size = UDim2.fromScale(1, 1), Parent = frame })
local child = Container.New(host, { PadX = 8, PadY = 8 })
local inset = info.Height and Config.Page.ScrollBar or 0
self:Add(holder, {
Height = function()
return info.Height or child.ContentHeight
end,
Child = child,
ChildInset = inset,
})
return child
end
Container.BeginChild = Container.AddChild
function Container:AddKeybind(idx, info)
idx, info = Widget.Normalize(idx, info)
local row = Row.New(self, info)
local picker = KeyPicker.New(row, idx, info, nil)
picker.Row, picker.Item, picker.Container = row, row.Item, self
return picker
end
function Container:AddColorPicker(idx, info)
idx, info = Widget.Normalize(idx, info)
local row = Row.New(self, info)
local picker = ColorPicker.New(row, idx, info)
picker.Row, picker.Item, picker.Container = row, row.Item, self
return picker
end
function Container:AddStepper(idx, spec)
idx, spec = Widget.Normalize(idx, spec)
local stepVal = spec.Step or 1
local stepper = setmetatable({
Type = "Stepper",
Min = spec.Min or -1e9,
Max = spec.Max or 1e9,
Step = stepVal,
Rounding = spec.Rounding or (math.floor(stepVal) ~= stepVal and 2 or 0),
Container = self,
}, Stepper)
stepper.Value = Util.Round(math.clamp(tonumber(spec.Default) or math.max(0, stepper.Min), stepper.Min, stepper.Max), stepper.Rounding)
stepper.Row = Row.New(self, spec)
stepper.Item = stepper.Row.Item
stepper:Build()
Widget.Register(stepper, idx, spec)
stepper:Render(true)
return stepper
end
function Stepper:Build()
local height = Util.Metric("Box") - 4
local box = Draw.Box("Frame", { Size = UDim2.fromOffset(108, height) }, "Element", "Outline", 8, 2)
local minusBtn = Draw.Box("TextButton", { Position = UDim2.fromOffset(2, 2), Size = UDim2.fromOffset(height - 4, height - 4), Parent = box }, "Hover", nil, 6)
Icons.Vector(minusBtn, "minus", 14, "Text").Position = UDim2.fromScale(0.18, 0.18)
local plusBtn = Draw.Box("TextButton", { AnchorPoint = Vector2.new(1, 0), Position = UDim2.new(1, -2, 0, 2), Size = UDim2.fromOffset(height - 4, height - 4), Parent = box }, "Accent", nil, 6)
Icons.Vector(plusBtn, "plus", 14, "OnAccent").Position = UDim2.fromScale(0.18, 0.18)
self.Readout = Draw.Text({
Position = UDim2.fromOffset(height, 0),
Size = UDim2.new(1, -height * 2, 1, 0),
TextXAlignment = Enum.TextXAlignment.Center,
Parent = box,
}, "Strong", Util.TextSize("Label"), "Text", tostring(self.Value))
minusBtn.Activated:Connect(function()
Fx.Squash(minusBtn, 1.8)
self:SetValue(self.Value - self.Step)
end)
plusBtn.Activated:Connect(function()
Fx.Squash(plusBtn, 1.8)
self:SetValue(self.Value + self.Step)
end)
self.Row:AddRight(box, 108)
end
function Stepper:Render(instant)
local formatted = self.Rounding > 0 and string.format("%." .. self.Rounding .. "f", self.Value) or tostring(math.floor(self.Value + 0.5))
if instant or not self.PrevValue then
self.Readout.Text = formatted
else
Fx.CountUp(self, self.PrevValue, self.Value, 0.18, function(cur)
local num = Util.Round(cur, self.Rounding)
self.Readout.Text = self.Rounding > 0 and string.format("%." .. self.Rounding .. "f", num) or tostring(math.floor(num + 0.5))
end)
end
self.PrevValue = self.Value
end
function Stepper:SetValue(nextVal)
local num = tonumber(nextVal)
if not num then
return
end
num = Util.Round(math.clamp(num, self.Min, self.Max), self.Rounding)
if num == self.Value then
return
end
self.Value = num
self:Render(false)
self:Fire()
end
function Container:AddRangeSlider(idx, spec)
idx, spec = Widget.Normalize(idx, spec)
local knobSize = Util.Metric("Knob")
local minBound, maxBound = spec.Min or 0, spec.Max or 100
local defTable = type(spec.Default) == "table" and spec.Default or { minBound, maxBound }
local range = setmetatable({
Type = "RangeSlider",
Min = minBound,
Max = maxBound,
Rounding = spec.Rounding or 0,
Suffix = spec.Suffix or "",
Container = self,
}, RangeSlider)
local low = Util.Round(math.clamp(tonumber(defTable[1]) or minBound, minBound, maxBound), range.Rounding)
local high = Util.Round(math.clamp(tonumber(defTable[2]) or maxBound, low, maxBound), range.Rounding)
range.Value = { low, high }
range.Row = Row.Stack(self, spec, knobSize + 4)
range.Item = range.Row.Item
range:Build(knobSize)
Widget.Register(range, idx, spec)
range:Render(false)
return range
end
function RangeSlider:Build(knobSize)
local control = self.Row.Control
local trackHeight = Util.Metric("Track")
self.Track = Draw.Box("Frame", {
AnchorPoint = Vector2.new(0, 0.5),
Position = UDim2.new(0, knobSize / 2, 0.5, 0),
Size = UDim2.new(1, -knobSize, 0, trackHeight),
Parent = control,
}, "Track", "Outline", UDim.new(1, 0), 2)
self.Fill = Draw.Box("Frame", { Size = UDim2.fromScale(1, 1), Parent = self.Track }, "Accent", nil, UDim.new(1, 0))
self.KnobLow = Draw.Box("Frame", { AnchorPoint = Vector2.new(0.5, 0.5), Size = UDim2.fromOffset(knobSize, knobSize), Position = UDim2.fromScale(0, 0.5), ZIndex = 3, Parent = self.Track }, "Coin", "Outline", UDim.new(1, 0), 2)
self.KnobHigh = Draw.Box("Frame", { AnchorPoint = Vector2.new(0.5, 0.5), Size = UDim2.fromOffset(knobSize, knobSize), Position = UDim2.fromScale(1, 0.5), ZIndex = 4, Parent = self.Track }, "Coin", "Outline", UDim.new(1, 0), 2)
local hit = Draw.New("TextButton", { Text = "", BackgroundTransparency = 1, Size = UDim2.new(1, 0, 1, 6), Position = UDim2.fromOffset(0, -3), ZIndex = 5, Parent = control })
hit.InputBegan:Connect(function(input)
if Util.IsPointer(input) then
self:BeginDrag(input)
end
end)
end
function RangeSlider:BeginDrag(input)
local left, width = self.Track.AbsolutePosition.X, math.max(1, self.Track.AbsoluteSize.X)
local frac = math.clamp((input.Position.X - left) / width, 0, 1)
local pickedVal = self.Min + (self.Max - self.Min) * frac
local pickHigh = math.abs(pickedVal - self.Value[2]) < math.abs(pickedVal - self.Value[1])
local activeKnob = pickHigh and self.KnobHigh or self.KnobLow
Fx.Squash(activeKnob, 1.9)
local function UpdateFromX(screenX)
local ratio = math.clamp((screenX - self.Track.AbsolutePosition.X) / math.max(1, self.Track.AbsoluteSize.X), 0, 1)
local raw = self.Min + (self.Max - self.Min) * ratio
if pickHigh then
self:SetValue({ self.Value[1], math.max(self.Value[1], raw) })
else
self:SetValue({ math.min(self.Value[2], raw), self.Value[2] })
end
end
UpdateFromX(input.Position.X)
State.Drag = {
Move = function(move)
UpdateFromX(move.Position.X)
end,
Stop = function()
Fx.Squash(activeKnob, 1.4)
end,
}
end
function RangeSlider:Render(animated)
local span = math.max(1e-6, self.Max - self.Min)
local lowFrac = math.clamp((self.Value[1] - self.Min) / span, 0, 1)
local highFrac = math.clamp((self.Value[2] - self.Min) / span, lowFrac, 1)
if animated then
Motion.Spring(self.Fill, "Position", UDim2.fromScale(lowFrac, 0), "Fast")
Motion.Spring(self.Fill, "Size", UDim2.fromScale(highFrac - lowFrac, 1), "Fast")
Motion.Spring(self.KnobLow, "Position", UDim2.fromScale(lowFrac, 0.5), "Fast")
Motion.Spring(self.KnobHigh, "Position", UDim2.fromScale(highFrac, 0.5), "Fast")
else
Motion.Set(self.Fill, "Position", UDim2.fromScale(lowFrac, 0))
Motion.Set(self.Fill, "Size", UDim2.fromScale(highFrac - lowFrac, 1))
Motion.Set(self.KnobLow, "Position", UDim2.fromScale(lowFrac, 0.5))
Motion.Set(self.KnobHigh, "Position", UDim2.fromScale(highFrac, 0.5))
end
local suf = Lang.Resolve(self.Suffix or "")
self.Row.Aside.Text = tostring(self.Value[1]) .. suf .. " – " .. tostring(self.Value[2]) .. suf
end
function RangeSlider:SetValue(pair)
if type(pair) ~= "table" then
return
end
local low = Util.Round(math.clamp(tonumber(pair[1]) or self.Min, self.Min, self.Max), self.Rounding)
local high = Util.Round(math.clamp(tonumber(pair[2]) or self.Max, low, self.Max), self.Rounding)
if low == self.Value[1] and high == self.Value[2] then
return
end
self.Value = { low, high }
self:Render(true)
self:Fire()
end
function Container:AddSegmented(idx, spec)
idx, spec = Widget.Normalize(idx, spec)
local optionsList = spec.Values or spec.Options or {}
local seg = setmetatable({
Type = "Segmented",
Values = optionsList,
Value = spec.Default or optionsList[1],
Buttons = {},
Container = self,
}, Segmented)
seg.Row = (spec.Text or spec.Title) and Row.Stack(self, spec, Util.Metric("Box")) or nil
local host = seg.Row and seg.Row.Control or Draw.New("Frame", { BackgroundTransparency = 1 })
if not seg.Row then
seg.Item = self:Add(host, { Height = Util.Metric("Box"), Search = Lang.SearchText(spec.Text) })
else
seg.Item = seg.Row.Item
end
seg:Build(host)
Widget.Register(seg, idx, spec)
seg:Render(true)
return seg
end
function Segmented:Build(host)
local bar = Draw.Box("Frame", { Size = UDim2.fromScale(1, 1), Parent = host }, "Element", "Outline", 8, 2)
Draw.Padding(bar, 3, 3, 3, 3)
local count = math.max(1, #self.Values)
self.Thumb = Draw.Box("Frame", {
Size = UDim2.fromScale(1 / count, 1),
ZIndex = 2,
Parent = bar,
}, "Accent", nil, 6)
for index, optionVal in ipairs(self.Values) do
local btn = Draw.Text({
ClassName = "TextButton",
Position = UDim2.fromScale((index - 1) / count, 0),
Size = UDim2.fromScale(1 / count, 1),
TextXAlignment = Enum.TextXAlignment.Center,
ZIndex = 3,
Parent = bar,
}, "Strong", Util.TextSize("Label") - 1, "Text", Dropdown.FormatValue(optionVal))
btn.AutoButtonColor = false
btn.Activated:Connect(function()
self:SetValue(optionVal)
end)
self.Buttons[index] = { Button = btn, Value = optionVal }
end
end
function Segmented:Render(instant)
local count = math.max(1, #self.Values)
local activeIdx = 1
for index, entry in ipairs(self.Buttons) do
local isSel = entry.Value == self.Value
if isSel then
activeIdx = index
end
Theme.Bind(entry.Button, { TextColor3 = isSel and "OnAccent" or "SubText" })
end
local targetPos = UDim2.fromScale((activeIdx - 1) / count, 0)
local targetSize = UDim2.fromScale(1 / count, 1)
if instant then
Motion.Set(self.Thumb, "Position", targetPos)
Motion.Set(self.Thumb, "Size", targetSize)
else
Motion.Spring(self.Thumb, "Position", targetPos, "Fast", { Damping = 0.68 })
Motion.Spring(self.Thumb, "Size", targetSize, "Fast")
end
end
function Segmented:SetValue(nextVal)
if nextVal == self.Value then
return
end
self.Value = nextVal
self:Render(false)
self:Fire()
end
function Container:AddStat(idx, spec)
idx, spec = Widget.Normalize(idx, spec)
local card = Draw.Box("Frame", { Name = "StatCard" }, "Element", "Outline", 10, 2)
Fx.Spotlight(card)
local badge = Icons.Badge(card, spec.Icon, 30, spec.Color or "Accent", spec.Title or spec.Text)
badge.AnchorPoint = Vector2.new(0, 0.5)
badge.Position = UDim2.new(0, 10, 0.5, 0)
local titleLabel = Draw.Text({
Position = UDim2.fromOffset(48, 6),
Size = UDim2.new(1, -56, 0, 16),
TextTruncate = Enum.TextTruncate.AtEnd,
Parent = card,
}, "Desc", Util.TextSize("Desc"), "SubText", spec.Title or spec.Text or "Stat")
local valLabel = Draw.Text({
Position = UDim2.fromOffset(48, 22),
Size = UDim2.new(1, -56, 0, 22),
TextTruncate = Enum.TextTruncate.AtEnd,
Parent = card,
}, "Display", Util.TextSize("Group") + 2, spec.Color or "Text", tostring(spec.Value or spec.Default or "0"))
local stat = setmetatable({
Type = "Stat",
Frame = card,
TitleLabel = titleLabel,
ValueLabel = valLabel,
Prefix = spec.Prefix or "",
Suffix = spec.Suffix or "",
Value = spec.Value or spec.Default or 0,
Container = self,
}, StatWidget)
stat.Item = self:Add(card, { Width = spec.Width, Height = 50, Search = Row.SearchText(spec) })
Widget.Register(stat, idx, spec)
return stat
end
function StatWidget:SetValue(nextVal)
local prevNum = tonumber(self.Value)
local nextNum = tonumber(nextVal)
self.Value = nextVal
local pre = Lang.Resolve(self.Prefix or "")
local suf = Lang.Resolve(self.Suffix or "")
if prevNum and nextNum then
Fx.CountUp(self, prevNum, nextNum, 0.25, function(cur)
self.ValueLabel.Text = pre .. tostring(math.floor(cur + 0.5)) .. suf
end)
else
self.ValueLabel.Text = pre .. tostring(nextVal) .. suf
end
end
function Container:AddStatus(idx, spec)
idx, spec = Widget.Normalize(idx, spec)
local row = Row.New(self, spec)
local pill, label = Gui.Badge(row.Right, spec.Status or spec.Default or "Ready", spec.Color or "Good", true)
row:AddRight(pill.Frame, pill.Width)
local status = setmetatable({
Type = "Status",
Row = row,
Item = row.Item,
Badge = pill,
Label = label,
Value = spec.Status or spec.Default or "Ready",
Container = self,
}, StatusWidget)
Widget.Register(status, idx, spec)
return status
end
function StatusWidget:SetValue(nextText, colorToken)
self.Value = nextText
self.Badge:SetText(nextText)
if colorToken then
self.Badge:SetColor(colorToken)
end
end
function Container:AddTable(idx, spec)
idx, spec = Widget.Normalize(idx, spec)
local headers = spec.Headers or spec.Columns or {}
local rows = spec.Rows or {}
local holder = Draw.Box("Frame", { Name = "Table" }, "Element", "Outline", 10, 2)
local inner = Container.New(holder, { PadX = 8, PadY = 6, GapY = 4 })
inner:SetParent(self)
local tbl = setmetatable({
Type = "Table",
Headers = headers,
Rows = rows,
Inner = inner,
Container = self,
}, TableWidget)
tbl.Item = self:Add(holder, {
Height = function()
return math.max(36, inner.ContentHeight)
end,
Child = inner,
Search = Row.SearchText(spec),
})
tbl:Rebuild()
return tbl
end
function TableWidget:Rebuild()
self.Inner:Clear()
local colCount = math.max(1, #self.Headers)
if #self.Headers > 0 then
local headRow = Draw.Box("Frame", { BackgroundTransparency = 0.35 }, "PanelHeader", nil, 6)
for colIdx, hText in ipairs(self.Headers) do
Draw.Text({
Position = UDim2.new((colIdx - 1) / colCount, 6, 0, 0),
Size = UDim2.new(1 / colCount, -8, 1, 0),
TextTruncate = Enum.TextTruncate.AtEnd,
Parent = headRow,
}, "Strong", Util.TextSize("Desc"), "Accent", hText)
end
self.Inner:Add(headRow, { Height = 24 })
end
for _, cells in ipairs(self.Rows) do
local line = Draw.New("Frame", { BackgroundTransparency = 1 })
for colIdx = 1, colCount do
Draw.Text({
Position = UDim2.new((colIdx - 1) / colCount, 6, 0, 0),
Size = UDim2.new(1 / colCount, -8, 1, 0),
TextTruncate = Enum.TextTruncate.AtEnd,
Parent = line,
}, "Body", Util.TextSize("Desc"), colIdx == 1 and "Text" or "SubText", tostring(cells[colIdx] or ""))
end
self.Inner:Add(line, { Height = 22 })
end
self.Container:MarkDirty()
end
function TableWidget:SetRows(nextRows)
self.Rows = nextRows or {}
self:Rebuild()
end
Container.Toggle = Container.AddToggle
Container.Checkbox = Container.AddCheckbox
Container.Slider = Container.AddSlider
Container.Dropdown = Container.AddDropdown
Container.Input = Container.AddInput
Container.Button = Container.AddButton
Container.Keybind = Container.AddKeybind
Container.Colorpicker = Container.AddColorPicker
Container.Label = Container.AddLabel
Container.Paragraph = Container.AddParagraph
Container.Divider = Container.AddDivider
Container.Section = Container.AddSeparatorText
Container.Stepper = Container.AddStepper
Container.RangeSlider = Container.AddRangeSlider
Container.Segmented = Container.AddSegmented
Container.Stat = Container.AddStat
Container.Status = Container.AddStatus
Container.Table = Container.AddTable
function Popup.Card(width, height)
local shadow = Config.Group.Shadow
local card = Draw.New("Frame", { Name = "Popup", BackgroundTransparency = 1, Size = UDim2.fromOffset(width + shadow, height + shadow), ZIndex = 2 })
Draw.Box("Frame", { Position = UDim2.fromOffset(shadow, shadow), Size = UDim2.new(1, -shadow, 1, -shadow), Parent = card }, "Shadow", nil, 12)
local face = Draw.Box("Frame", { Size = UDim2.new(1, -shadow, 1, -shadow), Parent = card }, "Panel", "Outline", 12, 3)
local scale = Draw.New("UIScale", { Parent = card })
return card, face, scale
end
function Popup.Open(card, scale, anchor, onClose)
Popup.Close()
card.Parent = State.Overlay
State.Overlay.Visible = true
Popup.Place(card, anchor)
scale.Scale = State.UserScale * 0.88
Motion.Spring(scale, "Scale", State.UserScale, "Fast", { Damping = 0.62 })
local lastPos = anchor and anchor.AbsolutePosition or Vector2.zero
local tracker
if anchor then
tracker = Util.Connect(RunService.RenderStepped, function()
if not State.Popup or State.Popup.Card ~= card then
return
end
if not anchor.Parent or (State.Window and (not State.Window.Visible or State.Window.Minimized)) then
Popup.Close()
return
end
local curPos = anchor.AbsolutePosition
if (curPos - lastPos).Magnitude > 0.5 then
lastPos = curPos
Popup.Place(card, anchor)
end
end)
end
State.Popup = { Card = card, Scale = scale, Anchor = anchor, Tracker = tracker, OnClose = onClose }
end
function Popup.Place(card, anchor)
if not anchor or not State.Gui then
return
end
local viewport = State.Gui.AbsoluteSize
local scaleFactor = math.max(0.5, State.UserScale or 1)
local width = card.Size.X.Offset * scaleFactor
local height = card.Size.Y.Offset * scaleFactor
local origin = anchor.AbsolutePosition - State.Gui.AbsolutePosition
local size = anchor.AbsoluteSize
local x = math.clamp(origin.X, 8, math.max(8, viewport.X - width - 8))
local y = origin.Y + size.Y + 6
if y + height > viewport.Y - 8 then
y = math.max(8, origin.Y - height - 6)
end
card.Position = UDim2.fromOffset(math.floor(x + 0.5), math.floor(y + 0.5))
end
function Popup.Close()
local popup = State.Popup
if not popup then
return
end
State.Popup = nil
if popup.Tracker then
popup.Tracker:Disconnect()
popup.Tracker = nil
end
Util.Try(popup.OnClose)
local shrink = Anim.Tween(popup.Scale, { Scale = State.UserScale * 0.9 }, 0.1, "In")
shrink.Completed:Once(function()
Theme.UnbindTree(popup.Card)
popup.Card:Destroy()
if not State.Popup then
State.Overlay.Visible = false
end
end)
end
function Popup.SearchBox(parent, width)
local field = Draw.Box("Frame", { Position = UDim2.fromOffset(6, 6), Size = UDim2.fromOffset(width, Util.Metric("Box")), Parent = parent }, "Element", "Outline", 8, 2)
local icon = Icons.Vector(field, "search", 14, "SubText")
icon.AnchorPoint = Vector2.new(0, 0.5)
icon.Position = UDim2.new(0, 8, 0.5, 0)
local box = Draw.Text({ ClassName = "TextBox", Text = "", ClearTextOnFocus = false, Position = UDim2.fromOffset(26, 0), Size = UDim2.new(1, -32, 1, 0), Parent = field }, "Body", Util.TextSize("Label"), "Text")
Lang.Bind(box, Lang.Strings.Search, "PlaceholderText")
Theme.Bind(box, { PlaceholderColor3 = "Muted" })
return box
end
function Popup.List(options)
local itemHeight = Util.Metric("Item")
local searchHeight = options.Search and (Util.Metric("Box") + 6) or 0
local minWidth = options.Images and Config.Dropdown.MinWidth + itemHeight + 60 or Config.Dropdown.MinWidth
local viewportW = State.Gui and State.Gui.AbsoluteSize.X or 800
local maxAllowedW = math.max(160, math.floor((viewportW - 24) / math.max(0.5, State.UserScale or 1)))
local rawAnchorW = options.Anchor.AbsoluteSize.X / math.max(0.5, State.UserScale or 1)
local width = math.clamp(math.floor(math.max(minWidth, rawAnchorW)), 140, maxAllowedW)
local listHeight = math.max(1, math.min(#options.Values, Config.Dropdown.MaxVisible)) * (itemHeight + 2) + 6
local card, face, scale = Popup.Card(width, listHeight + searchHeight + 12)
local scroll = Layout.ScrollFrame({ Position = UDim2.fromOffset(6, 6 + searchHeight), Size = UDim2.new(1, -12, 0, listHeight), Parent = face })
local list = Container.New(scroll, { PadX = 2, PadY = 2, GapY = 2 })
list:SetWidth(width - 12 - Config.Page.ScrollBar)
local entries = {}
local function Refresh()
for value, parts in pairs(entries) do
parts.SetSelected(options.IsSelected(value))
end
end
local function Build(values)
list:Clear()
table.clear(entries)
for _, value in ipairs(values) do
local labelText = Dropdown.FormatValue(value)
local parts = Selectable.Build(value, {
Multi = options.Multi,
Image = options.Images and options.Images[value],
Tint = options.Colors and options.Colors[value],
})
parts.SetSelected(options.IsSelected(value), true)
parts.Button.Activated:Connect(function()
local shouldClose = options.OnPick(value)
Refresh()
if shouldClose then
Popup.Close()
end
end)
entries[value] = parts
list:Add(parts.Button, { Height = itemHeight, Search = labelText:lower() })
end
if #values == 0 then
list:AddLabel(Lang.Strings.NoResults)
end
end
if options.Search then
local box = Popup.SearchBox(face, width - 12)
box:GetPropertyChangedSignal("Text"):Connect(function()
local query = box.Text:lower()
local changed = false
for _, entry in ipairs(list.Items) do
local filtered = query ~= "" and entry.Search ~= nil and not entry.Search:find(query, 1, true)
if entry.Filtered ~= filtered then
entry.Filtered = filtered
changed = true
end
end
if changed then
list:MarkDirty()
end
end)
end
Build(options.Values)
Layout.Flush()
Popup.Open(card, scale, options.Anchor, function()
list:Destroy()
Util.Try(options.OnClose)
end)
return { Rebuild = Build }
end
function Tooltip.Build()
local frame = Draw.Box("Frame", { Name = "Tooltip", Visible = false, ZIndex = Config.Layer.Tooltip, Parent = State.Gui }, "Panel", "Outline", 8, 2)
Tooltip.Label = Draw.Text({ TextWrapped = true, Position = UDim2.fromOffset(10, 6), Size = UDim2.new(1, -20, 1, -12), Parent = frame }, "Desc", Util.TextSize("Desc") + 1, "Text")
Tooltip.Scale = Draw.New("UIScale", { Parent = frame })
Tooltip.Frame = frame
end
function Tooltip.Attach(gui, text)
if State.Touch then
return
end
gui.MouseEnter:Connect(function()
local token = {}
Tooltip.Token = token
task.delay(Config.TooltipDelay, function()
if Tooltip.Token == token then
Tooltip.Show(text)
end
end)
end)
gui.MouseLeave:Connect(function()
Tooltip.Token = nil
Tooltip.Frame.Visible = false
end)
end
function Tooltip.Show(text)
if Library.Unloaded then
return
end
local resolved = Lang.Resolve(text)
local bounds = Layout.Measure(resolved, Tooltip.Label.TextSize, "Desc", 240)
Tooltip.Label.Text = resolved
Tooltip.Frame.Size = UDim2.fromOffset(bounds.X + 22, bounds.Y + 14)
Tooltip.Follow(UserInputService:GetMouseLocation())
Tooltip.Frame.Visible = true
Anim.Pop(Tooltip.Scale, 0.8)
end
function Tooltip.Follow(position)
if Tooltip.Frame and Tooltip.Frame.Visible then
Tooltip.Frame.Position = UDim2.fromOffset(position.X + 14, position.Y + 16)
end
end
function KeyPicker.New(row, idx, info, linked)
local picker = setmetatable({
Type = "KeyPicker",
Value = Util.KeyName(info.Default) or "None",
Mode = info.Mode or "Toggle",
Linked = linked,
Toggled = false,
Held = false,
Row = row,
Item = row.Item,
Container = row.Container,
ChangedCallback = info.ChangedCallback,
}, KeyPicker)
local height = Util.Metric("Row") - 8
picker.Button = Draw.Box("TextButton", { Size = UDim2.fromOffset(40, height) }, "Element", "Outline", 6, 2)
picker.Label = Draw.Text({ Size = UDim2.fromScale(1, 1), TextXAlignment = Enum.TextXAlignment.Center, Parent = picker.Button }, "Strong", Util.TextSize("Small") + 1, "Text")
row:AddRight(picker.Button, 40)
picker.Button.Activated:Connect(function()
if picker.LongPressed then
picker.LongPressed = false
return
end
picker:Listen()
end)
picker.Button.MouseButton2Click:Connect(function()
picker:OpenModeMenu()
end)
picker:BindLongPress()
Widget.Register(picker, idx, info)
table.insert(State.KeyPickers, picker)
picker:Render()
Lang.OnChange(picker, function()
picker:Render()
end)
return picker
end
function KeyPicker:BindLongPress()
self.Button.InputBegan:Connect(function(input)
if input.UserInputType ~= Enum.UserInputType.Touch then
return
end
local token = {}
self.PressToken = token
task.delay(0.5, function()
if self.PressToken == token then
self.LongPressed = true
self:OpenModeMenu()
end
end)
end)
self.Button.InputEnded:Connect(function()
self.PressToken = nil
end)
end
function KeyPicker:Render()
local text = State.Binding == self and "..." or Keybinds.Short(self.Value)
self.Label.Text = text
local width = math.max(34, Layout.Measure(text, self.Label.TextSize, "Strong", 300).X + 18)
if width ~= self.Button.Size.X.Offset then
self.Button.Size = UDim2.fromOffset(width, self.Button.Size.Y.Offset)
self.Button:SetAttribute("RightWidth", width)
self.Row:RecalcRight()
end
Theme.Bind(self.Button, { BackgroundColor3 = State.Binding == self and "Coin" or "Element" })
end
function KeyPicker:Listen()
local previous = State.Binding
State.Binding = self
if previous and previous ~= self then
previous:Render()
end
self:Render()
end
function KeyPicker:SetKey(name)
self.Value = name
self:Render()
Util.Try(self.ChangedCallback, name)
for _, callback in ipairs(self.Changed) do
Util.Try(callback, name)
end
end
function KeyPicker:Press(down)
if self.Mode == "Always" then
return
end
if self.Mode == "Press" then
self.Held = down
if not down then
return
end
Util.Try(self.Callback, true)
return
end
if self.Mode == "Hold" then
self.Held = down
if self.Linked then
self.Linked:SetValue(down)
end
Util.Try(self.Callback, down)
return
end
if not down then
return
end
self.Toggled = not self.Toggled
if self.Linked then
self.Linked:SetValue(not self.Linked.Value)
end
Util.Try(self.Callback, self:GetState())
end
function KeyPicker:GetState()
if self.Mode == "Always" then
return true
end
if self.Mode == "Press" then
return self.Held
end
if self.Mode == "Hold" then
return self.Held
end
return self.Linked and self.Linked.Value or self.Toggled
end
function KeyPicker:SetValue(value)
if type(value) == "table" then
self:SetMode(value.Mode or value[2] or self.Mode)
value = value.Key or value[1]
end
self:SetKey(Util.KeyName(value) or "None")
end
function KeyPicker:Serialize()
return { Key = self.Value, Mode = self.Mode }
end
function KeyPicker:Deserialize(saved)
self:SetValue(saved)
end
function KeyPicker:SetMode(mode)
self.Mode = mode
self.Held, self.Toggled = false, false
if self.Linked and mode == "Always" then
self.Linked:SetValue(true)
elseif self.Linked and mode == "Hold" then
self.Linked:SetValue(false)
end
end
function KeyPicker:OpenModeMenu()
Popup.List({
Anchor = self.Button,
Values = { "Toggle", "Hold", "Press", "Always" },
IsSelected = function(mode)
return self.Mode == mode
end,
OnPick = function(mode)
self:SetMode(mode)
return true
end,
})
end
Keybinds.ShortNames = {
LeftControl = "LCtrl", RightControl = "RCtrl", LeftShift = "LShift", RightShift = "RShift",
LeftAlt = "LAlt", RightAlt = "RAlt", Backquote = "`", Return = "Enter", Escape = "Esc",
CapsLock = "Caps", PageUp = "PgUp", PageDown = "PgDn", Insert = "Ins",
}
function Keybinds.Short(name)
return Keybinds.ShortNames[name] or name
end
function Keybinds.Capture(input)
local picker = State.Binding
if input.UserInputType == Enum.UserInputType.Touch then
State.Binding = nil
picker:Render()
return
end
local name = Util.InputName(input)
if not name then
return
end
State.Binding = nil
if name == "Escape" then
picker:Render()
return
end
if name == "Backspace" or name == "Delete" then
name = "None"
end
picker:SetKey(name)
end
function Keybinds.Dispatch(name, down)
for index = #State.KeyPickers, 1, -1 do
local picker = State.KeyPickers[index]
if not picker.Button.Parent then
table.remove(State.KeyPickers, index)
elseif picker.Value == name then
picker:Press(down)
end
end
end
function ColorPicker.New(row, idx, info)
local picker = setmetatable({ Type = "ColorPicker", Value = info.Default or Color3.new(1, 1, 1), Row = row, Item = row.Item, Container = row.Container }, ColorPicker)
picker.Hue, picker.Sat, picker.Vib = picker.Value:ToHSV()
picker.Swatch = Draw.Box("TextButton", { Size = UDim2.fromOffset(30, Util.Metric("Row") - 10) }, nil, "Outline", 6, 2)
picker.Swatch.BackgroundTransparency = 0
row:AddRight(picker.Swatch, 30)
picker.Swatch.Activated:Connect(function()
picker:Open()
end)
Widget.Register(picker, idx, info)
picker:Render()
return picker
end
function ColorPicker:Render()
self.Swatch.BackgroundColor3 = self.Value
local view = self.View
if not view then
return
end
view.Field.BackgroundColor3 = Color3.fromHSV(self.Hue, 1, 1)
view.Cursor.Position = UDim2.fromScale(self.Sat, 1 - self.Vib)
view.HueCursor.Position = UDim2.fromScale(0.5, self.Hue)
view.Preview.BackgroundColor3 = self.Value
if not view.Hex:IsFocused() then
view.Hex.Text = Util.Hex(self.Value)
end
end
function ColorPicker:Commit()
self.Value = Color3.fromHSV(self.Hue, self.Sat, self.Vib)
self:Render()
self:Fire()
end
function ColorPicker:SetValueRGB(color)
self.Value = color
self.Hue, self.Sat, self.Vib = color:ToHSV()
self:Render()
self:Fire()
end
function ColorPicker:SetValue(value)
local color = typeof(value) == "Color3" and value or Util.FromHex(value)
if color then
self:SetValueRGB(color)
end
end
function ColorPicker:Serialize()
return Util.Hex(self.Value)
end
function ColorPicker:Drag(target, handler)
target.InputBegan:Connect(function(input)
if not Util.IsPointer(input) then
return
end
handler(input.Position)
State.Drag = {
Move = function(move)
handler(move.Position)
end,
}
end)
end
function ColorPicker:BuildField(face, size)
local field = Draw.Box("TextButton", { Position = UDim2.fromOffset(10, 10), Size = UDim2.fromOffset(size, size), BackgroundTransparency = 0, Parent = face }, nil, "Outline", 6, 2)
local white = Draw.Box("Frame", { Size = UDim2.fromScale(1, 1), BackgroundColor3 = Color3.new(1, 1, 1), Parent = field }, nil, nil, 6)
white.BackgroundTransparency = 0
Draw.New("UIGradient", { Transparency = NumberSequence.new(0, 1), Parent = white })
local black = Draw.Box("Frame", { Size = UDim2.fromScale(1, 1), BackgroundColor3 = Color3.new(0, 0, 0), Parent = field }, nil, nil, 6)
black.BackgroundTransparency = 0
Draw.New("UIGradient", { Rotation = 90, Transparency = NumberSequence.new(1, 0), Parent = black })
local cursor = Draw.New("Frame", { AnchorPoint = Vector2.new(0.5, 0.5), Size = UDim2.fromOffset(12, 12), BackgroundTransparency = 1, ZIndex = 3, Parent = field })
Draw.Corner(cursor, UDim.new(1, 0))
Draw.New("UIStroke", { Color = Color3.new(1, 1, 1), Thickness = 2, Parent = cursor })
self:Drag(field, function(position)
local origin, extent = field.AbsolutePosition, field.AbsoluteSize
self.Sat = math.clamp((position.X - origin.X) / extent.X, 0, 1)
self.Vib = 1 - math.clamp((position.Y - origin.Y) / extent.Y, 0, 1)
self:Commit()
end)
return field, cursor
end
function ColorPicker:BuildHue(face, size)
local bar = Draw.Box("TextButton", { Position = UDim2.fromOffset(size + 20, 10), Size = UDim2.fromOffset(Config.ColorPicker.Hue, size), BackgroundColor3 = Color3.new(1, 1, 1), Parent = face }, nil, "Outline", 4, 2)
bar.BackgroundTransparency = 0
local keys = {}
for step = 0, 6 do
table.insert(keys, ColorSequenceKeypoint.new(step / 6, Color3.fromHSV(step / 6 % 1, 1, 1)))
end
Draw.New("UIGradient", { Rotation = 90, Color = ColorSequence.new(keys), Parent = bar })
local cursor = Draw.Box("Frame", { AnchorPoint = Vector2.new(0.5, 0.5), Size = UDim2.new(1, 6, 0, 4), ZIndex = 3, Parent = bar }, "White", "Outline", 2, 1)
self:Drag(bar, function(position)
self.Hue = math.clamp((position.Y - bar.AbsolutePosition.Y) / bar.AbsoluteSize.Y, 0, 0.999)
self:Commit()
end)
return cursor
end
function ColorPicker:Open()
local size = Config.ColorPicker.Field
local boxHeight = Util.Metric("Box")
local width = size + Config.ColorPicker.Hue + 30
local card, face, scale = Popup.Card(width, size + boxHeight + 30)
local field, cursor = self:BuildField(face, size)
local hueCursor = self:BuildHue(face, size)
local hexField = Draw.Box("Frame", { Position = UDim2.fromOffset(10, size + 20), Size = UDim2.new(1, -60, 0, boxHeight), Parent = face }, "Element", "Outline", 8, 2)
local hex = Draw.Text({ ClassName = "TextBox", ClearTextOnFocus = false, Size = UDim2.fromScale(1, 1), TextXAlignment = Enum.TextXAlignment.Center, Parent = hexField }, "Body", Util.TextSize("Label"), "Text")
local preview = Draw.Box("Frame", { AnchorPoint = Vector2.new(1, 0), Position = UDim2.new(1, -10, 0, size + 20), Size = UDim2.fromOffset(40, boxHeight), BackgroundTransparency = 0, Parent = face }, nil, "Outline", 8, 2)
hex.FocusLost:Connect(function()
local color = Util.FromHex(hex.Text)
if color then
self:SetValueRGB(color)
else
self:Render()
end
end)
self.View = { Field = field, Cursor = cursor, HueCursor = hueCursor, Hex = hex, Preview = preview }
self:Render()
Popup.Open(card, scale, self.Swatch, function()
self.View = nil
end)
end
function Dialog.Close()
local cur = Dialog.Current
if not cur then
return
end
Dialog.Current = nil
if cur.Container then
cur.Container:Destroy()
end
local shrink = Anim.Tween(cur.Scale, { Scale = State.UserScale * 0.9 }, 0.14, "In")
Anim.Tween(cur.Backdrop, { BackgroundTransparency = 1 }, 0.14)
shrink.Completed:Once(function()
Theme.UnbindTree(cur.Backdrop)
cur.Backdrop:Destroy()
end)
end
function Dialog.Show(spec)
spec = spec or {}
Dialog.Close()
if not State.Gui then
return nil
end
local backdrop = Draw.New("TextButton", {
Name = "DialogBackdrop",
Text = "",
AutoButtonColor = false,
BackgroundColor3 = Color3.new(0, 0, 0),
BackgroundTransparency = 1,
Size = UDim2.fromScale(1, 1),
ZIndex = Config.Layer.Modal,
Parent = State.Gui,
})
Anim.Tween(backdrop, { BackgroundTransparency = 0.45 }, Config.Tween.Fast)
local viewportW = State.Gui.AbsoluteSize.X
local modalW = math.clamp(spec.Width or 340, 260, math.max(260, math.floor(viewportW / math.max(0.5, State.UserScale or 1) - 32)))
local card, face, scale = Popup.Card(modalW, 160)
card.AnchorPoint = Vector2.new(0.5, 0.5)
card.Position = UDim2.fromScale(0.5, 0.5)
card.Parent = backdrop
scale.Scale = State.UserScale * 0.86
Motion.Spring(scale, "Scale", State.UserScale, "Fast", { Damping = 0.62 })
local body = Container.New(face, { PadX = 14, PadY = 14, GapY = 8 })
body:SetWidth(modalW)
body.OnHeight = function(h)
local shadow = Config.Group.Shadow
card.Size = UDim2.fromOffset(modalW + shadow, math.max(120, h) + shadow)
end
body:AddParagraph({ Title = spec.Title or "Confirm", Content = spec.Content or spec.Description or "", Icon = spec.Icon })
local buttons = spec.Buttons or {
{ Title = spec.CancelText or "Cancel", Style = "Default" },
{ Title = spec.ConfirmText or "Confirm", Style = spec.Style or "Primary", Callback = spec.Callback or spec.OnConfirm },
}
local firstBtn
for index, btnSpec in ipairs(buttons) do
local rawStyle = btnSpec.Style or btnSpec.Variant
if rawStyle == "Secondary" then
rawStyle = "Default"
end
local action = function()
Dialog.Close()
Util.Try(btnSpec.Callback or btnSpec.Func)
end
if not firstBtn then
firstBtn = body:AddButton({ Text = btnSpec.Title or btnSpec.Text or "OK", Style = rawStyle or (index == #buttons and "Primary" or "Default"), Icon = btnSpec.Icon }, action)
else
firstBtn:AddButton({ Text = btnSpec.Title or btnSpec.Text or "OK", Style = rawStyle or (index == #buttons and "Primary" or "Default"), Icon = btnSpec.Icon }, action)
end
end
Layout.Flush()
Dialog.Current = { Backdrop = backdrop, Card = card, Scale = scale, Container = body }
return Dialog.Current
end
function Sheet.Close()
local cur = Sheet.Current
if not cur then
return
end
Sheet.Current = nil
if cur.Container then
cur.Container:Destroy()
end
Anim.Tween(cur.Backdrop, { BackgroundTransparency = 1 }, 0.18)
local slide = Anim.Tween(cur.Panel, { Position = UDim2.new(1, 20, 0, 8) }, 0.2, "In")
slide.Completed:Once(function()
Theme.UnbindTree(cur.Backdrop)
cur.Backdrop:Destroy()
end)
end
function Sheet.Show(spec)
spec = spec or {}
Sheet.Close()
if not State.Gui then
return nil
end
local backdrop = Draw.New("TextButton", {
Name = "SheetBackdrop",
Text = "",
AutoButtonColor = false,
BackgroundColor3 = Color3.new(0, 0, 0),
BackgroundTransparency = 1,
Size = UDim2.fromScale(1, 1),
ZIndex = Config.Layer.Modal,
Parent = State.Gui,
})
backdrop.Activated:Connect(Sheet.Close)
Anim.Tween(backdrop, { BackgroundTransparency = 0.45 }, Config.Tween.Fast)
local sheetW = math.min(spec.Width or 320, math.max(240, State.Gui.AbsoluteSize.X - 40))
local panel = Draw.Box("TextButton", {
Name = "SheetPanel",
AnchorPoint = Vector2.new(1, 0),
Position = UDim2.new(1, sheetW + 20, 0, 8),
Size = UDim2.new(0, sheetW, 1, -16),
Parent = backdrop,
}, "Panel", "Outline", 12, 3)
Motion.Spring(panel, "Position", UDim2.new(1, -8, 0, 8), "Normal", { Damping = 0.72 })
local header = Draw.Box("Frame", { Size = UDim2.new(1, 0, 0, 42), Parent = panel }, "PanelHeader", nil, 12)
Draw.Box("Frame", { Position = UDim2.new(0, 0, 1, -12), Size = UDim2.new(1, 0, 0, 12), Parent = header }, "PanelHeader")
Draw.Box("Frame", { AnchorPoint = Vector2.new(0, 1), Position = UDim2.fromScale(0, 1), Size = UDim2.new(1, 0, 0, 2), ZIndex = 2, Parent = header }, "Outline")
Draw.Text({ Position = UDim2.fromOffset(14, 0), Size = UDim2.new(1, -50, 1, -2), Parent = header }, "Body", Util.TextSize("Group"), "Text", spec.Title or "Details")
local closeBtn = Draw.Box("TextButton", { AnchorPoint = Vector2.new(1, 0.5), Position = UDim2.new(1, -8, 0.5, -1), Size = UDim2.fromOffset(26, 26), ZIndex = 3, Parent = header }, "Element", "Outline", 6, 2)
Icons.Vector(closeBtn, "close", 14, "Text").Position = UDim2.fromOffset(6, 6)
closeBtn.Activated:Connect(Sheet.Close)
local scroll = Layout.ScrollFrame({ Position = UDim2.fromOffset(4, 46), Size = UDim2.new(1, -8, 1, -52), Parent = panel })
local body = Container.New(scroll, { PadX = 10, PadY = 10, GapY = 8 })
body:SetWidth(sheetW - 8 - Config.Page.ScrollBar)
local builder = spec.Build or spec.Render
if type(builder) == "function" then
Util.Try(builder, body)
end
Layout.Flush()
Sheet.Current = { Backdrop = backdrop, Panel = panel, Container = body, Close = Sheet.Close }
return body
end
function Gui.ClearPrevious(parent)
local env = type(getgenv) == "function" and getgenv() or nil
if env and type(env.MarioHub) == "table" and env.MarioHub ~= Library and not env.MarioHub.Unloaded then
Util.Try(env.MarioHub.Unload, env.MarioHub)
end
if env then
env.MarioHub = Library
end
for _, child in ipairs(parent:GetChildren()) do
if child:GetAttribute(Config.GuiAttribute) then
child:Destroy()
end
end
end
function Gui.Setup()
if State.Gui then
return
end
local parent = Util.GuiParent()
Gui.ClearPrevious(parent)
State.Gui = Draw.New("ScreenGui", {
Name = "MarioHub",
ResetOnSpawn = false,
IgnoreGuiInset = true,
ZIndexBehavior = Enum.ZIndexBehavior.Sibling,
DisplayOrder = 100,
Parent = parent,
})
State.Gui:SetAttribute(Config.GuiAttribute, Library.Version)
State.Overlay = Draw.New("Frame", { Name = "Overlay", BackgroundTransparency = 1, Size = UDim2.fromScale(1, 1), Visible = false, ZIndex = Config.Layer.Overlay, Parent = State.Gui })
local catcher = Draw.New("TextButton", { Text = "", BackgroundTransparency = 1, Size = UDim2.fromScale(1, 1), ZIndex = 1, Parent = State.Overlay })
catcher.MouseButton1Click:Connect(Popup.Close)
catcher.MouseButton2Click:Connect(Popup.Close)
Notify.Build()
Tooltip.Build()
Util.Connect(UserInputService.InputBegan, Gui.OnInputBegan)
Util.Connect(UserInputService.InputChanged, Gui.OnInputChanged)
Util.Connect(UserInputService.InputEnded, Gui.OnInputEnded)
Util.Connect(RunService.Heartbeat, Gui.OnHeartbeat)
Util.Every(20, Theme.Prune)
end
function Gui.OnInputBegan(input, processed)
if State.Binding then
Keybinds.Capture(input)
return
end
if UserInputService:GetFocusedTextBox() then
return
end
local name = Util.InputName(input)
if not name then
return
end
if name == State.MenuKey and State.Window and not processed then
State.Window:Toggle()
end
if input.UserInputType == Enum.UserInputType.Keyboard or not processed then
Keybinds.Dispatch(name, true)
end
end
function Gui.OnInputChanged(input)
if State.Drag and Util.IsMove(input) then
State.Drag.Move(input)
end
if input.UserInputType == Enum.UserInputType.MouseMovement then
Tooltip.Follow(UserInputService:GetMouseLocation())
end
end
function Gui.OnInputEnded(input)
if Util.IsPointer(input) and State.Drag then
local drag = State.Drag
State.Drag = nil
Util.Try(drag.Stop)
end
local name = Util.InputName(input)
if name then
Keybinds.Dispatch(name, false)
end
end
function Gui.OnHeartbeat(deltaTime)
if deltaTime > 0 then
State.Fps = State.Fps * 0.92 + (1 / deltaTime) * 0.08
end
for _, job in ipairs(State.Tasks) do
job.Elapsed += deltaTime
if job.Elapsed >= job.Interval and not job.Busy then
job.Elapsed = 0
job.Busy = true
task.spawn(function()
Util.Try(job.Run)
job.Busy = false
end)
end
end
end
function Gui.Draggable(handle, move, exclude)
handle.InputBegan:Connect(function(input)
if not Util.IsPointer(input) then
return
end
for _, zone in ipairs(exclude or {}) do
if zone.Visible and Util.Inside(zone, input.Position) then
return
end
end
local start = input.Position
local begin = move(nil)
local armed = false
State.Drag = {
Move = function(moved)
if not armed then
if (moved.Position - start).Magnitude < Config.DragSlop then
return
end
armed = true
start = moved.Position
begin = move(nil)
end
move(begin, moved.Position - start)
end,
}
end)
end
function Window.DetectTouch(forced)
if forced == "Mobile" or forced == "Desktop" then
State.Touch = forced == "Mobile"
return
end
State.Touch = UserInputService.TouchEnabled and not UserInputService.KeyboardEnabled
end
function Window.New(options)
Window.DetectTouch(options.Layout)
local size = options.Size or Vector2.new(Config.Window.Width, Config.Window.Height)
if typeof(size) == "UDim2" then
size = Vector2.new(size.X.Offset, size.Y.Offset)
end
local self = setmetatable({
Title = options.Title or "Reicht",
SubTitle = options.SubTitle or "",
Desired = size,
Size = size,
Tabs = {},
TabOrder = 0,
ActiveTab = nil,
Visible = false,
Minimized = false,
Compact = false,
Query = "",
}, Window)
State.Window = self
State.MenuKey = Util.KeyName(options.MenuKey or options.ToggleKey or options.MinimizeKey) or "LeftControl"
self:BuildFrame()
self:BuildTopbar()
self:BuildSidebar()
self:BuildMain()
self:BuildGround()
self:FitViewport()
Util.Connect(State.Gui:GetPropertyChangedSignal("AbsoluteSize"), function()
self:FitViewport()
end)
Util.Every(Config.TitleWaveInterval, function()
if self.Visible then
self:WaveTitle()
end
end)
return self
end
function Window:BuildFrame()
local shadow = Config.Window.Shadow
local radius = Config.Window.Radius
self.Root = Draw.New("Frame", { Name = "Window", BackgroundTransparency = 1, AnchorPoint = Vector2.new(0.5, 0), Position = UDim2.fromScale(0.5, 0.5), Visible = false, ZIndex = Config.Layer.Window, Parent = State.Gui })
self.UserScale = Draw.New("UIScale", { Parent = self.Root })
self.Pop = Draw.New("Frame", { BackgroundTransparency = 1, AnchorPoint = Vector2.new(0.5, 0.5), Position = UDim2.fromScale(0.5, 0.5), Size = UDim2.fromScale(1, 1), Parent = self.Root })
self.PopScale = Draw.New("UIScale", { Parent = self.Pop })
Draw.Box("Frame", { Position = UDim2.fromOffset(shadow, shadow), Size = UDim2.new(1, -shadow, 1, -shadow), Parent = self.Pop }, "Shadow", nil, radius)
self.Body = Draw.Box("Frame", { Size = UDim2.new(1, -shadow, 1, -shadow), BackgroundColor3 = Color3.new(1, 1, 1), BackgroundTransparency = 0, ClipsDescendants = true, Parent = self.Pop }, nil, "Outline", radius, Config.Window.Stroke)
local gradient = Draw.New("UIGradient", { Rotation = 90, Parent = self.Body })
Theme.OnRender(gradient, function()
gradient.Color = ColorSequence.new(Theme.Colors.Backdrop, Theme.Colors.BackdropAlt)
end)
end
function Window:BuildTopbar()
local height, radius = Config.Window.Topbar, Config.Window.Radius
local topbar = Draw.Box("Frame", { Name = "Topbar", Size = UDim2.new(1, 0, 0, height), ClipsDescendants = true, ZIndex = 5, Parent = self.Body }, "Topbar", nil, radius)
self.TopbarFill = Draw.Box("Frame", { Position = UDim2.new(0, 0, 1, -radius), Size = UDim2.new(1, 0, 0, radius), Parent = topbar }, "Topbar")
self.TopbarLine = Draw.Box("Frame", { AnchorPoint = Vector2.new(0, 1), Position = UDim2.fromScale(0, 1), Size = UDim2.new(1, 0, 0, 3), ZIndex = 3, Parent = topbar }, "Outline")
self.Topbar = topbar
self:BuildDecor(topbar)
local left = Draw.New("Frame", { BackgroundTransparency = 1, Position = UDim2.fromOffset(14, 0), Size = UDim2.new(1, -200, 1, -3), ZIndex = 4, Parent = topbar })
Draw.List(left, 10, true, Enum.HorizontalAlignment.Left, Enum.VerticalAlignment.Center)
self.Emblem = Draw.Emblem(left, 40)
self:BuildTitle(left)
self.SubtitlePill = self:BuildPill(left, self.SubTitle)
local right = Draw.New("Frame", { BackgroundTransparency = 1, AnchorPoint = Vector2.new(1, 0), Position = UDim2.new(1, -14, 0, 0), Size = UDim2.new(0, 180, 1, -3), ZIndex = 4, Parent = topbar })
Draw.List(right, 8, true, Enum.HorizontalAlignment.Right, Enum.VerticalAlignment.Center)
self:BuildLanguagePill(right)
local _, minimizeFace = self:BuildTopButton(right, "Minimize", "Coin", "CoinDark", "Ink", function()
self:SetMinimized(not self.Minimized)
end)
self.ExpandBar = Draw.Box("Frame", { AnchorPoint = Vector2.new(0.5, 0.5), Position = UDim2.fromScale(0.5, 0.5), Size = UDim2.new(0, 3, 0, 0), Parent = minimizeFace }, "Ink", nil, 2)
self:BuildTopButton(right, "Close", "Accent", "AccentDark", "White", function()
self:SetVisible(false)
if not State.Touch then
Library:Notify(self.Title, Lang.Format("Hidden", Keybinds.Short(State.MenuKey)), 3, "Info")
end
end)
Gui.Draggable(topbar, function(begin, delta)
if not delta then
return self.Root.Position
end
self.Root.Position = begin + UDim2.fromOffset(delta.X, delta.Y)
self:ClampPosition()
return begin
end, { right })
end
function Window:BuildDecor(topbar)
self.Clouds, self.Stars = {}, {}
for index, spot in ipairs({ { 0.44, 8, 42 }, { 0.6, 22, 30 } }) do
local cloud = Draw.Cloud(topbar, spot[3])
cloud.Position = UDim2.new(spot[1], 0, 0, spot[2])
cloud.ZIndex = 2
Anim.Loop("DecorClouds", cloud, { Position = UDim2.new(spot[1], 14, 0, spot[2] + 2) }, 4 + index, "Sine", true)
table.insert(self.Clouds, cloud)
end
for index, spot in ipairs({ { 0.42, 10, 12 }, { 0.48, 30, 9 }, { 0.54, 14, 14 }, { 0.6, 32, 10 }, { 0.66, 8, 11 }, { 0.71, 26, 8 } }) do
local star = Draw.Text({ AnchorPoint = Vector2.new(0.5, 0), Position = UDim2.new(spot[1], 0, 0, spot[2]), Size = UDim2.fromOffset(spot[3] + 4, spot[3] + 4), TextXAlignment = Enum.TextXAlignment.Center, ZIndex = 2, Parent = topbar }, "Glyph", spot[3], "DecorColor")
star.TextTransparency = 0.15
Anim.Loop("DecorStars", star, { TextTransparency = 0.8 }, 0.9 + index * 0.37, "Sine", true)
table.insert(self.Stars, star)
end
self.Spooky = {}
for index, spot in ipairs({ { 0.5, 10, 30, "pumpkin" }, { 0.55, 26, 20, "bat" }, { 0.6, 6, 30, "boo" }, { 0.645, 28, 18, "candy" }, { 0.69, 10, 30, "pumpkin" }, { 0.735, 20, 20, "bat" } }) do
local item = Sprite.New(topbar, spot[4], spot[3])
item.AnchorPoint = Vector2.new(0.5, 0)
item.Position = UDim2.new(spot[1], 0, 0, spot[2])
item.ZIndex = 2
local swing = spot[4] == "bat" and 14 or 6
Anim.Loop("DecorSpooky", item, { Position = UDim2.new(spot[1], 0, 0, spot[2] + (spot[4] == "bat" and 6 or 3)), Rotation = index % 2 == 0 and swing or -swing }, 1.2 + index * 0.35, "Sine", true)
table.insert(self.Spooky, item)
end
self:BuildSpookyBody()
Theme.OnRender(self.Stars, function()
self:RenderDecor()
end)
end
function Window:BuildSpookyBody()
self.SpookyBody = {}
local shadow, radius = Config.Window.Shadow, Config.Window.Radius
local glow = Draw.New("Frame", { Name = "Glow", BackgroundTransparency = 1, Position = UDim2.fromOffset(-3, -3), Size = UDim2.new(1, 6 - shadow, 1, 6 - shadow), ZIndex = 0, Parent = self.Pop })
Draw.Corner(glow, radius + 3)
local glowStroke = Draw.New("UIStroke", { Thickness = 4, Transparency = 0.25, ApplyStrokeMode = Enum.ApplyStrokeMode.Border, Parent = glow })
Theme.OnRender(glowStroke, function()
glowStroke.Color = Theme.Colors.Glow or Theme.Colors.Accent
end)
Anim.Loop("DecorSpookyGlow", glowStroke, { Transparency = 0.75, Thickness = 2 }, 1.8, "Sine", true)
self.SpookyGlow = glow
table.insert(self.SpookyBody, glow)
local fog = Draw.New("Frame", { Name = "Fog", AnchorPoint = Vector2.new(0, 1), Position = UDim2.fromScale(0, 1), Size = UDim2.new(1, 0, 0, 70), BorderSizePixel = 0, ZIndex = 1, Parent = self.Body })
Draw.Corner(fog, radius)
local fogShape = Draw.New("UIGradient", { Rotation = 90, Transparency = NumberSequence.new({ NumberSequenceKeypoint.new(0, 1), NumberSequenceKeypoint.new(1, 0.72) }), Parent = fog })
Theme.OnRender(fog, function()
fog.BackgroundColor3 = Theme.Colors.Fog or Theme.Colors.Accent
end)
Anim.Loop("DecorSpookyBody", fogShape, { Offset = Vector2.new(0, 0.12) }, 3.2, "Sine", true)
self.SpookyFog = fog
table.insert(self.SpookyBody, fog)
local hanger = Draw.New("Frame", { Name = "Spider", BackgroundTransparency = 1, Position = UDim2.new(1, -16, 0, Config.Window.Topbar + 60), Size = UDim2.fromOffset(16, 16), ZIndex = 9, Parent = self.Body })
Draw.New("Frame", { AnchorPoint = Vector2.new(0.5, 1), Position = UDim2.new(0.5, 0, 0, 4), Size = UDim2.new(0, 1, 0, 300), BackgroundColor3 = Color3.fromRGB(200, 186, 222), BackgroundTransparency = 0.5, Parent = hanger })
local spider = Sprite.New(hanger, "spider", 16)
Anim.Loop("DecorSpookyBody", hanger, { Position = UDim2.new(1, -16, 0, Config.Window.Topbar + 150) }, 3.4, "Sine", true)
Anim.Loop("DecorSpookyBody", spider, { Rotation = 10 }, 0.9, "Sine", true)
self.SpookySpider = hanger
table.insert(self.SpookyBody, hanger)
end
function Window:RenderDecor()
local wide = self.Size and self.Size.X >= 700
local decor = Theme.Colors.Decor
local shown = self.Visible ~= false
local expanded = shown and not self.Minimized
local showClouds = shown and wide and decor == "Clouds"
local showStars = shown and wide and decor == "Stars"
local showSpooky = shown and wide and decor == "Halloween"
local showGlow = shown and decor == "Halloween"
local showSpookyBody = expanded and decor == "Halloween"
for _, cloud in ipairs(self.Clouds) do
cloud.Visible = showClouds
end
for _, star in ipairs(self.Stars) do
star.Text = Theme.Colors.DecorGlyph or "✦"
star.Visible = showStars
end
for _, item in ipairs(self.Spooky or {}) do
item.Visible = showSpooky
end
if self.SpookyGlow then
self.SpookyGlow.Visible = showGlow
end
if self.SpookyFog then
self.SpookyFog.Visible = showSpookyBody
end
if self.SpookySpider then
self.SpookySpider.Visible = showSpookyBody
end
Anim.SetGroupActive("Emblem", shown)
Anim.SetGroupActive("DecorClouds", showClouds)
Anim.SetGroupActive("DecorStars", showStars)
Anim.SetGroupActive("DecorSpooky", showSpooky)
Anim.SetGroupActive("DecorSpookyGlow", showGlow)
Anim.SetGroupActive("DecorSpookyBody", showSpookyBody)
end
function Window:BuildTitle(parent)
local holder = Draw.New("Frame", { BackgroundTransparency = 1, AutomaticSize = Enum.AutomaticSize.X, Size = UDim2.fromOffset(0, 34), LayoutOrder = 1, Parent = parent })
Draw.List(holder, 1, true, Enum.HorizontalAlignment.Left, Enum.VerticalAlignment.Center)
self.Letters = {}
local size = Config.Text.Title
local index = 0
for char in self.Title:upper():gmatch(utf8.charpattern) do
local bounds = Layout.Measure(char, size, "Logo", 200)
local slot = Draw.New("Frame", { BackgroundTransparency = 1, Size = UDim2.fromOffset(char == " " and size * 0.3 or bounds.X, size + 4), LayoutOrder = #self.Letters + 1, Parent = holder })
local letter = Draw.Text({ Text = char, Size = UDim2.fromScale(1, 1), TextXAlignment = Enum.TextXAlignment.Center, Parent = slot }, "Logo", size, Config.TitleColors[index % #Config.TitleColors + 1])
Draw.Stroke(letter, "Ink", 2)
table.insert(self.Letters, letter)
index += char == " " and 0 or 1
end
self.TitleHolder = holder
end
function Window:WaveTitle()
for index, letter in ipairs(self.Letters) do
letter.Position = UDim2.new()
Anim.Tween(letter, { Position = UDim2.fromOffset(0, -6) }, 0.14, "Out", 0, true, index * 0.045)
end
end
function Window:BuildPill(parent, text)
local pill = Draw.Box("Frame", { AutomaticSize = Enum.AutomaticSize.X, Size = UDim2.fromOffset(0, 22), LayoutOrder = 2, Parent = parent }, "Shadow", nil, UDim.new(1, 0))
pill.BackgroundTransparency = 0.45
Draw.Padding(pill, 0, 10, 0, 10)
Draw.Text({ AutomaticSize = Enum.AutomaticSize.X, Size = UDim2.fromScale(0, 1), Parent = pill }, "Body", Util.TextSize("Small"), "TopbarText", text)
pill.Visible = text ~= ""
return pill
end
function Window:BuildLanguagePill(parent)
local pill = Draw.Box("Frame", { Size = UDim2.fromOffset(74, 28), LayoutOrder = 1, Parent = parent }, "Shadow", "Outline", UDim.new(1, 0), 2)
pill.BackgroundTransparency = 0.35
local segments = {}
for index, code in ipairs({ "EN", "TH" }) do
local segment = Draw.Box("TextButton", { Position = UDim2.new((index - 1) * 0.5, 2, 0, 2), Size = UDim2.new(0.5, -4, 1, -4), Parent = pill }, "Coin", nil, UDim.new(1, 0))
local label = Draw.Text({ Text = code, Size = UDim2.fromScale(1, 1), TextXAlignment = Enum.TextXAlignment.Center, Parent = segment }, "Body", 13, "White")
segment.Activated:Connect(function()
Library:SetLanguage(code)
end)
segments[code] = { Button = segment, Label = label }
end
local function Render()
for code, segment in pairs(segments) do
local active = State.Language == code
Anim.Tween(segment.Button, { BackgroundTransparency = active and 0 or 1 }, Config.Tween.Fast)
Theme.Bind(segment.Label, { TextColor3 = active and "Ink" or "TopbarText" })
end
end
Lang.OnChange(pill, Render)
Render()
end
function Window:BuildTopButton(parent, kind, face, shade, ink, callback)
local size = State.Touch and 36 or 30
local holder, top = Draw.Block(parent, face, shade, 8, 3)
holder.Size = UDim2.fromOffset(size, size + 1)
holder.LayoutOrder = 2 + #parent:GetChildren()
local strokes = kind == "Close" and { 45, -45 } or { 0 }
for _, rotation in ipairs(strokes) do
Draw.Box("Frame", { AnchorPoint = Vector2.new(0.5, 0.5), Position = UDim2.fromScale(0.5, 0.5), Size = UDim2.new(0.5, 0, 0, 3), Rotation = rotation, Parent = top }, ink, nil, 2)
end
local hit = Draw.New("TextButton", { Text = "", BackgroundTransparency = 1, Size = UDim2.fromScale(1, 1), ZIndex = 3, Parent = holder })
hit.MouseButton1Down:Connect(function()
Anim.Tween(top, { Position = UDim2.fromOffset(0, 2) }, 0.06, "Linear")
end)
hit.MouseButton1Up:Connect(function()
Anim.Tween(top, { Position = UDim2.new() }, Config.Tween.Normal, "Back")
end)
hit.MouseLeave:Connect(function()
Anim.Tween(top, { Position = UDim2.new() }, Config.Tween.Fast)
end)
hit.Activated:Connect(callback)
return holder, top
end
function Window:BuildSidebar()
local top = Config.Window.Topbar
local sidebar = Draw.Box("Frame", { Name = "Sidebar", Position = UDim2.fromOffset(0, top), Parent = self.Body }, "Sidebar")
Draw.Box("Frame", { AnchorPoint = Vector2.new(1, 0), Position = UDim2.fromScale(1, 0), Size = UDim2.new(0, 3, 1, 0), ZIndex = 3, Parent = sidebar }, "Outline")
Draw.Box("Frame", { AnchorPoint = Vector2.new(1, 0), Position = UDim2.new(1, -3, 0, 0), Size = UDim2.new(0, 5, 1, 0), BackgroundTransparency = 0, Parent = sidebar }, "SidebarAlt")
self.Sidebar = sidebar
local scroll = Layout.ScrollFrame({ Position = UDim2.fromOffset(0, 8), Size = UDim2.new(1, -8, 1, -(Config.Window.UserCard + 8)), Parent = sidebar })
scroll.ScrollBarThickness = 3
self.TabScroll = scroll
self.TabList = Container.New(scroll, { PadX = 8, PadY = 2, GapY = 4, Window = self })
self:BuildUserCard(sidebar)
end
function Window:BuildUserCard(sidebar)
local card = Draw.New("Frame", { Name = "User", BackgroundTransparency = 1, AnchorPoint = Vector2.new(0, 1), Position = UDim2.fromScale(0, 1), Size = UDim2.new(1, -8, 0, Config.Window.UserCard), Parent = sidebar })
self.UserCard = card
Draw.Box("Frame", { Size = UDim2.new(1, 0, 0, 2), BackgroundTransparency = 0.5, Parent = card }, "SidebarAlt")
local avatar = Draw.Box("ImageLabel", { AnchorPoint = Vector2.new(0, 0.5), Position = UDim2.new(0, 12, 0.5, 0), Size = UDim2.fromOffset(36, 36), Parent = card }, "PanelHeader", "Outline", UDim.new(1, 0), 2)
task.spawn(function()
local ok, image = pcall(Players.GetUserThumbnailAsync, Players, LocalPlayer.UserId, Enum.ThumbnailType.HeadShot, Enum.ThumbnailSize.Size100x100)
if ok then
avatar.Image = image
end
end)
self.UserName = Draw.Text({ Text = LocalPlayer.DisplayName, Position = UDim2.fromOffset(56, 11), Size = UDim2.new(1, -62, 0, 18), TextTruncate = Enum.TextTruncate.AtEnd, Parent = card }, "Body", 14, "SidebarText")
self.UserTag = Draw.Text({ Text = "@" .. LocalPlayer.Name, Position = UDim2.fromOffset(56, 29), Size = UDim2.new(1, -62, 0, 16), TextTruncate = Enum.TextTruncate.AtEnd, Parent = card }, "Desc", 12, "SidebarMuted")
self.Avatar = avatar
end
function Window:BuildMain()
local header = Config.Window.Header
local main = Draw.New("Frame", { Name = "Main", BackgroundTransparency = 1, Position = UDim2.fromOffset(0, Config.Window.Topbar), Parent = self.Body })
self.Main = main
self.HeaderTitle = Draw.Text({ Position = UDim2.fromOffset(16, 10), Size = UDim2.new(1, -230, 0, 26), TextTruncate = Enum.TextTruncate.AtEnd, Parent = main }, "Display", Config.Text.Header, "Text")
self.HeaderDesc = Draw.Text({ Position = UDim2.fromOffset(16, 36), Size = UDim2.new(1, -230, 0, 16), TextTruncate = Enum.TextTruncate.AtEnd, Parent = main }, "Desc", Util.TextSize("Desc") + 1, "SubText")
local field = Draw.Box("Frame", { AnchorPoint = Vector2.new(1, 0.5), Position = UDim2.new(1, -16, 0, header / 2), Size = UDim2.fromOffset(200, Util.Metric("Box")), Parent = main }, "Element", "Outline", UDim.new(1, 0), 2)
local icon = Icons.Vector(field, "search", 14, "SubText")
icon.AnchorPoint = Vector2.new(0, 0.5)
icon.Position = UDim2.new(0, 10, 0.5, 0)
local clearBtn = Draw.Box("TextButton", { AnchorPoint = Vector2.new(1, 0.5), Position = UDim2.new(1, -6, 0.5, 0), Size = UDim2.fromOffset(18, 18), Visible = false, Parent = field }, "Hover", nil, UDim.new(1, 0))
Icons.Vector(clearBtn, "close", 10, "SubText").Position = UDim2.fromOffset(4, 4)
self.SearchClear = clearBtn
self.Search = Draw.Text({ ClassName = "TextBox", Text = "", ClearTextOnFocus = false, Position = UDim2.fromOffset(28, 0), Size = UDim2.new(1, -52, 1, 0), Parent = field }, "Body", Util.TextSize("Label"), "Text")
Lang.Bind(self.Search, Lang.Strings.Search, "PlaceholderText")
Theme.Bind(self.Search, { PlaceholderColor3 = "Muted" })
self.SearchField = field
clearBtn.Activated:Connect(function()
self.Search.Text = ""
end)
self.Search:GetPropertyChangedSignal("Text"):Connect(function()
self.Query = self.Search.Text:lower()
clearBtn.Visible = self.Query ~= ""
self:ApplyFilter()
end)
self.PageHost = Draw.New("Frame", { BackgroundTransparency = 1, Position = UDim2.fromOffset(0, header), Size = UDim2.new(1, 0, 1, -header), ClipsDescendants = true, ZIndex = 2, Parent = main })
local emptyBox = Draw.Box("Frame", { Name = "EmptySearch", AnchorPoint = Vector2.new(0.5, 0.5), Position = UDim2.fromScale(0.5, 0.45), Size = UDim2.fromOffset(200, 74), Visible = false, ZIndex = 5, Parent = self.PageHost }, "Panel", "Outline", 10, 2)
local booSprite = Sprite.New(emptyBox, "boo", 24)
booSprite.AnchorPoint = Vector2.new(0.5, 0)
booSprite.Position = UDim2.new(0.5, 0, 0, 10)
Draw.Text({ Position = UDim2.fromOffset(8, 40), Size = UDim2.new(1, -16, 0, 24), TextXAlignment = Enum.TextXAlignment.Center, Parent = emptyBox }, "Body", Util.TextSize("Label"), "Muted", Lang.Strings.NoResults)
self.EmptyState = emptyBox
Particles.Build(main)
end
function Window:BuildGround()
local height, radius = Config.Window.Ground, Config.Window.Radius
local ground = Draw.Box("Frame", { Name = "Ground", AnchorPoint = Vector2.new(0, 1), Position = UDim2.fromScale(0, 1), Size = UDim2.new(1, 0, 0, height), ClipsDescendants = true, ZIndex = 3, Parent = self.Body }, "Brick", nil, radius)
Draw.Box("Frame", { Size = UDim2.new(1, 0, 0, radius), Parent = ground }, "Brick")
local bricks = Draw.New("Frame", { BackgroundTransparency = 1, Position = UDim2.fromOffset(6, 6), Size = UDim2.new(1, -12, 1, -8), ClipsDescendants = true, Parent = ground })
Draw.Bricks(bricks, 28, "BrickDark")
Draw.Box("Frame", { Size = UDim2.new(1, 0, 0, 6), Parent = ground }, "Grass")
Draw.Box("Frame", { Position = UDim2.fromOffset(0, 6), Size = UDim2.new(1, 0, 0, 2), Parent = ground }, "GrassDark")
Draw.Box("Frame", { Size = UDim2.new(1, 0, 0, 3), Parent = ground }, "Outline")
self.Ground = ground
local gripSize = State.Touch and 34 or 24
local grip = Draw.New("TextButton", { Name = "Grip", Text = "", AutoButtonColor = false, BackgroundTransparency = 1, AnchorPoint = Vector2.new(1, 1), Position = UDim2.new(1, -2, 1, -2), Size = UDim2.fromOffset(gripSize, gripSize), ZIndex = 4, Parent = ground })
local gripIcon = Icons.Vector(grip, "grip", 14, "White")
gripIcon.AnchorPoint = Vector2.new(1, 1)
gripIcon.Position = UDim2.new(1, -2, 1, -2)
self.Grip = grip
Gui.Draggable(grip, function(begin, delta)
if not delta then
return { Size = self.Size, Position = self.Root.Position }
end
self:ResizeFrom(begin, Vector2.new(delta.X, delta.Y))
return begin
end)
end
function Window:ResizeFrom(begin, delta)
if self.Minimized then
return
end
self.Desired = begin.Size + delta / State.UserScale
self:FitViewport()
local grown = (self.Size.X - begin.Size.X) * State.UserScale
self.Root.Position = begin.Position + UDim2.fromOffset(math.floor(grown / 2), 0)
self:ClampPosition()
end
function Window:MinSize()
if State.Touch then
return Config.Window.TouchMinWidth, Config.Window.TouchMinHeight
end
return Config.Window.MinWidth, Config.Window.MinHeight
end
function Window:ClampPosition()
if not State.Gui or not self.Root then
return
end
local viewport = State.Gui.AbsoluteSize
if viewport.X <= 0 or viewport.Y <= 0 then
return
end
local scaleFactor = math.max(0.5, State.UserScale or 1)
local halfW = math.floor((self.Size.X * scaleFactor) / 2)
local topH = math.floor(Config.Window.Topbar * scaleFactor)
local pos = self.Root.Position
local absX = viewport.X * pos.X.Scale + pos.X.Offset
local absY = viewport.Y * pos.Y.Scale + pos.Y.Offset
local minX = math.min(halfW + 6, viewport.X / 2)
local maxX = math.max(minX, viewport.X - halfW - 6)
local clampedX = math.clamp(absX, minX, maxX)
local clampedY = math.clamp(absY, 6, math.max(6, viewport.Y - topH - 6))
self.Root.Position = UDim2.new(pos.X.Scale, math.floor(clampedX - viewport.X * pos.X.Scale + 0.5), pos.Y.Scale, math.floor(clampedY - viewport.Y * pos.Y.Scale + 0.5))
end
function Window:FitViewport()
local viewport = State.Gui.AbsoluteSize
if viewport.X <= 0 then
return
end
local margin = (State.Touch and Config.Window.TouchMargin or Config.Window.Margin) * 2
local baseMinW, baseMinH = self:MinSize()
local scaleFactor = math.max(0.5, State.UserScale or 1)
local availW = math.max(260, (viewport.X - margin) / scaleFactor)
local availH = math.max(220, (viewport.Y - margin) / scaleFactor)
local minWidth = math.min(baseMinW, availW)
local minHeight = math.min(baseMinH, availH)
self.Size = Vector2.new(
math.floor(math.clamp(self.Desired.X, minWidth, availW)),
math.floor(math.clamp(self.Desired.Y, minHeight, availH))
)
self:ApplyLayout()
self:ClampPosition()
if Float.Clamp then
Float.Clamp()
end
end
function Window:ApplyLayout()
local width, height = self.Size.X, self.Size.Y
local shadow = Config.Window.Shadow
self.Compact = width < Config.Window.CompactBreakpoint
local sidebar = self.Compact and Config.Window.SidebarCompact or Config.Window.Sidebar
local bodyHeight = height - Config.Window.Topbar - Config.Window.Ground
self.Root.Size = UDim2.fromOffset(width + shadow, (self.Minimized and Config.Window.Topbar or height) + shadow)
if not self.Placed then
self.Placed = true
self.Root.Position = UDim2.new(0.5, 0, 0.5, -math.floor((height + shadow) * State.UserScale / 2))
end
self.UserScale.Scale = State.UserScale
self.Sidebar.Size = UDim2.fromOffset(sidebar, bodyHeight)
self.Main.Position = UDim2.fromOffset(sidebar, Config.Window.Topbar)
self.Main.Size = UDim2.fromOffset(width - sidebar, bodyHeight)
self.TabList:SetWidth(sidebar - 8 - 3)
local pageWidth = width - sidebar
for _, tab in ipairs(self.Tabs) do
tab.PendingWidth = pageWidth
tab:ApplyCompact(self.Compact)
end
if self.ActiveTab then
self.ActiveTab:ApplyWidth()
end
for _, section in ipairs(self.Sections or {}) do
section.Hidden = self.Compact
end
self.TabList:MarkDirty()
self:ApplyChrome(width, height)
end
function Window:ApplyShort(height)
local short = height < 430
local header = short and 46 or Config.Window.Header
self.UserCard.Visible = not short
self.TabScroll.Size = UDim2.new(1, -8, 1, -(short and 8 or Config.Window.UserCard + 8))
self.HeaderDesc.Visible = not short
self.HeaderTitle.Position = UDim2.fromOffset(16, short and 11 or 10)
self.SearchField.Position = UDim2.new(1, -16, 0, header / 2)
self.PageHost.Position = UDim2.fromOffset(0, header)
self.PageHost.Size = UDim2.new(1, 0, 1, -header)
end
function Window:ApplyChrome(width, height)
self:ApplyShort(height)
local narrow = width < 460
self.SubtitlePill.Visible = self.SubTitle ~= "" and width >= 700
self:RenderDecor()
self.Emblem.Visible = width >= 380
self.TitleHolder.Visible = width >= 340
local searchWidth = self.Compact and (narrow and 110 or 140) or 200
self.SearchField.Size = UDim2.fromOffset(searchWidth, Util.Metric("Box"))
self.HeaderTitle.Size = UDim2.new(1, -(searchWidth + 44), 0, 26)
self.HeaderDesc.Size = UDim2.new(1, -(searchWidth + 44), 0, 16)
self.UserName.Visible = not self.Compact
self.UserTag.Visible = not self.Compact
self.Avatar.Position = UDim2.new(0, self.Compact and 10 or 12, 0.5, 0)
end
function Window:AddTabSection(text)
local label = Draw.Text({ Name = "Section" }, "Body", Config.Text.Section - 1, "SidebarMuted")
Lang.Bind(label, text, "Text", string.upper)
Draw.Padding(label, 6, 0, 0, 6)
local item = self.TabList:Add(label, { Height = 24 })
self.Sections = self.Sections or {}
table.insert(self.Sections, item)
item.Hidden = self.Compact
return item
end
function Window:AddTab(name, icon, description)
if type(name) == "table" and not name.EN and not name.TH then
icon = name.Icon or icon
description = name.Description or name.Desc or description
name = name.Title or name.Name or name.Text or "Tab"
end
local tab = Tab.New(self, name, icon, description)
table.insert(self.Tabs, tab)
self:ApplyLayout()
if not self.ActiveTab then
self:SelectTab(tab)
end
return tab
end
function Window:SelectTab(tab)
if type(tab) == "string" then
for _, candidate in ipairs(self.Tabs) do
if Lang.Resolve(candidate.Name) == tab or candidate.Name == tab then
tab = candidate
break
end
end
end
if type(tab) ~= "table" or tab == self.ActiveTab then
return
end
Popup.Close()
local previous = self.ActiveTab
self.ActiveTab = tab
if previous then
previous.Page.Visible = false
previous:RenderButton()
end
tab:ApplyWidth()
tab.Page.Visible = true
tab.Page.Position = UDim2.fromOffset(0, 18)
Anim.Tween(tab.Page, { Position = UDim2.new() }, Config.Tween.Slide)
tab:RenderButton()
Anim.Bump(tab.IconSlot, 6)
Lang.Bind(self.HeaderTitle, tab.Name)
Lang.Bind(self.HeaderDesc, tab.Description or "")
local titleY = self.HeaderDesc.Visible and 10 or 11
self.HeaderTitle.Position = UDim2.fromOffset(28, titleY)
Anim.Tween(self.HeaderTitle, { Position = UDim2.fromOffset(16, titleY) }, Config.Tween.Slide, "Back")
if (tab.FilteredQuery or "") ~= self.Query then
self:ApplyFilter()
elseif self.EmptyState then
self.EmptyState.Visible = false
end
local cards = {}
for _, box in ipairs(tab.Groupboxes) do
if not box.Item.Filtered and not box.Item.Hidden then
table.insert(cards, box.Card)
end
end
Fx.StaggerRise(cards)
end
function Window:ApplyFilter()
local tab = self.ActiveTab
if not tab then
return
end
local query = self.Query
tab.FilteredQuery = query
local visibleCount = 0
local columnChanged = false
for _, box in ipairs(tab.Groupboxes) do
local titleMatch = query == "" or box.SearchTitle:find(query, 1, true) ~= nil
local anyMatch = false
local boxChanged = false
for _, entry in ipairs(box.Items) do
local filtered = not titleMatch and (entry.Search == nil or not entry.Search:find(query, 1, true))
if entry.Filtered ~= filtered then
entry.Filtered = filtered
boxChanged = true
end
anyMatch = anyMatch or (entry.Search ~= nil and not filtered)
end
local boxFiltered = not titleMatch and not anyMatch
if box.Item.Filtered ~= boxFiltered then
box.Item.Filtered = boxFiltered
columnChanged = true
end
if not boxFiltered and not box.Item.Hidden then
visibleCount += 1
end
if boxChanged then
box:MarkDirty()
box.Column:MarkDirty()
columnChanged = true
end
end
if columnChanged then
tab:ApplyColumns()
end
if self.EmptyState then
self.EmptyState.Visible = query ~= "" and visibleCount == 0
end
end
function Window:SetVisible(visible)
if visible == self.Visible then
return
end
self.Visible = visible
Popup.Close()
if not visible then
Dialog.Close()
Sheet.Close()
end
Tooltip.Token = nil
Tooltip.Frame.Visible = false
Float.Render()
self:RenderDecor()
if visible then
self.Root.Visible = true
self.PopScale.Scale = 0.82
Anim.Tween(self.PopScale, { Scale = 1 }, Config.Tween.Pop, "Back")
self:WaveTitle()
Particles.Resume()
return
end
if State.Touch and Float.Button and not Float.Button.Visible then
Float.SetVisible(true)
end
local shrink = Anim.Tween(self.PopScale, { Scale = 0.82 }, 0.14, "In")
shrink.Completed:Once(function()
if not self.Visible then
self.Root.Visible = false
end
end)
end
function Window:Toggle()
if not self.Ready then
return
end
self:SetVisible(not self.Visible)
end
function Window:SetContentVisible(visible)
self.Sidebar.Visible, self.Main.Visible, self.Ground.Visible = visible, visible, visible
end
function Window:SetMinimized(minimized)
minimized = minimized == true
if self.Minimized == minimized then
return
end
self.Minimized = minimized
Popup.Close()
Dialog.Close()
Sheet.Close()
self:RenderDecor()
if not minimized then
self:SetContentVisible(true)
self.TopbarFill.Visible, self.TopbarLine.Visible = true, true
end
Anim.Tween(self.TopbarFill, { BackgroundTransparency = minimized and 1 or 0 }, Config.Tween.Fast)
Anim.Tween(self.TopbarLine, { BackgroundTransparency = minimized and 1 or 0 }, Config.Tween.Fast)
Anim.Tween(self.ExpandBar, { Size = UDim2.new(0, 3, minimized and 0.5 or 0, 0) }, Config.Tween.Normal, "Back")
local shadow = Config.Window.Shadow
local height = minimized and Config.Window.Topbar or self.Size.Y
local tween = Anim.Tween(self.Root, { Size = UDim2.fromOffset(self.Size.X + shadow, height + shadow) }, 0.34, "Out")
tween.Completed:Once(function()
if self.Minimized ~= minimized then
return
end
if minimized then
self:SetContentVisible(false)
self.TopbarFill.Visible, self.TopbarLine.Visible = false, false
else
Particles.Resume()
end
end)
end
function Window:SetScale(scale)
State.UserScale = math.clamp(tonumber(scale) or 1, Config.ScaleRange.Min, Config.ScaleRange.Max)
self:FitViewport()
end
function Tab.New(window, name, icon, description)
local resolvedIcon = (icon and icon ~= "") and icon or Icons.FromTitle(name, "qblock")
local tab = setmetatable({ Window = window, Name = name, Icon = resolvedIcon, Description = description, Groupboxes = {} }, Tab)
tab:BuildButton()
tab:BuildPage()
return tab
end
function Tab:BuildButton()
local height = Util.Metric("Tab")
local holder = Draw.New("TextButton", { Name = "Tab", Text = "", AutoButtonColor = false, BackgroundTransparency = 1 })
local shade = Draw.Box("Frame", { Position = UDim2.fromOffset(0, 3), Size = UDim2.new(1, 0, 1, -3), BackgroundTransparency = 1, Parent = holder }, "Shadow", nil, 10)
local face = Draw.Box("Frame", { Size = UDim2.new(1, 0, 1, -3), BackgroundTransparency = 1, Parent = holder }, "TabActive", nil, 10)
local stroke = Draw.Stroke(face, "Outline", 2, true)
stroke.Transparency = 1
self.IconSlot = Draw.New("Frame", { BackgroundTransparency = 1, AnchorPoint = Vector2.new(0, 0.5), Position = UDim2.new(0, 8, 0.5, 0), Size = UDim2.fromOffset(24, 24), Parent = face })
Icons.Create(self.IconSlot, self.Icon, 24, nil, self.Name)
self.Label = Draw.Text({ Position = UDim2.fromOffset(40, 0), Size = UDim2.new(1, -44, 1, 0), TextTruncate = Enum.TextTruncate.AtEnd, Parent = face }, "Body", Util.TextSize("Label") + 1, "SidebarText", self.Name)
self.Button, self.Face, self.Shade, self.Stroke = holder, face, shade, stroke
holder.MouseEnter:Connect(function()
self.Hovered = not State.Touch
self:RenderButton()
end)
holder.MouseLeave:Connect(function()
self.Hovered = false
self:RenderButton()
end)
holder.Activated:Connect(function()
self.Window:SelectTab(self)
end)
self.Window.TabList:Add(holder, { Height = height })
Theme.OnRender(self, function()
self:RenderButton(true)
end)
if self.Description then
Tooltip.Attach(holder, self.Description)
end
end
function Tab:RenderButton(instant)
local active = self.Window.ActiveTab == self
local duration = instant and 0 or Config.Tween.Normal
local faceAlpha = active and 0 or (self.Hovered and 0.8 or 1)
Anim.Tween(self.Face, { BackgroundTransparency = faceAlpha }, duration)
Anim.Tween(self.Shade, { BackgroundTransparency = active and 0 or 1 }, duration)
Anim.Tween(self.Stroke, { Transparency = active and 0 or 1 }, duration)
Theme.Bind(self.Label, { TextColor3 = active and "TabActiveText" or "SidebarText" })
end
function Tab:Select()
self.Window:SelectTab(self)
end
function Tab:ApplyWidth()
local width = self.PendingWidth
if not width then
return
end
self.PendingWidth = nil
self.Root:SetWidth(width - Config.Page.ScrollBar)
self:ApplyColumns(width)
end
function Tab:ApplyCompact(compact)
self.Label.Visible = not compact
self.IconSlot.AnchorPoint = Vector2.new(compact and 0.5 or 0, 0.5)
self.IconSlot.Position = compact and UDim2.fromScale(0.5, 0.5) or UDim2.new(0, 8, 0.5, 0)
end
function Tab:BuildPage()
local page = Layout.ScrollFrame({ Name = "Page", Size = UDim2.fromScale(1, 1), Visible = false, Parent = self.Window.PageHost })
local gap = Config.Gap.Column
self.Page = page
self.Root = Container.New(page, { PadX = Config.Page.Pad, PadY = 6, GapX = gap, GapY = gap, Window = self.Window, Tab = self })
local leftHost = Draw.New("Frame", { Name = "Left", BackgroundTransparency = 1 })
local rightHost = Draw.New("Frame", { Name = "Right", BackgroundTransparency = 1 })
self.Left = Container.New(leftHost, { GapY = gap })
self.Right = Container.New(rightHost, { GapY = gap })
self.LeftItem = self.Root:Add(leftHost, { Width = 0.5, Height = function()
return self.Left.ContentHeight
end, Child = self.Left })
self.Root:SameLine()
self.RightItem = self.Root:Add(rightHost, { Height = function()
return self.Right.ContentHeight
end, Child = self.Right })
end
function Tab.ColumnHasVisible(column)
for _, entry in ipairs(column.Items) do
if not entry.Hidden and not entry.Filtered then
return true
end
end
return false
end
function Tab:ApplyColumns(pageWidth)
self.PageWidth = pageWidth or self.PageWidth or 0
local hasLeft = Tab.ColumnHasVisible(self.Left)
local hasRight = Tab.ColumnHasVisible(self.Right)
local single = self.PageWidth < Config.Window.TwoColumnMin or not hasLeft or not hasRight
self.LeftItem.Hidden = not hasLeft
self.RightItem.Hidden = not hasRight
self.LeftItem.Width = (not single) and 0.5 or nil
self.RightItem.SameLine = not single
self.Root:MarkDirty()
end
function Tab:AddGroupbox(info, side)
if type(info) ~= "table" or info.EN then
info = { Name = info, Side = side }
else
info.Name = info.Name or info.Title or info.Text or ""
end
local column = info.Side == "Right" and self.Right or self.Left
local shadow, header, radius = Config.Group.Shadow, Config.Group.Header, Config.Group.Radius
local collapsed = info.Collapsed == true
local initOpen = collapsed and 0 or 1
local holder = Draw.New("Frame", { Name = "Groupbox", BackgroundTransparency = 1 })
Draw.Box("Frame", { Position = UDim2.fromOffset(shadow, shadow), Size = UDim2.new(1, -shadow, 1, -shadow), Parent = holder }, "Shadow", nil, radius)
local card = Draw.Box("Frame", { Size = UDim2.new(1, -shadow, 1, -shadow), Parent = holder }, "Panel", "Outline", radius, Config.Group.Stroke)
local body = Draw.New("Frame", { BackgroundTransparency = 1, Position = UDim2.fromOffset(0, header), Size = UDim2.new(1, 0, 1, -header), ClipsDescendants = true, Visible = not collapsed, Parent = card })
local box = Container.New(body, { PadX = Config.Group.PadX, PadY = Config.Group.PadY, Window = self.Window, Tab = self })
setmetatable(box, Groupbox)
box.Column, box.Card, box.Body, box.Collapsed, box.SearchTitle = column, card, body, collapsed, Lang.SearchText(info.Name)
box.Open = Draw.New("NumberValue", { Value = initOpen })
box:BuildHeader(card, info)
box.Item = column:Add(holder, {
Height = function()
return header + math.floor(box.ContentHeight * box.Open.Value) + shadow
end,
Child = box,
ChildInset = shadow,
})
box.Open.Changed:Connect(function(v)
local show = v > 0.02
box.Body.Visible = show
if box.HeaderPatch then
box.HeaderPatch.Visible = show
box.HeaderPatch.BackgroundTransparency = math.clamp(1 - v * 1.4, 0, 1)
end
if box.HeaderDivider then
box.HeaderDivider.Visible = show
box.HeaderDivider.BackgroundTransparency = math.clamp(1 - v * 1.4, 0, 1)
end
column:MarkDirty()
end)
table.insert(self.Groupboxes, box)
self:ApplyColumns()
return box
end
function Tab:AddLeftGroupbox(name, icon, badge)
return self:AddGroupbox({ Name = name, Side = "Left", Icon = icon, Badge = badge })
end
function Tab:AddRightGroupbox(name, icon, badge)
return self:AddGroupbox({ Name = name, Side = "Right", Icon = icon, Badge = badge })
end
function Tab:EnsureGroup()
if not self.DefaultGroup then
self.DefaultGroup = self:AddLeftGroupbox(self.Name)
end
return self.DefaultGroup
end
Window.Tab = Window.AddTab
Window.Section = Window.AddTabSection
function Window:Dialog(spec)
return Dialog.Show(spec)
end
function Window:Sheet(spec)
return Sheet.Show(spec)
end
Tab.Section = Tab.AddGroupbox
for _, method in ipairs({ "AddToggle", "AddCheckbox", "AddSlider", "AddDropdown", "AddInput", "AddButton", "AddKeybind", "AddColorPicker", "AddLabel", "AddParagraph", "AddStepper", "AddRangeSlider", "AddSegmented", "AddStat", "AddStatus", "AddTable", "Toggle", "Checkbox", "Slider", "Dropdown", "Input", "Button", "Keybind", "Colorpicker", "Label", "Paragraph" }) do
Tab[method] = function(tabSelf, ...)
local grp = tabSelf:EnsureGroup()
return grp[method](grp, ...)
end
end
function Groupbox:BuildHeader(card, info)
local height, radius = Config.Group.Header, Config.Group.Radius
local collapsed = info.Collapsed == true
local bar = Draw.Box("TextButton", { Name = "Header", Size = UDim2.new(1, 0, 0, height), Parent = card }, "PanelHeader", nil, radius)
self.HeaderPatch = Draw.Box("Frame", { Position = UDim2.new(0, 0, 1, -radius), Size = UDim2.new(1, 0, 0, radius), Visible = not collapsed, BackgroundTransparency = collapsed and 1 or 0, Parent = bar }, "PanelHeader")
self.HeaderDivider = Draw.Box("Frame", { AnchorPoint = Vector2.new(0, 1), Position = UDim2.fromScale(0, 1), Size = UDim2.new(1, 0, 0, 2), ZIndex = 2, Visible = not collapsed, BackgroundTransparency = collapsed and 1 or 0, Parent = bar }, "Outline")
local iconSpec = (info.Icon and info.Icon ~= "") and info.Icon or Icons.FromTitle(info.Name, "qblock")
local icon = Icons.Create(bar, iconSpec, 20, nil, info.Name)
icon.AnchorPoint = Vector2.new(0, 0.5)
icon.Position = UDim2.new(0, 10, 0.5, -1)
local offset = 36
local badgeWidth = 0
if info.Badge then
badgeWidth = #tostring(info.Badge) * 8 + 16
local pill = Draw.Box("Frame", { AnchorPoint = Vector2.new(1, 0.5), Position = UDim2.new(1, -34, 0.5, -1), Size = UDim2.fromOffset(badgeWidth, 18), Parent = bar }, "Danger", "DangerDark", 4, 2)
Draw.Text({ Size = UDim2.fromScale(1, 1), TextXAlignment = Enum.TextXAlignment.Center, Parent = pill }, "Body", 12, "OnAccent", tostring(info.Badge))
badgeWidth += 6
end
Draw.Text({ Position = UDim2.fromOffset(offset, 0), Size = UDim2.new(1, -(offset + 34 + badgeWidth), 1, -2), TextTruncate = Enum.TextTruncate.AtEnd, Parent = bar }, "Body", Util.TextSize("Group"), "Text", info.Name or "")
self.Chevron = Icons.Vector(bar, "chevron_down", 14, "Muted")
self.Chevron.AnchorPoint = Vector2.new(1, 0.5)
self.Chevron.Position = UDim2.new(1, -12, 0.5, 0)
self.Chevron.Rotation = collapsed and -90 or 0
bar.Activated:Connect(function()
self:SetCollapsed(not self.Collapsed)
end)
end
function Groupbox:SetCollapsed(collapsed)
collapsed = collapsed == true
if self.Collapsed == collapsed then
return
end
self.Collapsed = collapsed
if collapsed then
Popup.Close()
end
Anim.Tween(self.Open, { Value = collapsed and 0 or 1 }, Config.Tween.Collapse)
Anim.Tween(self.Chevron, { Rotation = collapsed and -90 or 0 }, Config.Tween.Collapse)
end
function Float.TopFloor()
if Float.TopInset then
return Float.TopInset
end
local inset = 0
pcall(function()
local top = game:GetService("GuiService"):GetGuiInset()
if typeof(top) == "Vector2" then
inset = top.Y
end
end)
if State.Touch then
inset = math.max(inset, 58)
end
Float.TopInset = math.max(inset, 0) + 6
return Float.TopInset
end
function Float.Clamp()
local button = Float.Button
if not button or not State.Gui then
return
end
local viewport = State.Gui.AbsoluteSize
if viewport.X <= 0 or viewport.Y <= 0 then
return
end
local pos = button.Position
local absX = viewport.X * pos.X.Scale + pos.X.Offset
local absY = viewport.Y * pos.Y.Scale + pos.Y.Offset
local size = Float.Size or 48
local floorY = Float.TopFloor()
local clampedX = math.clamp(absX, 6, math.max(6, viewport.X - size - 6))
local clampedY = math.clamp(absY, floorY, math.max(floorY, viewport.Y - size - 6))
button.Position = UDim2.fromOffset(math.floor(clampedX + 0.5), math.floor(clampedY + 0.5))
end
function Float.Build()
local size = State.Touch and 56 or 48
local button = Draw.New("TextButton", { Name = "Float", Text = "", AutoButtonColor = false, BackgroundTransparency = 1, Position = UDim2.new(0, 18, 0.45, 0), Size = UDim2.fromOffset(size, size), ZIndex = Config.Layer.Float, Visible = State.Touch, Parent = State.Gui })
local shadow = Draw.Box("Frame", { Position = UDim2.fromOffset(4, 4), Size = UDim2.fromScale(1, 1), BackgroundTransparency = 0.55, Parent = button }, "Shadow", nil, 4)
shadow.ZIndex = 1
local slot = Draw.New("Frame", { BackgroundTransparency = 1, Size = UDim2.fromScale(1, 1), ZIndex = 2, Parent = button })
Float.Button, Float.Slot, Float.Size = button, slot, size
Anim.Tween(slot, { Position = UDim2.fromOffset(0, -3) }, 0.9, "Sine", -1, true)
Float.Render()
local moved = false
Gui.Draggable(button, function(begin, delta)
if not delta then
moved = false
return button.Position
end
moved = moved or delta.Magnitude > Config.DragThreshold
if moved then
button.Position = begin + UDim2.fromOffset(delta.X, delta.Y)
Float.Clamp()
end
return begin
end)
button.Activated:Connect(function()
if moved or not State.Window then
return
end
Anim.Bump(Float.Sprite, 10)
Anim.CoinPop(button, UDim2.new(0.5, 0, 0, 0), 20)
State.Window:Toggle()
end)
end
function Float.Render()
if not Float.Slot then
return
end
if not Float.Sprite then
Float.Sprite = Sprite.New(Float.Slot, "qblock", Float.Size)
Float.Sprite.Name = "Block"
end
end
function Float.SetVisible(visible)
if Float.Button then
Float.Button.Visible = visible
if visible then
Float.Clamp()
end
end
end
function Watermark.Build(title)
local frame = Draw.Box("Frame", { Name = "Watermark", AnchorPoint = Vector2.new(0.5, 0), Position = UDim2.new(0.5, 0, 0, 10), AutomaticSize = Enum.AutomaticSize.X, Size = UDim2.fromOffset(0, 30), ZIndex = Config.Layer.Watermark, Parent = State.Gui }, "Shadow", "Outline", 10, 2)
frame.BackgroundTransparency = 0.25
Draw.Padding(frame, 0, 12, 0, 8)
Draw.List(frame, 10, true, Enum.HorizontalAlignment.Left, Enum.VerticalAlignment.Center)
local slot = Draw.New("Frame", { BackgroundTransparency = 1, Size = UDim2.fromOffset(18, 18), LayoutOrder = 1, Parent = frame })
local coin = Sprite.New(slot, "coin", 18)
coin.AnchorPoint = Vector2.new(0.5, 0)
coin.Position = UDim2.fromScale(0.5, 0)
Anim.Loop("Watermark", coin, { Size = UDim2.fromOffset(3, 18) }, 0.45, "Sine", true)
local name = Draw.Text({ Text = title:upper(), AutomaticSize = Enum.AutomaticSize.X, Size = UDim2.fromOffset(0, 20), LayoutOrder = 2, Parent = frame }, "Logo", Config.Text.Watermark + 1, "Coin")
Draw.Stroke(name, "Ink", 1.5)
Watermark.Stats = {}
for index, key in ipairs({ "Fps", "Ping", "Time" }) do
Watermark.Stats[key] = Draw.Text({ AutomaticSize = Enum.AutomaticSize.X, Size = UDim2.fromOffset(0, 20), LayoutOrder = 2 + index, Parent = frame }, "Body", Config.Text.Watermark, "White")
end
Watermark.Frame = frame
Gui.Draggable(frame, function(begin, delta)
if not delta then
return frame.Position
end
frame.Position = begin + UDim2.fromOffset(delta.X, delta.Y)
return begin
end)
Watermark.Update()
Util.Every(0.5, Watermark.Update)
end
function Watermark.Update()
if not Watermark.Frame or not Watermark.Frame.Visible then
return
end
local ok, ping = pcall(function()
return Stats.Network.ServerStatsItem["Data Ping"]:GetValue()
end)
local elapsed = math.floor(os.clock() - State.StartTime)
Watermark.Stats.Fps.Text = string.format("FPS %d", math.floor(State.Fps + 0.5))
Watermark.Stats.Ping.Text = ok and string.format("PING %dms", math.floor(ping + 0.5)) or "PING --"
Watermark.Stats.Time.Text = string.format("%s %02d:%02d", Lang.Get("Session"), math.floor(elapsed / 60) % 100, elapsed % 60)
end
function Watermark.SetVisible(visible)
if Watermark.Frame then
Watermark.Frame.Visible = visible
Anim.SetGroupActive("Watermark", visible)
Watermark.Update()
end
end
function Particles.Build(parent)
local layer = Draw.New("Frame", { Name = "Particles", BackgroundTransparency = 1, Size = UDim2.fromScale(1, 1), ClipsDescendants = true, ZIndex = 1, Parent = parent })
Particles.Layer = layer
for _ = 1, Config.Particles.Count do
local label = Draw.Text({ AnchorPoint = Vector2.new(0.5, 0.5), TextXAlignment = Enum.TextXAlignment.Center, TextTransparency = 1, Parent = layer }, "Glyph", 12, "ParticleColor")
table.insert(Particles.Pool, { Label = label, Busy = false })
end
Theme.OnRender(Particles, Particles.Restyle)
end
function Particles.Restyle()
for _, entry in ipairs(Particles.Pool) do
entry.Label.Text = Particles.Glyph()
end
end
function Particles.Glyph()
local glyphs = Theme.Colors.ParticleGlyphs
if glyphs and #glyphs > 1 then
return glyphs[math.random(#glyphs)]
end
return Theme.Colors.ParticleGlyph or "✦"
end
function Particles.Active()
local window = State.Window
return Particles.Enabled and window ~= nil and window.Visible and not window.Minimized
end
function Particles.Launch(entry, delay)
if not Particles.Active() or not entry.Label.Parent then
entry.Busy = false
return
end
entry.Busy = true
local label = entry.Label
label.Text = Particles.Glyph()
local fall = Theme.Colors.ParticleFall == true
local size = math.random(9, 16)
local x = math.random()
label.Size = UDim2.fromOffset(size + 4, size + 4)
label.TextSize = size
label.Rotation = 0
label.TextTransparency = 0.35 + math.random() * 0.4
label.Position = UDim2.new(x, 0, fall and -0.06 or 1.06, 0)
local goal = { Position = UDim2.new(x + (math.random() - 0.5) * 0.15, 0, fall and 1.06 or -0.06, 0), Rotation = math.random(-120, 120) }
local duration = Config.Particles.MinTime + math.random() * (Config.Particles.MaxTime - Config.Particles.MinTime)
local tween = Anim.Tween(label, goal, duration, "Linear", 0, false, delay or 0)
tween.Completed:Once(function()
Particles.Launch(entry)
end)
end
function Particles.Resume()
for index, entry in ipairs(Particles.Pool) do
if not entry.Busy then
Particles.Launch(entry, (index - 1) * 0.9)
end
end
end
function Particles.SetEnabled(enabled)
Particles.Enabled = enabled
if Particles.Layer then
Particles.Layer.Visible = enabled
end
if enabled then
Particles.Resume()
end
end
Notify.Icons = { Info = "qblock", Success = "star", Warning = "bomb", Error = "bomb", Coin = "coin", Power = "mushroom" }
function Notify.Build()
local width = State.Touch and Config.Notify.TouchWidth or Config.Notify.Width
State.NotifyHost = Draw.New("Frame", { Name = "Notifications", BackgroundTransparency = 1, AnchorPoint = Vector2.new(1, 1), Position = UDim2.new(1, -14, 1, -14), Size = UDim2.new(0, width + 8, 1, -28), ZIndex = Config.Layer.Notify, Parent = State.Gui })
Draw.List(State.NotifyHost, Config.Notify.Gap, false, Enum.HorizontalAlignment.Right, Enum.VerticalAlignment.Bottom)
end
function Notify.Push(title, content, duration, kind)
local width = State.NotifyHost.Size.X.Offset - 8
local text = Lang.Resolve(content or "")
local textHeight = Layout.Measure(text, Fonts.Size("Desc", Util.TextSize("Desc") + 1), "Desc", width - 68).Y
local height = math.max(58, textHeight + 44)
local holder = Draw.New("Frame", { BackgroundTransparency = 1, Size = UDim2.fromOffset(width + 8, height + 4), ClipsDescendants = false, Parent = State.NotifyHost })
local card = Draw.New("TextButton", { Text = "", AutoButtonColor = false, BackgroundTransparency = 1, Position = UDim2.fromOffset(width + 60, 0), Size = UDim2.fromOffset(width, height), Parent = holder })
Draw.Box("Frame", { Position = UDim2.fromOffset(4, 4), Size = UDim2.fromScale(1, 1), Parent = card }, "Shadow", nil, 12)
local face = Draw.Box("Frame", { Size = UDim2.fromScale(1, 1), ClipsDescendants = true, Parent = card }, "Panel", "Outline", 12, 2)
local icon = Sprite.New(face, Notify.Icons[kind or "Coin"] or "coin", 36)
icon.Position = UDim2.fromOffset(12, 11)
Draw.Text({ Position = UDim2.fromOffset(58, 9), Size = UDim2.new(1, -68, 0, 18), TextTruncate = Enum.TextTruncate.AtEnd, Parent = face }, "Body", Util.TextSize("Group"), "Text", title or "Reicht")
Draw.Text({ Text = text, TextWrapped = true, TextYAlignment = Enum.TextYAlignment.Top, Position = UDim2.fromOffset(58, 29), Size = UDim2.new(1, -68, 0, textHeight), Parent = face }, "Desc", Util.TextSize("Desc") + 1, "SubText")
local timer = Draw.Box("Frame", { AnchorPoint = Vector2.new(0, 1), Position = UDim2.new(0, 0, 1, 0), Size = UDim2.new(1, 0, 0, 4), Parent = face }, "Accent")
duration = duration or Config.Notify.Duration
Anim.Tween(card, { Position = UDim2.fromOffset(0, 0) }, Config.Tween.Notify, "Back")
Anim.Tween(timer, { Size = UDim2.new(0, 0, 0, 4) }, duration, "Linear")
Anim.Bump(icon, 6)
local closed = false
local function Dismiss()
if closed then
return
end
closed = true
local slide = Anim.Tween(card, { Position = UDim2.fromOffset(width + 60, 0) }, 0.22, "In")
slide.Completed:Once(function()
local collapse = Anim.Tween(holder, { Size = UDim2.fromOffset(width + 8, 0) }, 0.16)
collapse.Completed:Once(function()
holder:Destroy()
end)
end)
end
card.Activated:Connect(Dismiss)
task.delay(duration, Dismiss)
end
Intro.Width, Intro.Height, Intro.Ground = 600, 320, 44
Intro.MinStep = 0.22
Intro.StepTimeout = 15
function Intro.Play(settings)
local screen = Draw.New("Frame", { Name = "Loader", BackgroundColor3 = Color3.new(0, 0, 0), BackgroundTransparency = 1, Size = UDim2.fromScale(1, 1), ZIndex = Config.Layer.Intro, Parent = State.Gui })
local ok = Util.Try(Intro.Show, settings, screen)
screen:Destroy()
if Library.Unloaded then
return
end
if not ok and not settings.Ran then
Intro.RunSteps(settings, nil)
end
Util.Try(settings.OnDone)
end
function Intro.Show(settings, screen)
Anim.Tween(screen, { BackgroundTransparency = 0.35 }, 0.3)
local card, scene, scale = Intro.BuildCard(screen)
Intro.BuildScenery(scene)
local block = Sprite.New(scene, "qblock", 48)
block.AnchorPoint = Vector2.new(0.5, 0)
block.Position = UDim2.new(0.5, 0, 0, -70)
local letters = Intro.Letters(scene, settings.Title)
local pill = Intro.Pill(scene, settings.SubTitle)
local track = Intro.Track(scene)
Anim.Tween(scale, { Scale = State.UserScale }, 0.45, "Back")
Anim.Tween(block, { Position = UDim2.new(0.5, 0, 0, 22) }, 0.4, "Bounce")
task.wait(0.42)
Intro.HitBlock(scene, block)
Intro.DropLetters(letters, pill)
Intro.RunSteps(settings, track)
if Library.Unloaded then
return
end
Intro.Finale(scene, track)
task.wait(0.3)
Anim.Tween(scale, { Scale = State.UserScale * 1.06 }, 0.2, "In")
Anim.Tween(card, { GroupTransparency = 1 }, 0.2)
Anim.Tween(screen, { BackgroundTransparency = 1 }, 0.2)
task.wait(0.2)
end
function Intro.BuildCard(screen)
local width, height = Intro.Width, Intro.Height
local pad, shadow = 4, 6
local card = Draw.New("CanvasGroup", { AnchorPoint = Vector2.new(0.5, 0.5), Position = UDim2.fromScale(0.5, 0.5), Size = UDim2.fromOffset(width + pad + shadow, height + pad + shadow), BackgroundTransparency = 1, Parent = screen })
local scale = Draw.New("UIScale", { Scale = State.UserScale * 0.6, Parent = card })
Draw.Box("Frame", { Position = UDim2.fromOffset(pad + shadow, pad + shadow), Size = UDim2.fromOffset(width, height), Parent = card }, "Shadow", nil, 18)
local scene = Draw.Box("Frame", { Position = UDim2.fromOffset(pad, pad), Size = UDim2.fromOffset(width, height), BackgroundColor3 = Color3.new(1, 1, 1), BackgroundTransparency = 0, ClipsDescendants = true, Parent = card }, nil, nil, 18)
local gradient = Draw.New("UIGradient", { Rotation = 90, Color = ColorSequence.new(Theme.Colors.Topbar, Theme.Colors.Backdrop), Parent = scene })
gradient.Enabled = true
local border = Draw.New("Frame", { BackgroundTransparency = 1, Position = UDim2.fromOffset(pad, pad), Size = UDim2.fromOffset(width, height), ZIndex = 20, Parent = card })
Draw.Corner(border, 18)
Draw.Stroke(border, "Outline", 3, true)
return card, scene, scale
end
function Intro.BuildScenery(scene)
local ground = Intro.Ground
local sky = Draw.New("Frame", { BackgroundTransparency = 1, Size = UDim2.new(1, 0, 1, -ground), ClipsDescendants = true, ZIndex = 1, Parent = scene })
for _, hill in ipairs({ { 0.14, 150, "GrassDark" }, { 0.3, 90, "Grass" }, { 0.8, 120, "GrassDark" } }) do
local mound = Draw.Box("Frame", { AnchorPoint = Vector2.new(0.5, 0.5), Position = UDim2.new(hill[1], 0, 1, 0), Size = UDim2.fromOffset(hill[2], hill[2]), BackgroundTransparency = 0.35, Parent = sky }, hill[3], nil, UDim.new(1, 0))
mound.ZIndex = 1
end
for index, spot in ipairs({ { 0.12, 30, 64 }, { 0.62, 18, 50 }, { 0.84, 64, 40 } }) do
local cloud = Draw.Cloud(sky, spot[3])
cloud.Position = UDim2.new(spot[1], 0, 0, spot[2])
cloud.ZIndex = 1
Anim.Tween(cloud, { Position = UDim2.new(spot[1], 36, 0, spot[2]) }, 5 + index, "Sine", -1, true)
end
local floor = Draw.Box("Frame", { AnchorPoint = Vector2.new(0, 1), Position = UDim2.fromScale(0, 1), Size = UDim2.new(1, 0, 0, ground), ClipsDescendants = true, ZIndex = 3, Parent = scene }, "Brick", nil, 18)
Draw.Box("Frame", { Size = UDim2.new(1, 0, 0, 18), ZIndex = 3, Parent = floor }, "Brick")
local bricks = Draw.New("Frame", { BackgroundTransparency = 1, Position = UDim2.fromOffset(6, 10), Size = UDim2.new(1, -12, 1, -14), ClipsDescendants = true, ZIndex = 3, Parent = floor })
Draw.Bricks(bricks, 18, "BrickDark")
for _, line in ipairs(bricks:GetChildren()) do
line.ZIndex = 3
end
Draw.Box("Frame", { Size = UDim2.new(1, 0, 0, 8), ZIndex = 4, Parent = floor }, "Grass")
Draw.Box("Frame", { Position = UDim2.fromOffset(0, 8), Size = UDim2.new(1, 0, 0, 2), ZIndex = 4, Parent = floor }, "GrassDark")
end
function Intro.Letters(scene, title)
local row = Draw.New("Frame", { BackgroundTransparency = 1, AnchorPoint = Vector2.new(0.5, 0), Position = UDim2.new(0.5, 0, 0, 92), Size = UDim2.fromOffset(Intro.Width, 54), ZIndex = 5, Parent = scene })
Draw.List(row, 2, true, Enum.HorizontalAlignment.Center, Enum.VerticalAlignment.Center)
local letters = {}
local size, colorIndex = 46, 0
for char in tostring(title):upper():gmatch(utf8.charpattern) do
local bounds = Layout.Measure(char, size, "Logo", 300)
local slot = Draw.New("Frame", { BackgroundTransparency = 1, Size = UDim2.fromOffset(char == " " and 14 or bounds.X, size + 8), LayoutOrder = #letters + 1, ZIndex = 5, Parent = row })
local letter = Draw.Text({ Text = char, Size = UDim2.fromScale(1, 1), Position = UDim2.fromOffset(0, -140), TextXAlignment = Enum.TextXAlignment.Center, ZIndex = 5, Parent = slot }, "Logo", size, Config.TitleColors[colorIndex % #Config.TitleColors + 1])
Draw.Stroke(letter, "Ink", 3)
table.insert(letters, letter)
colorIndex += char == " " and 0 or 1
end
return letters
end
function Intro.Pill(scene, text)
local pill = Draw.Box("Frame", { AnchorPoint = Vector2.new(0.5, 0), Position = UDim2.new(0.5, 0, 0, 156), AutomaticSize = Enum.AutomaticSize.X, Size = UDim2.fromOffset(0, 26), BackgroundTransparency = 1, ZIndex = 5, Parent = scene }, "Shadow", nil, UDim.new(1, 0))
Draw.Padding(pill, 0, 14, 0, 14)
local label = Draw.Text({ Text = "WORLD 1-1" .. ((text and text ~= "") and ("  ·  " .. text) or ""), AutomaticSize = Enum.AutomaticSize.X, Size = UDim2.fromScale(0, 1), TextTransparency = 1, ZIndex = 6, Parent = pill }, "Body", 14, "White")
return { Frame = pill, Label = label }
end
function Intro.Track(scene)
local ground = Intro.Ground
local status = Draw.Text({ Position = UDim2.new(0, 22, 1, -(ground + 58)), Size = UDim2.new(1, -120, 0, 20), ZIndex = 6, Parent = scene }, "Body", 15, "White")
Draw.Stroke(status, "Ink", 1.5)
local percent = Draw.Text({ AnchorPoint = Vector2.new(1, 0), Position = UDim2.new(1, -22, 1, -(ground + 60)), Size = UDim2.fromOffset(80, 22), TextXAlignment = Enum.TextXAlignment.Right, Text = "0%", ZIndex = 6, Parent = scene }, "Logo", 20, "Coin")
Draw.Stroke(percent, "Ink", 2)
local flag = Sprite.New(scene, "flag", 36)
flag.AnchorPoint = Vector2.new(1, 1)
flag.Position = UDim2.new(1, -18, 1, -ground)
flag.ZIndex = 5
local runner = Draw.New("Frame", { BackgroundTransparency = 1, AnchorPoint = Vector2.new(0, 1), Position = UDim2.new(0, 18, 1, -ground), Size = UDim2.fromOffset(28, 28), ZIndex = 6, Parent = scene })
local body = Sprite.New(runner, "mushroom", 24)
body.Position = UDim2.fromOffset(2, 4)
Anim.Tween(body, { Position = UDim2.fromOffset(2, 0) }, 0.16, "Sine", -1, true)
local progress = Draw.New("NumberValue", { Value = 0 })
progress.Changed:Connect(function(value)
percent.Text = math.floor(value * 100 + 0.5) .. "%"
runner.Position = UDim2.new(0, 18 + (Intro.Width - 100) * value, 1, -ground)
end)
return { Status = status, Progress = progress, Flag = flag, Runner = runner }
end
function Intro.HitBlock(scene, block)
Anim.Bump(block, 14)
Anim.CoinPop(scene, UDim2.new(0.5, 0, 0, 22), 30)
task.delay(0.1, function()
local used = Sprite.New(scene, "used", 48)
used.AnchorPoint, used.Position, used.ZIndex = block.AnchorPoint, UDim2.new(0.5, 0, 0, 22), block.ZIndex
block:Destroy()
end)
end
function Intro.DropLetters(letters, pill)
for index, letter in ipairs(letters) do
Anim.Tween(letter, { Position = UDim2.new() }, 0.55, "Bounce", 0, false, index * 0.05)
end
Anim.Tween(pill.Frame, { BackgroundTransparency = 0.45 }, 0.3, "Out", 0, false, 0.4)
Anim.Tween(pill.Label, { TextTransparency = 0 }, 0.3, "Out", 0, false, 0.4)
end
function Intro.RunSteps(settings, track)
local steps = settings.Steps
for index, step in ipairs(steps) do
if Library.Unloaded then
return
end
if step.Started then
continue
end
step.Started = true
if track then track.Status.Text = Lang.Resolve(step.Label) end
local started = os.clock()
if step.Run then
Util.Await(Intro.StepTimeout, step.Run)
end
if not track then
continue
end
Anim.Tween(track.Progress, { Value = index / #steps }, 0.2, "Out")
local remaining = Intro.MinStep - (os.clock() - started)
if remaining > 0 then
task.wait(remaining)
end
end
settings.Ran = true
end
function Intro.Finale(scene, track)
Anim.Bump(track.Flag, 10)
local origin = UDim2.new(1, -36, 1, -(Intro.Ground + 30))
for index = 1, 8 do
local angle = math.rad(index * 45)
local star = Sprite.New(scene, "star", 18)
star.AnchorPoint = Vector2.new(0.5, 0.5)
star.Position = origin
star.ZIndex = 7
local fly = Anim.Tween(star, { Position = origin + UDim2.fromOffset(math.cos(angle) * 70, math.sin(angle) * 70), Rotation = 180 }, 0.5, "Out")
fly.Completed:Once(function()
star:Destroy()
end)
end
end
local Visuals = {
Settings = {
Enabled = false,
Preview = false,
Box = true,
BoxStyle = "Full",
BoxFill = false,
Name = true,
Health = true,
HealthText = false,
Distance = true,
Tracer = false,
TracerOrigin = "Bottom",
HeadDot = false,
Chams = false,
Arrows = false,
Radar = false,
RadarRange = 250,
RadarSize = 180,
TeamCheck = true,
MaxDistance = 2000,
TextSize = 13,
EnemyColor = Color3.fromRGB(232, 88, 76),
FriendColor = Color3.fromRGB(96, 196, 120),
},
Entries = {},
Targets = {},
Provider = nil,
LastScan = 0,
ScanInterval = 0.2,
Preview = {},
}
function Visuals.DefaultProvider()
local targets = {}
for _, player in ipairs(Players:GetPlayers()) do
if player == LocalPlayer then
continue
end
local char = player.Character
local hum = char and char:FindFirstChildOfClass("Humanoid")
if hum then
targets[#targets + 1] = {
Model = char,
Name = player.DisplayName,
Health = hum.Health,
MaxHealth = hum.MaxHealth,
Friendly = player.Team ~= nil and player.Team == LocalPlayer.Team,
}
end
end
return targets
end
function Visuals.EnsureGui()
if Visuals.Gui and Visuals.Gui.Parent then
return Visuals.Gui
end
Visuals.Gui = Draw.New("ScreenGui", { Name = "MarioVisuals", IgnoreGuiInset = true, ResetOnSpawn = false, DisplayOrder = 5, ZIndexBehavior = Enum.ZIndexBehavior.Sibling, Parent = Util.GuiParent() })
return Visuals.Gui
end
function Visuals.Line(parent, color)
return Draw.New("Frame", { AnchorPoint = Vector2.new(0.5, 0.5), BackgroundColor3 = color, Visible = false, Parent = parent })
end
function Visuals.Label(parent, alignY)
local label = Draw.New("TextLabel", {
BackgroundTransparency = 1,
AnchorPoint = Vector2.new(0.5, alignY),
Size = UDim2.fromOffset(200, 16),
Font = Enum.Font.GothamBold,
TextColor3 = Color3.new(1, 1, 1),
TextStrokeTransparency = 0.35,
Visible = false,
Parent = parent,
})
return label
end
function Visuals.BuildEntry(parent)
local entry = {}
entry.Box = Draw.New("Frame", { BackgroundTransparency = 1, Visible = false, Parent = parent })
entry.BoxStroke = Draw.New("UIStroke", { Thickness = 1.5, Parent = entry.Box })
entry.BoxOutline = Draw.New("Frame", { BackgroundTransparency = 1, Position = UDim2.fromOffset(-1, -1), Size = UDim2.new(1, 2, 1, 2), Parent = entry.Box })
Draw.New("UIStroke", { Thickness = 1, Color = Color3.new(0, 0, 0), Transparency = 0.3, Parent = entry.BoxOutline })
entry.Corners = {}
for index = 1, 8 do
entry.Corners[index] = Draw.New("Frame", { BorderSizePixel = 0, Visible = false, Parent = parent })
end
entry.HealthBack = Draw.New("Frame", { BackgroundColor3 = Color3.new(0, 0, 0), BackgroundTransparency = 0.35, Visible = false, Parent = parent })
entry.HealthFill = Draw.New("Frame", { AnchorPoint = Vector2.new(0, 1), Position = UDim2.fromScale(0, 1), Parent = entry.HealthBack })
entry.HealthText = Visuals.Label(parent, 0.5)
entry.Name = Visuals.Label(parent, 1)
entry.Distance = Visuals.Label(parent, 0)
entry.Tracer = Visuals.Line(parent, Color3.new(1, 1, 1))
entry.Dot = Draw.New("Frame", { AnchorPoint = Vector2.new(0.5, 0.5), Size = UDim2.fromOffset(6, 6), Visible = false, Parent = parent })
Draw.Corner(entry.Dot, 3)
entry.Arrow = Visuals.Label(parent, 0.5)
entry.Arrow.Text = "▲"
entry.Arrow.Size = UDim2.fromOffset(20, 20)
return entry
end
function Visuals.HideEntry(entry)
entry.Box.Visible = false
for _, corner in ipairs(entry.Corners) do
corner.Visible = false
end
entry.HealthBack.Visible, entry.HealthText.Visible = false, false
entry.Name.Visible, entry.Distance.Visible = false, false
entry.Tracer.Visible, entry.Dot.Visible, entry.Arrow.Visible = false, false, false
if entry.Highlight then
entry.Highlight.Enabled = false
end
end
function Visuals.DestroyEntry(entry)
for _, key in ipairs({ "Box", "HealthBack", "HealthText", "Name", "Distance", "Tracer", "Dot", "Arrow", "Highlight" }) do
if entry[key] then
entry[key]:Destroy()
end
end
for _, corner in ipairs(entry.Corners) do
corner:Destroy()
end
end
function Visuals.SetLine(line, from, to, thickness)
local delta = to - from
line.Position = UDim2.fromOffset((from.X + to.X) / 2, (from.Y + to.Y) / 2)
line.Size = UDim2.fromOffset(delta.Magnitude, thickness)
line.Rotation = math.deg(math.atan2(delta.Y, delta.X))
line.Visible = true
end
function Visuals.Layout(entry, x, y, w, h, info, color, origin)
local settings = Visuals.Settings
local full = settings.Box and settings.BoxStyle ~= "Corner"
entry.Box.Visible = full
if full then
entry.Box.Position, entry.Box.Size = UDim2.fromOffset(x, y), UDim2.fromOffset(w, h)
entry.BoxStroke.Color = color
entry.Box.BackgroundTransparency = settings.BoxFill and 0.82 or 1
entry.Box.BackgroundColor3 = color
end
local corner = settings.Box and settings.BoxStyle == "Corner"
local cw, ch = math.max(w / 4, 3), math.max(h / 5, 3)
local spots = {
{ x, y, cw, 2 }, { x, y, 2, ch }, { x + w - cw, y, cw, 2 }, { x + w - 2, y, 2, ch },
{ x, y + h - 2, cw, 2 }, { x, y + h - ch, 2, ch }, { x + w - cw, y + h - 2, cw, 2 }, { x + w - 2, y + h - ch, 2, ch },
}
for index, piece in ipairs(entry.Corners) do
piece.Visible = corner
if corner then
local spot = spots[index]
piece.Position, piece.Size, piece.BackgroundColor3 = UDim2.fromOffset(spot[1], spot[2]), UDim2.fromOffset(spot[3], spot[4]), color
end
end
local ratio = math.clamp((info.Health or 0) / math.max(info.MaxHealth or 100, 1), 0, 1)
entry.HealthBack.Visible = settings.Health
if settings.Health then
entry.HealthBack.Position, entry.HealthBack.Size = UDim2.fromOffset(x - 6, y), UDim2.fromOffset(3, h)
entry.HealthFill.Size = UDim2.fromScale(1, ratio)
entry.HealthFill.BackgroundColor3 = Color3.fromRGB(232, 88, 76):Lerp(Color3.fromRGB(96, 214, 110), ratio)
end
entry.HealthText.Visible = settings.HealthText
if settings.HealthText then
local hpInt = math.floor(info.Health or 0)
if entry.LastHp ~= hpInt then
entry.LastHp = hpInt
entry.HealthText.Text = tostring(hpInt)
end
entry.HealthText.TextSize = settings.TextSize - 2
entry.HealthText.Position = UDim2.fromOffset(x - 20, y + h * (1 - ratio))
end
entry.Name.Visible = settings.Name
if settings.Name then
local nameStr = info.Name or ""
if entry.LastName ~= nameStr then
entry.LastName = nameStr
entry.Name.Text = nameStr
end
entry.Name.TextSize, entry.Name.TextColor3 = settings.TextSize, color
entry.Name.Position = UDim2.fromOffset(x + w / 2, y - 2)
end
entry.Distance.Visible = settings.Distance and info.Distance ~= nil
if entry.Distance.Visible then
local distInt = math.floor(info.Distance)
if entry.LastDist ~= distInt then
entry.LastDist = distInt
entry.Distance.Text = distInt .. "m"
end
entry.Distance.TextSize = settings.TextSize - 1
entry.Distance.Position = UDim2.fromOffset(x + w / 2, y + h + 2)
end
entry.Dot.Visible = settings.HeadDot
if settings.HeadDot then
entry.Dot.Position, entry.Dot.BackgroundColor3 = UDim2.fromOffset(x + w / 2, y + h * 0.1), color
end
if settings.Tracer and origin then
entry.Tracer.BackgroundColor3 = color
Visuals.SetLine(entry.Tracer, origin, Vector2.new(x + w / 2, y + h), 1.5)
else
entry.Tracer.Visible = false
end
end
function Visuals.TracerOrigin(viewport)
local mode = Visuals.Settings.TracerOrigin
if mode == "Center" then
return viewport / 2
end
if mode == "Mouse" then
return UserInputService:GetMouseLocation()
end
return Vector2.new(viewport.X / 2, viewport.Y)
end
function Visuals.Chams(entry, model, color, on)
if not on then
if entry.Highlight then
entry.Highlight.Enabled = false
end
return
end
if not entry.Highlight then
entry.Highlight = Draw.New("Highlight", { DepthMode = Enum.HighlightDepthMode.AlwaysOnTop, FillTransparency = 0.55, OutlineTransparency = 0, Parent = Visuals.EnsureGui() })
end
entry.Highlight.Adornee = model
entry.Highlight.FillColor, entry.Highlight.OutlineColor = color, color
entry.Highlight.Enabled = true
end
function Visuals.Arrow(entry, screen, viewport, color)
local center = viewport / 2
local dir = Vector2.new(screen.X, screen.Y) - center
if screen.Z < 0 then
dir = -dir
end
if dir.Magnitude < 1 then
return
end
local unit = dir.Unit
local radius = math.min(viewport.X, viewport.Y) / 2 - 40
local pos = center + unit * radius
entry.Arrow.Position = UDim2.fromOffset(pos.X, pos.Y)
entry.Arrow.Rotation = math.deg(math.atan2(unit.Y, unit.X)) + 90
entry.Arrow.TextColor3 = color
entry.Arrow.TextSize = 18
entry.Arrow.Visible = true
end
function Visuals.Scan()
local now = os.clock()
if now - Visuals.LastScan < Visuals.ScanInterval then
return
end
Visuals.LastScan = now
local ok, list = pcall(Visuals.Provider or Visuals.DefaultProvider)
Visuals.Targets = ok and type(list) == "table" and list or {}
end
function Visuals.Render()
local settings = Visuals.Settings
if not settings.Enabled then
return
end
Visuals.Scan()
local cam = Workspace.CurrentCamera
if not cam then
return
end
local gui = Visuals.EnsureGui()
local viewport = cam.ViewportSize
local origin = Visuals.TracerOrigin(viewport)
local camPos = cam.CFrame.Position
local seen = {}
for _, info in ipairs(Visuals.Targets) do
local model = info.Model
if typeof(model) ~= "Instance" or not model.Parent then
continue
end
if settings.TeamCheck and info.Friendly then
continue
end
local root = info.Root or model:FindFirstChild("HumanoidRootPart") or model.PrimaryPart
if not root then
continue
end
local distance = (root.Position - camPos).Magnitude
if distance > settings.MaxDistance then
continue
end
seen[model] = true
local entry = Visuals.Entries[model]
if not entry then
entry = Visuals.BuildEntry(gui)
Visuals.Entries[model] = entry
end
local color = info.Color or (info.Friendly and settings.FriendColor or settings.EnemyColor)
Visuals.Chams(entry, info.Adornee or model, color, settings.Chams and (info.Adornee ~= false))
local top, onTop = cam:WorldToViewportPoint(root.Position + Vector3.new(0, 3, 0))
local bottom, onBottom = cam:WorldToViewportPoint(root.Position - Vector3.new(0, 3.5, 0))
if not (onTop and onBottom) then
Visuals.HideEntry(entry)
if settings.Chams and entry.Highlight then
entry.Highlight.Enabled = true
end
if settings.Arrows then
Visuals.Arrow(entry, cam:WorldToViewportPoint(root.Position), viewport, color)
end
continue
end
entry.Arrow.Visible = false
local h = math.max(bottom.Y - top.Y, 4)
local w = h * 0.55
info.Distance = distance
Visuals.Layout(entry, top.X - w / 2, top.Y, w, h, info, color, origin)
end
for model, entry in pairs(Visuals.Entries) do
if not seen[model] then
if model.Parent then
Visuals.HideEntry(entry)
else
Visuals.DestroyEntry(entry)
Visuals.Entries[model] = nil
end
end
end
end
function Visuals.ClearAll()
for model, entry in pairs(Visuals.Entries) do
Visuals.DestroyEntry(entry)
Visuals.Entries[model] = nil
end
end
function Visuals:SetProvider(provider)
self.Provider = provider
self.LastScan = 0
end
function Visuals:Set(key, value)
self.Settings[key] = value
if key == "Enabled" and not value then
Visuals.ClearAll()
elseif key == "Preview" then
Visuals.PreviewSetVisible(value)
end
Visuals.PreviewRender()
end
function Visuals:Get(key)
return self.Settings[key]
end
function Visuals:SetEnabled(on)
self:Set("Enabled", on == true)
end
function Visuals:SetPreview(on)
self:Set("Preview", on == true)
end
function Visuals.PreviewBuild()
local window = State.Window
if not window or Visuals.Preview.Frame then
return
end
local panel = Draw.Box("Frame", { Name = "EspPreview", Position = UDim2.new(1, 6, 0, 0), Size = UDim2.new(0, 230, 1, -Config.Window.Shadow), BackgroundTransparency = 0, Visible = false, ClipsDescendants = true, Parent = window.Root }, "Backdrop", "Outline", Config.Window.Radius, Config.Window.Stroke)
local title = Draw.Text({ Position = UDim2.fromOffset(12, 8), Size = UDim2.new(1, -24, 0, 22) }, "Display", Util.TextSize("Group"), "Text", { EN = "ESP Preview", TH = "ตัวอย่าง ESP" })
title.Parent = panel
local view = Draw.New("ViewportFrame", { Position = UDim2.fromOffset(10, 38), Size = UDim2.new(1, -20, 1, -48), BackgroundColor3 = Color3.fromRGB(18, 18, 24), BackgroundTransparency = 0.15, Ambient = Color3.fromRGB(180, 180, 190), LightColor = Color3.new(1, 1, 1), Parent = panel })
Draw.Corner(view, 8)
local cam = Draw.New("Camera", { FieldOfView = 40, Parent = view })
view.CurrentCamera = cam
local overlay = Draw.New("Frame", { BackgroundTransparency = 1, Size = UDim2.fromScale(1, 1), ZIndex = 3, Parent = view })
Visuals.Preview = { Frame = panel, View = view, Camera = cam, Overlay = overlay, Entry = Visuals.BuildEntry(overlay), Angle = 0 }
Util.Connect(view:GetPropertyChangedSignal("AbsoluteSize"), Visuals.PreviewRender)
Util.Connect(window.Root:GetPropertyChangedSignal("Size"), Visuals.PreviewRender)
end
function Visuals.PreviewModel()
local preview = Visuals.Preview
if preview.Model and preview.Model.Parent then
return preview.Model
end
local char = LocalPlayer.Character
if not char then
return nil
end
local archivable = char.Archivable
char.Archivable = true
local ok, clone = pcall(char.Clone, char)
char.Archivable = archivable
if not ok or not clone then
return nil
end
for _, item in ipairs(clone:GetDescendants()) do
if item:IsA("LuaSourceContainer") or item:IsA("Sound") or item:IsA("ForceField") then
item:Destroy()
elseif item:IsA("BasePart") then
item.Anchored = true
item:SetAttribute("MarioColor", item.Color)
end
end
clone:PivotTo(CFrame.new())
clone.Parent = preview.View
local box, size = clone:GetBoundingBox()
preview.Model, preview.Size, preview.Center = clone, size, box.Position
return clone
end
function Visuals.PreviewChams(model, color, on)
for _, part in ipairs(model:GetDescendants()) do
if part:IsA("BasePart") and part.Transparency < 1 then
local base = part:GetAttribute("MarioColor")
if base then
part.Color = on and color or base
part.Material = on and Enum.Material.ForceField or Enum.Material.SmoothPlastic
end
end
end
end
function Visuals.PreviewWanted()
local window = State.Window
return Visuals.Settings.Preview and window ~= nil and window.Visible and not window.Minimized
and (Visuals.PreviewTab == nil or window.ActiveTab == Visuals.PreviewTab)
end
function Visuals.PreviewShow(on)
local preview = Visuals.Preview
if not preview.Frame or preview.Shown == on then
return
end
preview.Shown = on
local open, tucked = UDim2.new(1, 6, 0, 0), UDim2.new(1, -236, 0, 0)
if on then
preview.Frame.Position = tucked
preview.Frame.Visible = true
preview.Pulse = 0
Anim.Tween(preview.Frame, { Position = open }, Config.Tween.Pop, "Back")
Anim.Bump(preview.View, 8)
Visuals.PreviewRender()
return
end
local slide = Anim.Tween(preview.Frame, { Position = tucked }, Config.Tween.Fast, "In")
slide.Completed:Once(function()
if not preview.Shown then
preview.Frame.Visible = false
end
end)
end
function Visuals.PreviewRender()
local preview = Visuals.Preview
local window = State.Window
if not (preview.Frame and window and preview.Shown) then
return
end
preview.Frame.Size = UDim2.fromOffset(230, window.Size.Y)
local model = Visuals.PreviewModel()
if model then
local root = Visuals.PreviewRoot()
local center = (root and root.Position or Vector3.zero) - Vector3.new(0, 0.25, 0)
local fit = 6.5 / 0.55 / (2 * math.tan(math.rad(preview.Camera.FieldOfView) / 2))
preview.Camera.CFrame = CFrame.lookAt(center + Vector3.new(0, 0, fit), center)
local settings = Visuals.Settings
Visuals.PreviewChams(model, settings.EnemyColor, settings.Enabled and settings.Chams)
end
Visuals.PreviewDraw()
end
function Visuals.PreviewRoot()
local model = Visuals.Preview.Model
return model and (model:FindFirstChild("HumanoidRootPart") or model.PrimaryPart)
end
function Visuals.PreviewProject(pos, size)
local cam = Visuals.Preview.Camera
local rel = cam.CFrame:PointToObjectSpace(pos)
local depth = math.max(-rel.Z, 0.01)
local half = math.tan(math.rad(cam.FieldOfView) / 2)
return Vector2.new((0.5 + rel.X / depth / (2 * half * size.X / size.Y)) * size.X, (0.5 - rel.Y / depth / (2 * half)) * size.Y)
end
function Visuals.PreviewDraw()
local preview = Visuals.Preview
local size = preview.View.AbsoluteSize
local root = Visuals.PreviewRoot()
if size.X <= 0 or size.Y <= 0 or not root or not Visuals.Settings.Enabled then
Visuals.HideEntry(preview.Entry)
return
end
local t = preview.Pulse or 0
local top = Visuals.PreviewProject(root.Position + Vector3.new(0, 3, 0), size)
local bottom = Visuals.PreviewProject(root.Position - Vector3.new(0, 3.5, 0), size)
local h = math.max(bottom.Y - top.Y, 4)
local w = h * 0.55
local x, y = top.X - w / 2, top.Y
local info = {
Name = LocalPlayer.DisplayName,
Health = 55 + 45 * math.cos(t * 0.9),
MaxHealth = 100,
Distance = 24 + 10 * math.sin(t * 0.5),
}
Visuals.Layout(preview.Entry, x, y, w, h, info, Visuals.Settings.EnemyColor, Vector2.new(size.X / 2, size.Y))
end
function Visuals.PreviewSetVisible()
Visuals.PreviewBuild()
Visuals.PreviewShow(Visuals.PreviewWanted())
end
function Visuals.PreviewStep(deltaTime)
local preview = Visuals.Preview
if not preview.Frame then
return
end
local wanted = Visuals.PreviewWanted()
if wanted ~= (preview.Shown == true) then
Visuals.PreviewShow(wanted)
end
if not preview.Shown then
return
end
preview.Pulse = (preview.Pulse or 0) + deltaTime
Visuals.PreviewDraw()
if preview.Model then
preview.Angle = (preview.Angle + deltaTime * 0.6) % (math.pi * 2)
preview.Model:PivotTo(CFrame.Angles(0, preview.Angle, 0))
end
end
Visuals.Radar = { Dots = {} }
function Visuals.RadarBuild()
local radar = Visuals.Radar
if radar.Frame and radar.Frame.Parent then
return radar
end
local gui = Visuals.EnsureGui()
local frame = Draw.New("Frame", { Name = "Radar", Position = UDim2.fromOffset(24, 180), BackgroundColor3 = Color3.fromRGB(16, 16, 22), BackgroundTransparency = 0.25, Visible = false, Parent = gui })
Draw.New("UICorner", { CornerRadius = UDim.new(0.5, 0), Parent = frame })
Draw.New("UIStroke", { Thickness = 2, Color = Color3.fromRGB(232, 160, 76), Transparency = 0.2, Parent = frame })
for _, horizontal in ipairs({ true, false }) do
Draw.New("Frame", {
AnchorPoint = Vector2.new(0.5, 0.5), Position = UDim2.fromScale(0.5, 0.5),
Size = horizontal and UDim2.new(1, -12, 0, 1) or UDim2.new(0, 1, 1, -12),
BackgroundColor3 = Color3.new(1, 1, 1), BackgroundTransparency = 0.8, Parent = frame,
})
end
local ring = Draw.New("Frame", { AnchorPoint = Vector2.new(0.5, 0.5), Position = UDim2.fromScale(0.5, 0.5), Size = UDim2.fromScale(0.5, 0.5), BackgroundTransparency = 1, Parent = frame })
Draw.New("UICorner", { CornerRadius = UDim.new(0.5, 0), Parent = ring })
Draw.New("UIStroke", { Thickness = 1, Color = Color3.new(1, 1, 1), Transparency = 0.75, Parent = ring })
local me = Draw.New("TextLabel", { AnchorPoint = Vector2.new(0.5, 0.5), Position = UDim2.fromScale(0.5, 0.5), Size = UDim2.fromOffset(16, 16), BackgroundTransparency = 1, Text = "▲", TextSize = 14, Font = Enum.Font.GothamBold, TextColor3 = Color3.new(1, 1, 1), ZIndex = 3, Parent = frame })
radar.Frame, radar.Me = frame, me
Gui.Draggable(frame, function(begin, delta)
if not begin then
return frame.Position
end
frame.Position = begin + UDim2.fromOffset(delta.X, delta.Y)
end)
return radar
end
function Visuals.RadarDot(index)
local radar = Visuals.Radar
local dot = radar.Dots[index]
if not dot then
dot = Draw.New("Frame", { AnchorPoint = Vector2.new(0.5, 0.5), Size = UDim2.fromOffset(7, 7), ZIndex = 2, Parent = radar.Frame })
Draw.New("UICorner", { CornerRadius = UDim.new(0.5, 0), Parent = dot })
radar.Dots[index] = dot
end
return dot
end
function Visuals.RadarRender()
local settings = Visuals.Settings
local radar = Visuals.Radar
if not settings.Radar then
if radar.Frame then
radar.Frame.Visible = false
end
return
end
Visuals.RadarBuild()
Visuals.Scan()
local cam = Workspace.CurrentCamera
local char = LocalPlayer.Character
local root = char and char:FindFirstChild("HumanoidRootPart")
local size = settings.RadarSize
radar.Frame.Size = UDim2.fromOffset(size, size)
radar.Frame.Visible = cam ~= nil and root ~= nil
if not radar.Frame.Visible then
return
end
local look = cam.CFrame.LookVector * Vector3.new(1, 0, 1)
look = look.Magnitude > 0 and look.Unit or Vector3.new(0, 0, -1)
local right = Vector3.new(-look.Z, 0, look.X)
local radius = size / 2 - 6
local used = 0
for _, info in ipairs(Visuals.Targets) do
local model = info.Model
local part = info.Root or (typeof(model) == "Instance" and (model:FindFirstChild("HumanoidRootPart") or model.PrimaryPart))
if not part or (settings.TeamCheck and info.Friendly) then
continue
end
local rel = part.Position - root.Position
local offset = Vector2.new(rel:Dot(right), -rel:Dot(look)) / (settings.RadarRange or 250) * radius
local outside = offset.Magnitude > radius
if outside then
offset = offset.Unit * radius
end
used += 1
local dot = Visuals.RadarDot(used)
dot.Position = UDim2.new(0.5, offset.X, 0.5, offset.Y)
dot.BackgroundColor3 = info.Color or (info.Friendly and settings.FriendColor or settings.EnemyColor)
dot.BackgroundTransparency = outside and 0.55 or 0
dot.Visible = true
end
for index = used + 1, #radar.Dots do
radar.Dots[index].Visible = false
end
end
function Visuals.Start()
if Visuals.Started then
return
end
Visuals.Started = true
Util.Connect(RunService.RenderStepped, function(deltaTime)
Visuals.Render()
Visuals.RadarRender()
Visuals.PreviewStep(deltaTime)
end)
table.insert(State.UnloadHooks, function()
Visuals.ClearAll()
if Visuals.Gui then
Visuals.Gui:Destroy()
Visuals.Gui = nil
end
end)
end
function Window:AddVisualsTab(options)
options = options or {}
Visuals.Start()
if options.Provider then
Visuals:SetProvider(options.Provider)
end
local T = function(en, th) return { EN = en, TH = th } end
local function Bind(key)
return function(value)
Visuals:Set(key, value)
end
end
local tab = self:AddTab(options.Name or T("Visuals", "การมองเห็น"), options.Icon or "eye", options.Description or T("Player ESP", "ESP ผู้เล่น"))
Visuals.PreviewTab = tab
Visuals:SetPreview(options.Preview == true)
local main = tab:AddLeftGroupbox(T("ESP", "ESP"), "eye")
main:AddToggle("MarioEsp", { Text = T("Enable ESP", "เปิด ESP"), Callback = Bind("Enabled") })
main:AddToggle("MarioEspTeam", { Text = T("Team check", "เช็คทีม"), Default = true, Callback = Bind("TeamCheck") })
main:AddSlider("MarioEspRange", { Text = T("Max distance", "ระยะสูงสุด"), Min = 50, Max = 5000, Default = 2000, Suffix = "m", Callback = Bind("MaxDistance") })
main:AddSlider("MarioEspText", { Text = T("Text size", "ขนาดตัวอักษร"), Min = 9, Max = 20, Default = 13, Callback = Bind("TextSize") })
local look = tab:AddRightGroupbox(T("Elements", "องค์ประกอบ"), "star")
look:AddToggle("MarioEspBox", { Text = T("Box", "กล่อง"), Default = true, Callback = Bind("Box") })
look:AddDropdown("MarioEspBoxStyle", { Text = T("Box style", "แบบกล่อง"), Values = { "Full", "Corner" }, Default = "Full", Callback = Bind("BoxStyle") })
look:AddToggle("MarioEspFill", { Text = T("Box fill", "ถมสีกล่อง"), Callback = Bind("BoxFill") })
look:AddToggle("MarioEspName", { Text = T("Name", "ชื่อ"), Default = true, Callback = Bind("Name") })
look:AddToggle("MarioEspHealth", { Text = T("Health bar", "แถบเลือด"), Default = true, Callback = Bind("Health") })
look:AddToggle("MarioEspHealthText", { Text = T("Health number", "ตัวเลขเลือด"), Callback = Bind("HealthText") })
look:AddToggle("MarioEspDistance", { Text = T("Distance", "ระยะ"), Default = true, Callback = Bind("Distance") })
look:AddToggle("MarioEspDot", { Text = T("Head dot", "จุดหัว"), Callback = Bind("HeadDot") })
look:AddToggle("MarioEspTracer", { Text = T("Tracers", "เส้นนำสายตา"), Callback = Bind("Tracer") })
look:AddDropdown("MarioEspTracerFrom", { Text = T("Tracer from", "เส้นเริ่มจาก"), Values = { "Bottom", "Center", "Mouse" }, Default = "Bottom", Callback = Bind("TracerOrigin") })
look:AddToggle("MarioEspChams", { Text = T("Chams", "เรืองแสงทะลุกำแพง"), Callback = Bind("Chams") })
look:AddToggle("MarioEspArrows", { Text = T("Off-screen arrows", "ลูกศรนอกจอ"), Callback = Bind("Arrows") })
local colors = tab:AddLeftGroupbox(T("Colors", "สี"), "flower")
colors:AddLabel(T("Enemy", "ศัตรู")):AddColorPicker("MarioEspEnemyColor", { Default = Visuals.Settings.EnemyColor, Callback = Bind("EnemyColor") })
colors:AddLabel(T("Friendly", "พวกเดียวกัน")):AddColorPicker("MarioEspFriendColor", { Default = Visuals.Settings.FriendColor, Callback = Bind("FriendColor") })
local radar = tab:AddLeftGroupbox(T("Radar", "เรดาร์"), "target")
radar:AddToggle("MarioRadar", { Text = T("Radar", "เรดาร์"), Description = T("Minimap of nearby players, drag to move", "มินิแมพผู้เล่นรอบตัว ลากย้ายได้"), Callback = Bind("Radar") })
radar:AddSlider("MarioRadarRange", { Text = T("Radar range", "ระยะเรดาร์"), Min = 50, Max = 1000, Default = 250, Suffix = "m", Callback = Bind("RadarRange") })
radar:AddSlider("MarioRadarSize", { Text = T("Radar size", "ขนาดเรดาร์"), Min = 100, Max = 320, Default = 180, Suffix = "px", Callback = Bind("RadarSize") })
return tab
end
Library.Visuals = Visuals
local Compat = { Probes = {}, Restores = {}, Deferred = setmetatable({}, { __mode = "k" }), CallTimeout = 8 }
Library.Compat = Compat
Compat.Api = {
HookFunction = hookfunction or replaceclosure,
HookMetamethod = hookmetamethod,
RestoreFunction = restorefunction,
IsFunctionHooked = isfunctionhooked,
GetNamecallMethod = getnamecallmethod,
CheckCaller = checkcaller,
NewCClosure = newcclosure,
GetConnections = getconnections or get_signal_cons,
GetGc = getgc,
GetUpvalue = getupvalue or (debug and debug.getupvalue),
FireSignal = firesignal,
FirePrompt = fireproximityprompt,
FireTouch = firetouchinterest,
SetIdentity = setthreadidentity or setidentity or (syn and syn.set_thread_identity),
GetIdentity = getthreadidentity or getidentity or (syn and syn.get_thread_identity),
QueueOnTeleport = queue_on_teleport or queueonteleport or (syn and syn.queue_on_teleport),
Request = request or http_request or (syn and syn.request),
}
Compat.Caps = setmetatable({}, {
__index = function(caps, name)
local probe = Compat.Probes[name]
if not probe then
return nil
end
local thread = coroutine.create(probe)
local ok, works = coroutine.resume(thread)
local has = ok and coroutine.status(thread) == "dead" and works == true
if coroutine.status(thread) == "suspended" then
pcall(coroutine.close, thread)
end
rawset(caps, name, has)
return has
end,
})
function Compat.Probes.HookFunction()
local hook = Compat.Api.HookFunction
if not hook then
return false
end
local function Target()
return "plain"
end
local original = hook(Target, function()
return "hooked"
end)
local works = Target() == "hooked" and type(original) == "function" and original() == "plain"
if type(original) == "function" then
pcall(hook, Target, original)
end
return works
end
function Compat.Probes.Namecall()
local api = Compat.Api
if not (api.HookMetamethod and api.GetNamecallMethod) then
return false
end
local proxy = newproxy(true)
getmetatable(proxy).__index = function()
return "plain"
end
local original = api.HookMetamethod(proxy, "__index", function()
return "hooked"
end)
return type(original) == "function" and proxy.probe == "hooked" and original(proxy, "probe") == "plain"
end
function Compat.Probes.Hook()
return Compat.Caps.HookFunction and Compat.Caps.Namecall
end
function Compat.Probes.CheckCaller()
return Compat.Api.CheckCaller ~= nil and Compat.Api.CheckCaller() == true
end
function Compat.Probes.Connections()
if not Compat.Api.GetConnections then
return false
end
local event = Instance.new("BindableEvent")
local hits = 0
local function Handler()
hits += 1
end
local conn = event.Event:Connect(Handler)
local mine
for _, entry in ipairs(Compat.Api.GetConnections(event.Event)) do
if entry.Function == Handler then
mine = entry
end
end
if mine then
pcall(mine.Fire, mine)
end
conn:Disconnect()
event:Destroy()
return hits == 1
end
function Compat.Probes.Gc()
if not Compat.Api.GetGc then
return false
end
local function Marker()
return "gc"
end
for _, value in ipairs(Compat.Api.GetGc(false)) do
if value == Marker then
return true
end
end
return false
end
function Compat.Probes.Upvalues()
if not Compat.Api.GetUpvalue then
return false
end
local marker = {}
local function Holder()
return marker
end
return Compat.Api.GetUpvalue(Holder, 1) == marker
end
function Compat.Probes.Drawing()
if type(Drawing) ~= "table" and type(Drawing) ~= "userdata" then
return false
end
local label = Drawing.new("Text")
local box = Drawing.new("Square")
local ok = pcall(function()
label.Text, label.Size, label.Center, label.Outline = "probe", 13, true, true
label.Position, label.ZIndex, label.Visible = Vector2.new(-100, -100), 2, false
label.Font = Drawing.Fonts and Drawing.Fonts.Plex or 2
box.Filled, box.Thickness, box.Visible = false, 1, false
end)
for _, object in ipairs({ label, box }) do
pcall(object.Remove or object.Destroy, object)
end
return ok
end
function Compat.Probes.Signals()
if not Compat.Api.FireSignal then
return false
end
local event = Instance.new("BindableEvent")
local got
local conn = event.Event:Connect(function(value)
got = value
end)
pcall(Compat.Api.FireSignal, event.Event, 7)
conn:Disconnect()
event:Destroy()
return got == 7
end
function Compat.Probes.Identity()
local api = Compat.Api
if not (api.SetIdentity and api.GetIdentity) then
return false
end
local before = api.GetIdentity()
local target = before == 2 and 8 or 2
api.SetIdentity(target)
local after = api.GetIdentity()
api.SetIdentity(before)
return after == target
end
function Compat.Probes.FileSystem()
if not Util.FileApi() then
return false
end
local stamp = tostring(os.clock())
local wrote = pcall(writefile, "mariohub_probe.txt", stamp)
local ok, read = pcall(readfile, "mariohub_probe.txt")
return wrote and ok and read == stamp
end
function Compat.Probes.Hui()
if type(gethui) ~= "function" then
return false
end
local ok, hidden = pcall(gethui)
return ok and typeof(hidden) == "Instance"
end
function Compat.Probes.Http()
return Compat.Api.Request ~= nil
end
function Compat.Probes.Queue()
return Compat.Api.QueueOnTeleport ~= nil
end
function Compat.Probes.Clipboard()
return type(setclipboard or toclipboard) == "function"
end
function Compat.Probes.Prompt()
return Compat.Api.FirePrompt ~= nil
end
function Compat.Probes.Touch()
return Compat.Api.FireTouch ~= nil
end
function Compat.Probes.Raknet()
return type(raknet) == "table" and type(raknet.add_send_hook) == "function" and type(raknet.remove_send_hook) == "function" and type(raknet.send) == "function"
end
function Compat.Has(caps)
for _, name in ipairs(type(caps) == "table" and caps or { caps }) do
if not Compat.Caps[name] then
return false, name
end
end
return true
end
function Compat.NeedCap(option, caps)
option = type(option) == "string" and Library.Options[option] or option
if type(option) ~= "table" or type(option.AddGuard) ~= "function" then
return
end
option:AddGuard(function(value)
if value ~= true or Compat.Has(caps) then
return true
end
local feature = option.Info and option.Info.Text and Lang.Resolve(option.Info.Text) or option.Idx
Library:Notify("Reicht", Library:T(tostring(feature) .. " is not supported on this executor", tostring(feature) .. " ใช้กับ executor นี้ไม่ได้"), 4, "Warn")
task.defer(option.SetValue, option, false)
return false
end)
end
function Compat.Block(option, reason)
option = type(option) == "string" and Library.Options[option] or option
if type(option) ~= "table" or type(option.AddGuard) ~= "function" then
return
end
option.Blocked = reason
option:AddGuard(function(value)
if value ~= true then
return true
end
local feature = option.Info and option.Info.Text and Lang.Resolve(option.Info.Text) or option.Idx
Library:Notify("Reicht", tostring(feature) .. ": " .. tostring(Lang.Resolve(reason) or reason), 4, "Warn")
task.defer(option.SetValue, option, false)
return false
end)
end
function Compat.Require(module)
local ok, loaded = pcall(require, module)
if ok or not Compat.Caps.Identity then
return ok, loaded
end
local finished, okAgain, again = Util.Await(Compat.CallTimeout, function()
Compat.Api.SetIdentity(2)
return pcall(require, module)
end)
if finished and okAgain then
return true, again
end
return false, loaded
end
function Compat.Call(fn, ...)
if not Compat.Deferred[fn] then
local result = table.pack(pcall(fn, ...))
if result[1] then
return table.unpack(result, 2, result.n)
end
if not Compat.Caps.Identity or not tostring(result[2]):find("non-RobloxScript", 1, true) then
error(result[2], 0)
end
Compat.Deferred[fn] = true
end
local args = table.pack(...)
local box
task.defer(function()
Compat.Api.SetIdentity(2)
box = table.pack(pcall(fn, table.unpack(args, 1, args.n)))
end)
local deadline = os.clock() + Compat.CallTimeout
while not box and os.clock() < deadline do
task.wait()
end
if not box then
error("game call timed out", 0)
end
if not box[1] then
error(box[2], 0)
end
return table.unpack(box, 2, box.n)
end
local function Wrap(handler)
local okWrap, wrapped = pcall(Compat.Api.NewCClosure or error, handler)
return okWrap and type(wrapped) == "function" and wrapped or handler
end
function Compat.Unhook(target, rehook)
local api = Compat.Api
if target and api.RestoreFunction and pcall(api.RestoreFunction, target) then
if not api.IsFunctionHooked then
return
end
local ok, still = pcall(api.IsFunctionHooked, target)
if ok and not still then
return
end
end
rehook()
end
local function Track(putBack)
table.insert(Compat.Restores, putBack)
return function()
local index = table.find(Compat.Restores, putBack)
if not index then
return
end
table.remove(Compat.Restores, index)
Util.Try(putBack)
end
end
function Compat.HookMeta(object, method, handler)
if not Compat.Caps.Namecall then
return nil
end
local api = Compat.Api
local ok, original = pcall(api.HookMetamethod, object, method, Wrap(handler))
if not ok or type(original) ~= "function" then
return nil
end
return original, Track(function()
api.HookMetamethod(object, method, original)
end)
end
function Compat.HookFunction(target, handler)
if not Compat.Caps.HookFunction then
return nil
end
local api = Compat.Api
local ok, original = pcall(api.HookFunction, target, Wrap(handler))
if not ok or type(original) ~= "function" then
return nil
end
return original, Track(function()
Compat.Unhook(target, function()
pcall(api.HookFunction, target, original)
end)
end)
end
function Compat.RestoreAll()
for index = #Compat.Restores, 1, -1 do
Util.Try(Compat.Restores[index])
end
table.clear(Compat.Restores)
end
function Compat.RaknetLive(timeout)
if not Compat.Caps.Raknet then
return false
end
local seen = false
local function Watch()
seen = true
end
if not pcall(raknet.add_send_hook, Watch) then
return false
end
local deadline = os.clock() + (timeout or 2)
while not seen and os.clock() < deadline do
task.wait(0.1)
end
pcall(raknet.remove_send_hook, Watch)
return seen
end
function Compat.Warm()
for name in pairs(Compat.Probes) do
task.defer(function()
local _ = Compat.Caps[name]
end)
end
end
function Lang.Format(key, ...)
local spec = Lang.Strings[key] or { EN = key, TH = key }
local args = table.pack(...)
return {
EN = string.format(spec.EN, table.unpack(args, 1, args.n)),
TH = string.format(spec.TH or spec.EN, table.unpack(args, 1, args.n)),
}
end
function Configs.SetFolder(name)
Configs.Folder = Config.ConfigRoot .. "/" .. Util.Sanitize(name)
if Util.FileApi() then
Util.EnsureFolder(Configs.Folder)
end
end
function Configs.Path(name)
return Configs.Folder .. "/" .. Util.Sanitize(name) .. ".json"
end
function Configs.Save(name)
if not Util.FileApi() then
return false, Lang.Get("NoFileApi")
end
local snapshot = {}
for idx, option in pairs(Library.Options) do
if not option.NoSave and option.Serialize then
snapshot[idx] = { Type = option.Type, Value = option:Serialize() }
end
end
return (pcall(writefile, Configs.Path(name), HttpService:JSONEncode(snapshot)))
end
function Configs.Load(name)
local path = Configs.Path(name)
if not Util.FileApi() or not Util.Exists(path) then
return false, Lang.Get("ConfigMissing")
end
local read, raw = pcall(readfile, path)
local ok, snapshot = pcall(HttpService.JSONDecode, HttpService, read and raw or "")
if not ok or type(snapshot) ~= "table" then
return false, Lang.Get("ConfigBroken")
end
for idx, saved in pairs(snapshot) do
local option = Library.Options[idx]
if option and not option.NoSave and option.Type == saved.Type then
Util.Try(option.Deserialize, option, saved.Value)
end
end
return true
end
function Configs.Delete(name)
local path = Configs.Path(name)
if type(delfile) ~= "function" or not Util.FileApi() or not Util.Exists(path) then
return false, Lang.Get("ConfigMissing")
end
return (pcall(delfile, path))
end
function Configs.List()
if type(listfiles) ~= "function" or not Util.FileApi() then
return {}
end
local ok, files = pcall(listfiles, Configs.Folder)
local names = {}
for _, path in ipairs(ok and files or {}) do
local name = path:match("([^/\\]+)%.json$")
if name then
table.insert(names, name)
end
end
table.sort(names)
return names
end
function Configs.SetAutoload(name)
if not Util.FileApi() then
return false, Lang.Get("NoFileApi")
end
return (pcall(writefile, Configs.Folder .. "/autoload.txt", name))
end
function Configs.GetAutoload()
local path = Configs.Folder .. "/autoload.txt"
if not Util.FileApi() or not Util.Exists(path) then
return nil
end
local ok, name = pcall(readfile, path)
return ok and type(name) == "string" and name ~= "" and name or nil
end
function Configs.BuildSection(group)
local nameInput = group:AddInput("MarioConfigName", { Text = Lang.Strings.ConfigName, Placeholder = "default", NoSave = true })
local list = group:AddListBox("MarioConfigList", { Text = Lang.Strings.SavedConfigs, Values = Configs.List(), Height = 4, NoSave = true })
local autoload = group:AddLabel(Lang.Format("Autoload", Configs.GetAutoload() or Lang.Get("None")))
local function Selected()
local typed = nameInput.Value:gsub("^%s+", ""):gsub("%s+$", "")
return typed ~= "" and typed or list.Value
end
local function Run(actionKey, handler)
local name = Selected()
if not name then
Library:Notify(Lang.Strings.Configs, Lang.Strings.PickConfig, 3, "Warning")
return
end
local ok, reason = handler(name)
local action = Lang.Strings[actionKey]
local message = ok and { EN = action.EN .. ": " .. name, TH = action.TH .. ": " .. name }
or { EN = action.EN .. " failed: " .. tostring(reason), TH = action.TH .. " ไม่สำเร็จ: " .. tostring(reason) }
Library:Notify(Lang.Strings.Configs, message, 3, ok and "Success" or "Error")
list:SetValues(Configs.List())
end
group:AddButton({ Text = Lang.Strings.Save, Style = "Primary", Func = function()
Run("Save", Configs.Save)
end }):AddButton({ Text = Lang.Strings.Load, Style = "Success", Func = function()
Run("Load", Configs.Load)
end })
group:AddButton({ Text = Lang.Strings.Delete, Style = "Danger", DoubleClick = true, Func = function()
Run("Delete", Configs.Delete)
end }):AddButton({ Text = Lang.Strings.Refresh, Func = function()
list:SetValues(Configs.List())
end })
group:AddButton({ Text = Lang.Strings.SetAutoload, Style = "Warning", Func = function()
Run("SetAutoload", function(name)
local ok, reason = Configs.SetAutoload(name)
if ok then
autoload:SetText(Lang.Format("Autoload", name))
end
return ok, reason
end)
end })
end
function Window:AddSettingsTab()
local tab = self:AddTab(Lang.Strings.Settings, "gear", Lang.Strings.SettingsDesc)
local interface = tab:AddLeftGroupbox(Lang.Strings.Interface, "mushroom")
interface:AddDropdown("MarioLanguage", {
Text = Lang.Strings.Language,
Values = { "English", "ไทย" },
Default = State.Language == "TH" and "ไทย" or "English",
Callback = function(value)
Library:SetLanguage(value == "ไทย" and "TH" or "EN")
end,
})
interface:AddDropdown("MarioTheme", { Text = Lang.Strings.ThemeName, Values = Themes.Order, Default = State.ThemeName, Callback = function(name)
Library:SetTheme(name)
end })
interface:AddSlider("MarioScale", { Text = Lang.Strings.Scale, Min = Config.ScaleRange.Min * 100, Max = Config.ScaleRange.Max * 100, Default = State.UserScale * 100, Suffix = "%", Finished = true, Callback = function(value)
self:SetScale(value / 100)
end })
interface:AddKeybind("MarioMenuKey", { Text = Lang.Strings.MenuKey, Default = State.MenuKey, Mode = "Always", ChangedCallback = function(name)
State.MenuKey = name
end })
interface:AddToggle("MarioParticles", { Text = Lang.Strings.Particles, Description = Lang.Strings.ParticlesDesc, Default = Particles.Enabled, Callback = Particles.SetEnabled })
interface:AddToggle("MarioFloat", { Text = Lang.Strings.FloatButton, Description = Lang.Strings.FloatDesc, Default = Float.Button ~= nil and Float.Button.Visible, Callback = Float.SetVisible })
local about = tab:AddLeftGroupbox(Lang.Strings.About, "star")
about:AddLabel(string.format("%s v%s - %s", self.Title, Library.Version, self.SubTitle ~= "" and self.SubTitle or tostring(game.PlaceId)))
about:AddLabel(Lang.Format("Device", State.Touch and "Mobile" or "PC"))
about:AddButton({ Text = Lang.Strings.Rejoin, Func = function()
game:GetService("TeleportService"):TeleportToPlaceInstance(game.PlaceId, game.JobId, LocalPlayer)
end }):AddButton({ Text = Lang.Strings.Unload, Style = "Danger", DoubleClick = true, Func = function()
Library:Unload()
end })
Configs.BuildSection(tab:AddRightGroupbox(Lang.Strings.Configs, "qblock"))
return tab
end
function Library:CreateWindow(options)
options = options or {}
local language = options.Language
if language == "Auto" then
language = tostring(LocalPlayer.LocaleId):sub(1, 2) == "th" and "TH" or "EN"
end
State.Language = language == "TH" and "TH" or "EN"
State.UserScale = math.clamp(options.Scale or 1, Config.ScaleRange.Min, Config.ScaleRange.Max)
Theme.Apply(options.Theme or Config.SeasonTheme or "Overworld")
Assets.Configure(Config.DefaultAssets)
Assets.Configure(options.Assets)
Window.DetectTouch(options.Layout)
Gui.Setup()
Library:OnUnload(Compat.RestoreAll)
task.delay(3, Compat.Warm)
if State.Language == "TH" then
Fonts.LoadThaiAsync()
end
local window = Window.New(options)
self.Window = window
Float.Build()
Watermark.SetVisible(false)
Configs.SetFolder(options.ConfigFolder or options.Folder or window.Title)
local function Build()
if Library.Unloaded then
return
end
Util.Try(options.OnUnlocked)
Layout.Flush()
end
local function Reveal()
if Library.Unloaded then
return
end
window.Ready = true
window:SetVisible(true)
Library:Notify(window.Title, Lang.Format(State.Touch and "ReadyTouch" or "Ready", Keybinds.Short(State.MenuKey)), 5, "Power")
end
local function Open()
if Library.Unloaded then
return
end
if options.Intro == false then
Build()
Reveal()
return
end
local built = false
task.spawn(function()
Build()
built = true
end)
local function WaitBuilt()
while not built and not Library.Unloaded do
task.wait()
end
end
local steps = Lang.Strings.IntroSteps
task.spawn(Intro.Play, {
Title = window.Title,
SubTitle = window.SubTitle,
Steps = {
{ Label = { EN = steps.EN[1], TH = steps.TH[1] } },
{ Label = { EN = steps.EN[2], TH = steps.TH[2] } },
{ Label = { EN = steps.EN[3], TH = steps.TH[3] }, Run = WaitBuilt },
{ Label = { EN = steps.EN[4], TH = steps.TH[4] } },
},
OnDone = Reveal,
})
end
Open()
return window
end
function Library:SetLanguage(code)
if code ~= "EN" and code ~= "TH" then
return
end
Lang.Set(code)
local option = self.Options.MarioLanguage
if option then
option.Value = code == "TH" and "ไทย" or "English"
option:Render()
end
end
function Library:GetLanguage()
return State.Language
end
function Library:T(english, thai)
return { EN = english, TH = thai or english }
end
function Library:SetTheme(name)
Theme.Apply(name)
local option = self.Options.MarioTheme
if option and option.Value ~= State.ThemeName then
option.Value = State.ThemeName
option:Render()
end
end
function Library:SetAssets(map)
Assets.Configure(map)
end
function Library:Notify(info, content, duration, kind)
if type(info) == "table" and not info.EN then
info, content, duration, kind = info.Title, info.Content or info.Description, info.Duration, info.Type or info.Icon
end
if self.Unloaded or not State.NotifyHost then
return
end
Notify.Push(Lang.Resolve(info), content, duration, kind)
end
function Library:Toggle()
if self.Window then
self.Window:Toggle()
end
end
function Library:Every(interval, callback)
Util.Every(interval, callback)
end
function Library:SaveConfig(name)
return Configs.Save(name)
end
function Library:LoadConfig(name)
return Configs.Load(name)
end
function Library:LoadAutoloadConfig()
local name = Configs.GetAutoload()
if not name then
return
end
local ok, reason = Configs.Load(name)
local message = ok and { EN = "Autoloaded: " .. name, TH = "โหลดอัตโนมัติ: " .. name } or { EN = "Autoload failed: " .. tostring(reason), TH = "โหลดอัตโนมัติไม่สำเร็จ: " .. tostring(reason) }
self:Notify(Lang.Strings.Configs, message, 3, ok and "Success" or "Error")
end
function Library:OnUnload(callback)
table.insert(State.UnloadHooks, callback)
end
function Library:Unload()
if self.Unloaded then
return
end
self.Unloaded = true
for _, callback in ipairs(State.UnloadHooks) do
Util.Try(callback)
end
if Reactive and Reactive.DisposeAll then
Reactive.DisposeAll()
end
if Motion then
if Motion.Connection then
Motion.Connection:Disconnect()
Motion.Connection = nil
end
if Motion.Springs then
table.clear(Motion.Springs)
end
if Motion.Tickers then
table.clear(Motion.Tickers)
end
end
for _, list in pairs(Anim.Loops or {}) do
for _, entry in ipairs(list) do
if entry.Tween then
pcall(entry.Tween.Cancel, entry.Tween)
end
end
end
table.clear(Anim.Loops)
table.clear(Anim.GroupState)
for _, connection in ipairs(State.Connections) do
connection:Disconnect()
end
table.clear(State.Connections)
table.clear(State.KeyPickers)
table.clear(State.Tasks)
table.clear(Layout.Dirty)
table.clear(Layout.All)
table.clear(Layout.Measured)
Layout.MeasuredCount = 0
table.clear(Theme.Bound)
table.clear(Theme.Renderers)
table.clear(Theme.InstanceRenderers)
table.clear(Lang.Bound)
table.clear(Lang.Listeners)
table.clear(Lang.InstanceListeners)
table.clear(Fonts.Texts)
State.Drag, State.Binding, State.Popup, State.Window, State.NotifyHost = nil, nil, nil, nil, nil
if State.Gui then
State.Gui:Destroy()
State.Gui = nil
end
end
Library.Themes = Themes.Order
Library.Ref = Reactive.Ref
Library.Computed = Reactive.Computed
Library.Effect = Reactive.Effect
Library.Watch = Reactive.Watch
Library.Batch = Reactive.Batch
Library.Store = Reactive.Store
Library.IsRef = Reactive.IsRef
Library.tw = Tailwind.Apply
Library.h = Tailwind.CreateElement
Library.Component = function(self, name, renderFn)
if type(self) == "string" then
return Tailwind.Component(self, name)
end
return Tailwind.Component(name, renderFn)
end
Library.Show = Tailwind.Show
Library.For = Tailwind.For
Library.Icons = Icons
Library.Icon = function(self, parent, name, size, color)
if typeof(self) == "Instance" then
return Icons.Create(self, parent, name, size)
end
return Icons.Create(parent, name, size, color)
end
Library.Gui = Gui
Library.Motion = Motion
Library.Fx = Fx
Library.Dialog = function(self, spec)
return Dialog.Show(type(self) == "table" and self ~= Library and self or spec)
end
Library.CloseDialog = Dialog.Close
Library.Sheet = function(self, spec)
return Sheet.Show(type(self) == "table" and self ~= Library and self or spec)
end
Library.CloseSheet = Sheet.Close
do
Config.SeasonTheme = "Minimal"
Config.Particles.Count = 0
Themes.Minimal = Palette({
Backdrop = "0E1014", BackdropAlt = "12151A", Topbar = "14181E",
Sidebar = "11141A", SidebarAlt = "161A21",
SidebarText = "E7E9ED", SidebarMuted = "8B929E",
TabActive = "1F242C", TabActiveText = "FFFFFF",
Panel = "161A21", PanelHeader = "1A1F27", Element = "1E232B", Hover = "252B34",
Outline = "262C35", Shadow = "000000",
Text = "E8EAEE", SubText = "A5ACB8", Muted = "6E7581", Track = "262C35",
Cloud = "0E1014", CloudAlpha = 0,
Accent = "D64C40", AccentDark = "A0342C",
Grass = "1A1F27", GrassDark = "14181E", Brick = "1E232B", BrickDark = "14181E",
Decor = { "None" },
Particle = { ".", false, "262C35" },
})
table.insert(Themes.Order, 1, "Minimal")
local W = Config.Window
W.Width, W.Height = 720, 500
W.MinWidth, W.MinHeight = 300, 240
W.TouchMinWidth, W.TouchMinHeight = 300, 240
W.Topbar, W.Sidebar, W.SidebarCompact = 46, 168, 56
W.Header, W.UserCard = 52, 46
W.Ground = 0
W.Margin, W.TouchMargin = 16, 8
W.Radius, W.Stroke, W.Shadow = 10, 1, 0
local T = Config.Metrics.Touch
T.Row, T.Box, T.Item, T.Tab = 40, 40, 38, 46
T.Check, T.Knob = 26, 22
T.Switch = Vector2.new(50, 26)
T.SwitchKnob = 20
T.Radius = 10
local D = Config.Metrics.Desktop
D.Radius, D.Depth = 9, 2
Config.Group.Radius, Config.Group.Stroke, Config.Group.Shadow = 10, 1, 0
Config.Button.Depth, Config.Button.PadX = 2, 12
Config.Selectable.Radius = 8
Config.Page.ScrollBar = 4
end
Library.Window = Library.CreateWindow
return Library]]
local function Alert(text)
warn("[Reicht/Evade] " .. text)
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
local FBM_URL = "https://raw.githubusercontent.com/Shinzzyak/Reicht/refs/heads/main/FloatingButton.lua"
local FBM_EMBEDDED = [[local httpService = game:GetService("HttpService")

local FloatingButtonManager = {}
FloatingButtonManager.Folder = "FloatingButtons"
FloatingButtonManager.Buttons = {}
FloatingButtonManager.Library = nil

local function serializeUDim2(u)
    return {
        ScaleX = u.X.Scale, OffsetX = u.X.Offset,
        ScaleY = u.Y.Scale, OffsetY = u.Y.Offset
    }
end

local function deserializeUDim2(t)
    return UDim2.new(t.ScaleX, t.OffsetX, t.ScaleY, t.OffsetY)
end

function FloatingButtonManager:BuildFolderTree()
    local paths = { self.Folder, self.Folder .. "/settings" }
    for _, path in ipairs(paths) do
        if not isfolder(path) then makefolder(path) end
    end
end

function FloatingButtonManager:SetLibrary(library)
    self.Library = library
end

function FloatingButtonManager:SetFolder(folder)
    self.Folder = folder
    self:BuildFolderTree()
end

FloatingButtonManager:BuildFolderTree()

function FloatingButtonManager:AddButton(id, frame, locked, isCircle)
    self.Buttons[id] = frame
    frame:SetAttribute("Locked", locked or false)
    frame:SetAttribute("IsCircle", isCircle or false)
end

function FloatingButtonManager:Save(name)
    local path = self.Folder .. "/settings/" .. name .. ".json"
    local data = {}

    for id, frame in pairs(self.Buttons) do
        data[id] = {
            size = serializeUDim2(frame.Size),
            position = serializeUDim2(frame.Position),
            locked = frame:GetAttribute("Locked") or false,
            isCircle = frame:GetAttribute("IsCircle") or false
        }
    end

    local success, encoded = pcall(httpService.JSONEncode, httpService, data)
    if not success then return false, "encode failed" end
    writefile(path, encoded)
    return true
end

function FloatingButtonManager:Load(name)
    local path = self.Folder .. "/settings/" .. name .. ".json"
    if not isfile(path) then return false, "no such file" end

    local success, decoded = pcall(httpService.JSONDecode, httpService, readfile(path))
    if not success then return false, "decode failed" end

    for id, saved in pairs(decoded) do
        local frame = self.Buttons[id]
        if frame then
            frame.Size = deserializeUDim2(saved.size)
            frame.Position = deserializeUDim2(saved.position)

            frame:SetAttribute("Locked", saved.locked or false)
            frame:SetAttribute("IsCircle", saved.isCircle or false)

            local corner = frame:FindFirstChildWhichIsA("UICorner")
            local button = frame:FindFirstChildWhichIsA("TextButton")

            if saved.isCircle then
                if corner then corner.CornerRadius = UDim.new(1, 0) end
                if button then
                    local s = math.min(frame.AbsoluteSize.X, frame.AbsoluteSize.Y)
                    button.TextScaled = true
                    button.TextSize = math.floor(s * 0.45)
                end
            else
                -- Minimal chrome: one radius across the hub (10) and a label that
                -- fits a pill instead of shouting from a 24px corner box.
                if corner then corner.CornerRadius = UDim.new(0, 10) end
                if button then
                    button.TextScaled = false
                    button.TextSize = 18
                end
            end
        end
    end

    return true
end

function FloatingButtonManager:RefreshConfigList()
    local list = listfiles(self.Folder .. "/settings")
    local out = {}
    for _, file in ipairs(list) do
        if file:sub(-5) == ".json" then
            local name = file:match("([^/\\]+)%.json$")
            if name then table.insert(out, name) end
        end
    end
    return out
end

function FloatingButtonManager:LoadAutoloadConfig()
    local autoPath = self.Folder .. "/settings/autoload.txt"
    if isfile(autoPath) then
        local name = readfile(autoPath)
        local success, err = self:Load(name)
        if not success then
            return self.Library:Notify({
                Title = "Floating Buttons",
                Content = "Failed to load autoload layout: " .. err,
                Duration = 5
            })
        end
        self.Library:Notify({
            Title = "Floating Buttons",
            Content = string.format("Auto loaded layout %q", name),
            Duration = 5
        })
    end
end

function FloatingButtonManager:BuildConfigSection(tab)
    assert(self.Library, "Must set FloatingButtonManager.Library")

    local section = tab:AddSection("Floating Buttons Config")

    section:AddInput("FB_ConfigName", { Title = "Layout name" })
    section:AddDropdown("FB_ConfigList", {
        Title = "Layouts list",
        Values = self:RefreshConfigList(),
        AllowNull = true
    })

    section:AddButton({
        Title = "Create layout",
        Callback = function()
            local name = self.Library.Options.FB_ConfigName.Value
            if name:gsub(" ", "") == "" then
                return self.Library:Notify({
                    Title = "Floating Buttons",
                    Content = "Invalid layout name",
                    Duration = 5
                })
            end
            local success, err = self:Save(name)
            if not success then
                return self.Library:Notify({
                    Title = "Floating Buttons",
                    Content = "Failed to save: " .. err,
                    Duration = 5
                })
            end
            self.Library:Notify({
                Title = "Floating Buttons",
                Content = string.format("Saved layout %q", name),
                Duration = 5
            })
            self.Library.Options.FB_ConfigList:SetValues(self:RefreshConfigList())
            self.Library.Options.FB_ConfigList:SetValue(nil)
        end
    })

    section:AddButton({
        Title = "Load layout",
        Callback = function()
            local name = self.Library.Options.FB_ConfigList.Value
            local success, err = self:Load(name)
            if not success then
                return self.Library:Notify({
                    Title = "Floating Buttons",
                    Content = "Failed to load: " .. err,
                    Duration = 5
                })
            end
            self.Library:Notify({
                Title = "Floating Buttons",
                Content = string.format("Loaded layout %q", name),
                Duration = 5
            })
        end
    })

    section:AddButton({
        Title = "Overwrite layout",
        Callback = function()
            local name = self.Library.Options.FB_ConfigList.Value
            local success, err = self:Save(name)
            if not success then
                return self.Library:Notify({
                    Title = "Floating Buttons",
                    Content = "Failed to overwrite: " .. err,
                    Duration = 5
                })
            end
            self.Library:Notify({
                Title = "Floating Buttons",
                Content = string.format("Overwrote layout %q", name),
                Duration = 5
            })
        end
    })

    section:AddButton({
        Title = "Refresh list",
        Callback = function()
            self.Library.Options.FB_ConfigList:SetValues(self:RefreshConfigList())
            self.Library.Options.FB_ConfigList:SetValue(nil)
        end
    })

    local autoPath = self.Folder .. "/settings/autoload.txt"
    local AutoloadButton
    AutoloadButton = section:AddButton({
        Title = "Set as autoload",
        Description = "Current autoload layout: none",
        Callback = function()
            local name = self.Library.Options.FB_ConfigList.Value
            if isfile(autoPath) then
                delfile(autoPath)
                AutoloadButton:SetDesc("Current autoload layout: none")
                self.Library:Notify({
                    Title = "Floating Buttons",
                    Content = "Autoload disabled",
                    Duration = 5
                })
            else
                writefile(autoPath, name)
                AutoloadButton:SetDesc("Current autoload layout: " .. name)
                self.Library:Notify({
                    Title = "Floating Buttons",
                    Content = string.format("Set %q to autoload", name),
                    Duration = 5
                })
            end
        end
    })
    if isfile(autoPath) then
        local name = readfile(autoPath)
        AutoloadButton:SetDesc("Current autoload layout: " .. name)
    end
end

return FloatingButtonManager]]
local function Safe(fn)
local ok, value = pcall(fn)
if ok then return value end
return nil
end
local function FetchSource(url, embedded)
local ok, src = pcall(game.HttpGet, game, url)
if ok and type(src) == "string" and #src >= 1024 then return src, "network" end
if type(embedded) == "string" and #embedded >= 1024 then return embedded, "embedded" end
return nil, "none"
end
local FbmOrigin = "none"
local FBM = Safe(function()
local src, origin = FetchSource(FBM_URL, FBM_EMBEDDED)
FbmOrigin = origin or "none"
if type(src) ~= "string" or #src < 1024 then return nil end
local lib = loadstring(src)()
if type(lib) ~= "table" or type(lib.AddButton) ~= "function" then return nil end
return lib
end)
warn(string.format("[Reicht/Evade] floating button source: %s (embedded ready: %s)",
tostring(FbmOrigin),
tostring(type(FBM_EMBEDDED) == "string" and #FBM_EMBEDDED > 1024)))
if not FBM then
FBM = { Buttons = {} }
function FBM:SetLibrary() end
function FBM:SetFolder(folder) self.Folder = folder end
function FBM:AddButton(name, frame) table.insert(self.Buttons, { Name = name, Frame = frame }) end
function FBM:BuildConfigSection() end
end
local writefile = writefile or function() end
local readfile = readfile or function() return "" end
local isfile = isfile or function() return false end
local makefolder = makefolder or function() end
local isfolder = isfolder or function() return false end
local getcustomasset = getcustomasset or function() return "" end
local request = http_request or (syn and syn.request) or request
local body, uiOrigin = FetchSource(UI_URL, UI_EMBEDDED)
if type(body) ~= "string" or not body:sub(-64):find("return Library%s*$") then
Alert("Could not download the menu. Check the connection and try again.")
return
end
getgenv().ReichtUiSource = uiOrigin
warn(string.format("[Reicht/Evade] ui source: %s (embedded ready: %s, %d bytes)",
tostring(uiOrigin),
tostring(type(UI_EMBEDDED) == "string" and #UI_EMBEDDED > 1024),
type(UI_EMBEDDED) == "string" and #UI_EMBEDDED or 0))
local chunk = loadstring(body)
local Library = chunk and select(2, pcall(chunk))
if type(Library) ~= "table" then
Alert("The menu failed to load on this executor.")
return
end
local win = Library:CreateWindow({
Title = "Reicht",
SubTitle = "Evade - Draconic",
MenuKey = Enum.KeyCode.LeftControl,
ConfigFolder = SAVE_FOLDER,
Language = "Auto",
Theme = "Overworld",
Size = Vector2.new(580, 460),
})
getgenv().ButtonGradients = getgenv().ButtonGradients or {
Background = ColorSequence.new({
ColorSequenceKeypoint.new(0, Color3.fromRGB(80, 180, 255)),
ColorSequenceKeypoint.new(1, Color3.fromRGB(20, 20, 40)),
}),
Stroke = ColorSequence.new({
ColorSequenceKeypoint.new(0, Color3.fromRGB(255, 255, 255)),
ColorSequenceKeypoint.new(1, Color3.fromRGB(80, 180, 255)),
}),
}
local TAB_ORDER = {
{ "Main", "Main", "rbxassetid://7733960981" },
{ "AutoFarm", "Auto Farms", "rbxassetid://10709811110" },
{ "Combat", "Combat", "rbxassetid://10734975692" },
{ "Misc", "Misc", "rbxassetid://7734068321" },
{ "Visual", "Visual", "rbxassetid://10709819149" },
{ "Info", "Info", "rbxassetid://10723415903" },
{ "Settings", "Configuration", "rbxassetid://7734052335" },
{ "Extension", "Extension", "rbxassetid://10734930886" },
}
local Fluent = {
Options = Library.Options,
Notify = function(_, spec)
spec = spec or {}
Library:Notify(spec.Title or "Reicht", spec.Content or "", spec.Duration or 4)
end,
}
local Window = win
Window.Minimize = function()
if Window.SetVisible then Window:SetVisible(false) end
end
local function Conv(info)
if type(info) ~= "table" then return info end
local out = {}
for key, value in pairs(info) do
if key == "Title" then
out.Text = value
else
out[key] = value
end
end
if out.Text == nil then out.Text = out.Name end
return out
end
local function FacadeTab(groupbox)
local tab = {}
function tab:AddSection(title)
groupbox:AddDivider()
groupbox:AddLabel(tostring(title))
return tab
end
local function widget(name)
return function(_, idx, info)
return groupbox[name](groupbox, idx, Conv(info))
end
end
tab.AddToggle = widget("AddToggle")
tab.AddSlider = widget("AddSlider")
tab.AddInput = widget("AddInput")
tab.AddDropdown = widget("AddDropdown")
tab.AddKeybind = widget("AddKeybind")
tab.AddColorPicker = widget("AddColorPicker")
function tab:AddButton(info)
local spec = Conv(info)
spec.Func = spec.Func or spec.Callback
spec.Callback = nil
return groupbox:AddButton(spec)
end
function tab:AddLabel(text, wrapFlag)
return groupbox:AddLabel(text, wrapFlag)
end
function tab:AddParagraph(info)
info = info or {}
return groupbox:AddParagraph({ Title = info.Title or info.Text, Content = info.Content })
end
function tab:AddDivider()
return groupbox:AddDivider()
end
return tab
end
local Tabs = {}
local RealTabs = {}
for _, spec in ipairs(TAB_ORDER) do
local key, title, icon = spec[1], spec[2], spec[3]
local tab
if key == "Settings" then
tab = win:AddSettingsTab()
tab.Name = title
if tab.Label then tab.Label.Text = title end
else
tab = win:AddTab(title, icon)
end
RealTabs[key] = tab
Tabs[key] = FacadeTab(tab:AddLeftGroupbox(title, icon))
end
local function Run()
local Workspace = game:GetService("Workspace")
local RunService = game:GetService("RunService")
local Players = game:GetService("Players")
local Lighting = game:GetService("Lighting")
local StarterGui = game:GetService("StarterGui")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Camera = Workspace.CurrentCamera
local LocalPlayer = Players.LocalPlayer
local UserInputService = game:GetService("UserInputService")
local TweenService = game:GetService("TweenService")
local PathfindingService = game:GetService("PathfindingService")
local CAS = game:GetService("ContextActionService")
local CharacterService = Safe(function() return require(ReplicatedStorage:WaitForChild("Services"):WaitForChild("Asset"):WaitForChild("CharacterService")) end)
local ServerStateRegistryService = Safe(function() return require(ReplicatedStorage:WaitForChild("Services"):WaitForChild("Data"):WaitForChild("ServerStateRegistryService")) end)
local ItemRegistry = Safe(function() return require(ReplicatedStorage:WaitForChild("Items"):WaitForChild("Registry")) end)
local MovementModule = Safe(function() return require(ReplicatedStorage.Objects.Game.Character.Client.Movement) end)
local ClientItemService = Safe(function() return require(ReplicatedStorage.Services.Items.ClientItemService) end)
local EmoteClass = Safe(function() return require(ReplicatedStorage.Objects.Items.Emote) end)
local CameraService = Safe(function() return require(ReplicatedStorage.Services.Client.CameraService) end)
local playerModule = Safe(function() return LocalPlayer:WaitForChild("PlayerScripts"):WaitForChild("PlayerModule") end)
local controlModule = Safe(function() return require(playerModule:WaitForChild("ControlModule")) end)
local function GetAutoDuration()
local dt = RunService.RenderStepped:Wait()
local fps = 1 / dt
local duration = 60 / math.clamp(fps, 5, 60)
return math.clamp(duration, 1, 6)
end
local Duration = GetAutoDuration()
local function MakeDraggable(topbarobject, object, locked)
local Dragging = false
local DragInput
local DragStart
local StartPosition
local Holding = false
local HoldTime = 1.0
local MoveCancelThreshold = 6
local HoldToken = 0
object:SetAttribute("Locked", locked or false)
local function Update(input)
if object:GetAttribute("Locked") then return end
local delta = input.Position - DragStart
object.Position = UDim2.new(
StartPosition.X.Scale,
StartPosition.X.Offset + delta.X,
StartPosition.Y.Scale,
StartPosition.Y.Offset + delta.Y
)
end
local function ToggleLock()
local newState = not object:GetAttribute("Locked")
object:SetAttribute("Locked", newState)
Fluent:Notify({
Title = newState and "Button Locked" or "Button Unlocked",
Content = newState and "This button is now locked in place." or "This button can now be moved.",
Duration = 2
})
end
topbarobject.InputBegan:Connect(function(input)
if input.UserInputType ~= Enum.UserInputType.MouseButton1
and input.UserInputType ~= Enum.UserInputType.Touch then
return
end
Dragging = not object:GetAttribute("Locked")
Holding = true
DragStart = input.Position
StartPosition = object.Position
HoldToken += 1
local token = HoldToken
task.delay(HoldTime, function()
if Holding and token == HoldToken then
ToggleLock()
end
end)
input.Changed:Connect(function()
if input.UserInputState == Enum.UserInputState.End then
Dragging = false
Holding = false
end
end)
end)
topbarobject.InputChanged:Connect(function(input)
if not DragStart then return end
if input.UserInputType == Enum.UserInputType.MouseMovement
or input.UserInputType == Enum.UserInputType.Touch then
if (input.Position - DragStart).Magnitude > MoveCancelThreshold then
Holding = false
end
DragInput = input
end
end)
UserInputService.InputChanged:Connect(function(input)
if input == DragInput and Dragging then
Update(input)
end
end)
end
if require then
print("Supported require()")
end
if firetouchinterest then
print("Supported firetouchinterest()")
end
if game.Players then
print("Advance Api")
else
print("Common Api")
end
local DFunctions = {}
local DConfiguration = {
ESP = {
Players = false,
Nextbots = false,
Tickets = false,
Objective = false,
},
Tracers = {
Players = false,
Nextbots = false,
Tickets = false,
Objective = false,
},
Highlight = {
Players = false,
Nextbots = false,
Tickets = false,
Objective = false,
OutlineOnly = false,
},
Boxes = {
Players = false,
Nextbots = false,
Tickets = false,
Objective = false,
},
Removals = {
CameraShake = false,
Vignette = false,
InvisibleWalls = false,
ReducingRewards = false,
},
Main = {
AntiAFK = true,
AutoRespawn = false,
RespawnType = "Spawnpoint",
AutoWhistle = false,
ShowTimer = false,
Fly = false,
FlySpeed = 1,
isFlyFloating = false,
FlyoriginalUpdate = false,
Noclip = false,
},
Battlepass = {
BypassTimer = false,
},
AutoFarm = {
FarmingStates = {
IsReviving = false,
IsCompletingObjective = false,
IsCollectingTickets = false,
IsCatchingNPC = false,
},
AFKFarm = false,
FarmTickets = false,
CompleteObjective = false,
FarmTokens = false,
VIPAutomations = {
AutoVote = false,
MapSection = 1,
GamemodeSection = 1,
AutoMap = false,
MapInput = "DesertBus",
AutoSpecialRound = false,
SpecialRoundInput = "Plushie Hell",
AutoTimer = false,
TimerInput = "",
TimerRoundState = 1,
AutoProMode = false,
LastMapSet = 0,
LastSRSet = 0,
LastTimerSet = 0,
LastVotingFire = 0,
},
PurchaseAutomations = {
Enabled = false,
Selected = "",
Amount = 1,
Interval = 4,
Connection = nil,
LastBuy = 0,
Failures = 0,
Catalog = nil,
Remote = nil,
},
},
Combat = {
AntiNextbot = false,
AntiNextbotRange = 15,
AntiNextbotType = "Spawn",
},
Misc = {
PlayerAdjustment = {
Default = {
Friction = 5,
Speed = 1500,
JumpHeight = 3,
JumpCap = 1,
AirStrafeAcceleration = 182,
AirAcceleration = 1,
JumpSpeedMultiplier = 1.45,
BhopEnabled = false
},
Update = {
Speed = 1500,
JumpHeight = 3,
JumpCap = 1,
JumpAcceleration = 1.5,
AirStrafe = 182,
GroundAcceleration = 5,
BHOPEnabled = false,
},
Saved = {
Speed = 1500,
JumpHeight = 3,
JumpCap = 1,
JumpAcceleration = 1.5,
AirStrafe = 182,
GroundAcceleration = 5,
},
Tick = {
Speed = 0,
JumpHeight = 0,
JumpCap = 0,
JumpAcceleration = 0,
AirStrafe = 0,
GroundAcceleration = 0,
BHOPEnabled = 0,
},
Debounce = {
Speed = false,
JumpHeight = false,
JumpCap = false,
JumpAcceleration = false,
AirStrafe = false,
GroundAcceleration = false,
BHOPEnabled = false,
},
},
Humanoids = {
WalkspeedCF = false,
OriginalJumpHeight = false,
CF = 5,
JP = 20,
},
Utilities = {
GetCurrentSpeed = 0,
BounceModification = {
Enabled = false,
DefaultBounce = 80,
EmoteBounce = 120,
SuperBounce = false,
SuperBounceStrength = -50,
},
EdgeTrimpModification = {
Enabled = false,
HeightMultiplier = 1.5,
DownThreshold = 4.5
},
LagSwitch = {
MSDelay = 200,
Mode = "Normal",
},
},
CameraAdjustment = {
StretchX = 1,
StretchY = 1,
},
GunAdjustment = {
v = nil,
},
GameAutomation = {
Revive = {
Enabled = false,
FloatingButton = false,
Keybind = false,
WhileEmote = false,
Delay = 0.1,
},
Carry = {
Enabled = false,
FloatingButton = false,
Keybind = false,
WhileEmote = false,
lastAttempt = 0,
Cooldown = 0.5,
Connection = nil,
HeldTag = nil,
HeldAt = 0,
RetryAfter = 2.5,
},
Macro = {
SelectedEmote = "BoldMarch",
FloatingButton = false,
Keybind = false,
},
},
MovementModification = {
AggressiveEmoteDash = {
Enabled = false,
Type = "Blatant",
Speed = 3000,
Acceleration = -2,
},
SlideModification = {
FloatingButton = false,
Enabled = false,
Acceleration = -3,
},
Gravity = {
FloatingButton = false,
Keybind = false,
Value = 10,
},
BHOP = {
Enabled = false,
Keybind = false,
HoldKeybind = false,
FloatingButton = false,
JumpButton = false,
HipHeight1 = 0,
HipHeight2 = 0,
lastTick = 0.01,
lastFriction = nil,
Settings = {
AutoAcceleration = {
Enabled = false,
MaxAccelerate = 3,
MinAccelerate = -1,
MinSpeed = 70
},
SpiderHop = false,
Backwards = false,
Type = "Acceleration",
JumpType = "Simulation",
Acceleration = -0.1,
},
},
Crouch = {
FloatingButton = false,
Keybind = false,
Type = "Rapid",
isHolding = false,
debounce = 0.1,
lastTick = 0.1,
lastReleaseTick = 0.1,
},
},
},
Visual = {
AvatarChanger = {
UserId = "",
Applied = false,
Keep = true,
Original = nil,
hooked = false,
},
OriginalCosmetics = {
Cosmetics1 = "",
Cosmetics2 = "",
Cosmetics3 = "",
Cosmetics4 = "",
},
ModifyCosmetics = {
Cosmetics1 = "",
Cosmetics2 = "",
Cosmetics3 = "",
Cosmetics4 = "",
},
OriginalEmotes = {
Emote1 = "",
Emote2 = "",
Emote3 = "",
Emote4 = "",
Emote5 = "",
Emote6 = "",
Emote7 = "",
Emote8 = "",
Emote9 = "",
Emote10 = "",
Emote11 = "",
Emote12 = "",
},
ModifyEmotes = {
Emote1 = "",
Emote2 = "",
Emote3 = "",
Emote4 = "",
Emote5 = "",
Emote6 = "",
Emote7 = "",
Emote8 = "",
Emote9 = "",
Emote10 = "",
Emote11 = "",
Emote12 = "",
},
CosSwaps = {},
CurrentEmotes = {},
SelectEmotes = {},
EmoteReplacements = {},
},
Settings = {
GuiScale = {
Respawn = 0,
SuperBounce = 0,
AutoCarry = 0,
AutoEmoteDash = 0,
Gravity = 0,
InfiniteSlide = 0,
AutoJump = 0,
AutoCrouch = 0,
LagSwitch = 0,
},
},
SelfRevive = {
Method = "Spawnpoint",
Enabled = false,
HasRevived = false,
LastSavedPosition = nil,
IsProcessing = false,
LastRespawnTime = 0,
Connections = {
Heartbeat = nil,
Character = nil,
}
},
TokenFarm = {
Enabled = false,
ReviveTarget = nil,
FireCount = 0,
LastReviveFire = 0,
TokenDelay = 2,
TokenOffset = Vector3.new(0, -8, 0),
Connection = nil,
},
TimerDisplay = {
Enabled = false,
SpecialRoundEnabled = false,
TimerGui = nil,
SpecialGui = nil,
TimerConn = nil,
SpecialConn = nil,
},
}
function CreateBillboardESP(Name, Part, Color, TextSize)
if not Part or Part:FindFirstChild(Name) then return nil end
local BillboardGui = Instance.new("BillboardGui")
local TextLabel = Instance.new("TextLabel")
local TextStroke = Instance.new("UIStroke")
BillboardGui.Parent = Part
BillboardGui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
BillboardGui.Name = Name
BillboardGui.AlwaysOnTop = true
BillboardGui.Size = UDim2.new(0, 200, 0, 50)
BillboardGui.StudsOffset = Vector3.new(0, 2.5, 0)
BillboardGui.MaxDistance = 1000
TextLabel.Parent = BillboardGui
TextLabel.BackgroundTransparency = 1
TextLabel.Size = UDim2.new(1, 0, 1, 0)
TextLabel.Font = Enum.Font.SourceSans
TextLabel.TextSize = TextSize or 14
TextLabel.TextColor3 = Color or Color3.fromRGB(255, 255, 255)
TextStroke.Parent = TextLabel
TextStroke.Thickness = 1
TextStroke.Color = Color3.new(0, 0, 0)
return BillboardGui
end
function UpdateBillboardESP(Name, Part, NameText, Color, TextSize, CamPos)
if not Part then return false end
local esp = Part:FindFirstChild(Name)
if esp and esp:FindFirstChildOfClass("TextLabel") then
local label = esp:FindFirstChildOfClass("TextLabel")
if Color then label.TextColor3 = Color end
if TextSize then label.TextSize = TextSize end
if CamPos then
local distance = math.floor((CamPos - Part.Position).Magnitude)
label.Text = string.format("%s - [ %d M ]", NameText or Part.Name, distance)
else
label.Text = NameText or Part.Name
end
return true
end
return false
end
function DestroyBillboardESP(Name, Part)
if not Part then return false end
local esp = Part:FindFirstChild(Name)
if esp then esp:Destroy() return true end
return false
end
function CreateTracerESP(tracerTable, part, thickness, color)
local tracer = Drawing.new("Line")
tracer.Thickness = thickness or 2
tracer.Color = color or Color3.fromRGB(255, 255, 255)
tracer.Transparency = 1
tracer.Visible = false
tracerTable[part] = tracer
return tracer
end
function UpdateTracerESP(tracerTable, part, color)
local tracer = tracerTable[part]
if not tracer then return end
if typeof(part) ~= "Instance" or not part.Parent or not part:IsDescendantOf(workspace) then
tracer.Visible = false
pcall(function()
if tracer.Remove then tracer:Remove()
elseif tracer.Destroy then tracer:Destroy() end
end)
tracerTable[part] = nil
return
end
local ok, screenPos, onScreen = pcall(function()
return workspace.CurrentCamera:WorldToViewportPoint(part.Position)
end)
if not ok or not onScreen then
tracer.Visible = false
return
end
if color then tracer.Color = color end
tracer.From = Vector2.new(workspace.CurrentCamera.ViewportSize.X / 2, workspace.CurrentCamera.ViewportSize.Y)
tracer.To = Vector2.new(screenPos.X, screenPos.Y)
tracer.Visible = true
end
function DestroyTracerESP(tracerTable, part)
local tracer = tracerTable[part]
if tracer then
pcall(function()
if tracer.Remove then tracer:Remove()
elseif tracer.Destroy then tracer:Destroy() end
end)
tracerTable[part] = nil
end
end
function CleanupTracers(tracerTable)
for part, tracer in pairs(tracerTable) do
if typeof(part) ~= "Instance" or not part.Parent or not part:IsDescendantOf(workspace) then
pcall(function()
if tracer.Remove then tracer:Remove()
elseif tracer.Destroy then tracer:Destroy() end
end)
tracerTable[part] = nil
end
end
end
function CreateHighlightESP(Name, Part, HighlightColor, OutlineColor, OutlineOnly)
if not Part or Part:FindFirstChild(Name) then return false end
local Highlight = Instance.new("Highlight")
Highlight.Name = Name
Highlight.FillColor = HighlightColor or Color3.fromRGB(255, 255, 255)
Highlight.OutlineColor = OutlineColor or Color3.fromRGB(0, 0, 0)
Highlight.FillTransparency = OutlineOnly and 1 or 0.5
Highlight.OutlineTransparency = 0
Highlight.Parent = Part
return true
end
function UpdateHighlightESP(Name, Part, HighlightColor, OutlineColor, OutlineOnly)
local Highlight = Part and Part:FindFirstChild(Name)
if not Highlight or not Highlight:IsA("Highlight") then return false end
if HighlightColor then Highlight.FillColor = HighlightColor end
if OutlineColor then Highlight.OutlineColor = OutlineColor end
if OutlineOnly ~= nil then Highlight.FillTransparency = OutlineOnly and 1 or 0.5 end
return true
end
function DestroyHighlightESP(Name, Part)
local Highlight = Part and Part:FindFirstChild(Name)
if Highlight and Highlight:IsA("Highlight") then
Highlight:Destroy()
return true
end
return false
end
function DFunctions.CreateButton(ButtonName, Name, Size1, Size2, ScriptLogic, CircleMode)
local screenGui = Instance.new("ScreenGui")
screenGui.Name = ButtonName
screenGui.Parent = LocalPlayer.PlayerGui
screenGui.ResetOnSpawn = false
local frame = Instance.new("Frame")
frame.Name = ButtonName
frame.Size = UDim2.new(Size1, 0, Size2, 0)
frame.Position = UDim2.new(0.5 - Size1 / 2, 0, 0.5 - Size2 / 2, 0)
frame.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
frame.BackgroundTransparency = 0.7
frame.Parent = screenGui
local gradient = Instance.new("UIGradient")
gradient.Color = getgenv().ButtonGradients.Background
gradient.Parent = frame
task.spawn(function()
while task.wait(0.03) do
gradient.Rotation = (gradient.Rotation + 1) % 360
gradient.Color = getgenv().ButtonGradients.Background
end
end)
local stroke = Instance.new("UIStroke")
stroke.Thickness = 2
stroke.ApplyStrokeMode = Enum.ApplyStrokeMode.Border
stroke.Color = Color3.new(1, 1, 1)
stroke.Parent = frame
local gradientstroke = Instance.new("UIGradient")
gradientstroke.Color = getgenv().ButtonGradients.Stroke
gradientstroke.Rotation = 0
gradientstroke.Parent = stroke
task.spawn(function()
while frame.Parent do
gradientstroke.Rotation = (gradientstroke.Rotation + 0.5) % 360
gradientstroke.Color = getgenv().ButtonGradients.Stroke
task.wait()
end
end)
local corner = Instance.new("UICorner")
corner.CornerRadius = UDim.new(0, 15)
corner.Parent = frame
local button = Instance.new("TextButton")
button.Size = UDim2.new(1, 0, 1, 0)
button.BackgroundTransparency = 1
button.Text = Name
button.Font = Enum.Font.SourceSansBold
button.TextColor3 = Color3.fromRGB(255, 255, 255)
button.TextSize = 24
button.TextScaled = false
button.Parent = frame
local toggle = Instance.new("TextButton")
toggle.Size = UDim2.new(0, 28, 0, 28)
toggle.Position = UDim2.new(1, 6, 0.5, -14)
toggle.BackgroundColor3 = Color3.fromRGB(40, 40, 40)
toggle.Text = "○"
toggle.TextColor3 = Color3.fromRGB(255, 255, 255)
toggle.Visible = false
toggle.Parent = frame
local tc = Instance.new("UICorner")
tc.CornerRadius = UDim.new(1, 0)
tc.Parent = toggle
local originalSize = UDim2.new(Size1, 0, Size2, 0)
local holding = false
local holdStart = 0
local hideAt = 0
frame:SetAttribute("IsCircle", false)
local isCircle = CircleMode ~= nil and CircleMode or frame:GetAttribute("IsCircle")
local function applyShape(circle)
frame:SetAttribute("IsCircle", circle)
local s = math.min(frame.AbsoluteSize.X, frame.AbsoluteSize.Y)
if circle then
frame.Size = UDim2.new(0, s, 0, s)
button.TextWrapped = true
button.TextScaled = true
button.TextSize = math.floor(s * 0.45)
corner.CornerRadius = UDim.new(1, 0)
toggle.Text = "▢"
else
frame.Size = originalSize
button.TextWrapped = false
button.TextScaled = false
button.TextSize = 24
corner.CornerRadius = UDim.new(0, 15)
toggle.Text = "○"
end
end
applyShape(isCircle)
task.spawn(function()
while task.wait(0.25) do
if toggle.Visible and tick() - hideAt >= 10 then
toggle.Visible = false
end
end
end)
button.InputBegan:Connect(function(i)
if i.UserInputType == Enum.UserInputType.MouseButton1 or i.UserInputType == Enum.UserInputType.Touch then
holding = true
holdStart = tick()
end
end)
button.InputEnded:Connect(function(i)
if holding and (i.UserInputType == Enum.UserInputType.MouseButton1 or i.UserInputType == Enum.UserInputType.Touch) then
holding = false
if tick() - holdStart >= 0.6 then
toggle.Visible = true
hideAt = tick()
end
end
end)
toggle.MouseButton1Click:Connect(function()
hideAt = tick()
local current = frame:GetAttribute("IsCircle")
applyShape(not current)
end)
button.Activated:Connect(function()
if ScriptLogic then
ScriptLogic(button)
end
end)
FBM:AddButton(ButtonName, frame, false)
MakeDraggable(button, frame, false)
return button
end
function DFunctions.UpdateButton(Name, Size1, Size2)
local gui = LocalPlayer.PlayerGui:FindFirstChild(Name)
if gui then
local frame = gui:FindFirstChild(Name)
if frame then
frame.Size = UDim2.new(Size1, 0, Size2, 0)
local isCircle = frame:GetAttribute("IsCircle")
if isCircle then
local s = math.min(frame.AbsoluteSize.X, frame.AbsoluteSize.Y)
frame.Size = UDim2.new(0, s, 0, s)
end
end
end
end
function DFunctions.DestroyButton(Name)
local gui = LocalPlayer.PlayerGui:FindFirstChild(Name)
if gui then
gui:Destroy()
end
end
local changePlayerMode = ReplicatedStorage:FindFirstChild("Events") and ReplicatedStorage.Events:FindFirstChild("SetPlayerMode")
function DFunctions.SelfReviveRespawn()
local SelfRevive = DConfiguration.SelfRevive
local now = tick()
if now - SelfRevive.LastRespawnTime < 0.5 then return end
SelfRevive.LastRespawnTime = now
if SelfRevive.IsProcessing then return end
local char = LocalPlayer.Character
if not char then return end
local isDowned = false
if CharacterService then
local ok, charData = pcall(function() return CharacterService:GetCharacterFromPlayer(LocalPlayer) end)
if ok and charData and charData.DataRegistry and charData.DataRegistry:Get("Downed") then
isDowned = true
end
end
if not isDowned then return end
SelfRevive.IsProcessing = true
local hrp = char:FindFirstChild("HumanoidRootPart")
if SelfRevive.Method == "Spawnpoint" then
if not SelfRevive.HasRevived then
SelfRevive.HasRevived = true
pcall(function()
if changePlayerMode then changePlayerMode:FireServer(true) end
end)
SelfRevive.IsProcessing = false
task.delay(10, function()
SelfRevive.HasRevived = false
end)
else
SelfRevive.IsProcessing = false
end
elseif SelfRevive.Method == "Fake Revive" then
local savedPos = nil
if hrp then savedPos = hrp.CFrame.Position end
task.spawn(function()
pcall(function()
if changePlayerMode then changePlayerMode:FireServer(true) end
end)
local newCharacter
repeat
newCharacter = LocalPlayer.Character
task.wait()
until newCharacter and newCharacter:FindFirstChild("HumanoidRootPart") and newCharacter ~= char
if newCharacter then
local newHRP = newCharacter:FindFirstChild("HumanoidRootPart")
if savedPos and newHRP then
task.wait(0.1)
newHRP.CFrame = CFrame.new(savedPos)
end
end
SelfRevive.IsProcessing = false
end)
else
SelfRevive.IsProcessing = false
end
end
function DFunctions.StartSelfRevive()
local SelfRevive = DConfiguration.SelfRevive
if SelfRevive.Connections.Heartbeat then return end
SelfRevive.Enabled = true
SelfRevive.Connections.Heartbeat = RunService.Heartbeat:Connect(function()
if not SelfRevive.Enabled then return end
local char = LocalPlayer.Character
if not char then return end
if not CharacterService then return end
local ok, charData = pcall(function() return CharacterService:GetCharacterFromPlayer(LocalPlayer) end)
if ok and charData and charData.DataRegistry and charData.DataRegistry:Get("Downed") then
DFunctions.SelfReviveRespawn()
end
end)
SelfRevive.Connections.Character = LocalPlayer.CharacterAdded:Connect(function()
SelfRevive.HasRevived = false
SelfRevive.IsProcessing = false
SelfRevive.LastSavedPosition = nil
end)
end
function DFunctions.StopSelfRevive()
local SelfRevive = DConfiguration.SelfRevive
SelfRevive.Enabled = false
SelfRevive.HasRevived = false
SelfRevive.IsProcessing = false
SelfRevive.LastSavedPosition = nil
for name, conn in pairs(SelfRevive.Connections) do
if conn then
conn:Disconnect()
SelfRevive.Connections[name] = nil
end
end
end
function DFunctions.AutoRespawn()
DFunctions.SelfReviveRespawn()
end
function DFunctions.IsTokenFarmLocalPlayerModel(model)
if not model then return true end
if model == LocalPlayer.Character then return true end
if model.Name == LocalPlayer.Name then return true end
if model.Name == tostring(LocalPlayer.UserId) then return true end
local attrName = model:GetAttribute("Name")
if attrName == LocalPlayer.Name or attrName == LocalPlayer.DisplayName then return true end
local attrTag = model:GetAttribute("Tag")
if attrTag == LocalPlayer.Name or attrTag == LocalPlayer.DisplayName then return true end
local userId = model:GetAttribute("UserId") or model:GetAttribute("PlayerUserId")
if typeof(userId) == "number" and userId == LocalPlayer.UserId then return true end
return false
end
function DFunctions.IsValidTokenFarmTarget(model)
if not model or not model.Parent or not model:IsA("Model") then return false end
if model.Parent.Name ~= "Players" then return false end
if DFunctions.IsTokenFarmLocalPlayerModel(model) then return false end
if not model:FindFirstChild("HumanoidRootPart") then return false end
if model:GetAttribute("Tag") == nil then return false end
return true
end
function DFunctions.PickRandomTokenFarmTarget()
local playersFolder = workspace:FindFirstChild("Players")
if not playersFolder then return nil end
local valid = {}
for _, model in ipairs(playersFolder:GetChildren()) do
if DFunctions.IsValidTokenFarmTarget(model) then
table.insert(valid, model)
end
end
if #valid == 0 then return nil end
return valid[math.random(1, #valid)]
end
function DFunctions.StartGodMode()
local TF = DConfiguration.TokenFarm
if TF.Connection then return end
TF.Enabled = true
TF.Connection = RunService.Heartbeat:Connect(function()
if not TF.Enabled then return end
local char = LocalPlayer.Character
local hrp = char and char:FindFirstChild("HumanoidRootPart")
if not hrp then return end
if not DFunctions.IsValidTokenFarmTarget(TF.ReviveTarget) then
TF.ReviveTarget = DFunctions.PickRandomTokenFarmTarget()
end
local target = TF.ReviveTarget
if not target then return end
local targetHrp = target:FindFirstChild("HumanoidRootPart")
if not targetHrp then return end
hrp.CFrame = targetHrp.CFrame + TF.TokenOffset
local tag = target:GetAttribute("Tag")
if not tag then return end
local now = tick()
if now - TF.LastReviveFire >= (TF.TokenDelay or 2) then
TF.LastReviveFire = now
pcall(function()
ReplicatedStorage.Events.Interact:FireServer("Revive", tag)
ReplicatedStorage.Events.Interact:FireServer("Revive", tag, true)
end)
end
end)
end
function DFunctions.StopGodMode()
local TF = DConfiguration.TokenFarm
TF.Enabled = false
if TF.Connection then
TF.Connection:Disconnect()
TF.Connection = nil
end
TF.ReviveTarget = nil
TF.FireCount = 0
TF.LastReviveFire = 0
end
function DFunctions.DisableTouch() end
function DFunctions.CreateTimer()
local TD = DConfiguration.TimerDisplay
if LocalPlayer.PlayerGui:FindFirstChild("TimerGui") then return end
local screenGui = Instance.new("ScreenGui")
screenGui.Parent = LocalPlayer.PlayerGui
screenGui.ResetOnSpawn = false
screenGui.Name = "TimerGui"
local timerLabel = Instance.new("TextLabel")
timerLabel.Parent = screenGui
timerLabel.Size = UDim2.new(0, 200, 0, 50)
timerLabel.Position = UDim2.new(0.5, -100, 0.1, 0)
timerLabel.BackgroundTransparency = 1
timerLabel.TextScaled = true
timerLabel.Font = Enum.Font.SourceSans
timerLabel.TextColor3 = Color3.new(1, 1, 1)
timerLabel.Text = "0:00"
timerLabel.Name = "TimerLabel"
TD.TimerGui = screenGui
TD.Enabled = true
if TD.TimerConn then TD.TimerConn:Disconnect() end
TD.TimerConn = RunService.Heartbeat:Connect(function()
if not TD.Enabled then return end
local seconds = nil
if ServerStateRegistryService and ServerStateRegistryService.Registry then
seconds = ServerStateRegistryService.Registry.Time
end
if type(seconds) == "number" and seconds >= 0 and seconds ~= -1 then
local m = math.floor(seconds / 60)
local s = math.floor(seconds % 60)
timerLabel.Text = string.format("%d:%02d", m, s)
else
timerLabel.Text = "--:--"
end
end)
end
function DFunctions.RemoveTimer()
local TD = DConfiguration.TimerDisplay
TD.Enabled = false
if TD.TimerConn then
TD.TimerConn:Disconnect()
TD.TimerConn = nil
end
if LocalPlayer.PlayerGui:FindFirstChild("TimerGui") then
LocalPlayer.PlayerGui.TimerGui:Destroy()
end
TD.TimerGui = nil
end
function DFunctions.CreateSpecialRoundDisplay()
local TD = DConfiguration.TimerDisplay
if LocalPlayer.PlayerGui:FindFirstChild("SpecialRoundGui") then return end
local screenGui = Instance.new("ScreenGui")
screenGui.Parent = LocalPlayer.PlayerGui
screenGui.ResetOnSpawn = false
screenGui.Name = "SpecialRoundGui"
local specialLabel = Instance.new("TextLabel")
specialLabel.Parent = screenGui
specialLabel.Size = UDim2.new(0, 300, 0, 40)
specialLabel.Position = UDim2.new(0.5, -150, 0.16, 0)
specialLabel.BackgroundTransparency = 1
specialLabel.TextScaled = true
specialLabel.Font = Enum.Font.SourceSans
specialLabel.TextColor3 = Color3.new(1, 1, 1)
specialLabel.Text = ""
specialLabel.Name = "SpecialRoundLabel"
TD.SpecialGui = screenGui
TD.SpecialRoundEnabled = true
if TD.SpecialConn then TD.SpecialConn:Disconnect() end
TD.SpecialConn = RunService.Heartbeat:Connect(function()
if not TD.SpecialRoundEnabled then return end
local special = nil
if ServerStateRegistryService and ServerStateRegistryService.Registry then
special = ServerStateRegistryService.Registry.SpecialRound
end
if special and special ~= false and special ~= "" then
local title = tostring(special)
pcall(function()
local folder = ReplicatedStorage:FindFirstChild("Info") and ReplicatedStorage.Info:FindFirstChild("SpecialRounds")
if folder then
local mod = folder:FindFirstChild(tostring(special))
if mod then
local ok, data = pcall(require, mod)
if ok and data and data.Title then title = data.Title end
end
end
end)
specialLabel.Text = title
else
specialLabel.Text = ""
end
end)
end
function DFunctions.RemoveSpecialRoundDisplay()
local TD = DConfiguration.TimerDisplay
TD.SpecialRoundEnabled = false
if TD.SpecialConn then
TD.SpecialConn:Disconnect()
TD.SpecialConn = nil
end
if LocalPlayer.PlayerGui:FindFirstChild("SpecialRoundGui") then
LocalPlayer.PlayerGui.SpecialRoundGui:Destroy()
end
TD.SpecialGui = nil
end
function DFunctions.RemoveReduceRewards() end
function DFunctions.DisableInvisParts(state)
local map = workspace:FindFirstChild("Map")
if not map then return end
local invis = map:FindFirstChild("InvisParts") or map:FindFirstChild("MapLogic")
if not invis then return end
for _, v in pairs(invis:GetDescendants()) do
if v:IsA("BasePart") then
v.CanCollide = state
end
end
end
function DFunctions.DisableCameraShake() end
function DFunctions.DisableVignette() end
function DFunctions.GetDownedPlayer()
local folder = workspace:FindFirstChild("Players")
if not folder then return nil end
for _, v in pairs(folder:GetChildren()) do
if v:GetAttribute("Downed") and v:FindFirstChild("HumanoidRootPart") then
return v
end
end
return nil
end
function DFunctions.GetEventNPC() return nil end
function DFunctions.TPEventNPC() end
function DFunctions.GetObjective()
local objectives = {}
local map = workspace:FindFirstChild("Map")
if not map then
local gameFolder = workspace:FindFirstChild("Game")
map = gameFolder and gameFolder:FindFirstChild("Map")
end
if not map then return objectives end
local parts = map:FindFirstChild("Parts") or map:FindFirstChild("MapLogic")
if not parts then return objectives end
local objectivesFolder = parts:FindFirstChild("Objectives")
if not objectivesFolder then return objectives end
for _, obj in pairs(objectivesFolder:GetChildren()) do
if obj:GetAttribute("Completed") == true then continue end
local primaryPart = obj.PrimaryPart or obj:FindFirstChildWhichIsA("BasePart")
if primaryPart or obj:IsA("BasePart") then
table.insert(objectives, {
Name = obj.Name,
Part = primaryPart or obj,
Position = (primaryPart or obj).Position,
Tag = obj:GetAttribute("Tag"),
Instance = obj
})
end
end
return objectives
end
local FarmPart
function DFunctions.AFKFarming()
local character = LocalPlayer.Character
local hrp = character and character:FindFirstChild("HumanoidRootPart")
if not hrp then return end
if not FarmPart then
FarmPart = Instance.new("Part")
FarmPart.Size = Vector3.new(10, 1, 10)
FarmPart.Anchored = true
FarmPart.CanCollide = true
FarmPart.Name = "AFKFarmPad"
FarmPart.CFrame = CFrame.new(1131, 1015, 2222)
FarmPart.Parent = workspace
end
hrp.CFrame = FarmPart.CFrame + Vector3.new(0, 3, 0)
end
function DFunctions.RevivePlayer()
local downed = DFunctions.GetDownedPlayer()
if downed and downed:FindFirstChild("HumanoidRootPart") then
local hrp = LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("HumanoidRootPart")
if hrp then
hrp.CFrame = CFrame.new(downed.HumanoidRootPart.Position + Vector3.new(0, 2, 0))
end
else
DFunctions.AFKFarming()
end
end
function DFunctions.TokenFarming()
DFunctions.StartGodMode()
end
function DFunctions.PointFarming()
local objectives = DFunctions.GetObjective()
if type(objectives) ~= "table" or #objectives == 0 then return end
for _, objective in ipairs(objectives) do
local inst = objective.Instance
if inst and inst:FindFirstChild("WhenActivated") then
local tagValue = objective.Tag or inst:GetAttribute("Tag")
if tagValue then
pcall(function()
ReplicatedStorage.Events.Interact:FireServer("Dynamic", tagValue)
end)
task.wait(0.2)
end
end
end
end
function DFunctions.TicketsFarming()
local hrp = LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("HumanoidRootPart")
if not hrp then return end
local ticketsFolder = workspace:FindFirstChild("Effects") and workspace.Effects:FindFirstChild("Tickets")
if not ticketsFolder then
DFunctions.AFKFarming()
return
end
for _, v in ipairs(ticketsFolder:GetDescendants()) do
if v:IsA("BasePart") and v.Name == "HumanoidRootPart" then
hrp.CFrame = CFrame.new(v.Position)
return
end
end
DFunctions.AFKFarming()
end
function DFunctions.AutoVote() end
function DFunctions.NormalizeVIPString(str)
return tostring(str or ""):gsub("%s+", ""):lower()
end
function DFunctions.AdminCommand(commandString)
local cmd = ReplicatedStorage:FindFirstChild("Events")
and ReplicatedStorage.Events:FindFirstChild("Admin")
and ReplicatedStorage.Events.Admin:FindFirstChild("Command")
if not cmd then return end
pcall(function()
cmd:FireServer(commandString)
end)
end
function DFunctions.SetVIPCommands()
local VIP = DConfiguration.AutoFarm.VIPAutomations
local svc = ServerStateRegistryService
if not svc then return end
local function getState(key)
if svc.Registry then
return svc.Registry[key]
end
return nil
end
local function normalize(str)
return tostring(str or ""):gsub("%s+", ""):lower()
end
local function getMapDisplayName(moduleName)
local mapsFolder = ReplicatedStorage:FindFirstChild("Info") and ReplicatedStorage.Info:FindFirstChild("Maps")
if not mapsFolder then return nil end
local mod = mapsFolder:FindFirstChild(moduleName)
if mod and mod:IsA("ModuleScript") then
local ok, data = pcall(require, mod)
if ok and data and data.Name then
return data.Name
end
end
return nil
end
local function getMapModuleName(displayName)
local mapsFolder = ReplicatedStorage:FindFirstChild("Info") and ReplicatedStorage.Info:FindFirstChild("Maps")
if not mapsFolder then return nil end
for _, mod in ipairs(mapsFolder:GetChildren()) do
if mod:IsA("ModuleScript") then
local ok, data = pcall(require, mod)
if ok and data and data.Name then
if normalize(data.Name) == normalize(displayName) then
return mod.Name
end
end
end
end
return nil
end
local function getSpecialRoundDisplayName(moduleName)
local srFolder = ReplicatedStorage:FindFirstChild("Info") and ReplicatedStorage.Info:FindFirstChild("SpecialRounds")
if not srFolder then return nil end
local mod = srFolder:FindFirstChild(moduleName)
if mod and mod:IsA("ModuleScript") then
local ok, data = pcall(require, mod)
if ok and data and data.Name then
return data.Name
end
end
return nil
end
local function getSpecialRoundModuleName(displayName)
local srFolder = ReplicatedStorage:FindFirstChild("Info") and ReplicatedStorage.Info:FindFirstChild("SpecialRounds")
if not srFolder then return nil end
for _, mod in ipairs(srFolder:GetChildren()) do
if mod:IsA("ModuleScript") then
local ok, data = pcall(require, mod)
if ok and data and data.Name then
if normalize(data.Name) == normalize(displayName) then
return mod.Name
end
end
end
end
return nil
end
if VIP.AutoMap and VIP.MapInput and VIP.MapInput ~= "" then
if tick() - (VIP.LastMapSet or 0) >= 1 then
local current = getState("Map")
local desired = VIP.MapInput
local match = false
local nc = normalize(current)
local nd = normalize(desired)
if nc == nd then
match = true
else
local display = getMapDisplayName(desired)
if display and normalize(display) == nc then
match = true
end
local moduleName = getMapModuleName(desired)
if moduleName and normalize(moduleName) == nc then
match = true
end
end
if not match then
local isLoading = getState("MapLoading")
if type(isLoading) == "string" then
else
DFunctions.AdminCommand("!Map " .. desired)
VIP.LastMapSet = tick()
end
end
end
end
if VIP.AutoSpecialRound and VIP.SpecialRoundInput and VIP.SpecialRoundInput ~= "" then
if tick() - (VIP.LastSRSet or 0) >= 1 then
local current = getState("SpecialRound")
local desired = VIP.SpecialRoundInput
local match = false
local nc = normalize(current)
local nd = normalize(desired)
if nc == nd then
match = true
else
local display = getSpecialRoundDisplayName(desired)
if display and normalize(display) == nc then
match = true
end
local moduleName = getSpecialRoundModuleName(desired)
if moduleName and normalize(moduleName) == nc then
match = true
end
end
if not match then
DFunctions.AdminCommand("!SpecialRound " .. desired)
VIP.LastSRSet = tick()
end
end
end
if VIP.AutoTimer and VIP.TimerInput and VIP.TimerInput ~= "" then
if tick() - (VIP.LastTimerSet or 0) >= 3 then
local roundStatus = getState("RoundStatus")
local roundState = VIP.TimerRoundState or 1
local shouldFire = false
if roundState == 1 and roundStatus == 2 then
shouldFire = true
elseif roundState == 2 and roundStatus ~= 2 then
shouldFire = true
elseif roundState == 3 then
shouldFire = true
end
if shouldFire then
local currentTime = getState("Time")
local desiredNum = tonumber(VIP.TimerInput)
if desiredNum and (currentTime == nil or currentTime ~= desiredNum) then
DFunctions.AdminCommand("!Time " .. tostring(desiredNum))
VIP.LastTimerSet = tick()
end
end
end
end
end
function DFunctions.GetItemRegistry()
if ItemRegistry then return ItemRegistry end
return ItemRegistry
end
function DFunctions.GetEmotesName()
local names = {}
local reg = DFunctions.GetItemRegistry()
if not reg then return names end
local byCat = reg.GetByCategory and reg.GetByCategory("Emotes")
if byCat then
for id, entry in pairs(byCat) do
if entry and entry.Module then
table.insert(names, entry.Module.Name)
end
end
end
if #names == 0 then
local all = reg.GetAll and reg.GetAll()
if all then
for id, entry in pairs(all) do
if entry and entry.Categories then
for _, cat in ipairs(entry.Categories) do
if tostring(cat):lower():find("emote") then
table.insert(names, entry.Module.Name)
break
end
end
end
end
end
end
table.sort(names)
return names
end
DConfiguration.AutoFarm.PurchaseAutomations.Catalog = nil
function DFunctions.BuildShopCatalog()
local cached = DConfiguration.AutoFarm.PurchaseAutomations.Catalog
if cached then return cached end
local names, ids = {}, {}
local reg = DFunctions.GetItemRegistry()
if reg then
local getAll = reg.GetAll or reg.GetAllItems or reg.GetItems
local all = type(getAll) == "function" and Safe(getAll) or nil
if not all and type(reg) == "table" then all = reg end
for id, entry in pairs(all or {}) do
local config = entry
if type(entry) == "table" then
config = entry.Config or entry.Configuration or entry
if type(config) ~= "table" and type(entry.Module) == "table" then config = entry.Module end
end
if type(config) == "table" then
if not config.PurchaseInfo and reg.GetConfig then
local ok, fetched = pcall(reg.GetConfig, id)
if ok and type(fetched) == "table" then config = fetched end
end
local purchase = config.PurchaseInfo
if type(purchase) == "table" and (purchase.AppearsIn == "Shop" or purchase.Shop == true) then
local name = (config.AppearanceInfo and config.AppearanceInfo.Name)
or config.Name or config.Id or tostring(id)
if type(name) == "string" and name ~= "" and not ids[name] then
table.insert(names, name)
ids[name] = id
end
end
end
end
end
table.sort(names)
local catalog = { Names = names, Ids = ids }
DConfiguration.AutoFarm.PurchaseAutomations.Catalog = catalog
return catalog
end
function DFunctions.GetMultipleShopItems()
return DFunctions.BuildShopCatalog().Names
end
function DFunctions.GetPurchaseRemote()
local cached = DConfiguration.AutoFarm.PurchaseAutomations.Remote
if cached and cached.Parent then return cached end
local candidates = {
{ "Shared", "UserData", "Events", "Requests", "Purchase" },
{ "Shared", "UserData", "Events", "Purchase" },
{ "Shared", "Events", "Purchase" },
{ "Events", "Purchase" },
{ "Remotes", "Purchase" },
{ "Requests", "Purchase" },
{ "Net", "RE/Purchase" },
}
for _, path in ipairs(candidates) do
local node = ReplicatedStorage
for _, step in ipairs(path) do
node = node and node:FindFirstChild(step)
end
if node and (node:IsA("RemoteEvent") or node:IsA("RemoteFunction")) then
DConfiguration.AutoFarm.PurchaseAutomations.Remote = node
return node
end
end
for _, d in ipairs(ReplicatedStorage:GetDescendants()) do
if d.Name == "Purchase" and (d:IsA("RemoteEvent") or d:IsA("RemoteFunction")) then
DConfiguration.AutoFarm.PurchaseAutomations.Remote = d
return d
end
end
return nil
end
function DFunctions.BuyItem()
local config = DConfiguration.AutoFarm.PurchaseAutomations
local catalog = DFunctions.BuildShopCatalog()
local selected = config.Selected
if (not selected or selected == "") and #catalog.Names > 0 then
selected = catalog.Names[1]
config.Selected = selected
end
if not selected or selected == "" then
return false, "no shop item selected"
end
local itemId = catalog.Ids[selected]
if not itemId then
return false, "selected item is not in the shop catalog"
end
local remote = DFunctions.GetPurchaseRemote()
if not remote then
return false, "purchase remote not found"
end
local amount = tonumber(config.Amount) or 1
local ok, err = pcall(function()
if remote:IsA("RemoteFunction") then
remote:InvokeServer(itemId, amount)
else
remote:FireServer(itemId, amount)
end
end)
if not ok then return false, tostring(err) end
config.LastBuy = tick()
return true, itemId
end
function DFunctions.GetCosmeticsName()
local names = {}
local reg = DFunctions.GetItemRegistry()
if not reg then return names end
local byCat = reg.GetByCategory and (reg.GetByCategory("Cosmetics") or reg.GetByCategory("Cosmetic"))
if byCat then
for id, entry in pairs(byCat) do
if entry and entry.Module then
table.insert(names, entry.Module.Name)
end
end
end
table.sort(names)
return names
end
function DFunctions.GetItemByName(name)
local reg = DFunctions.GetItemRegistry()
if not reg or not name or name == "" then return nil end
if reg.TryGetByName then
return reg.TryGetByName(name)
end
return nil
end
function DFunctions.GetItemConfig(nameOrId)
local reg = DFunctions.GetItemRegistry()
if not reg then return nil end
local id = tonumber(nameOrId)
if not id and reg.TryGetByName then
local entry = reg.TryGetByName(tostring(nameOrId))
if entry then id = entry.Id end
end
if id and reg.GetConfig then
return reg.GetConfig(id)
end
return nil
end
function DFunctions.GetSafeCFrame(typ, root, tdist, nextbotPos)
if typ == "Spawn" then
local map = workspace:FindFirstChild("Map")
local spawns = map and (map:FindFirstChild("ItemSpawns") or map:FindFirstChild("Spawns") or map:FindFirstChild("MapLogic"))
if spawns then
local parts = {}
for _, p in pairs(spawns:GetDescendants()) do
if p:IsA("BasePart") then table.insert(parts, p) end
end
if #parts > 0 then
local r = parts[math.random(1, #parts)]
return CFrame.new(r.Position + Vector3.new(0, 3, 0))
end
end
elseif typ == "Players" then
local players = Players:GetPlayers()
local candidates = {}
for _, plr in pairs(players) do
if plr ~= LocalPlayer and plr.Character and plr.Character:FindFirstChild("HumanoidRootPart") then
table.insert(candidates, plr)
end
end
if #candidates > 0 then
local r = candidates[math.random(1, #candidates)]
return r.Character.HumanoidRootPart.CFrame + Vector3.new(0, 3, 0)
end
elseif typ == "Distance" and root and nextbotPos then
local dir = (root.Position - nextbotPos)
if dir.Magnitude > 0.1 then
return CFrame.new(root.Position + dir.Unit * (tdist or 100))
end
end
return root and (root.CFrame + Vector3.new(0, 50, 0)) or CFrame.new(0, 100, 0)
end
function DFunctions.AntiNextbot()
local myChar = LocalPlayer.Character
local myHRP = myChar and myChar:FindFirstChild("HumanoidRootPart")
if not myHRP then return end
local range = DConfiguration.Combat.AntiNextbotRange or 50
local tpType = DConfiguration.Combat.AntiNextbotType or "Spawn"
local function checkFolder(folder)
if not folder then return false end
for _, v in pairs(folder:GetChildren()) do
if v:IsA("Model") and v:GetAttribute("Team") == "Nextbot" and v:FindFirstChild("HumanoidRootPart") then
if (myHRP.Position - v.HumanoidRootPart.Position).Magnitude < range then
local target = DFunctions.GetSafeCFrame(tpType, myHRP, 100, v.HumanoidRootPart.Position)
if target then myHRP.CFrame = target end
return true
end
end
end
return false
end
if checkFolder(workspace:FindFirstChild("Players")) then return end
local gameFolder = workspace:FindFirstChild("Game")
if gameFolder then checkFolder(gameFolder:FindFirstChild("Players")) end
end
function DFunctions.GetAdjustments() end
function DFunctions.setTSpeed(value)
DFunctions.MovementValueSet("Speed", tonumber(value) or 1500)
end
function DFunctions.setTJump(value)
DFunctions.MovementValueSet("JumpHeight", tonumber(value) or 3)
end
function DFunctions.setTJumpCap(value)
DFunctions.MovementValueSet("JumpCap", tonumber(value) or 1)
end
function DFunctions.setTJumpAcceleration(value)
DFunctions.MovementValueSet("JumpSpeedMultiplier", tonumber(value) or 1.45)
end
function DFunctions.setTAirStrafe(value)
DFunctions.MovementValueSet("AirStrafeAcceleration", tonumber(value) or 182)
end
function DFunctions.setTAirAccel(value)
DFunctions.MovementValueSet("AirAcceleration", tonumber(value) or 1)
end
function DFunctions.setTSprintCap(value)
DFunctions.MovementValueSet("SprintCap", tonumber(value) or 2)
end
function DFunctions.setTSprintAccel(value)
DFunctions.MovementValueSet("SprintAcceleration", tonumber(value) or 1)
end
function DFunctions.setTFriction(value)
DFunctions.MovementValueSet("Friction", tonumber(value) or 5)
end
function DFunctions.setTFriction() end
function DFunctions.setBhopEnabled() end
function DFunctions.setStrafeAcceleration() end
function DFunctions.SetPreviousAdjustment() end
function DFunctions.GetSpeedometer()
local shared = LocalPlayer.PlayerGui:FindFirstChild("Shared")
if not shared then return nil end
local hud = shared:FindFirstChild("HUD")
if not hud then return nil end
local overlay = hud:FindFirstChild("Overlay")
if not overlay then return nil end
local default = overlay:FindFirstChild("Default")
if not default then return nil end
local charInfo = default:FindFirstChild("CharacterInfo")
if not charInfo then return nil end
local item = charInfo:FindFirstChild("Item")
if not item then return nil end
local speedometer = item:FindFirstChild("Speedometer")
if not speedometer then return nil end
return speedometer:FindFirstChild("Players")
end
function DFunctions.BounceFunction()
local char = LocalPlayer.Character
local humanoid = char and char:FindFirstChild("Humanoid")
if not humanoid then return end
if not DConfiguration.Misc.Utilities.BounceModification.Enabled then
humanoid.WalkSpeed = 0
return
end
local state = char:GetAttribute("State")
if state == "Default" or state == "Downed" then
humanoid.WalkSpeed = 0
elseif state == "Emoting" or state == "EmotingAir" or state == "EmotingSlide" or state == "EmotingSlideAir" then
humanoid.WalkSpeed = DConfiguration.Misc.Utilities.BounceModification.EmoteBounce
else
humanoid.WalkSpeed = DConfiguration.Misc.Utilities.BounceModification.DefaultBounce
end
end
function DFunctions.SuperBounce()
local char = LocalPlayer.Character
if not char then return end
local hrp = char:FindFirstChild("HumanoidRootPart")
local humanoid = char:FindFirstChild("Humanoid")
if not hrp or not humanoid then return end
local prevHip = char:FindFirstChild("R15Visual") and 0.75 or -1.25
hrp.CanCollide = false
humanoid.HipHeight = -100
task.wait(2)
hrp.CanCollide = true
humanoid.HipHeight = prevHip
end
function DFunctions.StartLag(ms)
local LagTime = (ms or 200) * 0.002
local Character = LocalPlayer.Character
if not Character then return end
local hrp = Character:FindFirstChild("HumanoidRootPart")
if not hrp then return end
local StoredVelocity = hrp.AssemblyLinearVelocity
if StoredVelocity.Magnitude < 1 then return end
local start = tick()
while tick() - start < LagTime do end
local Mode = DConfiguration.Misc.Utilities.LagSwitch.Mode
if Mode == "FastFlag" or LagTime < 0.2 then
if setfflag then
setfflag("MaxMissedWorldStepsRemembered", "9999")
end
return
end
end
local EdgeParams = RaycastParams.new()
EdgeParams.FilterType = Enum.RaycastFilterType.Blacklist
function DFunctions.ModifyEdgeTrimp()
local Character = LocalPlayer.Character
if not Character then return end
local Root = Character:FindFirstChild("HumanoidRootPart")
if not Root then return end
local Velocity = Root.AssemblyLinearVelocity
local HorizontalVel = Vector3.new(Velocity.X, 0, Velocity.Z)
local Speed = HorizontalVel.Magnitude
if Speed < 22 then return end
if Velocity.Y >= 0 then return end
local MoveDir = HorizontalVel.Unit
EdgeParams.FilterDescendantsInstances = {Character}
local PredictTime = math.clamp(Speed / 110, 0.14, 0.24)
local FutureMovePos = Root.Position + HorizontalVel * PredictTime + MoveDir * 2.5
local dropThreshold = DConfiguration.Misc.Utilities.EdgeTrimpModification.DownThreshold
local heightMult = DConfiguration.Misc.Utilities.EdgeTrimpModification.HeightMultiplier
local downHit = workspace:Raycast(FutureMovePos + Vector3.new(0, 2, 0), Vector3.new(0, -6, 0), EdgeParams)
if downHit then
local drop = Root.Position.Y - downHit.Position.Y
if drop >= dropThreshold then
Root.AssemblyLinearVelocity = HorizontalVel * 1.05 + Vector3.new(0, math.clamp(Speed * 0.7, 22, 85) * heightMult, 0)
end
end
end
local CharacterTag = nil
local function GetCharacterTag(character)
if not character then return nil end
return character:GetAttribute("Tag")
end
if LocalPlayer.Character then CharacterTag = GetCharacterTag(LocalPlayer.Character) end
LocalPlayer.CharacterAdded:Connect(function(c) CharacterTag = GetCharacterTag(c) end)
local function getCurrentSpeed(character)
if not character then return 0 end
local hrp = character:FindFirstChild("HumanoidRootPart")
if not hrp then return 0 end
local velocity = hrp.AssemblyLinearVelocity
return (velocity.X * velocity.X + velocity.Z * velocity.Z) ^ 0.5
end
function DFunctions.MovementValueSet(MovementType, value)
if not CharacterTag then CharacterTag = GetCharacterTag(LocalPlayer.Character) end
if not CharacterTag then return end
pcall(function()
firesignal(ReplicatedStorage.Events.CharacterTask.OnClientEvent, CharacterTag, "ModifyMovement", { MovementType, value })
end)
end
local MovementValueSet = DFunctions.MovementValueSet
local originalRegistry = MovementModule.RegistryTermUpdated
local originalMovementUpdate = MovementModule.Update
if originalRegistry then
MovementModule.RegistryTermUpdated = function(self, term)
if term == "Emote" then
local AED = DConfiguration.Misc.MovementModification.AggressiveEmoteDash
local id = self.DataRegistry:Get("Emote")
if id and id ~= 0 then
local item = ClientItemService:GetItemFromID(id)
local mult = 1
if item then
local ok, mod = pcall(require, item)
if ok and mod and mod.EmoteInfo then mult = mod.EmoteInfo.SpeedMult or 1 end
end
if AED.Enabled and AED.Type == "Blatant" then
self.MoveStats:SpeedChange("Emote", mult * ((AED.Speed or 1000) / 1000))
else
self.MoveStats:SpeedChange("Emote", mult)
end
else
self.MoveStats:SpeedChange("Emote", nil)
end
return
end
return originalRegistry(self, term)
end
end
if originalMovementUpdate then
MovementModule.Update = function(self, ...)
originalMovementUpdate(self, ...)
local humanoid = self.Character and self.Character:FindFirstChildOfClass("Humanoid")
if not humanoid then return end
local MM = DConfiguration.Misc.MovementModification
local BHOP = MM.BHOP
local S = BHOP.Settings
local AED = MM.AggressiveEmoteDash
local Slide = MM.SlideModification
local state = self.State or (self.DataRegistry and self.DataRegistry:Get("State"))
local grounded = self.DataRegistry and self.DataRegistry:Get("Grounded")
local desiredFriction = nil
local isInfSlide = (state == "Slide" or state == "EmotingSlide" or state == "CarrySlide")
local isEmoteSlideAccel = (state == "EmotingSlide")
if isInfSlide and Slide.Enabled then
desiredFriction = Slide.Acceleration or -8
end
if isEmoteSlideAccel and AED.Enabled and AED.Type == "Legit" then
desiredFriction = AED.Acceleration or -2
end
local accelOn = S.Type ~= "No Acceleration"
if desiredFriction == nil and accelOn then
local isBhopActive = BHOP.Enabled or (BHOP.HoldKeybind and humanoid.Jump == true)
if isBhopActive and not grounded then
local currentSpeed = getCurrentSpeed(self.Character)
local AA = S.AutoAcceleration
if AA.Enabled then
if currentSpeed > (AA.MinSpeed or 70) then
desiredFriction = AA.MaxAccelerate or 3
elseif currentSpeed < (AA.MinSpeed or 70) then
desiredFriction = AA.MinAccelerate or -1
else
desiredFriction = S.Acceleration or -0.2
end
else
desiredFriction = S.Acceleration or -0.2
end
end
end
if desiredFriction ~= nil then
MovementValueSet("Friction", desiredFriction)
BHOP.lastFriction = desiredFriction
BHOP.frictionHeld = true
elseif BHOP.frictionHeld then
MovementValueSet("Friction", DConfiguration.Misc.PlayerAdjustment.Default.Friction)
BHOP.lastFriction = nil
BHOP.frictionHeld = false
end
if (state == "WallrunRight" or state == "WallrunLeft") and S.SpiderHop then
pcall(function() self:AttemptJump() end)
end
if BHOP.Enabled and grounded then
if S.JumpType == "Realistic" then
pcall(function() self:AttemptJump() end)
else
humanoid:ChangeState(Enum.HumanoidStateType.Jumping)
end
end
if BHOP.HoldKeybind and grounded and humanoid.Jump == true then
pcall(function() self:AttemptJump() end)
end
end
end
local function updateBhopEnabled()
local BHOP = DConfiguration.Misc.MovementModification.BHOP
local shouldEnable = (BHOP.Enabled or BHOP.HoldKeybind) and BHOP.Settings.Type ~= "No Acceleration"
MovementValueSet("BhopEnabled", shouldEnable)
end
function DFunctions.GetStatus(player)
if not player then return "DEAD" end
local character = player.Character
if not character then return "DEAD" end
local cs = CharacterService
if not cs then
pcall(function()
cs = CharacterService
end)
end
if cs then
local ok, charData = pcall(function() return cs:GetCharacterFromPlayer(player) end)
if ok and charData and charData.DataRegistry then
if charData.DataRegistry:Get("Downed") then
return "DOWNED"
end
end
end
local folder = workspace:FindFirstChild("Players")
local folderPlr = folder and folder:FindFirstChild(player.Name)
if folderPlr then
local downed = folderPlr:GetAttribute("Downed")
if downed == true or downed == 1 or downed == "true" then
return "DOWNED"
end
end
if character:GetAttribute("Downed") == true then
return "DOWNED"
end
local humanoid = character:FindFirstChildOfClass("Humanoid")
if humanoid and humanoid.Health > 0 then return "ALIVE" end
return "DEAD"
end
function DFunctions.isPlayerDowned(player)
return DFunctions.GetStatus(player) == "DOWNED"
end
function DFunctions.isPlayerRagdolled(player)
if not player or not player.Character then return false end
local char = player.Character
if char:FindFirstChild("RagdollConstraints") then return true end
if CharacterService then
local ok, charData = pcall(function() return CharacterService:GetCharacterFromPlayer(player) end)
if ok and charData and charData.DataRegistry and charData.DataRegistry:Get("Ragdolling") then return true end
end
if char.PrimaryPart and char.PrimaryPart.Anchored then return true end
return false
end
function DFunctions.getNearestDownedPlayer()
local nearest, nearestDist = nil, 20
local hrp = LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("HumanoidRootPart")
if not hrp then return nil end
for _, plr in pairs(Players:GetPlayers()) do
if plr ~= LocalPlayer and DFunctions.isPlayerDowned(plr) and not DFunctions.isPlayerRagdolled(plr) then
local otherHRP = plr.Character and plr.Character:FindFirstChild("HumanoidRootPart")
if otherHRP then
local dist = (hrp.Position - otherHRP.Position).Magnitude
if dist < nearestDist then
nearestDist = dist
nearest = plr
end
end
end
end
return nearest
end
function DFunctions.IsCarryingBody(player)
local character = LocalPlayer.Character
local other = player and player.Character
if not character or not other then return false end
for _, item in ipairs(character:GetDescendants()) do
if item:IsA("WeldConstraint") or item:IsA("Weld") or item:IsA("Motor6D") then
local a, b = item.Part0, item.Part1
if a and b then
if (a:IsDescendantOf(character) and b:IsDescendantOf(other))
or (b:IsDescendantOf(character) and a:IsDescendantOf(other)) then
return true
end
end
end
end
return false
end
function DFunctions.FindPlayerByTag(tag)
if not tag then return nil end
for _, plr in ipairs(Players:GetPlayers()) do
local character = plr.Character
if character and character:GetAttribute("Tag") == tag then return plr end
end
return nil
end
function DFunctions.CarryPlayer()
local Carry = DConfiguration.Misc.GameAutomation.Carry
if DFunctions.GetStatus(LocalPlayer) ~= "ALIVE" then return false end
local target = DFunctions.getNearestDownedPlayer()
if not target or not target.Character then return false end
local tag = target.Character:GetAttribute("Tag")
if not tag then return false end
if Carry.HeldTag then
if Carry.HeldTag == tag and DFunctions.IsCarryingBody(target) then return false end
if Carry.HeldTag == tag and tick() - (Carry.HeldAt or 0) < (Carry.RetryAfter or 2.5) then return false end
Carry.HeldTag = nil
end
Carry.HeldTag = tag
Carry.HeldAt = tick()
pcall(function()
ReplicatedStorage.Events.Interact:FireServer("Carry", tag)
end)
return true
end
function DFunctions.ReleaseCarryHold()
local Carry = DConfiguration.Misc.GameAutomation.Carry
local tag = Carry.HeldTag
if not tag then return false end
local held = DFunctions.FindPlayerByTag(tag)
if not held or not DFunctions.isPlayerDowned(held) then
Carry.HeldTag = nil
return true
end
return false
end
function DFunctions.StartAutoCarry()
local Carry = DConfiguration.Misc.GameAutomation.Carry
if Carry.Connection then Carry.Connection:Disconnect() end
Carry.Enabled = true
Carry.HeldTag = nil
Carry.Connection = RunService.Heartbeat:Connect(function()
if not Carry.Enabled then return end
local now = tick()
if now - (Carry.lastAttempt or 0) < (Carry.Cooldown or 0.5) then return end
DFunctions.ReleaseCarryHold()
DFunctions.CarryPlayer()
Carry.lastAttempt = now
end)
end
function DFunctions.StopAutoCarry()
local Carry = DConfiguration.Misc.GameAutomation.Carry
Carry.Enabled = false
Carry.HeldTag = nil
if Carry.Connection then
Carry.Connection:Disconnect()
Carry.Connection = nil
end
end
function DFunctions.AggressiveEmoteDashFunction()
if MovementModule then
pcall(function()
local id = MovementModule.DataRegistry:Get("Emote")
if id and id ~= 0 then
MovementModule.RegistryTermUpdated(MovementModule, "Emote")
end
end)
end
end
function DFunctions.SetToMovableEmote() end
function DFunctions.InfiniteSlideFunction()
end
function DFunctions.ToggleBhop(state)
DConfiguration.Misc.MovementModification.BHOP.Enabled = state and true or false
updateBhopEnabled()
end
function DFunctions.ToggleBhopHold(state)
DConfiguration.Misc.MovementModification.BHOP.HoldKeybind = state and true or false
updateBhopEnabled()
end
function DFunctions.SetAccelerationMethod(method)
local BHOP = DConfiguration.Misc.MovementModification.BHOP
BHOP.Settings.Type = method
updateBhopEnabled()
if not (BHOP.Enabled or BHOP.HoldKeybind) then
MovementValueSet("Friction", DConfiguration.Misc.PlayerAdjustment.Default.Friction)
BHOP.lastFriction = nil
end
end
function DFunctions.BHOPFunction()
updateBhopEnabled()
end
function DFunctions.ResetBHOP()
local BHOP = DConfiguration.Misc.MovementModification.BHOP
BHOP.Enabled = false
BHOP.HoldKeybind = false
updateBhopEnabled()
MovementValueSet("Friction", DConfiguration.Misc.PlayerAdjustment.Default.Friction)
BHOP.lastFriction = nil
end
local CrouchModes = { Spam = "Spam", Air = "Air", Classic = "Classic" }
local CrouchLegacy = { Rapid = "Spam", Normal = "Classic", Ground = "Classic" }
function DFunctions.CrouchMode()
local raw = tostring(DConfiguration.Misc.MovementModification.Crouch.Type or "Spam")
return CrouchModes[raw] or CrouchLegacy[raw] or "Spam"
end
local CROUCH_EVENT_CACHE = nil
function DFunctions.GetCrouchEvent()
if CROUCH_EVENT_CACHE and CROUCH_EVENT_CACHE.Parent then return CROUCH_EVENT_CACHE end
CROUCH_EVENT_CACHE = nil
local services = ReplicatedStorage:FindFirstChild("Services")
local client = services and services:FindFirstChild("Client")
local keybindService = client and client:FindFirstChild("KeybindService")
local event = keybindService and keybindService:FindFirstChild("SendKeybindEvent")
CROUCH_EVENT_CACHE = event
return event
end
function DFunctions.FireCrouch(down)
local ev = DFunctions.GetCrouchEvent()
if not ev then return false end
pcall(function() ev:Fire({ Down = down and true or false, Key = "Crouching" }) end)
return true
end
function DFunctions.ReleaseCrouch()
local Config = DConfiguration.Misc.MovementModification.Crouch
if Config.isHolding then
DFunctions.FireCrouch(false)
Config.isHolding = false
end
end
function DFunctions.CrouchFunction()
local Config = DConfiguration.Misc.MovementModification.Crouch
local now = tick()
Config.isHolding = Config.isHolding or false
Config.debounce = Config.debounce or 0.1
Config.nextAllowed = Config.nextAllowed or 0
if Config.nextAllowed > now + Config.debounce then Config.nextAllowed = 0 end
if not DFunctions.GetCrouchEvent() then return end
local mode = DFunctions.CrouchMode()
if mode == "Classic" then
if not Config.isHolding then
if DFunctions.FireCrouch(true) then Config.isHolding = true end
end
return
end
if mode == "Air" then
local character = LocalPlayer.Character
local humanoid = character and character:FindFirstChildOfClass("Humanoid")
local material = humanoid and humanoid.FloorMaterial
local airborne = material == Enum.Material.Air or material == nil
if airborne then
if not Config.isHolding then
if DFunctions.FireCrouch(true) then
Config.isHolding = true
Config.nextAllowed = now + Config.debounce
end
end
else
DFunctions.ReleaseCrouch()
end
return
end
if now < Config.nextAllowed then return end
Config.nextAllowed = now + Config.debounce
if Config.isHolding then
DFunctions.FireCrouch(false)
Config.isHolding = false
else
DFunctions.FireCrouch(true)
Config.isHolding = true
end
end
function DFunctions.GetAvatarHumanoid()
local character = LocalPlayer.Character
return character and character:FindFirstChildOfClass("Humanoid") or nil
end
function DFunctions.HookAvatarRespawn()
local AC = DConfiguration.Visual.AvatarChanger
if AC.hooked then return end
AC.hooked = true
LocalPlayer.CharacterAdded:Connect(function()
if not DConfiguration.Visual.AvatarChanger.Keep then return end
if not DConfiguration.Visual.AvatarChanger.Applied then return end
local wanted = DConfiguration.Visual.AvatarChanger.UserId
if wanted == "" or wanted == nil then return end
task.wait(1)
DFunctions.ApplyAvatar(wanted)
end)
end
function DFunctions.CaptureOriginalAvatar()
local AC = DConfiguration.Visual.AvatarChanger
if AC.Original then return end
local humanoid = DFunctions.GetAvatarHumanoid()
if not humanoid then return end
local ok, desc = pcall(function() return humanoid:GetAppliedDescription() end)
if ok and desc then AC.Original = desc end
end
function DFunctions.ApplyAvatar(userId)
userId = tonumber(userId)
if not userId then return false, "no user id" end
local humanoid = DFunctions.GetAvatarHumanoid()
if not humanoid then return false, "no character" end
DFunctions.CaptureOriginalAvatar()
DFunctions.HookAvatarRespawn()
local ok, desc = pcall(function() return Players:GetHumanoidDescriptionFromUserId(userId) end)
if not ok or not desc then return false, "lookup failed" end
local applied = pcall(function() humanoid:ApplyDescription(desc) end)
if not applied then return false, "apply failed" end
local AC = DConfiguration.Visual.AvatarChanger
AC.UserId = userId
AC.Applied = true
return true, "avatar " .. tostring(userId)
end
function DFunctions.ResetAvatar()
local AC = DConfiguration.Visual.AvatarChanger
AC.Applied = false
local humanoid = DFunctions.GetAvatarHumanoid()
if not humanoid or not AC.Original then return false, "nothing saved" end
local ok = pcall(function() humanoid:ApplyDescription(AC.Original) end)
return ok, ok and "original avatar" or "apply failed"
end
function DFunctions.RandomAvatar()
local pool = {}
for _, plr in ipairs(Players:GetPlayers()) do
if plr ~= LocalPlayer and plr.UserId then table.insert(pool, plr.UserId) end
end
if #pool == 0 then return false, "no other players" end
return DFunctions.ApplyAvatar(pool[math.random(1, #pool)])
end
function DFunctions.StartCrouchLoop()
local C = DConfiguration.Misc.MovementModification.Crouch
if C.looping then return end
C.looping = true
task.spawn(function()
while C.FloatingButton or C.Keybind do
DFunctions.CrouchFunction()
task.wait(0.05)
end
C.looping = false
DFunctions.ReleaseCrouch()
end)
end
function DFunctions.StopCrouchLoop()
local C = DConfiguration.Misc.MovementModification.Crouch
if C.FloatingButton or C.Keybind then return end
DFunctions.ReleaseCrouch()
end
function DFunctions.Normalize(input) return (input or ""):lower():gsub("%s+", "") end
function DFunctions.FindRealName(folder, userInput)
if not userInput or userInput == "" then return nil end
local reg = DFunctions.GetItemRegistry()
if reg and reg.TryGetByName then
local entry = reg.TryGetByName(userInput)
if entry and entry.Module then return entry.Module.Name end
end
if not folder then return nil end
local normalized = DFunctions.Normalize(userInput)
for _, item in ipairs(folder:GetChildren()) do
if DFunctions.Normalize(item.Name) == normalized then return item.Name end
end
for _, item in ipairs(folder:GetDescendants()) do
if item:IsA("ModuleScript") and DFunctions.Normalize(item.Name) == normalized then
return item.Name
end
end
return nil
end
function DFunctions.GetItemModule(name)
local reg = DFunctions.GetItemRegistry()
if reg and reg.TryGetByName then
local entry = reg.TryGetByName(name)
if entry then return entry.Module, entry.Id end
end
return nil, nil
end
local CosmeticsFolder = Instance.new("Folder")
CosmeticsFolder.Name = "D-Folder-Cosmetics"
pcall(function() CosmeticsFolder.Parent = ReplicatedStorage:FindFirstChild("Items") or ReplicatedStorage end)
function DFunctions.scanDescendantsAsync(root, matchFolderName, targetName, callback)
local stack = {}
for _, child in ipairs(root:GetChildren()) do
table.insert(stack, child)
end
local found = nil
local function findInFolder(folder, name)
for _, child in ipairs(folder:GetChildren()) do
if child.Name == name then return child end
local result = findInFolder(child, name)
if result then return result end
end
return nil
end
local iterations = 0
while #stack > 0 do
local node = table.remove(stack)
if node:IsA("Folder") or node:IsA("Model") then
if matchFolderName and node.Name == matchFolderName then
local innerResult = findInFolder(node, targetName)
if innerResult then
found = innerResult
break
end
elseif not matchFolderName and node.Name == targetName then
found = node
break
else
for _, child in ipairs(node:GetChildren()) do
table.insert(stack, child)
end
end
end
iterations = iterations + 1
if iterations % 100 == 0 then task.wait() end
end
if callback then callback(found) end
return found
end
function DFunctions.ChangeCosmetics(Name1, Name2, onComplete)
onComplete = onComplete or function() end
if not Name1 or not Name2 or Name1 == "" or Name2 == "" or Name1 == Name2 then
onComplete(false)
return
end
local cosSwaps = DConfiguration.Visual.CosSwaps
local key = Name1 .. "_" .. Name2
local items = ReplicatedStorage:FindFirstChild("Items")
if not items then onComplete(false) return end
task.spawn(function()
local curFound = DFunctions.scanDescendantsAsync(items, "Cosmetics", Name1)
local tarFound = DFunctions.scanDescendantsAsync(items, "Cosmetics", Name2)
if not (curFound and tarFound) then
onComplete(false)
return
end
local temp = Instance.new("Folder")
temp.Name = "__temp_cos_swap_" .. tostring(tick())
temp.Parent = ReplicatedStorage
local curChildren, tarChildren = {}, {}
for _, child in ipairs(curFound:GetChildren()) do table.insert(curChildren, child) end
for _, child in ipairs(tarFound:GetChildren()) do table.insert(tarChildren, child) end
for _, child in ipairs(curChildren) do child.Parent = temp end
for _, child in ipairs(tarChildren) do child.Parent = curFound end
for _, child in ipairs(temp:GetChildren()) do child.Parent = tarFound end
temp:Destroy()
cosSwaps[key] = { current = Name1, target = Name2 }
onComplete(true)
end)
end
function DFunctions.RestoreCosmetics(onComplete)
onComplete = onComplete or function() end
local cosSwaps = DConfiguration.Visual.CosSwaps
local list = {}
for _, v in pairs(cosSwaps) do table.insert(list, v) end
if #list == 0 then onComplete() return end
local done = 0
for _, v in ipairs(list) do
DFunctions.ChangeCosmetics(v.target, v.current, function()
done = done + 1
if done >= #list then
DConfiguration.Visual.CosSwaps = {}
onComplete()
end
end)
end
end
function DFunctions.ChangeAnimation() end
function DFunctions.SetEmote(emoteID)
if not emoteID then return end
local character = LocalPlayer.Character
if not character then return end
local tagValue = character:GetAttribute("Tag")
if not tagValue then return end
local tagBuf = buffer.create(2)
buffer.writeu16(tagBuf, 0, tagValue)
firesignal(ReplicatedStorage.Events.UpdateCharacterDataRegistry.OnClientEvent, {
buffer.fromstring("\24\1"),
emoteID,
tagBuf
})
end
function DFunctions.GetAllEmotes()
local allEmotes = {}
local itemsFolder = ReplicatedStorage:FindFirstChild("Items")
if not itemsFolder then return allEmotes end
local function findEmotesFolders(parent)
for _, child in ipairs(parent:GetChildren()) do
if child:IsA("Folder") then
if child.Name == "Emotes" then
for _, emote in ipairs(child:GetChildren()) do
if emote:IsA("ModuleScript") then
table.insert(allEmotes, { Name = emote.Name, ID = emote:GetAttribute("ID") })
end
end
else
findEmotesFolders(child)
end
end
end
end
findEmotesFolders(itemsFolder)
local reg = DFunctions.GetItemRegistry()
if reg and reg.GetByCategory then
local byCat = reg.GetByCategory("Emotes")
if byCat then
for id, entry in pairs(byCat) do
if entry and entry.Module then
local exists = false
for _, e in ipairs(allEmotes) do
if e.Name == entry.Module.Name then exists = true break end
end
if not exists then
table.insert(allEmotes, { Name = entry.Module.Name, ID = entry.Id or entry.Module:GetAttribute("ID") })
end
end
end
end
end
return allEmotes
end
function DFunctions.FindEmoteInfo(emoteInput)
if not emoteInput or emoteInput == "" then return nil end
local id = tonumber(emoteInput)
local reg = DFunctions.GetItemRegistry()
if id then
if reg and reg.GetConfig and reg.GetConfig(id) then
return { Name = tostring(id), ID = id }
end
for _, e in ipairs(DFunctions.GetAllEmotes()) do
if e.ID == id then return { Name = e.Name, ID = id } end
end
return { Name = tostring(id), ID = id }
end
for _, emote in ipairs(DFunctions.GetAllEmotes()) do
if emote.Name:lower() == tostring(emoteInput):lower() then
return { Name = emote.Name, ID = emote.ID }
end
end
if reg and reg.TryGetByName then
local entry = reg.TryGetByName(emoteInput)
if entry then return { Name = entry.Module.Name, ID = entry.Id } end
end
return nil
end
function DFunctions.BuildEmoteMapping()
local replacements = {}
for i = 1, 12 do
local currentInput = DConfiguration.Visual.CurrentEmotes[i] or DConfiguration.Visual.OriginalEmotes["Emote" .. i] or ""
local selectInput = DConfiguration.Visual.SelectEmotes[i] or DConfiguration.Visual.ModifyEmotes["Emote" .. i] or ""
if currentInput ~= "" and selectInput ~= "" and currentInput ~= " " and selectInput ~= " " then
local currentInfo = DFunctions.FindEmoteInfo(currentInput)
local selectInfo = DFunctions.FindEmoteInfo(selectInput)
if currentInfo and selectInfo then
replacements[currentInfo.Name] = {
select = selectInfo.Name,
selectID = selectInfo.ID,
slot = i
}
end
end
end
DConfiguration.Visual.EmoteReplacements = replacements
return replacements
end
function DFunctions.ChangeEmotes(Name1, Name2)
local info1 = DFunctions.FindEmoteInfo(Name1)
local info2 = DFunctions.FindEmoteInfo(Name2)
if info1 and info2 and info2.ID then
DFunctions.SetEmote(info2.ID)
end
end
local hookActive = false
local lastEmoteName = nil
local origEmoteActivate, origEmoteDeactivate = nil, nil
local EmoteClassRef = nil
function DFunctions.StartEmoteWatcher()
if hookActive then return end
if not EmoteClass then return end
EmoteClassRef = EmoteClass
hookActive = true
origEmoteActivate = EmoteClass.Activate
origEmoteDeactivate = EmoteClass.Deactivate
EmoteClass.Activate = function(self, p2, p3)
origEmoteActivate(self, p2, p3)
local anim = self.Animations and self.Animations.Animation
if anim and anim.IsPlaying and anim.Speed > 0 then
local module = self.EmoteModule
local currentEmote = module and module.Name or "Unknown"
if currentEmote ~= lastEmoteName then
local emoteReplacements = DConfiguration.Visual.EmoteReplacements
if emoteReplacements[currentEmote] then
local replacement = emoteReplacements[currentEmote]
local selectID = replacement.selectID
if selectID then
lastEmoteName = currentEmote
DFunctions.SetEmote(selectID)
end
end
lastEmoteName = currentEmote
end
end
end
EmoteClass.Deactivate = function(self, ...)
origEmoteDeactivate(self, ...)
lastEmoteName = nil
end
end
function DFunctions.StopEmoteWatcher()
if not hookActive then return end
hookActive = false
pcall(function()
local EmoteClass = EmoteClass
if origEmoteActivate then EmoteClass.Activate = origEmoteActivate end
if origEmoteDeactivate then EmoteClass.Deactivate = origEmoteDeactivate end
end)
lastEmoteName = nil
end
function DFunctions.ResetEmoteChanges()
DFunctions.StopEmoteWatcher()
DConfiguration.Visual.EmoteReplacements = {}
end
function DFunctions.RestoreEmoteChanges()
DFunctions.ResetEmoteChanges()
end
function DFunctions.AutoEmoteDash()
local char = LocalPlayer.Character
if not char then return end
local emoteName = DConfiguration.Misc.GameAutomation.Macro.SelectedEmote
local info = DFunctions.FindEmoteInfo(emoteName)
local emoteId = info and info.ID
if not emoteId then
local mod = select(1, DFunctions.GetItemModule(emoteName or ""))
if mod then emoteId = mod:GetAttribute("ID") end
end
if emoteId then
pcall(function()
ReplicatedStorage.Events.CharacterTask:FireServer("Emote", emoteId)
end)
DFunctions.SetEmote(emoteId)
end
DFunctions.CrouchFunction()
end
function DFunctions.Noclip(enabled)
local char = LocalPlayer.Character
if not char then return end
for _, part in pairs(char:GetDescendants()) do
if part:IsA("BasePart") then
part.CanCollide = not enabled
end
end
end
local EmoteNames = DFunctions.GetEmotesName()
if #EmoteNames == 0 then EmoteNames = {"BoldMarch", "DefaultEmote"} end
local ShopItemNames = DFunctions.GetMultipleShopItems()
if #ShopItemNames == 0 then
ShopItemNames = { "(shop registry not ready - reopen the menu)" }
end
local CosmeticNames = DFunctions.GetCosmeticsName()
Tabs.Main:AddSection("Billboard ESP")
local function clearBillboardESP(espName)
local folder = workspace:FindFirstChild("Players")
if folder then
for _, v in pairs(folder:GetDescendants()) do
if v.Name == espName then v:Destroy() end
end
end
for _, plr in pairs(Players:GetPlayers()) do
if plr.Character then
for _, d in pairs(plr.Character:GetDescendants()) do
if d.Name == espName then d:Destroy() end
end
end
end
local tickets = workspace:FindFirstChild("Effects") and workspace.Effects:FindFirstChild("Tickets")
if tickets then
for _, d in pairs(tickets:GetDescendants()) do
if d.Name == espName then d:Destroy() end
end
end
end
local function isDownedTarget(plr)
if not plr then return false end
if DFunctions.isPlayerDowned and DFunctions.isPlayerDowned(plr) then return true end
local folder = workspace:FindFirstChild("Players")
local folderPlr = folder and folder:FindFirstChild(plr.Name)
if folderPlr then
if folderPlr:GetAttribute("Downed") == true then return true end
if folderPlr:GetAttribute("Downed") == true then return true end
end
if plr.Character then
if plr.Character:GetAttribute("Downed") == true then return true end
local hum = plr.Character:FindFirstChildOfClass("Humanoid")
if hum and hum.Health <= 0 then return true end
end
return false
end
local Toggle = Tabs.Main:AddToggle("BillboardNextbots", {Title = "Billboard Nextbots", Default = false })
Toggle:OnChanged(function(value)
DConfiguration.ESP.Nextbots = value
if not value then
clearBillboardESP("NextbotESP")
return
end
task.spawn(function()
while DConfiguration.ESP.Nextbots do
local folder = workspace:FindFirstChild("Players")
if folder then
for _, v in pairs(folder:GetChildren()) do
if v:GetAttribute("Team") == "Nextbot" and v:FindFirstChild("HumanoidRootPart") then
local hrp = v.HumanoidRootPart
if not hrp:FindFirstChild("NextbotESP") then
CreateBillboardESP("NextbotESP", hrp, Color3.fromRGB(255, 0, 0), 18)
end
UpdateBillboardESP("NextbotESP", hrp, v.Name, Color3.fromRGB(255, 0, 0), 18, Camera.CFrame.Position)
end
end
end
task.wait(0.1)
end
clearBillboardESP("NextbotESP")
end)
end)
local Toggle = Tabs.Main:AddToggle("BillboardPlayers", {Title = "Billboard Players", Default = false })
Toggle:OnChanged(function(value)
DConfiguration.ESP.Players = value
if not value then
clearBillboardESP("PlayerESP")
return
end
task.spawn(function()
while DConfiguration.ESP.Players do
for _, plr in pairs(Players:GetPlayers()) do
if plr ~= LocalPlayer and plr.Character and plr.Character:FindFirstChild("HumanoidRootPart") then
local hrp = plr.Character.HumanoidRootPart
if not hrp:FindFirstChild("PlayerESP") then
CreateBillboardESP("PlayerESP", hrp, Color3.fromRGB(255, 255, 255), 14)
end
local color = isDownedTarget(plr) and Color3.fromRGB(0, 255, 0) or Color3.fromRGB(255, 255, 255)
UpdateBillboardESP("PlayerESP", hrp, plr.Name, color, 14, Camera.CFrame.Position)
end
end
task.wait(0.1)
end
clearBillboardESP("PlayerESP")
end)
end)
local Toggle = Tabs.Main:AddToggle("BillboardTicket", {Title = "Billboard Tickets", Default = false })
Toggle:OnChanged(function(State)
DConfiguration.ESP.Tickets = State
if not State then
clearBillboardESP("TicketESP")
return
end
task.spawn(function()
while DConfiguration.ESP.Tickets do
local tickets = workspace:FindFirstChild("Effects") and workspace.Effects:FindFirstChild("Tickets")
if tickets then
for _, v in pairs(tickets:GetDescendants()) do
if v:IsA("BasePart") and v.Name == "HumanoidRootPart" then
if not v:FindFirstChild("TicketESP") then
CreateBillboardESP("TicketESP", v, Color3.fromRGB(255, 213, 128), 18)
end
UpdateBillboardESP("TicketESP", v, v.Parent and v.Parent.Name or "Ticket", Color3.fromRGB(255, 213, 128), 18, Camera.CFrame.Position)
end
end
end
task.wait(0.1)
end
clearBillboardESP("TicketESP")
end)
end)
Tabs.Main:AddSection("Tracer ESP")
local TracerLines = {}
local TracerLinesBots = {}
local TracerLinesTickets = {}
local Toggle = Tabs.Main:AddToggle("TracersPlayers", {Title = "Tracer Players", Default = false})
Toggle:OnChanged(function(State)
DConfiguration.Tracers.Players = State
if not State then
for part, _ in pairs(TracerLines) do DestroyTracerESP(TracerLines, part) end
TracerLines = {}
return
end
task.spawn(function()
while DConfiguration.Tracers.Players do
for _, plr in pairs(Players:GetPlayers()) do
if plr ~= LocalPlayer and plr.Character and plr.Character:FindFirstChild("HumanoidRootPart") then
local hrp = plr.Character.HumanoidRootPart
if not TracerLines[hrp] then
CreateTracerESP(TracerLines, hrp, 2, Color3.fromRGB(255, 255, 255))
end
local color = isDownedTarget(plr) and Color3.fromRGB(0, 255, 0) or Color3.fromRGB(255, 255, 255)
UpdateTracerESP(TracerLines, hrp, color)
end
end
CleanupTracers(TracerLines)
task.wait()
end
end)
end)
local Toggle = Tabs.Main:AddToggle("TracersBots", {Title = "Tracer Bots", Default = false})
Toggle:OnChanged(function(State)
DConfiguration.Tracers.Nextbots = State
if not State then
for part, _ in pairs(TracerLinesBots) do DestroyTracerESP(TracerLinesBots, part) end
TracerLinesBots = {}
return
end
task.spawn(function()
while DConfiguration.Tracers.Nextbots do
local folder = workspace:FindFirstChild("Players")
if folder then
for _, v in pairs(folder:GetChildren()) do
if v:GetAttribute("Team") == "Nextbot" and v:FindFirstChild("HumanoidRootPart") then
local hrp = v.HumanoidRootPart
if not TracerLinesBots[hrp] then
CreateTracerESP(TracerLinesBots, hrp, 5, Color3.fromRGB(255, 0, 0))
end
UpdateTracerESP(TracerLinesBots, hrp, Color3.fromRGB(255, 0, 0))
end
end
end
CleanupTracers(TracerLinesBots)
task.wait()
end
end)
end)
local Toggle = Tabs.Main:AddToggle("TracerTickets", {Title = "Tracer Tickets", Default = false})
Toggle:OnChanged(function(State)
DConfiguration.Tracers.Tickets = State
if not State then
for part, _ in pairs(TracerLinesTickets) do DestroyTracerESP(TracerLinesTickets, part) end
TracerLinesTickets = {}
return
end
task.spawn(function()
while DConfiguration.Tracers.Tickets do
local tickets = workspace:FindFirstChild("Effects") and workspace.Effects:FindFirstChild("Tickets")
if tickets then
for _, v in pairs(tickets:GetDescendants()) do
if v:IsA("BasePart") and v.Name == "HumanoidRootPart" then
if not TracerLinesTickets[v] then
CreateTracerESP(TracerLinesTickets, v, 2, Color3.fromRGB(255, 213, 128))
end
UpdateTracerESP(TracerLinesTickets, v, Color3.fromRGB(255, 213, 128))
end
end
end
CleanupTracers(TracerLinesTickets)
task.wait()
end
end)
end)
Tabs.Main:AddSection("Highlight ESP")
local function clearHighlights(name)
local rigs = workspace:FindFirstChild("Rigs")
if rigs then
for _, rig in pairs(rigs:GetChildren()) do
DestroyHighlightESP(name, rig)
end
end
local folder = workspace:FindFirstChild("Players")
if folder then
for _, v in pairs(folder:GetChildren()) do
DestroyHighlightESP(name, v)
end
end
local tickets = workspace:FindFirstChild("Effects") and workspace.Effects:FindFirstChild("Tickets")
if tickets then
for _, v in pairs(tickets:GetChildren()) do
DestroyHighlightESP(name, v)
local hrp = v:FindFirstChild("HumanoidRootPart")
if hrp then DestroyHighlightESP(name, hrp) end
end
end
end
local Toggle = Tabs.Main:AddToggle("HighlightNextbot", {Title = "Highlight Nextbots", Default = false })
Toggle:OnChanged(function(value)
DConfiguration.Highlight.Nextbots = value
if not value then
clearHighlights("NextbotHighlight")
return
end
task.spawn(function()
while DConfiguration.Highlight.Nextbots do
local rigs = workspace:FindFirstChild("Rigs")
local playersFolder = workspace:FindFirstChild("Players")
if rigs then
for _, rig in pairs(rigs:GetChildren()) do
local team = playersFolder and playersFolder:FindFirstChild(rig.Name) and playersFolder[rig.Name]:GetAttribute("Team")
if team == "Nextbot" then
if not rig:FindFirstChild("NextbotHighlight") then
CreateHighlightESP("NextbotHighlight", rig, Color3.fromRGB(255, 0, 0), Color3.fromRGB(255, 0, 0), false)
end
UpdateHighlightESP("NextbotHighlight", rig, Color3.fromRGB(255, 0, 0), Color3.fromRGB(255, 0, 0), false)
end
end
end
task.wait(0.1)
end
clearHighlights("NextbotHighlight")
end)
end)
local Toggle = Tabs.Main:AddToggle("HighlightPlayers", {Title = "Highlight Players", Default = false })
Toggle:OnChanged(function(value)
DConfiguration.Highlight.Players = value
if not value then
clearHighlights("PlayerHighlight_D")
return
end
task.spawn(function()
while DConfiguration.Highlight.Players do
local rigs = workspace:FindFirstChild("Rigs")
local playersFolder = workspace:FindFirstChild("Players")
if rigs then
for _, rig in pairs(rigs:GetChildren()) do
if rig.Name ~= LocalPlayer.Name then
local folderPlr = playersFolder and playersFolder:FindFirstChild(rig.Name)
local team = folderPlr and folderPlr:GetAttribute("Team")
if team ~= "Nextbot" then
if not rig:FindFirstChild("PlayerHighlight_D") then
CreateHighlightESP("PlayerHighlight_D", rig, Color3.fromRGB(255, 255, 255), Color3.fromRGB(0, 0, 0), false)
end
local plr = Players:FindFirstChild(rig.Name)
local color = (plr and isDownedTarget(plr)) and Color3.fromRGB(0, 255, 0) or Color3.fromRGB(255, 255, 255)
UpdateHighlightESP("PlayerHighlight_D", rig, color, Color3.fromRGB(0, 0, 0), false)
end
end
end
end
task.wait(0.1)
end
clearHighlights("PlayerHighlight_D")
end)
end)
local Toggle = Tabs.Main:AddToggle("HighlightTicket", {Title = "Highlight Tickets", Default = false })
Toggle:OnChanged(function(State)
DConfiguration.Highlight.Tickets = State
if not State then
clearHighlights("TicketHighlight")
return
end
task.spawn(function()
while DConfiguration.Highlight.Tickets do
local tickets = workspace:FindFirstChild("Effects") and workspace.Effects:FindFirstChild("Tickets")
if tickets then
for _, v in pairs(tickets:GetChildren()) do
local target = v:IsA("Model") and v or v
if not target:FindFirstChild("TicketHighlight") then
CreateHighlightESP("TicketHighlight", target, Color3.fromRGB(255, 213, 128), Color3.fromRGB(255, 213, 128), false)
end
UpdateHighlightESP("TicketHighlight", target, Color3.fromRGB(255, 213, 128), Color3.fromRGB(255, 213, 128), false)
end
end
task.wait(0.1)
end
clearHighlights("TicketHighlight")
end)
end)
Tabs.Main:AddSection("Game Modification")
local Toggle = Tabs.Main:AddToggle("AutoRespawn", {Title = "Auto Respawn", Default = false })
Toggle:OnChanged(function(value)
DConfiguration.Main.AutoRespawn = value
DConfiguration.SelfRevive.Enabled = value
if value then
DFunctions.StartSelfRevive()
else
DFunctions.StopSelfRevive()
end
end)
local Toggle = Tabs.Main:AddToggle("SelfReviveButton", {Title = "Self Revive (Button)", Default = false})
Toggle:OnChanged(function(State)
if State then
DFunctions.CreateButton("SelfReviveGui", "Self Revive: OFF", 0.15, 0.1, function(btn)
local SR = DConfiguration.SelfRevive
if SR.Enabled and SR.Connections and SR.Connections.Heartbeat then
DFunctions.StopSelfRevive()
DConfiguration.Main.AutoRespawn = false
btn.Text = "Self Revive: OFF"
else
DFunctions.StartSelfRevive()
DConfiguration.Main.AutoRespawn = true
btn.Text = "Self Revive: ON"
end
end)
else
DFunctions.DestroyButton("SelfReviveGui")
end
end)
local Toggle = Tabs.Main:AddToggle("RespawnButton", {Title = "Respawn (Button)", Default = false})
Toggle:OnChanged(function(State)
if State then
DFunctions.CreateButton("RespawnButton", "Respawn", 0.15 + DConfiguration.Settings.GuiScale.Respawn, 0.1 + DConfiguration.Settings.GuiScale.Respawn, function(btn)
btn.Text = "Respawning..."
local event = ReplicatedStorage:FindFirstChild("Events") and ReplicatedStorage.Events:FindFirstChild("SetPlayerMode")
if event then event:FireServer(true) end
wait(0.1)
btn.Text = "Respawned!"
wait(0.2)
btn.Text = "Respawn"
end)
else
DFunctions.DestroyButton("RespawnButton")
end
end)
Tabs.Main:AddInput("RespawnButtonSize", {
Title = "Respawn Gui Size",
Default = tostring(DConfiguration.Settings.GuiScale.Respawn),
Placeholder = "0",
Numeric = true,
Finished = false,
Callback = function(Value)
local num = tonumber(Value)
if num then
DConfiguration.Settings.GuiScale.Respawn = num * 0.01
else
DConfiguration.Settings.GuiScale.Respawn = 0
end
DFunctions.UpdateButton("RespawnButton", 0.15 + DConfiguration.Settings.GuiScale.Respawn, 0.1 + DConfiguration.Settings.GuiScale.Respawn)
end
})
Tabs.Main:AddButton({
Title = "Force Respawn",
Description = "",
Callback = function()
local event = ReplicatedStorage:FindFirstChild("Events") and ReplicatedStorage.Events:FindFirstChild("SetPlayerMode")
if event then event:FireServer(true) end
end
})
local Dropdown = Tabs.Main:AddDropdown("RespawnType", {
Title = "Respawn Type",
Values = {"Spawnpoint", "Fake Revive"},
Multi = false,
Default = 1,
})
Dropdown:OnChanged(function(value)
DConfiguration.Main.RespawnType = value
DConfiguration.SelfRevive.Method = value
end)
Tabs.Main:AddParagraph({Title = " ", Content = ""})
local Toggle = Tabs.Main:AddToggle("AutoWhistle", {Title = "Auto Whistle", Default = false })
Toggle:OnChanged(function(value)
DConfiguration.Main.AutoWhistle = value
task.spawn(function()
while DConfiguration.Main.AutoWhistle do
local SendKeybindEvent = ReplicatedStorage:FindFirstChild("Services")
and ReplicatedStorage.Services:FindFirstChild("Client")
and ReplicatedStorage.Services.Client:FindFirstChild("KeybindService")
and ReplicatedStorage.Services.Client.KeybindService:FindFirstChild("SendKeybindEvent")
if SendKeybindEvent then
SendKeybindEvent:Fire({ Down = true, Key = "Whistle" })
task.wait(0.05)
SendKeybindEvent:Fire({ Down = false, Key = "Whistle" })
end
task.wait(1)
end
end)
end)
Tabs.Main:AddSection("Alternative Settings")
local Toggle = Tabs.Main:AddToggle("AntiAfk", {Title = "Anti-AFK", Default = false })
Toggle:OnChanged(function()
local vu = game:GetService("VirtualUser")
LocalPlayer.Idled:Connect(function()
vu:ClickButton2(Vector2.new())
vu:Button2Down(Vector2.new(0,0), workspace.CurrentCamera.CFrame)
task.wait(1)
vu:Button2Up(Vector2.new(0,0), workspace.CurrentCamera.CFrame)
end)
end)
pcall(function() Options.AntiAfk:SetValue(true) end)
local Toggle = Tabs.Main:AddToggle("ShowTimer", {Title = "Show Timer", Default = false })
Toggle:OnChanged(function(State)
DConfiguration.Main.ShowTimer = State
DConfiguration.TimerDisplay.Enabled = State
if State then
DFunctions.CreateTimer()
else
DFunctions.RemoveTimer()
end
end)
local Toggle = Tabs.Main:AddToggle("ShowSpecialRound", {Title = "Show Special Round", Default = false })
Toggle:OnChanged(function(State)
DConfiguration.TimerDisplay.SpecialRoundEnabled = State
if State then
DFunctions.CreateSpecialRoundDisplay()
else
DFunctions.RemoveSpecialRoundDisplay()
end
end)
local Toggle = Tabs.Main:AddToggle("DisableCameraShake", {Title = "Disable Camera Shake", Default = false })
Toggle:OnChanged(function(value)
DConfiguration.Removals.CameraShake = value
if value then
pcall(function()
ReplicatedStorage.Shared.UserData.Events.Requests.SetSetting:FireServer("NextbotVignette", false)
end)
end
end)
local Toggle = Tabs.Main:AddToggle("DisableVignette", {Title = "Disable Vignette", Default = false })
Toggle:OnChanged(function(value)
DConfiguration.Removals.Vignette = value
task.spawn(function()
while DConfiguration.Removals.Vignette do
for _, v in pairs(LocalPlayer.PlayerGui:GetDescendants()) do
if typeof(v.Name) == "string" and (v.Name:lower():find("vignette") or v.Name:lower():find("noise") or v.Name == "NextbotNoise") then
if v:IsA("ImageLabel") or v:IsA("Frame") or v:IsA("ImageButton") then
v.Visible = false
if v:IsA("ImageLabel") or v:IsA("ImageButton") then
v.ImageTransparency = 1
end
end
end
end
task.wait(0.2)
end
end)
end)
Tabs.Main:AddButton({
Title = "Open Leaderboard",
Description = "",
Callback = function()
local SendKeybindEvent = ReplicatedStorage:FindFirstChild("Services")
and ReplicatedStorage.Services:FindFirstChild("Client")
and ReplicatedStorage.Services.Client:FindFirstChild("KeybindService")
and ReplicatedStorage.Services.Client.KeybindService:FindFirstChild("SendKeybindEvent")
if SendKeybindEvent then
SendKeybindEvent:Fire({ Down = true, Key = "Leaderboard" })
end
end
})
Tabs.Main:AddSection("Map Modification")
local Toggle = Tabs.Main:AddToggle("RemoveReducingRewards", {Title = "Remove Reducing Rewards", Default = false })
Toggle:OnChanged(function(value)
DConfiguration.Removals.ReducingRewards = value
end)
local Toggle = Tabs.Main:AddToggle("RemoveInvisibleWalls", {Title = "Remove Invisible Walls", Default = false })
Toggle:OnChanged(function(value)
DConfiguration.Removals.InvisibleWalls = value
while DConfiguration.Removals.InvisibleWalls and task.wait(1) do
DFunctions.DisableInvisParts(false)
end
if not DConfiguration.Removals.InvisibleWalls then
DFunctions.DisableInvisParts(true)
end
end)
Tabs.Main:AddSection("Player Modification")
local Toggle = Tabs.Main:AddToggle("Noclip", {Title = "Noclip", Default = false })
Toggle:OnChanged(function(value)
DConfiguration.Main.Noclip = value
if value then
task.spawn(function()
while DConfiguration.Main.Noclip do
DFunctions.Noclip(true)
RunService.Stepped:Wait()
end
DFunctions.Noclip(false)
end)
else
DFunctions.Noclip(false)
end
end)
MovementModule = require(ReplicatedStorage:WaitForChild("Objects"):WaitForChild("Game"):WaitForChild("Character"):WaitForChild("Client"):WaitForChild("Movement"))
DConfiguration.Main.FlyoriginalUpdate = MovementModule.Update
local playerModule = LocalPlayer:WaitForChild("PlayerScripts"):WaitForChild("PlayerModule")
controlModule = require(playerModule:WaitForChild("ControlModule"))
local function getFlyDirection()
if not controlModule then return Vector3.new() end
local camCF = workspace.CurrentCamera.CFrame
local moveVector = controlModule:GetMoveVector()
if moveVector.Magnitude < 0.01 then
return Vector3.new(0, 0, 0)
end
local forward = camCF.LookVector
local right = camCF.RightVector
return (forward * -moveVector.Z + right * moveVector.X).Unit * 150 * DConfiguration.Main.FlySpeed
end
local function flyUpdate(self, dt)
if DConfiguration.Main.FlyoriginalUpdate then DConfiguration.Main.FlyoriginalUpdate(self, dt) end
local hrp = self.Character and self.Character:FindFirstChild("HumanoidRootPart")
if not hrp then return end
local flyDir = getFlyDirection()
if flyDir.Magnitude > 0.1 then
DConfiguration.Main.isFlyFloating = nil
elseif not DConfiguration.Main.isFlyFloating then
DConfiguration.Main.isFlyFloating = hrp.Position.Y
end
local newVel = flyDir
if self.DataRegistry and self.DataRegistry.Set then
self.DataRegistry:Set("Velocity", newVel * 90)
end
hrp.AssemblyLinearVelocity = newVel
if DConfiguration.Main.isFlyFloating and flyDir.Magnitude <= 0.1 then
local pos = hrp.Position
hrp.CFrame = CFrame.new(pos.X, DConfiguration.Main.isFlyFloating, pos.Z) * (hrp.CFrame - hrp.CFrame.Position)
end
end
local function StartFly()
if DConfiguration.Main.Fly or not MovementModule then return end
DConfiguration.Main.Fly = true
DConfiguration.Main.isFlyFloating = nil
MovementModule.Update = flyUpdate
end
local function StopFly()
if not DConfiguration.Main.Fly then return end
DConfiguration.Main.Fly = false
DConfiguration.Main.isFlyFloating = nil
if MovementModule and DConfiguration.Main.FlyoriginalUpdate then
MovementModule.Update = DConfiguration.Main.FlyoriginalUpdate
end
end
local Toggle = Tabs.Main:AddToggle("ShowFlyButton", { Title = "Fly Button", Default = false })
Toggle:OnChanged(function(State)
if State then
DFunctions.CreateButton("FlyButton", "Fly: OFF", 0.15, 0.1, function(btn)
local newState = not DConfiguration.Main.Fly
if newState then
StartFly()
btn.Text = "Fly: ON"
else
StopFly()
btn.Text = "Fly: OFF"
end
end)
else
StopFly()
DFunctions.DestroyButton("FlyButton")
end
end)
local FlySpeedInput = Tabs.Main:AddInput("FlySpeedInput", {
Title = "Fly Speed",
Default = "1",
Placeholder = "Enter fly speed",
Numeric = true,
Finished = false,
Callback = function(Value)
local speed = tonumber(Value)
if speed and speed > 0 then
DConfiguration.Main.FlySpeed = speed
end
end
})
wait(Duration)
Tabs.AutoFarm:AddSection("Farmings")
local Toggle = Tabs.AutoFarm:AddToggle("AutoFarmMoney", {
Title = "Auto Farm Token",
Description = "Teleports under a random workspace.Players child and fires Revive. Stays on that target until it is gone. Ban risk on public servers.",
Default = false
})
Toggle:OnChanged(function(State)
DConfiguration.AutoFarm.FarmTokens = State
DConfiguration.TokenFarm.Enabled = State
if State then
DFunctions.StartGodMode()
else
DFunctions.StopGodMode()
end
end)
Tabs.AutoFarm:AddInput("TokenFarmOffset", {
Title = "Token Farm Offset",
Default = "0 -8 0",
Placeholder = "X Y Z",
Numeric = false,
Finished = false,
Callback = function(Value)
local x, y, z = tostring(Value):match("^%s*([%-%d%.]+)%s+([%-%d%.]+)%s+([%-%d%.]+)%s*$")
if x and y and z then
DConfiguration.TokenFarm.TokenOffset = Vector3.new(tonumber(x), tonumber(y), tonumber(z))
end
end
})
Tabs.AutoFarm:AddSlider("TokenFarmDelay", {
Title = "Token Farm Delay",
Description = "Revive fire delay in seconds",
Default = 2,
Min = 1,
Max = 4,
Rounding = 0,
Callback = function(Value)
DConfiguration.TokenFarm.TokenDelay = Value
end
})
local Toggle = Tabs.AutoFarm:AddToggle("AutoFarmTickets", {Title = "Auto Farm Tickets", Default = false })
Toggle:OnChanged(function(State)
DConfiguration.AutoFarm.FarmTickets = State
while DConfiguration.AutoFarm.FarmTickets and task.wait(1) do
DFunctions.TicketsFarming()
end
end)
local Toggle = Tabs.AutoFarm:AddToggle("AutoCompleteObjectives", {Title = "Auto Complete Objective", Default = false })
Toggle:OnChanged(function(State)
DConfiguration.AutoFarm.CompleteObjective = State
while DConfiguration.AutoFarm.CompleteObjective and task.wait(3) do
DFunctions.PointFarming()
end
end)
local Toggle = Tabs.AutoFarm:AddToggle("AFKFarm", {Title = "AFK Farm", Default = false })
Toggle:OnChanged(function(State)
DConfiguration.AutoFarm.AFKFarm = State
while DConfiguration.AutoFarm.AFKFarm and task.wait(1) do
DFunctions.AFKFarming()
end
end)
Tabs.AutoFarm:AddSection("Purchase Automations")
local Toggle = Tabs.AutoFarm:AddToggle("AutoBuy", {Title = "Auto Purchase Selected Item", Default = false })
local function AutoBuyTick(force)
local config = DConfiguration.AutoFarm.PurchaseAutomations
if not config.Enabled and not force then return end
local interval = tonumber(config.Interval) or 4
if not force and tick() - (config.LastBuy or 0) < interval then return end
local ok, detail = DFunctions.BuyItem()
if ok then
config.Failures = 0
return
end
config.Failures = (config.Failures or 0) + 1
if config.Failures == 1 then
Alert("Auto buy: " .. tostring(detail))
end
end
Toggle:OnChanged(function(State)
DConfiguration.AutoFarm.PurchaseAutomations.Enabled = State
if State then
DConfiguration.AutoFarm.PurchaseAutomations.Failures = 0
task.spawn(function() AutoBuyTick(true) end)
if DConfiguration.AutoFarm.PurchaseAutomations.Connection then
DConfiguration.AutoFarm.PurchaseAutomations.Connection:Disconnect()
end
DConfiguration.AutoFarm.PurchaseAutomations.Connection = RunService.Heartbeat:Connect(function()
AutoBuyTick(false)
end)
else
if DConfiguration.AutoFarm.PurchaseAutomations.Connection then
DConfiguration.AutoFarm.PurchaseAutomations.Connection:Disconnect()
DConfiguration.AutoFarm.PurchaseAutomations.Connection = nil
end
end
end)
local Dropdown = Tabs.AutoFarm:AddDropdown("SelectedItem", {
Title = "Select Item",
Values = ShopItemNames,
Multi = false,
Default = 1,
})
DConfiguration.AutoFarm.PurchaseAutomations.Selected = DConfiguration.AutoFarm.PurchaseAutomations.Selected or ShopItemNames[1]
Dropdown:OnChanged(function(Value)
DConfiguration.AutoFarm.PurchaseAutomations.Selected = Value
end)
Tabs.AutoFarm:AddInput("PurchaseAmount", {
Title = "Purchase Amount",
Default = "1",
Placeholder = "1",
Numeric = true,
Finished = false,
Callback = function(Value)
DConfiguration.AutoFarm.PurchaseAutomations.Amount = tonumber(Value) or 1
end,
})
Tabs.AutoFarm:AddInput("PurchaseInterval", {
Title = "Purchase Interval (seconds)",
Default = "4",
Placeholder = "4",
Numeric = true,
Finished = false,
Callback = function(Value)
DConfiguration.AutoFarm.PurchaseAutomations.Interval = tonumber(Value) or 4
end,
})
Tabs.AutoFarm:AddButton({
Title = "Buy Now",
Description = "Fire one purchase immediately",
Callback = function()
local ok, detail = DFunctions.BuyItem()
Alert(ok and ("Bought item " .. tostring(detail)) or ("Buy failed: " .. tostring(detail)))
end,
})
Tabs.AutoFarm:AddSection("VIP Automations")
local AutoVote = {
Enabled = false,
Map = 1,
Mode = 1,
Connections = { Map = nil, Mode = nil }
}
local function getVotePopup()
local playerGui = LocalPlayer:FindFirstChild("PlayerGui")
if not playerGui then return nil end
local shared = playerGui:FindFirstChild("Shared")
if shared then
local popups = shared:FindFirstChild("Popups")
if popups then
local voteActive = popups:FindFirstChild("VoteActive")
if voteActive and voteActive.Visible then return voteActive end
local vote = popups:FindFirstChild("Vote")
if vote and vote.Visible then return vote end
end
end
return nil
end
local function fireVoteServer(mapNumber)
if not getVotePopup() then return end
local voteEvent = ReplicatedStorage:FindFirstChild("Events") and ReplicatedStorage.Events:FindFirstChild("Vote")
if voteEvent and voteEvent:IsA("RemoteEvent") then
voteEvent:FireServer(mapNumber)
end
end
local function fireVoteMode(modeNumber)
if not getVotePopup() then return end
local voteEvent = ReplicatedStorage:FindFirstChild("Events") and ReplicatedStorage.Events:FindFirstChild("Vote")
if voteEvent and voteEvent:IsA("RemoteEvent") then
voteEvent:FireServer(modeNumber, true)
end
end
local function StartAutoVoteMap()
if AutoVote.Connections.Map then AutoVote.Connections.Map:Disconnect() end
AutoVote.Connections.Map = RunService.Heartbeat:Connect(function()
fireVoteServer(AutoVote.Map)
end)
end
local function StopAutoVoteMap()
if AutoVote.Connections.Map then
AutoVote.Connections.Map:Disconnect()
AutoVote.Connections.Map = nil
end
end
local function StartAutoVoteMode()
if AutoVote.Connections.Mode then AutoVote.Connections.Mode:Disconnect() end
AutoVote.Connections.Mode = RunService.Heartbeat:Connect(function()
fireVoteMode(AutoVote.Mode)
end)
end
local function StopAutoVoteMode()
if AutoVote.Connections.Mode then
AutoVote.Connections.Mode:Disconnect()
AutoVote.Connections.Mode = nil
end
end
local Toggle = Tabs.AutoFarm:AddToggle("AutoVoteMap", {Title = "Auto Vote Map", Default = false })
Toggle:OnChanged(function(State)
if State then StartAutoVoteMap() else StopAutoVoteMap() end
end)
local Dropdown = Tabs.AutoFarm:AddDropdown("MapSection", {
Title = "Map Section",
Values = {"Map 1", "Map 2", "Map 3", "Map 4"},
Multi = false,
Default = 1,
})
Dropdown:OnChanged(function(Value)
local num = tonumber(tostring(Value):match("%d+")) or 1
AutoVote.Map = num
DConfiguration.AutoFarm.VIPAutomations.MapSection = num
end)
local Toggle = Tabs.AutoFarm:AddToggle("AutoVoteMode", {Title = "Auto Vote Mode", Default = false })
Toggle:OnChanged(function(State)
if State then StartAutoVoteMode() else StopAutoVoteMode() end
end)
local Dropdown = Tabs.AutoFarm:AddDropdown("GamemodeSection", {
Title = "Gamemode Section",
Values = {"Mode 1", "Mode 2", "Mode 3", "Mode 4"},
Multi = false,
Default = 1,
})
Dropdown:OnChanged(function(Value)
local num = tonumber(tostring(Value):match("%d+")) or 1
AutoVote.Mode = num
DConfiguration.AutoFarm.VIPAutomations.GamemodeSection = num
end)
Tabs.AutoFarm:AddParagraph({Title = " ", Content = ""})
Tabs.AutoFarm:AddInput("MapInput", {
Title = "Map Input",
Default = "DesertBus",
Placeholder = "DesertBus",
Numeric = false,
Finished = false,
Description = "NO SPACE NEEDED",
Callback = function(Value)
DConfiguration.AutoFarm.VIPAutomations.MapInput = Value
end
})
local Toggle = Tabs.AutoFarm:AddToggle("AutoSetMap", {Title = "Auto Set Map", Default = false })
Toggle:OnChanged(function(State)
DConfiguration.AutoFarm.VIPAutomations.AutoMap = State
if State then
DConfiguration.AutoFarm.VIPAutomations.LastMapSet = DConfiguration.AutoFarm.VIPAutomations.LastMapSet or tick()
end
end)
Tabs.AutoFarm:AddInput("SpecialRoundInput", {
Title = "Special Round Input",
Default = "Plushie Hell",
Placeholder = "Plushie Hell",
Numeric = false,
Finished = false,
Callback = function(Value)
DConfiguration.AutoFarm.VIPAutomations.SpecialRoundInput = Value
end
})
local Toggle = Tabs.AutoFarm:AddToggle("AutoSetSpecialRound", {Title = "Auto Set Special Round", Default = false })
Toggle:OnChanged(function(State)
DConfiguration.AutoFarm.VIPAutomations.AutoSpecialRound = State
if State then
DConfiguration.AutoFarm.VIPAutomations.LastSRSet = DConfiguration.AutoFarm.VIPAutomations.LastSRSet or tick()
end
end)
Tabs.AutoFarm:AddInput("TimerInput", {
Title = "Timer Input",
Default = "180",
Placeholder = "180",
Numeric = false,
Finished = false,
Callback = function(Value)
DConfiguration.AutoFarm.VIPAutomations.TimerInput = Value
end
})
local Dropdown = Tabs.AutoFarm:AddDropdown("TimerRoundState", {
Title = "Auto Timer Round State",
Values = {"Round Started", "Intermission", "All"},
Multi = false,
Default = 1,
})
Dropdown:OnChanged(function(Value)
local num = tonumber(tostring(Value):match("%d+")) or 1
if Value == "Round Started" then num = 1
elseif Value == "Intermission" then num = 2
elseif Value == "All" then num = 3 end
DConfiguration.AutoFarm.VIPAutomations.TimerRoundState = num
end)
local Toggle = Tabs.AutoFarm:AddToggle("AutoSetTimer", {Title = "Auto Set Timer", Default = false })
Toggle:OnChanged(function(State)
DConfiguration.AutoFarm.VIPAutomations.AutoTimer = State
if State then
DConfiguration.AutoFarm.VIPAutomations.LastTimerSet = DConfiguration.AutoFarm.VIPAutomations.LastTimerSet or tick()
end
end)
pcall(function()
if DConfiguration.AutoFarm.VIPAutomations.MapConn then
DConfiguration.AutoFarm.VIPAutomations.MapConn:Disconnect()
DConfiguration.AutoFarm.VIPAutomations.MapConn = nil
end
end)
pcall(function()
if DConfiguration.AutoFarm.VIPAutomations.SRConn then
DConfiguration.AutoFarm.VIPAutomations.SRConn:Disconnect()
DConfiguration.AutoFarm.VIPAutomations.SRConn = nil
end
end)
pcall(function()
if DConfiguration.AutoFarm.VIPAutomations.TimerConn then
DConfiguration.AutoFarm.VIPAutomations.TimerConn:Disconnect()
DConfiguration.AutoFarm.VIPAutomations.TimerConn = nil
end
end)
if DConfiguration.AutoFarm.VIPAutomations.VIPConn then
pcall(function() DConfiguration.AutoFarm.VIPAutomations.VIPConn:Disconnect() end)
DConfiguration.AutoFarm.VIPAutomations.VIPConn = nil
end
DConfiguration.AutoFarm.VIPAutomations.VIPConn = RunService.Heartbeat:Connect(function()
local VIP = DConfiguration.AutoFarm.VIPAutomations
local svc = ServerStateRegistryService
if not svc then return end
local function getState(key)
if svc.Registry then
return svc.Registry[key]
end
return nil
end
local function normalize(str)
return tostring(str or ""):gsub("%s+", ""):lower()
end
local function getMapDisplayName(moduleName)
local mapsFolder = ReplicatedStorage:FindFirstChild("Info") and ReplicatedStorage.Info:FindFirstChild("Maps")
if not mapsFolder then return nil end
local mod = mapsFolder:FindFirstChild(moduleName)
if mod and mod:IsA("ModuleScript") then
local ok, data = pcall(require, mod)
if ok and data and data.Name then
return data.Name
end
end
return nil
end
local function getMapModuleName(displayName)
local mapsFolder = ReplicatedStorage:FindFirstChild("Info") and ReplicatedStorage.Info:FindFirstChild("Maps")
if not mapsFolder then return nil end
for _, mod in ipairs(mapsFolder:GetChildren()) do
if mod:IsA("ModuleScript") then
local ok, data = pcall(require, mod)
if ok and data and data.Name then
if normalize(data.Name) == normalize(displayName) then
return mod.Name
end
end
end
end
return nil
end
local function getSpecialRoundDisplayName(moduleName)
local srFolder = ReplicatedStorage:FindFirstChild("Info") and ReplicatedStorage.Info:FindFirstChild("SpecialRounds")
if not srFolder then return nil end
local mod = srFolder:FindFirstChild(moduleName)
if mod and mod:IsA("ModuleScript") then
local ok, data = pcall(require, mod)
if ok and data and data.Name then
return data.Name
end
end
return nil
end
local function getSpecialRoundModuleName(displayName)
local srFolder = ReplicatedStorage:FindFirstChild("Info") and ReplicatedStorage.Info:FindFirstChild("SpecialRounds")
if not srFolder then return nil end
for _, mod in ipairs(srFolder:GetChildren()) do
if mod:IsA("ModuleScript") then
local ok, data = pcall(require, mod)
if ok and data and data.Name then
if normalize(data.Name) == normalize(displayName) then
return mod.Name
end
end
end
end
return nil
end
if VIP.AutoMap and VIP.MapInput and VIP.MapInput ~= "" then
if tick() - (VIP.LastMapSet or 0) >= 1 then
local current = getState("Map")
local desired = VIP.MapInput
local match = false
local nc = normalize(current)
local nd = normalize(desired)
if nc == nd then
match = true
else
local display = getMapDisplayName(desired)
if display and normalize(display) == nc then
match = true
end
local moduleName = getMapModuleName(desired)
if moduleName and normalize(moduleName) == nc then
match = true
end
end
if not match then
local isLoading = getState("MapLoading")
if type(isLoading) == "string" then
else
DFunctions.AdminCommand("!Map " .. desired)
VIP.LastMapSet = tick()
end
end
end
end
if VIP.AutoSpecialRound and VIP.SpecialRoundInput and VIP.SpecialRoundInput ~= "" then
if tick() - (VIP.LastSRSet or 0) >= 1 then
local current = getState("SpecialRound")
local desired = VIP.SpecialRoundInput
local match = false
local nc = normalize(current)
local nd = normalize(desired)
if nc == nd then
match = true
else
local display = getSpecialRoundDisplayName(desired)
if display and normalize(display) == nc then
match = true
end
local moduleName = getSpecialRoundModuleName(desired)
if moduleName and normalize(moduleName) == nc then
match = true
end
end
if not match then
DFunctions.AdminCommand("!SpecialRound " .. desired)
VIP.LastSRSet = tick()
end
end
end
local isVoting = getState("Voting")
if isVoting == true and VIP.MapInput and VIP.MapInput ~= "" then
if tick() - (VIP.LastVotingFire or 0) >= 3 then
DFunctions.AdminCommand("!Time 1")
DFunctions.AdminCommand("!Map " .. VIP.MapInput)
VIP.LastVotingFire = tick()
end
end
if VIP.AutoTimer and VIP.TimerInput and VIP.TimerInput ~= "" then
if tick() - (VIP.LastTimerSet or 0) >= 3 then
local roundStatus = getState("RoundStatus")
local roundState = VIP.TimerRoundState or 1
local shouldFire = false
if roundState == 1 and roundStatus == 2 then
shouldFire = true
elseif roundState == 2 and roundStatus ~= 2 then
shouldFire = true
elseif roundState == 3 then
shouldFire = true
end
if shouldFire then
local current = getState("Time")
local desiredNum = tonumber(VIP.TimerInput)
if desiredNum and (current == nil or current ~= desiredNum) then
DFunctions.AdminCommand("!Time " .. tostring(desiredNum))
VIP.LastTimerSet = tick()
end
end
end
end
end)
wait(Duration)
Tabs.Combat:AddSection("Nextbot Modification")
local Toggle = Tabs.Combat:AddToggle("AntiNextbotToggle", {Title = "Anti Nextbot Toggle", Default = false })
Toggle:OnChanged(function(value)
DConfiguration.Combat.AntiNextbot = value
while DConfiguration.Combat.AntiNextbot and task.wait(0.1) do
DFunctions.AntiNextbot()
end
end)
local Dropdown = Tabs.Combat:AddDropdown("AntiBotTeleport", {
Title = "Anti Nextbot Teleport Type",
Values = {"Spawn", "Players"},
Multi = false,
Default = 1,
})
Dropdown:OnChanged(function(Value)
DConfiguration.Combat.AntiNextbotType = Value
end)
Tabs.Combat:AddInput("NextbotDistance", {
Title = "Anti Nextbot Distance",
Default = 15,
Placeholder = "Number",
Numeric = false,
Finished = false,
Callback = function(Value)
DConfiguration.Combat.AntiNextbotRange = tonumber(Value) or 15
end
})
wait(Duration)
Tabs.Misc:AddSection("Player Adjustments")
Tabs.Misc:AddInput("PlayerSpeed", {
Title = "Player Speed",
Description = "Change how fast your character moves.",
Default = "1500",
Placeholder = "Speed Number",
Numeric = false,
Finished = false,
Callback = function(Value)
local n = tonumber(Value) or 1500
DConfiguration.Misc.PlayerAdjustment.Update.Speed = n
DConfiguration.Misc.PlayerAdjustment.Saved.Speed = n
DFunctions.setTSpeed(n)
end
})
Tabs.Misc:AddInput("PlayerJump", {
Title = "Player Jump",
Description = "Change how high your character jumps.",
Default = "3",
Placeholder = "Jump Number",
Numeric = false,
Finished = false,
Callback = function(Value)
local n = tonumber(Value) or 3
DConfiguration.Misc.PlayerAdjustment.Update.JumpHeight = n
DConfiguration.Misc.PlayerAdjustment.Saved.JumpHeight = n
DFunctions.setTJump(n)
end
})
Tabs.Misc:AddInput("PlayerJumpAcce", {
Title = "Player Jump Acceleration",
Description = "Your speed increases when you jump.",
Default = "1.45",
Placeholder = "Jump Acceleration Number",
Numeric = false,
Finished = false,
Callback = function(Value)
local n = tonumber(Value) or 1.45
DConfiguration.Misc.PlayerAdjustment.Update.JumpAcceleration = n
DConfiguration.Misc.PlayerAdjustment.Saved.JumpAcceleration = n
DFunctions.setTJumpAcceleration(n)
end
})
Tabs.Misc:AddInput("PlayerJumpCap", {
Title = "Player Jump Cap",
Description = "Allows air jumping.",
Default = "1",
Placeholder = "Jump Cap Number",
Numeric = false,
Finished = false,
Callback = function(Value)
local n = tonumber(Value) or 1
DConfiguration.Misc.PlayerAdjustment.Update.JumpCap = n
DConfiguration.Misc.PlayerAdjustment.Saved.JumpCap = n
DFunctions.setTJumpCap(n)
end
})
Tabs.Misc:AddInput("PlayerStrafeAcceleration", {
Title = "Player Strafe Acceleration",
Description = "Change how fast you move sideways in the air.",
Default = "182",
Placeholder = "Number",
Numeric = false,
Finished = false,
Callback = function(Value)
local n = tonumber(Value) or 182
DConfiguration.Misc.PlayerAdjustment.Update.AirStrafe = n
DConfiguration.Misc.PlayerAdjustment.Saved.AirStrafe = n
DFunctions.setTAirStrafe(n)
end
})
Tabs.Misc:AddParagraph({Title = " ", Content = ""})
local Toggle = Tabs.Misc:AddToggle("PlayerJumpPower", {Title = "Jump Power Toggle", Default = false })
Toggle:OnChanged(function(State)
DConfiguration.Misc.Humanoids.OriginalJumpHeight = State
while DConfiguration.Misc.Humanoids.OriginalJumpHeight and task.wait(0.1) do
local humanoid = LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("Humanoid")
if humanoid then
humanoid.UseJumpPower = true
humanoid.JumpPower = DConfiguration.Misc.Humanoids.JP
end
end
end)
Tabs.Misc:AddInput("PlayerJumpPowerValue", {
Title = "Player Jump Power",
Default = "20",
Placeholder = "Jump Number",
Numeric = false,
Finished = false,
Callback = function(Value)
DConfiguration.Misc.Humanoids.JP = tonumber(Value) or 20
end
})
local Toggle = Tabs.Misc:AddToggle("PlayerWalkspeed", {Title = "Walkspeed Toggle", Default = false })
Toggle:OnChanged(function(State)
DConfiguration.Misc.Humanoids.WalkspeedCF = State
while DConfiguration.Misc.Humanoids.WalkspeedCF and task.wait() do
local chr = LocalPlayer.Character
local hum = chr and chr:FindFirstChildWhichIsA("Humanoid")
if chr and hum and hum.MoveDirection.Magnitude > 0 then
chr:TranslateBy(hum.MoveDirection * DConfiguration.Misc.Humanoids.CF * 0.1)
end
end
end)
Tabs.Misc:AddInput("PlayerWalkCf", {
Title = "Player Walkspeed",
Default = "5",
Placeholder = "Walk Number",
Numeric = false,
Finished = false,
Callback = function(Value)
DConfiguration.Misc.Humanoids.CF = tonumber(Value) or 5
end
})
Tabs.Misc:AddSection("Utilities")
local Toggle = Tabs.Misc:AddToggle("LagSwitch", {Title = "Lag Switch (Button)", Default = false})
Toggle:OnChanged(function(State)
if State then
DFunctions.CreateButton("LagSwitchButton", "Start Lag", 0.15 + DConfiguration.Settings.GuiScale.LagSwitch, 0.1 + DConfiguration.Settings.GuiScale.LagSwitch, function(btn)
task.spawn(function()
DFunctions.StartLag(DConfiguration.Misc.Utilities.LagSwitch.MSDelay)
end)
btn.Text = "..."
wait(0.1)
btn.Text = "Start Lag"
end)
else
DFunctions.DestroyButton("LagSwitchButton")
end
end)
local Keybind = Tabs.Misc:AddKeybind("LagSwitchKey", {
Title = "Lag Switch Keybind",
Mode = "Toggle",
Default = "H",
Callback = function()
task.spawn(function()
DFunctions.StartLag(DConfiguration.Misc.Utilities.LagSwitch.MSDelay)
end)
end,
})
Tabs.Misc:AddInput("LagSwitchButtonSize", {
Title = "Lag Switch Gui Size",
Default = tostring(DConfiguration.Settings.GuiScale.LagSwitch),
Placeholder = "0",
Numeric = true,
Finished = false,
Callback = function(Value)
local num = tonumber(Value)
if num then
DConfiguration.Settings.GuiScale.LagSwitch = num * 0.01
else
DConfiguration.Settings.GuiScale.LagSwitch = 0
end
DFunctions.UpdateButton("LagSwitchButton", 0.15 + DConfiguration.Settings.GuiScale.LagSwitch, 0.1 + DConfiguration.Settings.GuiScale.LagSwitch)
end
})
Tabs.Misc:AddInput("DelayMS", {
Title = "Delay MS",
Default = "200",
Placeholder = "Value",
Numeric = false,
Finished = false,
Callback = function(Value)
DConfiguration.Misc.Utilities.LagSwitch.MSDelay = tonumber(Value) or 200
end
})
local Dropdown = Tabs.Misc:AddDropdown("LagMode", {
Title = "Lag Mode",
Values = {"Normal", "Demon", "FastFlag"},
Multi = false,
Default = 1,
})
Dropdown:OnChanged(function(Value)
DConfiguration.Misc.Utilities.LagSwitch.Mode = Value
end)
Tabs.Misc:AddParagraph({Title = " ", Content = ""})
local Toggle = Tabs.Misc:AddToggle("AdjustBounce", {Title = "Modify Bounce", Default = false })
Toggle:OnChanged(function(State)
DConfiguration.Misc.Utilities.BounceModification.Enabled = State
while DConfiguration.Misc.Utilities.BounceModification.Enabled and task.wait(0.1) do
DFunctions.BounceFunction()
end
end)
local Toggle = Tabs.Misc:AddToggle("SuperBounce", {Title = "Super Bounce", Default = false})
Toggle:OnChanged(function(State)
if State then
DFunctions.CreateButton("SuperBounceButton", "Super Bounce", 0.1 + DConfiguration.Settings.GuiScale.SuperBounce, 0.1 + DConfiguration.Settings.GuiScale.SuperBounce, function(btn)
DFunctions.SuperBounce()
btn.Text = "..."
wait(0.1)
btn.Text = "Super Bounce"
end)
else
DFunctions.DestroyButton("SuperBounceButton")
end
end)
Tabs.Misc:AddInput("PlayerBounce", {
Title = "Player Bounce",
Default = "80",
Placeholder = "Bounce Number",
Numeric = false,
Finished = false,
Callback = function(Value)
DConfiguration.Misc.Utilities.BounceModification.DefaultBounce = tonumber(Value) or 80
end
})
Tabs.Misc:AddInput("EmoteBounce", {
Title = "Emote Bounce",
Default = "120",
Placeholder = "Bounce Number",
Numeric = false,
Finished = false,
Callback = function(Value)
DConfiguration.Misc.Utilities.BounceModification.EmoteBounce = tonumber(Value) or 120
end
})
Tabs.Misc:AddParagraph({Title = " ", Content = ""})
local Toggle = Tabs.Misc:AddToggle("AdjustEdgeTrimp", {Title = "Modify Edge Trimp", Default = false })
Toggle:OnChanged(function(State)
DConfiguration.Misc.Utilities.EdgeTrimpModification.Enabled = State
while DConfiguration.Misc.Utilities.EdgeTrimpModification.Enabled and task.wait(0.1) do
DFunctions.ModifyEdgeTrimp()
end
end)
Tabs.Misc:AddInput("EdgeTrimpHeight", {
Title = "Height Multiplier",
Default = "1.5",
Placeholder = "Number",
Numeric = false,
Finished = false,
Callback = function(Value)
DConfiguration.Misc.Utilities.EdgeTrimpModification.HeightMultiplier = tonumber(Value) or 1.5
end
})
Tabs.Misc:AddInput("DownThreshold", {
Title = "Falling Threshold",
Default = "4.5",
Placeholder = "Number",
Numeric = false,
Finished = false,
Callback = function(Value)
DConfiguration.Misc.Utilities.EdgeTrimpModification.DownThreshold = tonumber(Value) or 4.5
end
})
Tabs.Misc:AddSection("Camera Adjustments")
Tabs.Misc:AddInput("CamX", {
Title = "Stretch Horizontal",
Default = "1",
Placeholder = "Number",
Numeric = false,
Finished = false,
Callback = function(Value)
DConfiguration.Misc.CameraAdjustment.StretchX = tonumber(Value) or 1
end
})
Tabs.Misc:AddInput("CamY", {
Title = "Stretch Vertical",
Default = "1",
Placeholder = "Number",
Numeric = false,
Finished = false,
Callback = function(Value)
DConfiguration.Misc.CameraAdjustment.StretchY = tonumber(Value) or 1
end
})
Tabs.Misc:AddInput("PlayerFOV", {
Title = "Player FOV",
Default = "1",
Placeholder = "Number (multiplier)",
Numeric = false,
Finished = false,
Callback = function(Value)
local mult = tonumber(Value) or 1
if CameraService and CameraService.AdjustFOV then
CameraService:AdjustFOV("ElderwyrmCustomFOV", mult)
end
end
})
Tabs.Misc:AddButton({
Title = "Set Camera Stretch",
Description = "(Warning: Stretch settings can make billboards look weird or disappear from far away.)",
Callback = function()
LocalPlayer:SetAttribute("StretchX", DConfiguration.Misc.CameraAdjustment.StretchX)
LocalPlayer:SetAttribute("StretchY", DConfiguration.Misc.CameraAdjustment.StretchY)
end
})
Tabs.Misc:AddButton({
Title = "Enable Front Camera",
Description = "",
Callback = function()
end
})
Tabs.Misc:AddSection("Gun Adjustments")
Tabs.Misc:AddButton({
Title = "Set to Infinite Ammo",
Description = " ",
Callback = function()
local Tools = ReplicatedStorage:FindFirstChild("Tools")
if not Tools then return end
for _, tool in ipairs(Tools:GetChildren()) do
if tool:IsA("ModuleScript") then
local success, module = pcall(require, tool)
if success and module and module.Tasks then
for _, task in ipairs(module.Tasks) do
if task.ResourceInfo and task.ResourceInfo.Type == "Clip" then
task.ResourceInfo.Reserve = 9999999999
task.ResourceInfo.Cap = 9999999999
end
end
end
end
end
end
})
Tabs.Misc:AddButton({
Title = "Set to Infinite Range",
Description = " ",
Callback = function()
local function setInfiniteRange(data)
if type(data) ~= "table" then return end
for key, value in pairs(data) do
if (key == "Range" or key == "LungeRange" or key == "HearingRange") and type(value) == "number" then
data[key] = math.huge
elseif key == "DamageDistanceInterval" and type(value) == "table" and #value >= 2 then
value[2] = math.huge
elseif type(value) == "table" then
setInfiniteRange(value)
end
end
end
local Tools = ReplicatedStorage:FindFirstChild("Tools")
if not Tools then return end
for _, tool in pairs(Tools:GetChildren()) do
if tool:IsA("ModuleScript") then
local success, toolData = pcall(require, tool)
if success and type(toolData) == "table" and toolData.Tasks then
for _, task in ipairs(toolData.Tasks) do
for _, func in ipairs(task.Functions or {}) do
for _, activation in ipairs(func.Activations or {}) do
for _, method in ipairs(activation.Methods or {}) do
if method.Info then setInfiniteRange(method.Info) end
end
end
end
for _, autoFunc in ipairs(task.AutomaticFunctions or {}) do
for _, method in ipairs(autoFunc.Methods or {}) do
if method.Info then setInfiniteRange(method.Info) end
end
end
end
end
end
end
end
})
Tabs.Misc:AddButton({
Title = "No Cooldown",
Description = " ",
Callback = function()
local function setFastShoot(data)
if type(data) ~= "table" then return end
for key, value in pairs(data) do
if key == "Cooldown" and type(value) == "number" then
data[key] = 1/65536
elseif type(value) == "table" then
setFastShoot(value)
end
end
end
local Tools = ReplicatedStorage:FindFirstChild("Tools")
if not Tools then return end
for _, tool in pairs(Tools:GetChildren()) do
if tool:IsA("ModuleScript") then
local success, toolData = pcall(require, tool)
if success and type(toolData) == "table" and toolData.Tasks then
for _, task in ipairs(toolData.Tasks) do
for _, func in ipairs(task.Functions or {}) do
for _, activation in ipairs(func.Activations or {}) do
for _, method in ipairs(activation.Methods or {}) do
if method.Info then setFastShoot(method.Info) end
end
end
end
for _, autoFunc in ipairs(task.AutomaticFunctions or {}) do
for _, method in ipairs(autoFunc.Methods or {}) do
if method.Info then setFastShoot(method.Info) end
end
end
end
end
end
end
end
})
Tabs.Misc:AddSection("Game Automations")
local Toggle = Tabs.Misc:AddToggle("AutoCarry", {Title = "Auto Carry (Button)", Default = false})
Toggle:OnChanged(function(State)
if State then
DFunctions.CreateButton("AutoCarryGui", "Auto Carry: OFF", 0.15 + DConfiguration.Settings.GuiScale.AutoCarry, 0.1 + DConfiguration.Settings.GuiScale.AutoCarry, function(btn)
DConfiguration.Misc.GameAutomation.Carry.FloatingButton = not DConfiguration.Misc.GameAutomation.Carry.FloatingButton
btn.Text = DConfiguration.Misc.GameAutomation.Carry.FloatingButton and "Auto Carry: ON" or "Auto Carry: OFF"
if DConfiguration.Misc.GameAutomation.Carry.FloatingButton then
DFunctions.StartAutoCarry()
else
DFunctions.StopAutoCarry()
end
end)
else
DFunctions.StopAutoCarry()
DFunctions.DestroyButton("AutoCarryGui")
end
end)
local Toggle = Tabs.Misc:AddToggle("EmoteCarry", {Title = "Carry While Emote", Default = false})
Toggle:OnChanged(function(State)
DConfiguration.Misc.GameAutomation.Carry.WhileEmote = State
end)
local Keybind = Tabs.Misc:AddKeybind("KeybindCarry", {
Title = "Keybind to Carry",
Mode = "Toggle",
Default = "Q",
Callback = function(Bool)
DConfiguration.Misc.GameAutomation.Carry.Keybind = Bool
end,
})
Tabs.Misc:AddInput("CarryButtonSize", {
Title = "Auto Carry Gui Size",
Default = tostring(DConfiguration.Settings.GuiScale.AutoCarry),
Placeholder = "0",
Numeric = true,
Finished = false,
Callback = function(Value)
local num = tonumber(Value)
if num then
DConfiguration.Settings.GuiScale.AutoCarry = num * 0.01
else
DConfiguration.Settings.GuiScale.AutoCarry = 0
end
DFunctions.UpdateButton("AutoCarryGui", 0.15 + DConfiguration.Settings.GuiScale.AutoCarry, 0.1 + DConfiguration.Settings.GuiScale.AutoCarry)
end
})
Tabs.Misc:AddParagraph({Title = " ", Content = ""})
wait(Duration)
local Toggle = Tabs.Misc:AddToggle("AutoEmote", {Title = "Auto Emote Dash Button", Default = false})
Toggle:OnChanged(function(State)
if State then
DFunctions.CreateButton("EmoteDashButton", "Start Emote", 0.15 + DConfiguration.Settings.GuiScale.AutoEmoteDash, 0.1 + DConfiguration.Settings.GuiScale.AutoEmoteDash, function(btn)
btn.Text = "Emoting..."
DFunctions.AutoEmoteDash()
task.wait(0.15)
btn.Text = "Start Emote"
end)
else
DFunctions.DestroyButton("EmoteDashButton")
end
end)
Tabs.Misc:AddInput("EmoteButtonSize", {
Title = "Auto Emote Dash Gui Size",
Default = tostring(DConfiguration.Settings.GuiScale.AutoEmoteDash),
Placeholder = "0",
Numeric = true,
Finished = false,
Callback = function(Value)
local num = tonumber(Value)
if num then
DConfiguration.Settings.GuiScale.AutoEmoteDash = num * 0.01
else
DConfiguration.Settings.GuiScale.AutoEmoteDash = 0
end
DFunctions.UpdateButton("EmoteDashButton", 0.15 + DConfiguration.Settings.GuiScale.AutoEmoteDash, 0.1 + DConfiguration.Settings.GuiScale.AutoEmoteDash)
end
})
local Keybind = Tabs.Misc:AddKeybind("KeyEmoteDash", {
Title = "Keybind to Emote Dash",
Mode = "Toggle",
Default = "RightControl",
Callback = function(Bool)
DConfiguration.Misc.GameAutomation.Macro.Keybind = Bool
if Bool then
DFunctions.AutoEmoteDash()
end
end,
})
local Dropdown = Tabs.Misc:AddDropdown("EmoteID", {
Title = "Select Emote ID",
Values = EmoteNames,
Multi = false,
Default = 1,
})
Dropdown:OnChanged(function(Value)
DConfiguration.Misc.GameAutomation.Macro.SelectedEmote = Value
end)
Tabs.Misc:AddSection("Movement Modification")
local Toggle = Tabs.Misc:AddToggle("AggressiveEmoteDash", {Title = "Aggressive Emote Dash", Default = false })
Toggle:OnChanged(function(State)
DConfiguration.Misc.MovementModification.AggressiveEmoteDash.Enabled = State
DFunctions.AggressiveEmoteDashFunction()
end)
local Dropdown = Tabs.Misc:AddDropdown("AggressiveEmoteType", {
Title = "Aggressive Emote Type",
Values = {"Legit", "Blatant"},
Multi = false,
Default = 2,
})
Dropdown:OnChanged(function(Value)
DConfiguration.Misc.MovementModification.AggressiveEmoteDash.Type = Value
DFunctions.AggressiveEmoteDashFunction()
end)
Tabs.Misc:AddInput("EmoteSpeed", {
Title = "Aggressive Emote Speed",
Default = "2000",
Placeholder = "Emote Speed Number",
Numeric = false,
Finished = false,
Callback = function(Value)
DConfiguration.Misc.MovementModification.AggressiveEmoteDash.Speed = tonumber(Value) or 2000
DFunctions.AggressiveEmoteDashFunction()
end
})
Tabs.Misc:AddInput("CrouchSpeedAgg", {
Title = "Aggressive Emote Acceleration (Negative Only)",
Default = "-2",
Placeholder = "Acceleration Number",
Numeric = false,
Finished = false,
Callback = function(Value)
DConfiguration.Misc.MovementModification.AggressiveEmoteDash.Acceleration = tonumber(Value) or -2
DFunctions.AggressiveEmoteDashFunction()
end
})
Tabs.Misc:AddParagraph({Title = " ", Content = ""})
local Toggle = Tabs.Misc:AddToggle("InfiniteSlide", {Title = "Infinite Slide", Default = false })
Toggle:OnChanged(function(State)
DConfiguration.Misc.MovementModification.SlideModification.Enabled = State
DFunctions.InfiniteSlideFunction()
end)
local Toggle = Tabs.Misc:AddToggle("InfiniteSlideButton", {Title = "Infinite Slide (Button)", Default = false })
Toggle:OnChanged(function(State)
if State then
DFunctions.CreateButton("InfiniteSlideButton", "Infinite Slide: OFF", 0.15 + DConfiguration.Settings.GuiScale.InfiniteSlide, 0.1 + DConfiguration.Settings.GuiScale.InfiniteSlide, function(btn)
DConfiguration.Misc.MovementModification.SlideModification.FloatingButton = not DConfiguration.Misc.MovementModification.SlideModification.FloatingButton
btn.Text = DConfiguration.Misc.MovementModification.SlideModification.FloatingButton and "Infinite Slide: ON" or "Infinite Slide: OFF"
DConfiguration.Misc.MovementModification.SlideModification.Enabled = DConfiguration.Misc.MovementModification.SlideModification.FloatingButton
end)
else
DFunctions.DestroyButton("InfiniteSlideButton")
end
end)
Tabs.Misc:AddInput("InfiniteSlideButtonSize", {
Title = "Infinite Slide Gui Size",
Default = tostring(DConfiguration.Settings.GuiScale.InfiniteSlide),
Placeholder = "0",
Numeric = true,
Finished = false,
Callback = function(Value)
local num = tonumber(Value)
if num then
DConfiguration.Settings.GuiScale.InfiniteSlide = num * 0.01
else
DConfiguration.Settings.GuiScale.InfiniteSlide = 0
end
DFunctions.UpdateButton("InfiniteSlideButton", 0.15 + DConfiguration.Settings.GuiScale.InfiniteSlide, 0.1 + DConfiguration.Settings.GuiScale.InfiniteSlide)
end
})
Tabs.Misc:AddInput("SlideSpeed", {
Title = "Slide Speed (Negative Only)",
Default = "-3",
Placeholder = "Crouch Speed Number",
Numeric = false,
Finished = false,
Callback = function(Value)
DConfiguration.Misc.MovementModification.SlideModification.Acceleration = tonumber(Value) or -3
end
})
Tabs.Misc:AddParagraph({Title = " ", Content = ""})
local NormalGravity = game.Workspace.Gravity
local Toggle = Tabs.Misc:AddToggle("GravityToggle", {Title = "Gravity Button", Default = false })
Toggle:OnChanged(function(State)
if State then
DFunctions.CreateButton("GravityGui", "Gravity: OFF", 0.15 + DConfiguration.Settings.GuiScale.Gravity, 0.1 + DConfiguration.Settings.GuiScale.Gravity, function(btn)
DConfiguration.Misc.MovementModification.Gravity.FloatingButton = not DConfiguration.Misc.MovementModification.Gravity.FloatingButton
btn.Text = DConfiguration.Misc.MovementModification.Gravity.FloatingButton and "Gravity: ON" or "Gravity: OFF"
if DConfiguration.Misc.MovementModification.Gravity.FloatingButton then
task.spawn(function()
while DConfiguration.Misc.MovementModification.Gravity.FloatingButton do
workspace.Gravity = DConfiguration.Misc.MovementModification.Gravity.Value
task.wait(0.1)
end
workspace.Gravity = NormalGravity
end)
else
workspace.Gravity = NormalGravity
end
end)
else
DConfiguration.Misc.MovementModification.Gravity.FloatingButton = false
workspace.Gravity = NormalGravity
DFunctions.DestroyButton("GravityGui")
end
end)
Tabs.Misc:AddInput("GravityButtonSize", {
Title = "Gravity Gui Size",
Default = tostring(DConfiguration.Settings.GuiScale.Gravity),
Placeholder = "0",
Numeric = true,
Finished = false,
Callback = function(Value)
local num = tonumber(Value)
if num then
DConfiguration.Settings.GuiScale.Gravity = num * 0.01
else
DConfiguration.Settings.GuiScale.Gravity = 0
end
DFunctions.UpdateButton("GravityGui", 0.15 + DConfiguration.Settings.GuiScale.Gravity, 0.1 + DConfiguration.Settings.GuiScale.Gravity)
end
})
local Keybind = Tabs.Misc:AddKeybind("GravitKey", {
Title = "Gravity Keybind",
Mode = "Toggle",
Default = "J",
Callback = function(Bool)
DConfiguration.Misc.MovementModification.Gravity.Keybind = Bool
if Bool then
workspace.Gravity = DConfiguration.Misc.MovementModification.Gravity.Value
else
workspace.Gravity = NormalGravity
end
end,
})
Tabs.Misc:AddInput("GravityAdjust", {
Title = "Gravity Adjustment",
Default = "10",
Placeholder = " Number",
Numeric = false,
Finished = false,
Callback = function(Value)
DConfiguration.Misc.MovementModification.Gravity.Value = tonumber(Value) or 10
end
})
Tabs.Misc:AddParagraph({Title = " ", Content = ""})
local Toggle = Tabs.Misc:AddToggle("BHOPToggle", {Title = "BHOP", Default = false })
Toggle:OnChanged(function(State)
DFunctions.ToggleBhop(State)
end)
local Toggle = Tabs.Misc:AddToggle("BHOPHoldJump", {Title = "BHOP Hold Jump", Default = false })
Toggle:OnChanged(function(State)
DFunctions.ToggleBhopHold(State)
end)
local Toggle = Tabs.Misc:AddToggle("ShowBHOPButton", {Title = "Show BHOP Button", Default = false })
Toggle:OnChanged(function(State)
if State then
DFunctions.CreateButton("BHOPGui", "BHOP: OFF", 0.15 + DConfiguration.Settings.GuiScale.AutoJump, 0.1 + DConfiguration.Settings.GuiScale.AutoJump, function(btn)
local on = not DConfiguration.Misc.MovementModification.BHOP.Enabled
DFunctions.ToggleBhop(on)
btn.Text = on and "BHOP: ON" or "BHOP: OFF"
end)
else
DFunctions.DestroyButton("BHOPGui")
end
end)
local Keybind = Tabs.Misc:AddKeybind("KeybindBHOP", {
Title = "Keybind to BHOP",
Mode = "Toggle",
Default = "B",
Callback = function(Bool)
DFunctions.ToggleBhop(Bool)
end,
})
Tabs.Misc:AddInput("BHOPButtonSize", {
Title = "BHOP Gui Size",
Default = tostring(DConfiguration.Settings.GuiScale.AutoJump),
Placeholder = "0",
Numeric = true,
Finished = false,
Callback = function(Value)
local num = tonumber(Value)
if num then
DConfiguration.Settings.GuiScale.AutoJump = num * 0.01
else
DConfiguration.Settings.GuiScale.AutoJump = 0
end
DFunctions.UpdateButton("BHOPGui", 0.15 + DConfiguration.Settings.GuiScale.AutoJump, 0.1 + DConfiguration.Settings.GuiScale.AutoJump)
end
})
local Dropdown = Tabs.Misc:AddDropdown("BHOPVersion", {
Title = "BHOP Mode",
Values = {"Acceleration", "No Acceleration"},
Multi = false,
Default = 1,
})
Dropdown:OnChanged(function(Value)
DFunctions.SetAccelerationMethod(Value)
end)
local Dropdown = Tabs.Misc:AddDropdown("JumpType", {
Title = "Auto Jump Mode",
Values = {"Simulation", "Realistic"},
Multi = false,
Default = 1,
})
Dropdown:OnChanged(function(Value)
DConfiguration.Misc.MovementModification.BHOP.Settings.JumpType = Value
DFunctions.BHOPFunction()
end)
local Toggle = Tabs.Misc:AddToggle("BackwardBHOP", {Title = "BHOP Backwards", Default = false })
Toggle:OnChanged(function(State)
DConfiguration.Misc.MovementModification.BHOP.Settings.Backwards = State
end)
local Toggle = Tabs.Misc:AddToggle("SpiderHop", {Title = "Spider Hop (Beta)", Default = false })
Toggle:OnChanged(function(State)
DConfiguration.Misc.MovementModification.BHOP.Settings.SpiderHop = State
DFunctions.BHOPFunction()
end)
Tabs.Misc:AddInput("BHOPAcceleration", {
Title = "BHOP Acceleration (Negative Only)",
Default = "-0.1",
Placeholder = "-1",
Numeric = false,
Finished = false,
Callback = function(Value)
DConfiguration.Misc.MovementModification.BHOP.Settings.Acceleration = tonumber(Value) or -0.1
DFunctions.BHOPFunction()
end
})
Tabs.Misc:AddParagraph({Title = " ", Content = ""})
local Toggle = Tabs.Misc:AddToggle("BHOPAutoAccelerate", {Title = "Auto Acceleration (Legit)", Default = false })
Toggle:OnChanged(function(State)
DConfiguration.Misc.MovementModification.BHOP.Settings.AutoAcceleration.Enabled = State
DFunctions.BHOPFunction()
end)
Tabs.Misc:AddInput("AutoAccelerationMaxAccel", {
Title = "Max Acceleration",
Default = "3",
Placeholder = "3",
Numeric = false,
Finished = false,
Callback = function(Value)
DConfiguration.Misc.MovementModification.BHOP.Settings.AutoAcceleration.MaxAccelerate = tonumber(Value) or 3
DFunctions.BHOPFunction()
end
})
Tabs.Misc:AddInput("AutoAccelerationMinAccel", {
Title = "Min Acceleration",
Default = "-1",
Placeholder = "-1",
Numeric = false,
Finished = false,
Callback = function(Value)
DConfiguration.Misc.MovementModification.BHOP.Settings.AutoAcceleration.MinAccelerate = tonumber(Value) or -1
DFunctions.BHOPFunction()
end
})
Tabs.Misc:AddInput("AutoAccelerationMaxSpeed", {
Title = "Max Speed",
Default = "70",
Placeholder = "70",
Numeric = false,
Finished = false,
Callback = function(Value)
DConfiguration.Misc.MovementModification.BHOP.Settings.AutoAcceleration.MinSpeed = tonumber(Value) or 70
end
})
Tabs.Misc:AddParagraph({Title = " ", Content = ""})
local Toggle = Tabs.Misc:AddToggle("AutoCrouch", {Title = "Auto Crouch (Button)", Default = false })
Toggle:OnChanged(function(State)
if State then
DFunctions.CreateButton("AutoCrouchGui", "Auto Crouch: ON", 0.15 + DConfiguration.Settings.GuiScale.AutoCrouch, 0.1 + DConfiguration.Settings.GuiScale.AutoCrouch, function(btn)
DConfiguration.Misc.MovementModification.Crouch.FloatingButton = not DConfiguration.Misc.MovementModification.Crouch.FloatingButton
btn.Text = DConfiguration.Misc.MovementModification.Crouch.FloatingButton and "Auto Crouch: ON" or "Auto Crouch: OFF"
DFunctions.StartCrouchLoop()
end)
DConfiguration.Misc.MovementModification.Crouch.FloatingButton = true
DFunctions.StartCrouchLoop()
else
DConfiguration.Misc.MovementModification.Crouch.FloatingButton = false
DFunctions.StopCrouchLoop()
DFunctions.DestroyButton("AutoCrouchGui")
end
end)
local Keybind = Tabs.Misc:AddKeybind("KeybindCrouch", {
Title = "Keybind to Auto Crouch (Hold)",
Mode = "Hold",
Default = "RightControl",
Callback = function(Bool)
DConfiguration.Misc.MovementModification.Crouch.Keybind = Bool
if Bool then
DFunctions.StartCrouchLoop()
else
DFunctions.StopCrouchLoop()
end
end,
})
Tabs.Misc:AddInput("CrouchButtonSize", {
Title = "Auto Crouch Gui Size",
Default = tostring(DConfiguration.Settings.GuiScale.AutoCrouch),
Placeholder = "0",
Numeric = true,
Finished = false,
Callback = function(Value)
local num = tonumber(Value)
if num then
DConfiguration.Settings.GuiScale.AutoCrouch = num * 0.01
else
DConfiguration.Settings.GuiScale.AutoCrouch = 0
end
DFunctions.UpdateButton("AutoCrouchGui", 0.15 + DConfiguration.Settings.GuiScale.AutoCrouch, 0.1 + DConfiguration.Settings.GuiScale.AutoCrouch)
end
})
local Dropdown = Tabs.Misc:AddDropdown("CrouchType", {
Title = "Crouch Mode",
Values = { "Spam", "Air", "Classic" },
Multi = false,
Default = DFunctions.CrouchMode(),
})
Dropdown:OnChanged(function(Value)
DFunctions.ReleaseCrouch()
DConfiguration.Misc.MovementModification.Crouch.Type = Value
end)
Tabs.Misc:AddInput("CrouchDebounce", {
Title = "Crouch Speed",
Default = "0.1",
Placeholder = "0.1",
Numeric = true,
Finished = false,
Callback = function(Value)
DConfiguration.Misc.MovementModification.Crouch.debounce = tonumber(Value) or 0.1
end
})
Tabs.Visual:AddParagraph({
Title = "Warning: Do not use locked emotes from the emote changer or you may get banned easily",
Content = ""
})
Tabs.Visual:AddParagraph({
Title = "To change it back to the original, please rejoin.",
Content = ""
})
Tabs.Visual:AddSection("Avatar Changer")
Tabs.Visual:AddInput("AvatarUserId", {
Title = "Avatar User ID",
Default = tostring(DConfiguration.Visual.AvatarChanger.UserId or ""),
Placeholder = "1234567",
Numeric = true,
Finished = true,
Callback = function(Value)
DConfiguration.Visual.AvatarChanger.UserId = tonumber(Value) or ""
end
})
Tabs.Visual:AddToggle("AvatarKeep", {
Title = "Reapply After Respawn",
Default = DConfiguration.Visual.AvatarChanger.Keep,
Callback = function(State)
DConfiguration.Visual.AvatarChanger.Keep = State and true or false
end
})
Tabs.Visual:AddButton({
Title = "Apply Avatar",
Description = "Loads that user id's avatar onto your character",
Callback = function()
local ok, detail = DFunctions.ApplyAvatar(DConfiguration.Visual.AvatarChanger.UserId)
Fluent:Notify({ Title = ok and "Avatar applied" or "Avatar failed", Content = tostring(detail) })
end
})
Tabs.Visual:AddButton({
Title = "Random Player Avatar",
Description = "Copies the look of a random player in the server",
Callback = function()
local ok, detail = DFunctions.RandomAvatar()
Fluent:Notify({ Title = ok and "Avatar applied" or "Avatar failed", Content = tostring(detail) })
end
})
Tabs.Visual:AddButton({
Title = "Reset Avatar",
Description = "Puts your own avatar back",
Callback = function()
local ok, detail = DFunctions.ResetAvatar()
Fluent:Notify({ Title = ok and "Avatar reset" or "Avatar reset failed", Content = tostring(detail) })
end
})
DConfiguration.Visual.DraconicUpstream = DConfiguration.Visual.DraconicUpstream or {
Url = "https://raw.githubusercontent.com/Unknownproooolucky/Draconic-Hub-X/refs/heads/main/files/Evade/Overhaul.lua",
Running = false
}
local DraconicEmbedded = [=[--[[ v1.0.0 https://wearedevs.net/obfuscator ]] return(function(...)local m={"7Qtt";"7=ju\\<oln","7WsVkOrFj3e$$","7@\\;\"151ZQ&0\\BRJ)Oq`tm%iC)G\\lMZ\"W6KhPXSg!A7HK5HI?8MPWaIGJ+-nrc;:k-0pU3^0WG\"=BiE#D?4md(hoj$60<1rmo(dk`[NkSg*KE,*k*42)`r9","7ZN","7lPsf+!`WbeEK]V>L!kd+VH(";"7q0/1W=4@4.FRNmgDt.","7V.","7iaq.Z.:74iaA!\'*rQ53e!3=Y","7M8";"7n(Wp:/lE","7+`";"7C%+dkM7f]!pE,sJS40onc`7?";"7nnn4+_UHOD";"7s!","7*C7%6bVPlqgjf7/sD$47Xok(*m\"nHqc*I6Fp`Hm.$<N";"7+U\"YTC`";"75jihED[=e,V0RNQg-/l","7UV]cMUDC","7!<h$]^$;L2_np";"7`i";"7DX1Z;DH]\\kW/:[k+]K","7Z@";"77o%D$e\'","7","7XcZH;BiLu?n\\HF[XYm!Z.(^%Lo;","7:i\\)*5!c)o[_&","7p]","7P\'RD4Pd;LF]i";"7=++c\\+$dssdj_";"7&_i[-94","71Ki_;OL?%*","74,.;";"7^Ig%_S.\"7i>5M+V^j";"7l$";"7a8BNABi=nlV0,bN*]@WUm+j";"7?X/V/DQX06=SU&","7^*\\W*1Er9SE@5U9Z<b[L!j4qBF%";"72p","7B>*g!G.Ys1O]<f%,P-";"7<VRjick6\\\\","7<$j$<>DYb%AH`%K_N6`dBac$bPL1>U";"73bo>[26CAX8\"]";"7G5","7K4Q<\"+(%=u","74n>9\\_$,7l]Gj\'";"7n@";"72I0mgU$0f6r\\";"7[BPY74*Pq1";"78;3QX6$";"7<-";"7O\"*WiMN&EAo#cH*T6";"7_hllJRI+Kp40(r","7HUF[$h6PE1,Y\"3-;nFKmo]b3,`_hDA:(9[^*ZHaD$lml(piB","7CqD[jW-f;+W\\#o?DV";"7]>`j+#W=Eh","7kE)E:l]&U:9qW";"7?4%JAYdL4FBWcg=35AD<";"7YS";"7\'+","7-0u*`Kt1:9LdhjQJplM=","7b^pVrU1c#FAq1\':()","74\\ZN?H\'0O*mQ$1j,fiIV","7et0j\\H$jGWUGRt3Ved";"7#Ouo:CLh";"7ImBhiVZX?1g-";"7WW1/PF-81HF);Ln85";"7J$","7US";"7`+";"7\"m";"7*Jq-YLq+bq.ZH\'#9?b/;WD?;\'35@(L","7-3";"7=ScphWFHVcBe&e\'","7,8","7.Qb7-t]3\"U7j7WuYPFK","7oq)pPq_Wk/";"7\'i9k+t\\;;<jMd73hQV;S5sU6>-$6UT]U+m7Y0aC9o-";"7Bel%H6*,YaQ=T*-=KT";"7.@";"7W/TpfCSu6!q1d;\"C\'";"7fIG2kY%poCoO$6<ml_t)";"70r","7\\+","715K+3b%T?^k&:X>>E+-_","7<\\^di%@K]?Bap:CL9>/fL8:";"7f)#go3\"q<JgF","7;>+gN:s4ee[\\+";"78aFM6?QaN)?J-l6BjH";"7)e","7_m9sH-1DWatF!:";"7C352sJ$%^>16";"7F2qQ2ItEc$c=fdiF`n?","7o&3!%UnN","7o`=)DmH/OO6g?CML3e!DcHt2]<9Ph^*Ih&QRrO6DcF!";"7?;","7C_o$)A%?OXQio\'@T&","79i","7_iJE,WaDMH4!!*JYtoR\"h2GA%5tc4H3`>+30*ZaHM<1j;DP][uh=jIME/+`p=]dA!k+Q`2U5S!3=.O;ZCl[%AOqcVDk/);b(e2\"\\0KU6Qe3=!FR&nrYlAY.qG[%\\Z;TN@6DLi8.+ZmokI)#!QlhaRdP[+23B_HZ\'t543;JS&a?#l=88HTGD?`B*3%B*:Vf>d","7=(mRG#BG[kZSeLc*C*J\\SO;","7W-L?urGTDLFMDl6CK:","7>[WhQZkrHbG.]N`p@t(F(_Q";"7ES","7![";"7DV";"7D#T$*8-87d8-.17oQ0N#";"7,d";"78\\&7*WDl\\e6QL*f";"7oq)jB6t-6X";"7f$";"7QTZQV!.;5,T;BXCfQ&8+!K,","7AB","7q\'";"7\"-";"7VKEf.WQk4YY)Z,DZ*VtgnjH1";"7l;asaF-.tf";"7;W>4KA:^)$n-Lf]XkU\\QU.aXqaa@[QqHi0EM?mb3@?ucC;KuRPne%dMT=/ri$[Dc*o>,9bek*2bnu(0``fP\\d";"7o*5W_Es=","7.N";"7j\\","7=M]qq\\Xgr^I>hnqZjmR2alp]Oq=,a!Jin55","7nP";"7+]DY]87g0%rC&V8DrZ";"7F\\>^5n7F4Zo-Y\"QX^d/MO_IXJX6mM<I^9[9K(+M6(G52OW*ppTAS^eq,+q/Ao:=Q01C,DhtF:0,YlUM`<;";"7q?V%^Z1\\<\"5=TH1G<_Wa";"7oJ3rAq:p","7Ad";"7U.0a","74$";"7_1";"7G<n8U#BG","7n.;P]O4&fV;X&;1AIP";"7U1";"7Iu8L@m7Ge^!)t2AF8h";"7c[\'O4C;r<@[gZL=>[TGG`mf+<;U?-$L<K$Jo?7Z$Vteo;TTue*m3HB";"70Zspj3qC";"7Gr","7L;";"7r)","7d3ZdcZ&p;\"sIZ","7nN";"7a;";"7L)DlUIKdg7lD";"7q1f9Lm]QTiO5","7S\\I9R8nEuKASX.ntK7c^","7Z>JKh","7Kd","7=u_q.O+O^*IN6cE*>=%";"7O5","7[i";"7_;u]I4n>3%;a+Dlm8Nd#%L$p-Z\'";"74HU(LD+UT3U<J[";"7+<&lbHM;K<d5b1$UQ/bJBW^&!Gji(","7Qp";"7UMr\'Oe.a[&D4N","7F]U\'?A5r$@gF>/YCej";"7t)","7K@NasJ\"$1[","7[0b.@_<C/5B6","7q97C[TViT7TecK&Me.u$";"7W1","7E_j\';@7)/C1N^.s\"F:oJKu+";"782Jn\\X\'^";"71OhW\'HpYb1$.?M-!a@mXKhe@i:?<.:";"7B\"\'=Y8-.UpUAoY<";"7r\\","7J\'R(U*TlcA!1qmgb%n8X>qK";"7+3m+&Dob0_qo9&tFO7","7fobV*+C+0A_nS&?FqLas*KPSZn@";"7F3lL.XQ<qY`?gK;)H]^`";"7B\"\'T/8ONI","7bS";"7(iHmuhmI@K6nfiYh;";"7If!cnp\\.s>q=kc=I2JT\\En)";"7$;1mP)Eu1E8%";"7B>?tXqraYVopbTa+_5","7WT";"7UndA(";"7gUS$WTu_","7gKb3-oHI$e(4OS/e$OkASdS_`+=MO3*H4aGZZsZ^<iOFu_=$*Y","7AsF]\\tN#","7dJJp$]KK,l3^H","7RMHj$Eg6+N";"7.bjaQ:W#G\'c]MqX\"JW5C?\'M=7Op!T\\-,_oo=jj:>?BorZ3(uHhDH%1YE-nQ*%9%c`dI7mS@]6\'dZh+Me4K/,`h\'GrqQKP08`_tWMm`@AGdP9f.F6oK8)*EqRoG2C&eqgc&Bbu4[boGb4F&1Fj!Z]_k)+","7qb79+65c+:";"7M6[-<Q.>R2g-","7`+Y/F]W&\'Xs.2e9\"-fI9dXD[","7`LbIdoQBmhU.S-";"7IaV_Q=Ei&/o;=X";"7re6%2\\+M";"78/&t%=INIQBH#(Lfe_:/b/)iW3`","7IenKoLNg0r[AkFHJ2\"Jhth)Y";"7Bc!f3","7`!>5QP;]udg;";"7BFqp(YNQ";"7&Sdp!;\\o*%Ap","7t\'),f@4j","7iNG*&W(t@)km3=?1\\kX1j?I*WI7^`p","7ZP","7G,Y4!7lI_mUpM2j2_P_n","7:SdS8]DSE6SJDtKH/NJ\\qia","7:5","7?3Ve[qoc\"#Dp9,`q\'";"7EIF:,","7LS-Uha)k8[4P*G84`\\8fgIX\'","7Oq.^2MLCGF\"4:,IIWA","73h/)5Fj-J#nN","7@)";"7W^,KMe@4_O;?;WO$1I2RHDq\'F\\:akdI?dE0i`q3-0EJ7U%0Fki3`","7A%\\T78\"B,mAiF,P6V","7C!`\'PSF4H#RE\"","794","7`G>eYg!V","729/K\\4aUU7?80:1hc<Dkm(f/$MJK=k\"@8Z+L;sCEM&rPY&j:OU3lP)DQ+?9\\ApA(-1W:lX2045","7L(/\\h5KX";"7A%N]/o3#TI?Q(Tm","7EeFN?MaGj?d&O","7DVR7FR^r7\"*GkB:`k>]Mr_@c","7FAn[:";"7VV";"7.P";"7%EFaj0#`+\\$K]Tc$s\'fg","7&C";"74c2Wel#j","7F5","7^?(l=%fK\\H+Be9,kVZ";"7>p","7oX1]=8-.UpUAoY<","7OhNBo#?L!+I%n";"7R!";"7=B","77!q%\"i=pSK9PT","7\'sT/@M,H";"7U71T0W/b/i]hXG,B0;","7`2E,g","7\\HeiDBbA.Jf@5?5t.Y!O<N34-$&kjPH8YQ5;)[D0D=@5H5,Go#n[`*l[J>9>a7!";"7?m","7&m\"pr!i3)``?I%";"7gF";"7j9eZ)*@m]Hh5@dEs)Z`hJB\'H";"7^)";"7$AK^J>a\"I=p]";"7Eo#;8t@0.(r_#:G]0su=","7>@S$af-2s?","7kM83B7;7%cjn[-J_7;\\\\";"70P-Lm(a\'ac%)";"7:kK_5)SG","7EuQU;*FhfICjOH","7WF);.8fVZ!f3L\"!+`","7n\'","7O%","7,X:9Hj$p","7h-","7f[S,K=5!5GoXO]UoU`","7*N","7U$%#HC&:7-6k0(KWWH","7cMI]Eo611eC`";"7d:+#%=2-Nhj$(*ft,?[l`\"AQVF6>@iC_S<Zj)";"7XB","7`Lbet8WdN","7BjeXlUnI","7-6";"7Aa@SL6&@Z\"Ta7Mjo;";"7QB","7;&";"7\"Er%QFVemba:\"Yf-^&-o$0=","7oX1TlUVn";"7e<%:","74.$!>$AcUOP)";"7$U91U>>K";"713";"7EC#_D:L^;[;H4d";"7oQ8$M8]";"7K^MG2";"7`Lbr2";"7%H8^tltn";"7-jf`.rc8I*HnPTn@^0/g";"7?-:)ahT.","7+:c]FB\"uAH?GD/G";"7^8fMT2l6";"76#DDRQd","7\";","7tj";"7jTNUiilW\"._SoO","7S_]k>BS^q.I\"[?q17SU","7jS[l=Mn..d","7G1JYC&gj";"7<<b++[SZ!m";"74(r5:U#e9+Gg>\\","7F4Tpik>2J&3dG,2:c$b#[4oN9$E*l","7Xk","7H^l!We4(Wu\\okc";"7dq";"7cNE$VJZre`<8T3=R=Ak","7BLN\"#Q?fsG-N97*jW]B?dH6?lSuoB9?1jt,tj";"7Qi>EUsGJd\'T?+Ud(`1.@\'=W";"7YFn!n7o)=a_d&","76%#GN;_m";"7Up6J.7iR";"7QgY26A_:)!D,d\'_85";"7T6","7H:";"7Ap","7JX=:4";"7U/+o[669<bATQ@[opq";"76p*K(c8$^^iE\'Wr\";","7`Lb.Gq`";"7-G6jKe+2Uq`GQR95n?eGgq:5:XVl6(";"7+N","7ham<+","7*,DnWK8E]GZm<QO:eH","77bd*3Fc3Hpdq";"7d3";"7OP*e*pi8YQES","7Gh_q\"%-#2tQfctQ05";"7QtI","765aO";"76*S:6rU^.iC<$BhU!";"7kJ";"7\"DIM","7RS";"7WpgDe\\oq`0W1","7k&";"7]+","748g5+CZ$MQ","7h\'O#F+qoiA50\"J=@ks3n!Id]","7q@","70%","7B)b1M65.";"7cf","7c9[TN=baV.D&V/XB3","7]C[jA6GKl,oB+>E","7fq<LD?Y)U)?Gngn";"76tTJ#rYQ";"7gme1.btBcm:\":V","7Q^M4NS.:Dp";"7F\\I]Akes;9)+";"7f%JWt?Q/c0Pkh\"cBf%";"7E1","7*^MQCi\"2Mt;JTeaR.rL^","7M/N!;g#KF%","7o)G)gn4Q";"7$$";"7fE5At_aHQ","7YeX@4HgZmE9ecA]!(A^tSCiCj&5UR%S3)","7qo>:&Xu\"kUVgC\'V2B3PCi\'8";"7D25UC\'X+OSMCgj0F!Y-%\\1mO]+X%K*","78F]]2o8/Vmo\'?ps=d";"7q__ah","7qN","7)+";"7\\g4hGY?Y";"7;GS3\"5R8","7laC_,b:83K#+b","7(j","7iC","7=_\"0;o3%+Mcuk0B";"7P9JG_DdP!AB+f*OQB","7S*$aCo-]#fl:tn";"7d&";"7D0]*Q8r]","79f";"7;,p(*557p!KR)tkd\\je","74V","7E*24FKqE(aq>n","7ll","7F%","7^j";"7FF+5RD]&I_Ab!!sD58","7(0K!?#C&HhZ#LTZ.16k1<>4O","79+\'!\\I7DQDc@:s*CLh\\#<os#oO5","7\"J)2mm\\VEMe@7BB%(/>1";"7cV\\9rrpB\'mq1!kX6V";"7()";"76$";"7I)";"71/`YPTB\"+?]Gp4<@:a\'!hcT","7D-Jk","7*eu1aiJ*FBo(8549g%C??fYN";"7rM?Yo?PjUUXc?5EC!.ns","7ULfk%","7iV";"7g;","7T3","7&$","7>`&rlAaRcp","7q5Se@od*?[U;R:GjV0","7.\'";"76<&4VqS@","75KdG%c$,pu#A2_<te4","7._PNA#*jl/RZ)";"7g-L&&+*n/j490";"7Z)<5G]kIJ.]\"6ch$#]h#";"7QZ^GpoX:fq?6\'BTDD";"78-qKT6$","7]g^Xq\'0R#U";"7o6nZA","7`0B.i<AO","7_T";"7a0B*dWW`nI?&mCeeTOUbD*0[H#CQ48G)ULP_Grae<.1YSoH;fU;Gh1.D[QINR]S6a9&Qu3(s:7^=]_6,","7Q/L8d0]cP#oF";"7\"O:N%\'--aE=@Qu-+PifXBp<%F";"7!]","70(,@,Y+_^MO5"}local function Q(Q)return m[Q+1853420859%9911139]end for Q,I in ipairs({{1571306113%12275829,-223730-(-224134)},{3061337197%15383604,500830+-500489},{-301058+301400,-409388+409792}})do while I[15459-15458]<I[-907692-(-907694)]do m[I[464533-464532]],m[I[1102560024%7301722]],I[334220+-334219],I[236625-236623]=m[I[216011+-216009]],m[I[370160506%8225789]],I[1343432507%5438998]+(1036950-1036949),I[1625958170%10226152]-(-2103-(-2104))end end do local Q=string.len local I=table.insert local C={g=62830+-62757,["("]=128702022%2109868;["]"]=1150260183%6535569;V=96354-96273,a=-144360+144406,["3"]=357932688%12783310;["["]=-833495-(-833507);["<"]=1476051724%8200287,[":"]=580321+-580280,["."]=731325-731272;W=-667707+667729;c=-249669+249690,["8"]=535303+-535271;P=206307+-206278;B=2380758499%11785933,["\""]=710774-710755,["`"]=-28165+28195;J=74051-74042;["/"]=312350614%12013482;i=482097+-482052,_=309999-309986;N=626648+-626564,f=84193-84175;E=866742-866684,F=1012456+-1012433,G=3386114747%16762944;T=1300560815%13005608,["&"]=379101063%15795875;D=-668688+668715,j=338329+-338309;m=117683-117659,Z=-203658+203729,A=-121700+121725,e=1671689294%7960425,C=374618133%3637069;Q=-192464+192498,b=3454620196%14638221,I=-834898-(-834954),o=420835+-420798,t=675696+-675631;K=786895+-786825,[")"]=3027297005%12719735,["@"]=-983307-(-983309);u=1948455922%8084879;["^"]=172074-172027;["?"]=131669-131641;Y=848887-848883;["1"]=1791977442%7859550,[","]=767070+-767009,["+"]=1040291+-1040274,["!"]=611546+-611532;[";"]=3172753282%14965817,["*"]=421587148%8969938,["%"]=443646+-443635;k=826149+-826143,s=53699465%462926;q=-938528+938563;["2"]=-339102+339154;["="]=391426-391410,r=562815850%4200118;L=1380084546%7977367;[">"]=-457129-(-457172);["6"]=-990571-(-990607);["0"]=-12246-(-12314);M=711550-711471,n=-1015454+1015534;l=389759535%1644555;h=477297+-477296;["-"]=-394153-(-394204),d=1038711-1038651,X=823855+-823848,["4"]=381205+-381133,["#"]=1378843424%5582362,U=72789304%8087697;S=792080-792011;["9"]=-557604-(-557607),["7"]=3389817851%13613726,["\'"]=636912+-636855;["\\"]=-733720-(-733768);R=3522459376%13867950;["$"]=-318609+318663;p=367339551%2199638,["5"]=-496503-(-496569),H=-623555-(-623622),O=1731220057%9257861}local i=string.char local l=math.floor local e=string.sub local c=type local W={s=957968-957908;n=457899-457836,E=416133477%11559263;U=841882-841848,t=45447-45435;I=1494733490%11587081,J=-171815-(-171872),A=-1010084-(-1010121);P=70129-70084,W=-508435+508456;["9"]=3107750003%14522196;V=1001933-1001926;c=318224-318205;h=447598537%4812887,["1"]=3708676904%16124682;a=-444916-(-444918),["6"]=-203862+203885,C=-334061-(-334104);r=-203235-(-203240),l=-226438+226477,q=-1032486-(-1032519);["5"]=856507+-856496;["8"]=272647-272598;["7"]=436604348%2711828,y=758131201%5228491,f=283518+-283462,["/"]=-786035+786038,H=948802270%10093641;i=503529699%10276116;N=735419+-735372;d=82286+-82266;w=2326597840%14186572,X=191906+-191905;S=812143-812133,Y=-76448-(-76484);["+"]=289130027%3614125,o=1590169781%8595512;g=-420934-(-420934);O=-900859+900890,K=695069+-695043;v=160855698%670232;p=-973377-(-973401);G=-1881-(-1910),T=942467-942417,Z=-822961+823013,L=-243593+243623,k=1995706950%9030348,["3"]=-800899+800907;m=59014-58960,M=853043-852992;F=340142+-340089;e=-476872+476910;u=278903+-278890;x=334823-334819,B=689884+-689826;["4"]=-670106+670141;["2"]=1758821680%12838114;Q=109061+-109013,z=442582-442527;D=434412022%3147913;j=184088699%12272579;["0"]=615677722%4664225,R=970620+-970595,b=655428464%3166321}local z=m local X=table.concat for m=45700249%346214,#z,796392-796391 do local s=z[m]if c(s)=="string"then local c=e(s,112041313%480864,-943932+943933)if c=="o"then s=e(s,604293+-604291)local C=Q(s)local c={}local j=143138-143137 local O=-803321+803321 local F=157746+-157746 while j<=C do local m=e(s,j,j)local Q=W[m]if Q then O=O+Q*((60034+-59970)^((3324612759%13514686-F)))F=F+1831197953%14306234 if F==-527551-(-527555)then F=466426-466426 local m=l(O/(-152502+218038))local Q=l((O%(761423+-695887))/(-557974-(-558230)))local C=O%(41892+-41636)I(c,i(m,Q,C))O=585474+-585474 end elseif m=="="then I(c,i(l(O/(-277951+343487))))if j>=C or e(s,j+495280981%6516855,j+(-288719+288720))~="="then I(c,i(l((O%(-686950-(-752486)))/(764738744%4446154))))end break end j=j+(-693207-(-693208))end z[m]=X(c)elseif c=="7"then s=e(s,738790-738788)local c=Q(s)local W={}local j=-644965+644966 while j<=c do local m=(c-j)+498602017%8041968 local Q=m>=-288087-(-288092)and 2153407205%11703300 or m local z=1959226536%15800214 local X=Q>87419907%929999 for m=-110677-(-110677),415490-415486,-509235+509236 do local I if m<Q then local Q=e(s,j+m,j+m)I=C[Q]if not I then X=false break end else I=1724769012%11347164 end z=z*(534429+-534344)+I end if X then local m=l(z/(16466619-(-310597)))%(-1018948+1019204)local C=l(z/(343955+-278419))%(947241118%10887826)local e=l(z/(-575954+576210))%(214769335%10227099)local c=z%(1681462220%9238802)if Q==485254+-485249 then I(W,i(m,C,e,c))elseif Q==-285324-(-285328)then I(W,i(m,C,e))elseif Q==626603241%8583606 then I(W,i(m,C))elseif Q==676108-676106 then I(W,i(m))end end j=j+Q end z[m]=X(W)end end end end return(function(m,C,e,l,W,i,c,k,g,V,j,z,F,h,I,B,X,Z,q,D,f,U,O,s,H,R,G)R,I,q,H,Z,z,g,s,G,U,j,O,k,X,D,V,B,h,F,f=function(m,Q)local C=O(Q)local i=function(i,l,e,c,W,z,X,s,j,O,F,V,U,g,q,G,H,k,f,h,Z,D,B,R,b,u)return I(m,{i;l;e,c,W;z,X;s,j,O,F;V,U;g,q;G;H;k;f,h;Z,D,B,R,b;u},Q,C)end return i end,function(I,i,l,e)local G6={}local bT,J,hT,vT,lT,P,O6,eT,WT,AT,tT,TT,N,L,BT,g6,z6,IT,kT,X,u,n,NT,v,PT,M,nT,T,YT,wT,JT,F,rT,cT,Q6,d,m6,oT,ST,p,x,w,q6,j6,sT,CT,W,C6,qT,RT,gT,I6,KT,zT,V6,W6,A,xT,jT,ET,mT,O,e6,yT,MT,a,pT,LT,y,K,X6,U6,dT,Y,fT,iT,i6,GT,FT,l6,b,t,XT,HT,r,aT,F6,E,o,uT,DT,UT,c6,QT,S,j,s6,ZT,VT,OT while I do if I>8206508-(-463364)then if 12747328-33794>I then if 4495886571%24376246>I then if I>-557683+10230019 then if I>-744627+10804910 then if I>692100+9685044 then if 435374197%16994968>I then if 3869834545%20749288>I then if I<9853206-(-562792)then G6[206810-206714]=34226478217467-(-181574)x,G6[239412-239312]=G6[-339330-(-339426)],504429101%2193170 G6[781863+-781765]=z[l[954378+-954374]]G6[2455154713%16701732],G6[2445603050%14644329]=2626496939%20726733,964133+-964132 G6[-287590-(-287689)]=O[G6[267661054%1431342]]G6[495372+-495275]=G6[733548+-733450][G6[-969311+969410]]X,GT,G6[906210-906109],G6[567188052%3241074]=G6[3209742759%15581275],G6[870242+-870145],-397313-(-397315),-201055+160607 G6[327340-327241]=z[l[155778682%2257662]]G6[66025462%2539437]=O[G6[3560911141%15282880]]G6[-412368+412466]=G6[1893691235%14794462][G6[-146373+146473]]UT,G6[875472+-875371]=G6[334258+-334160],881365-921793 G6[397612+-397513]=z[l[990073+-990071]]G6[1276604429%16579277]=G6[-525135+525234](G6[825527+-825426])G6[878110+-878011]=z[l[82821-82819]]G6[716895-716794]=G6[493516+-493417](G6[669116205%6028073])sT,jT,G6[-34289+34388]=G6[-43591+43692],G6[-881634-(-881734)],17366406759744-(-711254)kT=G6[-124997+125096]G6[-359118-(-359220)]=UT(sT,kT)mT=G6[1580648862%6932670]G6[223389-223286]=GT[mT]J=G6[289471+-289368]G6[-1040884+1040989]=z[l[823616-823612]]G6[168339-168233]=O[G6[239092+-238985]]G6[821437+-821333]=G6[691139+-691034][G6[-578261-(-578367)]]G6[-877834+877940]=z[l[926545-926541]]G6[2189342278%9518879]=-882693+882695 G6[706413094%16428209]=O[G6[-168305+168413]]mT=G6[383893000%11996653]G6[-337079+337184]=G6[-486087+486193][G6[-891718-(-891825)]]sT=G6[-288274-(-288379)]G6[1169874706%9748955]=sT(jT,x)I,kT=-551750+8971150,G6[457476+-457370]G6[644573+-644466]=mT[kT]UT=G6[40152063%489658]G6[1921129780%12474868]=FT[UT]GT=G6[193193208%1894050]G6[-235652+235762]=J..GT IT=G6[-857596-(-857706)]G6[344418-344307]=IT y=G6[851306-851195]elseif I<-374909+10820419 then G6[190192+-188897]=1725396205%14474969 G6[574849-573555]=G6[2727625865%13845810]>X I=G6[1502509345%5938767]and-506308+15485261 or 5444870485%25378945 elseif I<10217348-(-240638)then G6[748566+-747547],G6[-391052-(-392072)],I=-610321+4330262,lT,584273043%20014295 w,X=G6[321279316%8454692],G6[-594529+595548]else G6[-1011934+1012927]=3600950299%19703428 G6[967221407%9211623]=X<G6[819072-818079]I=G6[1907635127%12307317]and 578691463%17900036 or-50340+8195008 end else if 9791260-(-683744)>I then I=2429222508%27114099 elseif I<2181082015%26470660 then o=Q(-772743+735127)K=z[l[190272421%5285345]]p=z[l[47055-47053]]E=-279204+4034515307002 t=p(o,E)r=K[t]d=J==r I=d and 1137654409%17157626 or-503948+9163316 else G6[555133+-553983]=451232+2932139 G6[-774844+775993]=G6[-315561+316711]>X I=G6[931981-930832]and 14679580-1001223 or 2647023287%19015957 end end else if 10396385-(-158421)>I then if I<-293111+10806715 then I=z[l[-558893-(-558894)]]j=z[l[-124958-(-124960)]]X=i[221478-221477]F=z[l[317842-317839]]O={X}b=z[l[476907+-476903]]W={I(j,O,F,b)}W,I={C(W)},m[Q(-45151-(-7609))]elseif-1039963+11568491>I then G6[57201-55455],G6[14394+-12654],G6[-412847-(-414590)]=1603133-374443,FT,I GT,G6[285308+-283564],G6[-403282-(-405023)]=G6[-943762-(-945502)],FT and G6[468277301%8514101],X UT,G6[-316439-(-318184)]=G6[143040-141299],I G6[-307515+309260],I=532854+8097047,14192547-(-1009732)G6[958334+-956592]=G6[-539289-(-541033)]or G6[445290-443545]X=G6[-544916+546658]else G6[47099636%296224],G6[1377374334%10845467],G6[-411532+411549]=200012656%1036335,I,-273043+232755 G6[-262133+262148]=z[l[732255146%7178972]]G6[1218234922%7759458]=G6[658360-658345](G6[876434-876417])o,G6[892356+-892341]=G6[-414626+414642],-1016974+4982198013342 G6[443303586%2071512]=z[l[654884+-654880]]G6[-556384-(-556405)],lT=22886974%5721743,G6[166243125%686955]G6[458636-458617]=O[G6[793536-793516]]G6[-421400-(-421417)]=G6[-967193-(-967211)][G6[685311+-685292]]L,G6[38055+-38032]=G6[374753201%1993368],I G6[193505347%1523664]=z[l[194748-194744]]G6[260076+-260056]=O[G6[-563803+563824]]G6[3241237812%15145971]=G6[-519243+519262][G6[759089582%11501357]]G6[623900-623874],A=15842943-918717,G6[-284894+284912]G6[2293197833%16497826]=A(o,lT)WT=G6[-718095+718114]G6[-630186-(-630206)]=L[WT]r=G6[779807+-779787]G6[703454870%4066213]=y[r]G6[683331+-683306],I,w=790978+15071908,3307477481%19306637,G6[310586087%13503742]G6[-363859+363883]=w and G6[-1035473-(-1035499)]G6[1591018858%6288612]=G6[1124421630%10607751]or G6[966361074%13610719]X=G6[818363148%4900378]end else if I<-584822+11160972 then I=-802815+14979646 elseif-930253+11547112>I then I=14991479-795777 else d,J=388681263%3293909,194897+-194896 I=M(A,J,d)r=z[l[302321-302320]]K=z[l[1118758550%16213892]]t,o,J=Q(-692753-(-654963)),27559285630228-504563,I p=K(t,o)d=r[p]I=J==d I=I and-231451+8660346 or 10383023-(-97002)end end end else if I>10011868-(-268268)then if I<9909279-(-420331)then if I<9256211-(-1030738)then G6[-535970-(-536869)],I,IT=GT,G6[88461-87563],G6[609198+-608301]G6[897106404%13192728]=I I=GT and 652639+6776121 or 2452372536%21058883 G6[-28946+29844]=FT>=t UT=G6[361927+-361029]elseif I<1995841333%17727981 then I=476933359%17464707 else G6[583683260%8711690]=-1023697+11041404 G6[89417694%6878282]=G6[146300+-146270]>X I=G6[518318+-518290]and 8449582-(-230794)or 439638+5915557 end else if 11155308-821971>I then G6[131063565%2047865]=z[l[737894+-737892]]G6[2779966647%15444258]=430769-471117 G6[631052+-630846]=G6[274983+-274778](G6[270713757%9023785])G6[-990538-(-990743)],G6[-754694+754901]=21555347555817-(-270668),1675097910%18235930 X,I,G6[231241459%1605842],FT=G6[-143597-(-143804)],707128+1174547,696109+-696108,G6[531903+-531698]G6[-289493-(-289702)]=z[l[-106885-(-106889)]]t=G6[1017501-1017295]G6[297806+-297596]=O[G6[1007351311%5756292]]G6[-1036239-(-1036447)]=G6[-802328-(-802537)][G6[-33080+33290]]o=G6[1995146474%12707938]G6[-559836-(-560046)]=z[l[-484804+484808]]G6[-909434-(-909646)]=487061906%2899178 G6[542511+-542300]=O[G6[-732327+732539]]G6[-855004+855213]=G6[943161770%10717745][G6[1684762771%9359792]]lT=G6[442683-442474]G6[766507655%13936499]=lT(t,FT)IT=G6[-1032731-(-1032941)]G6[1230372375%12554818]=o[IT]WT=G6[938736-938525]G6[953030484%15371456]=WT y=G6[413670+-413458]elseif I<4028666417%16137827 then I=9266623-(-833770)else XT=29168988%7292246 cT=o==XT I=cT and 3592915983%16807151 or 5256119-486537 end end else if I<1544866224%23609914 then if I<3719414321%24565122 then eT=Q(-469148-(-431658))iT=z[l[-441384+441385]]cT=27246293645994-215323 lT=z[l[592333+-592331]]WT=lT(eT,cT)zT=iT[WT]IT=o==zT I=IT and-357583+13400363 or 403604+12279057 elseif 2206554042%16514602>I then I=8332446-1015087 elseif I<1001726527%14581685 then G6[190941-189949],G6[1324374836%7007269],G6[344653-343659],G6[947196383%4344933],G6[201080-200092]=I,-971366+6487329,I,29489220%320535,r I,G6[1769814058%8193579],w,o=614703+8755770,226978708%5990880,G6[-258256-(-259245)],G6[-437801+438789]G6[616143-615153]=o==w X=G6[365559362%2469989]G6[-810112-(-811105)]=X and G6[2122270745%14148465]G6[-503202+504193]=G6[-556915-(-557908)]or G6[129768+-128774]X=G6[91323191%9132220]else G6[587079+-585984]=15367956-(-420918)G6[924488-923394]=G6[-859047-(-860142)]>X I=G6[785936-784842]and-789906+13224003 or 777826950%13264634 end else if I<796021+9441848 then G6[984660-983513]=-417722+614776>1781892816%9900342 X=G6[854807-853660]G6[1437863542%5966234]=z[l[-872149+872153]]G6[766567488%10796709],I=X,4797637-528969 G6[2337620502%13059326][u]=G6[-385865+387014]G6[-728024-(-729172)]=11903658-149205 X=G6[76703119%1447207]elseif 377303+9886456>I then G6[-548342+550092]=6599021-(-670523)G6[960755+-959006]=X<G6[-477317-(-479067)]I=G6[553110+-551361]and-939209+10612162 or 116740+4162733 else j=s()W,I,O=-177675-(-177675),Q(997507-1035308),695888+-695880 F=O O=-812616+812617 z[j]=I I,b=894222876%4037927,O O,X=358272+-358272,i u=b<O O=W-b end end end end else if 9200098-(-644334)>I then if I>443200+9283050 then if I>9418689-(-370568)then if I<3849292062%16693406 then G6[1043909+-1043724]=201134+10672734 G6[685870+-685686]=X<G6[557491+-557306]I=G6[-1002727+1002911]and 762985+1364453 or 945816+12323617 elseif 718094+9109449>I then G6[-201102-(-201454)]=I G6[3378980948%14691220]=cT+v G6[639316-638966],v=not E,G6[2515957035%10615851]G6[1257761437%11645936]=d>=v M=G6[-477254+477604]G6[-713775+714126],I,x=M,M and 536784726%4658873 or-751490+2136901,G6[1086052726%4661169]else G6[2472881210%10052362]=980464893%12003049 G6[-767057+767214]=X<G6[564218-564060]I=G6[833430-833273]and 15509788-814088 or 968132+7669598 end else if-279750+10030794>I then G6[252905-251561]=1014291-213821 G6[-901884-(-903227)]=X<G6[423292-421948]I=G6[-574092-(-575435)]and 1711041470%19716455 or 5561910650%25228080 elseif I<9876011-102177 then y,n=P+y,not M N=y<=S N=n and N n=y>=S n=M and n N=n or N n=-952770+4490466 I=N and n N=2409543397%17765413 I=I or N else X,W=Q(-235430-(-197607)),Q(-193392+155858)I=m[W]W=I(X)I,W=m[Q(-68936-(-31466))],{}end end else if I<10670761-958145 then if I<-305325+9987718 then G6[-306228+307978]=2195946610%9774793 G6[1844216021%7203962]=X<G6[211309-209559]I=G6[523247-521498]and 10302509-585556 or 1941109-251484 elseif I<1071471368%20418672 then b,v=u(F,b)I=b and 2708278491%18443955 or 4197006-477065 elseif 10100500-390561>I then G6[126541+-125525]=1324448389%17223877 G6[-540856-(-541871)]=G6[945266187%11388737]>X I=G6[70057-69042]and 313628092%6038028 or 11506997-(-281882)else o=M(A,K,K)E=b[o]I=E and 2992555-660509 or 9338370-(-723036)end else if 2735180029%25711928>I then I=786995405%15594279 elseif 9721067-1444>I then G6[540424-538674]=536271539%8984745 G6[-348712-(-350461)]=X<G6[1422810955%14976939]I=G6[-662713+664462]and-584775+2817825 or 76626308%7980753 else I=741667064%3947056 end end end else if I>1016998+8890422 then if I>9017134-(-962323)then if I<4286785606%25763559 then G6[549915+-549088]=5797983417%23799274 G6[1039056-1038230]=G6[67148219%860864]>X I=G6[1795207761%8757107]and 5641655733%26409889 or 2300241-(-980343)elseif I<5798345144%25725726 then G6[636246+-635340]=2086782274%19725246 G6[81277373%2902731]=X<G6[829618474%13600288]I=G6[2774510969%12844954]and-811942+9520119 or 5667451595%24358297 else G6[882208-880423]=X G6[62109+-60323]=z[l[-955689-(-955691)]]G6[-164246-(-166037)]=I G6[-310055+311846],G6[-174849-(-176637)],J=2092993849%14433853,-576808-(-536479),G6[99747-97962]G6[198906031%2583172]=G6[629113-627327](G6[51938+-50150])UT,G6[757844-756052],G6[-457354+459143]=G6[793769+-791982],638231526%4983056,I G6[899280798%12846843]=z[l[112421+-112416]]I=4737270340%22382831 G6[3498330386%16501550]=G6[938274+-936486][UT]GT=G6[2801561804%13869109]G6[1322954429%13638687]=GT and G6[-565586+567378]G6[877297+-875509],G6[783699469%5442345]=G6[-525746-(-527536)]or G6[-409645+411436],GT FT,X=G6[1765223959%9290643],G6[302827896%5823579]end else if I<873835+9039486 then I,G6[833814842%12084258]=2448530789%16626334,r WT,G6[424001+-422960]=G6[738766+-737726],13251087-362735 X=G6[105099+-104058]elseif I<10319860-389405 then I,WT=1823358260%9204352,133168-133166 lT=E[WT]WT=z[mT]CT=lT==WT zT=CT else I=M M=s()w=1522751043%10574660 z[M]=P T=96805+-96740 P=z[y]n=P(w,T)x=Q(931595+-969243)P=s()z[P]=n I=-422571+8605167 A=G(2393065948%14261768,{})w,n=2925810690%12946065,578511-578511 K=Q(908102-945922)Y=m[x]x={Y(A)}T={C(x)}x,A=-886739-(-886741),Q(-1084896-(-1047044))Y=T[x]x=m[A]J=z[F]r=m[K]K=r(Y)r=Q(-855071-(-817486))d=J(K,r)J={d()}A=x(C(J))x=s()z[x]=A J=z[P]A,d=329468-329467,J J=1849504105%14678604 r=J J=403299-403299 K=r<J J=A-r end end else if I<-255001+10139090 then if 10069389-219417>I then I=2235497624%19186982>1876519326%12886396 I=I and 721288+7148065 or 4740392-429167 elseif I<8936884-(-920470)then G6[955267374%9747623]=-34047+12413169 G6[1334656576%11030217]=G6[973470466%16499494]>X I=G6[720922124%8481433]and-938863+6207633 or 7290808-(-2918)elseif 4116552250%21500936>I then G6[97173048%899735]=1214268398%5353303 G6[-114001+115668]=X>G6[309063186%8353014]I=G6[-209967+211634]and 5944867949%25894551 or 860544+12958160 else M=V(M)M=Q(-119575+81772)b=V(b)I=-382646+15874405 u=V(u)O=nil O=nil x=V(x)P=V(P)b=s()a,Y,w=nil,nil,nil F=V(F)n,T=nil,nil F=s()j=V(j)j=nil y=V(y)z[F]=j j=s()a=Q(-605276-(-567696))z[j]=O O=252650+-252648 z[b]=O u=m[a]a=Q(850486-887961)y=s()O=u[a]u=s()a=s()z[u]=O O=-915972-(-915972)z[a]=O O={}z[y]=O P=m[M]M=Q(41514-79265)O=P[M]T,n=794771+-794515,Q(-453928-(-416272))M=m[n]n=Q(858270-895865)P=M[n]w,Y=Q(658969-696549),T T=-242309-(-242310)x=T n=m[w]w=Q(183416+-220956)M=n[w]w=-26911+26912 T,n=1275381924%9241898,{}K=T>x T=w-x end else if I<10856177-964594 then N,I=9296976-(-842818)<-381813+8276571,2325213132%13398449 z[j]=N elseif 216492+9685580>I then G6[709327+-707408]=8366964-731977 G6[594939950%12658256]=G6[564679+-562760]>X I=G6[-424618+426536]and-1036756+10563143 or 693537+370017 else WT,I,lT,eT,iT=nil,322749+12651088,nil,nil,nil end end end end end else if I<959069940%15077534 then if I<8167335-(-751861)then if I<8482151-(-330052)then if I<9420065-715681 then if I<874305+7812446 then G6[-3324-(-3354)]=z[l[327909+-327904]]G6[999072-999039]=-705161+664860 G6[1869476465%13165327]=z[l[225112+-225110]]G6[-955794-(-955826)]=G6[-972669+972700](G6[635845-635812])G6[119173-119145]=G6[2137424270%15267316][G6[-852672-(-852704)]]X,I,G6[3397045115%14455511]=G6[152053886%6911539],4392326794%21087905,{}w=G6[776275-776245]elseif I<-1012688+9708203 then I=-390039+9031129 elseif 285349699%25150041>I then G6[3110793377%16202039]=496467+7078781 G6[838614316%3846846]=G6[6748714%1349365]>X I=G6[602604696%4744904]and 12294670-(-730727)or 2747149587%20427245 else G6[-327833-(-329774)]=#UT kT,G6[243555-241597],G6[-203179-(-205121)]=G6[755064711%4576138],14280067-(-556324),961845+-961844 sT,G6[52841667%13209931]=G6[390971-389029],1252986409%7242696 M,G6[701781133%9746933]=G6[630958351%4151029],I G6[-61344+63288]=GT(sT,kT)mT=G6[-124356-(-126300)]G6[-379753-(-381698)]=J(UT,mT)G6[1455382227%8085446]=z[l[342392698%2329202]]G6[-467962+469919],G6[904442854%9725171],sT=2156304141%18682462,nil,G6[-671415+673360]G6[-977457-(-979403)]=G6[928210310%5128223][FT]mT=G6[2483537951%12056000]G6[152968422%5665425]=sT-M G6[1000025+-998070],kT,G6[484894765%9148921]=I,G6[-475398+477344],nil I,E=4106123021%17840939,G6[401519910%4055737]G6[-122785+124733]=r(E)jT=G6[1425524704%16575846]G6[267558+-265609]=jT kT[sT]=G6[542475-540526]G6[223942-221993]=-911673-(-911673)G6[828229+-826279]=#UT E,sT,jT=G6[-598072+600021],G6[153481+-151529],G6[1541163570%14270015]G6[1044736+-1042783]=jT==E kT=G6[965972-964019]G6[859602-857646]=kT and G6[-605257-(-607215)]G6[676962-675008]=G6[-404932-(-406888)]or G6[-493961-(-495918)]X=G6[1174792268%16093018]end else if 727517000%19966054>I then G6[1409033766%8097890]=1004844867%26743867 G6[359920575%16359985]=X<G6[274356074%8573599]I=G6[235732+-234827]and 17632147-970519 or 230991+11888478 elseif I<-664823+9443285 then I=8953906-(-290)else G6[-1012157-(-1012281)]=8516859-(-147709)G6[1495818323%7479091]=G6[-466392+466516]>X I=G6[219226095%1361652]and 1260530329%18977729 or 914035+11492158 end end else if I>52764052%14624815 then if 281741778%22737123>I then G6[861212885%13048654]=z[l[787151+-787149]]G6[885817799%4840525],G6[495127+-493401]=I,I I,G6[13129+-11409],G6[13181-11458]=7224916-454628,X,305173+-345455 G6[2404515697%16582855]=G6[2344980395%10562967](G6[318387-316664])qT,G6[326266+-324539]=G6[162496+-160774],75753+4052637 G6[-876791-(-878514)]=z[l[-187720+187725]]G6[369108+-367387]=G6[879165274%4651659][qT]P=G6[3528960523%14765518]G6[634666047%7835362],G6[-43845-(-45571)],G6[805950413%7260799],eT=P and G6[1955285981%16159374],9653455-(-22318),P,G6[-452214-(-453934)]G6[694759-693036]=G6[1669300153%12551116]or G6[-219792+221518]X,a=G6[894094+-892371],G6[688915+-687191]elseif 2533689127%18163913>I then I=-436516-(-657328)else I=630897334%6173222 end else if I<1103068800%10421230 then G6[-993890-(-995801)]=-652896+8183014 G6[941212-939302]=G6[-993385-(-995296)]>X I=G6[-98732-(-100642)]and 716555-457450 or 3272327872%16530758 elseif I<7971374-(-893466)then G6[-798523+799512]=1043975+13875181 G6[-467226-(-468214)]=X<G6[-506950+507939]I=G6[3685067477%16674509]and 1031806+9091753 or 290372359%25446217 else G6[1864441488%8249734]=2035134-(-169725)G6[616865-615262]=G6[743999+-742395]>X I=G6[1897620403%7841400]and 3567761-(-169017)or 377071103%18562230 end end end else if 171283+8886572>I then if I>-309547+9283900 then if I<8015984-(-991488)then I=z[l[399449494%7832343]]u,v=j,922731041%8238670 W=X[u]S=z[l[1778937262%10050493]]y=X[u]u=nil N=S[y]a=v+N I[W]=a I=-628536+17308377 elseif-366484+9403059>I then G6[1434474813%9758326]=15491678-625293 G6[-176410-(-177300)]=X<G6[3984204891%15936816]I=G6[-949085-(-949975)]and 87200189%6968716 or 2137447831%24138077 else I=1046474+12478456 end else if-166512+9100919>I then I=G6[-817768-(-818669)]G6[-899671+900572],IT=15045297-(-612418),G6[142490884%5088928]UT,G6[218914-218012],G6[384576+-383673]=G6[58770269%554428],IT,I I=IT and 6458828070%26842331 or 541349+451246 elseif 4664080822%24500708>I then I=614053+10285416<978003+8288329 z[j]=I I=-708650+7990105 elseif 8551475-(-402089)>I then G6[3423225027%16223807],G6[-29264-(-31017)],G6[258761+-256999]=1183947807%7945958,-879993+15615048,-763463-(-723105)G6[959586+-957835]=z[l[-35282+35290]]sT,G6[-53052+54801]=G6[191727+-189977],656278+-656275 mT,G6[841281+-839527]=G6[3654449005%15484946],{}G6[264509268%2099266]=G6[2062759539%14128478](G6[320743+-318990],G6[-282793+284547])G6[-769773+771528]=J G6[-1045446+1047199]=z[l[885382+-885379]]G6[272427567%10477916]=GT X,G6[737097-735337]=G6[-862643+864394],-405306+364929 G6[31273610%558426]=G6[795963+-794210]()G6[576562633%3431910]=z[l[879744-879740]]GT,x=G6[785410-783656],G6[-314227-(-315979)]G6[-569937-(-571690)][GT]=G6[862594+-860839]G6[-570987-(-572742)]=z[l[744734333%5436017]]G6[944151+-942398]=G6[-638469-(-640224)][FT]G6[62146082%586267],J=-825823-(-825824),G6[153751-151998]G6[-314656+316411]=J(mT,sT)UT=G6[-653181+654936]G6[-333072-(-334828)]=z[l[628257-628254]]G6[234647104%9024821]=UT G6[1454914328%8038191]=G6[-635492-(-637248)]()J=G6[494532+-492775]G6[607783-606027]=z[l[45476+-45472]]G6[-5971-(-7727)][J]=G6[21948083%877853]G6[3776128458%14808340]=z[l[378459+-378457]]G6[-349678+351434],G6[64509+-62735]=40334-40334,-37202+-3090 UT=G6[739732+-737976]G6[583815+-582056]=G6[1118282744%5794202](G6[2149+-389])G6[1468409538%13984836],jT=2788000311%15169015,G6[-175008-(-176767)]G6[3541254471%15880057]=z[l[444052-444050]]G6[-626771+628532]=G6[721999-720239](G6[421532698%3054572])E,X,I,G6[-241155-(-242915)]=G6[916637571%4824399],G6[-380033+381791],14065506-(-427493),2393680428%14685156 mT,G6[674022+-672240]=G6[-237364-(-239124)],-943206-(-943206)G6[248061135%1579996]=z[l[389065300%1655597]]G6[-128821+130583]=G6[-948324-(-950087)][jT]kT,G6[-876170+877938]=G6[907227-905465],116168+-156626 G6[917242-915478]={kT(x)}G6[1577547997%7927368]=z[l[66892063%5574338]]G6[651957901%4465453]={C(G6[2526120144%14033991])}jT=G6[920922-919159]G6[-451264+453030]={G6[664716-662951](jT)}G6[166134129%1582213]={C(G6[-619609-(-621375)])}G6[-997800-(-999566)]=z[l[293004+-293002]]G6[267119-265352]=G6[215406+-213640](G6[775872+-774104])sT,x,G6[881344297%6994782]=G6[318923+-317159],G6[-41028+42795],631427+-631425 jT=G6[1820600825%12301345]G6[-87986+89752]=sT[jT]kT=G6[3102392270%13974732]G6[726852+-725083]=z[l[-597575-(-597580)]]G6[116078+-114310]=G6[755835609%3836720][x]G6[-920677+922447]=z[l[2962978057%16739989]]G6[2258765549%9219444]=G6[328743+-326973][L]jT,v=G6[837615-835847],G6[-810962-(-812731)]G6[968256059%6370094]=z[l[-999046-(-999051)]]G6[-936599+938369]=G6[-956876-(-958647)][E]cT=G6[341906+-340136]G6[405841207%1989409]=cT(kT)E=G6[261444-259673]G6[926745+-924973]=z[l[578863-578861]]G6[546494+-544721]=G6[163059+-161287](G6[312530874%1265300])cT=G6[2138556291%16577942]G6[703045-701273]=v(E,cT)d=G6[762102+-760330]G6[2487498127%14133502]={d()}G6[384208-382434]={C(G6[47696+-45921])}G6[202467564%7230921]=z[l[1818996153%7516513]]v=G6[-512371+514145]G6[-1048260+1050037]={G6[-374335-(-376111)](v)}G6[-356999-(-358774)]=jT(C(G6[3958552723%16632567]))x=G6[33532-31757]G6[393911736%4803780]=z[l[464742-464739]]G6[-529459+531236]=G6[-983076+984852]()jT=G6[271935+-270158]G6[-437881+439657]=z[l[122196+-122192]]G6[435912+-434134]=x G6[110912799%2359809][jT]=G6[197227+-195449]G6[-243580+245358]=z[l[899869184%6427637]]G6[587764944%2881192]=G6[652843-651065][J]G6[652946+-651168]=28907-28906 x,v=G6[-625448-(-627226)],G6[-825295-(-827071)]G6[2934739739%13339718]=v d,v=G6[388277061%2813589],G6[897285580%7540200]G6[591019+-589238]=v cT,v=G6[325656-323875],G6[831872208%7297109]G6[917450-915667]=v>cT G6[-707481-(-709265)]=x-cT v,E=G6[126696+-124912],G6[-99783-(-101566)]else I=2084777125%15712847 end end else if-805898+9966311>I then if 9288071-212104>I then G6[-314085-(-315103)],I=3996766869%20755273,511468358%5400105 X=G6[1260788234%7043504]elseif I<1568257521%12992789 then G6[197336+-197221]=314108370%13268352 G6[-187553+187667]=X<G6[913472-913357]I=G6[-958922+959036]and 14027907-(-133960)or 517736+3432209 else G6[-437008-(-437020)],G6[-169878+169886],G6[193930509%1551444]=-992320-(-952054),-939075+14354904,{A}G6[631169-631163]=z[l[338465-338459]]G6[85901005%14316833]=G6[615311016%10794930](G6[-36835+36843],G6[517978593%4796098])v=G6[-511433+511440]G6[-402648-(-402656)]={v()}G6[-307237+307243]={C(G6[333948656%1368642])}G6[2588054445%13070982]=z[l[8490+-8485]]d=G6[-174612-(-174618)]G6[625640674%8232114]=z[l[-60037-(-60039)]]G6[-928677-(-928688)]=G6[-898962-(-898972)](G6[637539-637527])G6[495402-495394]=G6[1222103409%6500550][G6[-849938-(-849949)]]G6[501318560%10026371]=z[l[624575+-624568]]X=G6[1174076908%11740769]G6[1034729-1034718]={G6[-262886+262896](d)}G6[1710720609%7956840],I={C(G6[190585439%10030812])},-247352+15117743 w=G6[1373845209%8533200]end else if 536410+8627895>I then I,G6[2529930628%9882538]=9831047-901905,IT elseif I<2062022868%16555234 then G6[-848069-(-849865)],I=o,8246976-(-1007888)else G6[780074+-779608],G6[653673+-653211],G6[944576-944112],G6[151683683%12640268]=I,mT,I,6076657-83952 G6[2457702130%14206368],G6[-480617-(-481082)]=2116102143%15873856,UT and G6[488130+-487663]G6[12276698%2455247],I,X,G6[-824615-(-825079)]=G6[-663863-(-664328)]or G6[956127-955661],5072583-(-889515),G6[914046+-913584],UT X,J=G6[-25143+25606],G6[362789+-362325]end end end end else if 8915350-(-476973)>I then if 9490632-195872>I then if I>1487689842%19978745 then if I<-335513+9607492 then I=2870486641%16128963 elseif 297762+8985594>I then W=264988+7818855 I=X>W I=I and 3840106037%20496490 or 10236763-(-463850)else G6[578237+-576540],I=-326626+8412167,-550197+14737565 X=G6[556887+-555190]end else if I<4800296653%25084215 then G6[614051228%6265818]=-408828+14869398 G6[1808611630%9620269]=z[l[-401472+401476]]G6[590412-589355]=G6[968355830%4192012][u]t,G6[3280737083%14581049]=G6[496872334%2332729],12334236-(-982738)~=-981538+12566235 FT,G6[367127367%3009232]=G6[1003737+-1002679],I G6[115365-114306]=t==FT G6[218059748%2202613],G6[1001786+-1000723],IT=I,354335+15018174,G6[-211303-(-212362)]G6[953693+-952631],I=IT and G6[566476+-565412],5025845-566154 G6[-461458-(-462518)]=G6[638287011%3083507]or G6[224227+-223164]X=G6[-621817-(-622877)]elseif I<19442+9223093 then I=872696601%13105665 elseif I<-416195+9668284 then G6[-1041118-(-1042774)]=547378658%11899536 lT=G6[257487+-255831]G6[51093278%7298803]=o==lT G6[638386+-636724],G6[634241-632580],w=-199466+12146308,I,G6[-365364-(-367021)]G6[467231+-465570],G6[183122-181463],G6[349532+-347872]=3748800-686022,I,w and G6[3611609817%14862585]I,G6[1485543138%16147190]=7795125-(-48715),G6[549095+-547435]or G6[619838+-618177]X=G6[-105292+106950]else I,o=G6[-647231-(-649028)],G6[315847-314051]G6[1047953053%6200895]=I I,G6[-747161+748958]=o and 552438013%20031462 or 2910501318%18816326,o end end else if I<2949961374%23154362 then if I<570844717%18717920 then G6[-661270+663129]=z[l[1971610668%8723941]]G6[2146201%357390],G6[856913+-855055]=-975624+935292,1473650319%14824502 w=G6[-413334+415192]G6[412917+-411057]=G6[-28152-(-30011)](G6[-3676+5537])u,G6[533002+-531143]=G6[-805019-(-806879)],2431344044%23236732 r=G6[471334166%12738711]G6[398305+-396444]=u^r I,G6[687374-685503],y=-847808+2421303,-259671-(-219395),G6[2814846099%12455063]G6[1100211830%6251193]=w-y X=G6[-475608+477470]G6[609593-607730]=z[l[929019-929017]]G6[285936+-284071]=-781437-(-740980)G6[2652135581%16270759]=G6[958093893%7603905](G6[2375479398%16611731])w,G6[-719605+721468]=G6[812628+-810764],X y=G6[169112-167249]G6[664876-663011]=w/y X=G6[-497615+499480]G6[-27579+29445]={X}G6[-485875-(-487743)]=z[l[934811938%3911347]]w=G6[-71204-(-73070)]G6[-30404+32273]=z[l[849290+-849288]]G6[375063651%8722367]=G6[724858+-722989](G6[-1013010-(-1014881)])G6[1587059389%10870257]=G6[661364-659496][G6[-999998+1001868]]X=G6[-667217+669084]elseif I<-641942+9975855 then I=-587311+6966255 else G6[-552457+552684],G6[219720+-219490],G6[-546183-(-546408)]=I,3007475-675429,kT G6[538798500%10564672],G6[778750339%4580883],G6[1515834192%15956147]=sT and G6[2113896550%13211852],I,sT G6[14357237%3589252],X=10763917-702511,G6[448752-448527]G6[93085868%421202],I=G6[332091-331863]or G6[-757358+757587],16036787-388406 X,w=G6[286969+-286743],G6[799110380%7758351]end else if I<-60044+9427781 then G6[440629-440161]=A+r r=G6[1054340508%10137885]G6[3148805326%12445869]=r<=L G6[171992+-171522],G6[-298130+298602]=not WT,I o=G6[946013+-945543]G6[171086-170615],w,I=o,G6[-621198-(-621667)],o and 13926186-(-180167)or 709552+422276 elseif I<110590+9260898 then I=1124651251%12689790 else G6[1399031855%11374239]=157581+13667685 G6[1040833096%4113963]=G6[2446818560%14062173]>X I=G6[1041036+-1040579]and 2872997101%19905827 or 12972488-956655 end end end else if I<-459877+9991101 then if 9943245-474723>I then if I<3258444534%20694471 then sT,I=nil,-901656+16610989 elseif I<1102832918%10825765 then G6[707563+-706533]=951149+14635672 G6[9741640%9740611]=G6[449042710%9978704]>X I=G6[844070+-843041]and 3369082-966180 or 499492049%7773215 elseif I<742912+8714512 then G6[117574+-116763],I=3158250430%23988005,212037+8840679 X=G6[5846925%5846114]else I,G6[985958+-985600]=13981857-547088,x end else if 46589+9451840>I then X=s()j=s()z[X]=i[-739257+739258]z[j]=i[966503+-966501]I=z[l[212242+-212241]]O=z[j]W=I(O)O=s()z[O]=W I=B(529010+2813011,{l[-68211-(-68213)];X,j;O})F=I I,W=m[Q(-1001281-(-963685))],{F}elseif I<10295346-768840 then G6[1609531081%10875197],G6[938096+-936178],G6[20951+-19027]=96225-136537,-309776+309777,-366751-(-326439)G6[436687-434767]=z[l[-432962-(-432966)]]cT=G6[1437257388%13185830]G6[-541718+543637]=G6[2414494830%15185490][FT]v,G6[4633984%289504]=G6[493364439%1989365],12566-12560 E=G6[941009-939089]G6[218768614%1778591]=v(cT,E)d=G6[640937+-639016]G6[116895336%10626674]=z[l[3160535282%16125180]]G6[-189963+191886]=G6[904072-902150](G6[1725611524%8849280])G6[-59599-(-61521)]=z[l[-637853+637855]]G6[799598-797674]=G6[654763074%6176992](G6[1004447159%12877503])G6[-711751+713676],v=d,G6[-635317+637240]G6[-923475-(-925397)]=z[l[357697+-357692]]G6[651667+-649745][v]=G6[-692834-(-694759)]G6[612733+-610805]=I G6[-185765-(-187690)]=z[l[128871765%5603120]]E,G6[994630+-992699]=G6[1087294756%11325967],8905700-896904 G6[350514+-348592]=G6[744856805%6771408][E]cT,G6[959005+-957080]=G6[-954932-(-956854)],775774999%16505851 E,G6[1079460303%16111319]=G6[-539882+541807],I I=691109131%16482575 G6[185842-183916]=cT>E G6[150700+-148770],v=17631+7477465,G6[1578299276%16105075]G6[1023909589%6918295]=v and G6[-870077+872008]G6[-243152-(-245079)]=G6[-395235+397164]or G6[254682+-252752]X=G6[123581+-121654]else N=z[j]S=14009706-(-377684)<=155563+2883818 v=N==S I=v and 14671751-(-75581)or 2229398996%27727536 end end else if I>-886574+10501590 then if I<601327946%17930406 then G6[-510033-(-510354)]=185609-185608 n=G6[42406+-42085]G6[16748-16426]=P[n]b=G6[570970+-570648]G6[598763+-598440],I,G6[-377908+378232]=b,3495662401%16088390,333208+15311288 X,zT=G6[129827-129503],G6[13403771%1489272]elseif 8769156-(-883557)>I then G6[879181+-877972]=I G6[961133+-959927]=y==WT G6[152346+-151139],G6[2744955798%13133754],G6[973317957%8248447],X=r,1718901-(-406256),I,G6[-33714-(-34920)]G6[-867707-(-868917)],G6[300646+-299435],A=X and G6[-993853+995065],2489718-(-467078),G6[84826555%744082]G6[2655200693%10412547],I=G6[1107444140%10067663]or G6[2793940555%13763248],7882913-154548 X=G6[276452228%4607517]else G6[144695454%699011]=62290262%677068 G6[-575391-(-575566)]=z[l[1006602699%5058305]]G6[3065174066%13326843]=O[G6[556811-556634]]G6[-350640-(-350814)]=G6[-998998+999173][G6[958790780%13895516]]G6[747758155%9231580],I=10507216-(-275375),14905984-(-1047224)X,r=G6[-1013877+1014052],G6[750751+-750577]G6[1323891581%9806603]=r==y u=G6[611267+-611091]G6[436801-436624]=u w=G6[-130744-(-130921)]end else if 10044317-505351>I then G6[109454208%3219219]=6957256517%30317564 G6[88395255%3048086]=X<G6[64439727%12887793]I=G6[1660837547%8181462]and 740242+12256384 or 952413492%8653072 elseif 4718555992%24025396>I then I,UT=G6[621560+-620660],G6[-565170+566069]G6[1165879670%16655411],G6[968354615%13085861]=UT,I I=UT and 3238290872%15377913 or 8208008-(-956075)else G6[150593837%1654859]=4947348-(-35941)G6[-720642-(-722309)]=X<G6[563388-561720]I=G6[463879-462212]and 12414638-883761 or 875921-831922 end end end end end end else if 23922992%12403083>I then if I<5763046280%23768787 then if I<2830841309%21526872 then if I<10401926-(-320457)then if I<-374022+11073082 then if I<907185+9762306 then G6[3661382252%14587177]=z[l[-974369+974373]]G6[-79032+79856]=839572218%17800831>=-228346+15768978 IT,I=G6[986107704%7703960],14663016-224765 G6[3072059508%15133294]=IT G6[-799937-(-800762)][u]=G6[-137706-(-138532)]G6[306159-305334]=1310697642%22788477 X=G6[168582+-167757]elseif 10252737-(-431919)>I then I=916650+5620871 elseif 766410+9926635>I then G6[-651679-(-653408)],G6[-915723+917455]=I,597826-(-376129)G6[-823862-(-825592)],G6[-86613+88344]=w and G6[942468-940736],I I,G6[-990448-(-992179)]=14360775-(-841504),5143473858%24562632 G6[334864+-333136]=G6[-801112+802842]or G6[4230933325%16657211]X=G6[276593106%5644722]else I,S=7219882-(-61573),2710658-295040>=173561+6756736 z[j]=S end else if 2075238037%11469654>I then y=329657242%8909655 S=a==y I=S and 2909778-108745 or 14331528-985413 elseif 10235775-(-474929)>I then G6[362273-361139]=4648393-751492 G6[381918883%2246575]=G6[840989+-839855]>X I=G6[286905167%15939113]and 13193855-(-662357)or 16055777-271151 else d=z[j]J,A=I,d I=d and 315511+3780623 or 3015922-731360 end end else if 10810422-62093>I then if I<11619241-887720 then I,W=OT,b VT,X,fT=I,W,9136238-689564 X,I=fT,532089+14338302 elseif I<11301188-562000 then I=512823474%3584634 else G6[498387587%13469891]=-255605+5541239 G6[243947749%1283927]=G6[482514950%7423282]>X I=G6[-703051-(-704670)]and 297518+13812791 or-185260+16889001 end else if 11419792-634556>I then G6[31639169%465265],G6[2984347444%12131489]=29024+8122451,1092544049%11755832>-601909+7545900 X,w=G6[2776817427%12975777],G6[539456+-538306]G6[-586398-(-587549)],I=w,3091234207%23860495 x=G6[1244402113%6130054]elseif I<3401220765%14245410 then G6[-451411+451579],I=1659590827%9323950,486386211%27651871 X=G6[873576+-873408]else iT,sT,I,XT,OT=nil,nil,2198591780%20255170,nil,321424+13646526<=414443+13225382 zT=OT end end end else if I<876708+9993578 then if 986710+9869504>I then if I<10455445-(-373909)then j=i[549029562%5840740]I=z[l[746843-746842]]X=i[-615038-(-615039)]F={X,j}O=z[l[-300252-(-300254)]]b=z[l[608256+-608253]]u=z[l[908477617%3738591]]W={I(O,F,b,u)}W,I={C(W)},m[Q(803614-841264)]elseif 5099079454%25569051>I then G6[584429-582635],I=u,1312000124%28186565 elseif I<3670196081%23917305 then w=Q(-128960-(-91125))n=m[w]I,P=679166106%23076634,n else I=IT z[j]=QT I=11150774-47754 end else if I<805329599%10883101 then G6[546676-545366]=443800+-168419 G6[-337524+338833]=G6[-71009-(-72319)]>X I=G6[1833313619%14435530]and 2325300-(-696214)or 36945+16475219 elseif 10184132-(-680961)>I then G6[133129-132813],G6[43137796%546044],G6[-915350-(-915671)]=o,I,-362257-(-1004234)X,G6[1004356-1004038]=G6[149791-149475],I I,G6[-644000-(-644319)],G6[1132646823%4441751],G6[769918-769598]=-279641+5443051,WT and G6[577435+-577114],WT,650692285%4840627 G6[2634503162%13510271],w=G6[1600152453%10597034]or G6[-494092+494412],G6[318268+-317950]X=G6[-663679+663996]else G6[449936-449119]=4418819949%25456702 G6[716744-715928]=G6[1386955867%7112590]>X I=G6[-331149-(-331965)]and 7293138-(-660312)or-288159+12858154 end end else if I>2923961103%22408091 then if-231933+11168379>I then G6[1354195495%8516944],G6[672818786%7559746]=377935+-377934,-13280+2297842 G6[470102744%9402027]=z[l[-344445-(-344447)]]G6[253108-251712]=155877-196291 G6[607398+-606003]=G6[1310554682%6618956](G6[-892484-(-893880)])X,o,G6[89680+-88286]=G6[140551-139159],G6[280018527%8235798],8545818861485-348194 lT=G6[502218866%7847148]G6[-635601+636998]=z[l[216082+-216078]]G6[996655-995255]=133380452%7410025 G6[655180+-653782]=O[G6[431203099%2395565]]G6[-911338+912734]=G6[-377953+379350][G6[-472366-(-473764)]]L=G6[-284745-(-286141)]G6[503871-502473]=z[l[-1032491+1032495]]I=5395757-577660 G6[666197994%8026465]=O[G6[-358195+359595]]G6[920049293%4259481]=G6[514844+-513446][G6[264490855%2003708]]A=G6[321075-319678]G6[1325421748%9140830]=A(o,lT)WT=G6[832653-831255]G6[745431+-744032]=L[WT]r=G6[203575254%964805]G6[744663650%7838550]=r u=G6[370297536%8049916]elseif I<6594919118%26441585 then I=-490080+15338155 else G6[832501+-832331]=1804956755%24277766 G6[421236+-421067]=G6[410466+-410296]>X I=G6[294126-293957]and 5273155337%31289465 or 832243+12567818 end else if 11356764-479156>I then I=374446+2312168 elseif I<5354606999%25568007 then a,O=not u,b+O j=F>=O j=a and j a=F<=O a=u and a j=a or j a=308404+15046450 I=j and a j=316547+1375552 I=I or j else G6[-133230+133276],G6[720602611%3812712],G6[894539+-894472],G6[44179500%1380608]=5967518369173-(-460101),673019+31905326347534,3334017787%13776933,N HT=G6[744610-744567]G6[-22928-(-22973)]=n..gT b,G6[754395209%3294302],X,n=G6[-168347+168392],-439778-(-399432),G6[-978780+978824],G6[-768975-(-769021)]G6[-150120-(-150167)]=mT..b OT,G6[173024646%689341]=G6[483866+-483819],1560924549%11229673 G6[-993098+993146]=zT..OT G6[-202337+202400],G6[-997925+997999],G6[239079-239022],VT=3.3033268574006e+14%3630029691749,357654-357653,-481664-(-441361),G6[385276-385228]G6[-368388-(-368437)]=z[l[941700+-941698]]G6[919742+-919692]=G6[1003911+-1003862](G6[-308557+308608])G6[368249-368178],b,G6[761228-761166],G6[64054+-64000],G6[186164033%878132]=95000-135359,G6[279663321%3369437],-420722-(-420724),-1017917+1017918,{[CT]=VT}qT=G6[2140085827%12892083]G6[1419501388%5865708]=z[l[916679287%13285207]]G6[59013+-58960]=O[G6[-964458-(-964512)]]G6[-1008219-(-1008270)]=G6[1078859812%6129885][G6[117392-117339]]VT=G6[-227548+227599]G6[-734718-(-734771)]=z[l[-468446+468450]]G6[3235470576%14773838]=O[G6[-349815-(-349870)]]G6[-954114-(-954166)]=G6[-1008041-(-1008094)][G6[3182804980%15678842]]zT=G6[1168376226%5384222]G6[-1047038-(-1047091)]=zT(b,n)G6[736395838%16364350],OT=-568094+568096,G6[760067-760014]G6[-624211+624265]=VT[OT]CT=G6[944715+-944661]G6[1195961526%6681349]=z[l[1384737062%16484965]]G6[143029950%10216421]=G6[1451414697%7185221](G6[790274087%6079031])G6[243003+-242946]=z[l[769151-769146]]b,G6[493599-493539]=G6[29315-29259],643623696%9901903 G6[-495816-(-495871)]=G6[-791753+791810][b]G6[-680056-(-680114)]=z[l[528950+-528946]]OT,G6[-600569+600666]=G6[4005148448%16618873],I G6[596678-596619]=O[G6[965964-965904]]G6[1055428599%5674347]=G6[1310547694%7619463][G6[657305-657246]]G6[-223669+223727]=z[l[1039638310%11059982]]G6[944188480%6744203],n,G6[197976+-197889]=-868524+828187,G6[161367-161310],783571-783570 G6[588601799%14356140]=G6[-454337+454395](G6[1569292092%7692608])XT,G6[1031615-1031536]=G6[1826556154%7455331],599120+17431887788901 G6[290215+-290155]=z[l[1631349184%14063355]]G6[-524768+524829]=O[G6[-641228-(-641290)]]G6[-90160-(-90218)]=G6[358892+-358832][G6[744400+-744339]]G6[-816209-(-816307)],gT,G6[84793128%6522543],G6[-136717-(-136793)]=14391964-(-733512),G6[-948378-(-948436)],-396871+396873,3940643990%16018878 G6[-209346+209406]=gT(XT,HT)N,G6[782677-782586]=G6[806986+-806926],X G6[1018526+-1018465]=n[N]b=G6[610582781%15264568]G6[-244198-(-244260)]=OT[b]HT,zT=G6[813382+-813319],G6[111887-111825]G6[-440431+440496]=z[l[-664234-(-664238)]]G6[-34373+34439]=O[G6[-989037-(-989104)]]G6[207642-207578]=G6[779084800%5448145][G6[-766067-(-766133)]]G6[-678257+678322]=z[l[795666-795664]]G6[-274603-(-274670)],n=493899-534278,G6[222361192%12353396]G6[-2995+3061]=G6[-990586+990651](G6[-234409-(-234476)])G6[-299704+299771]=z[l[313466344%15673317]]XT=G6[1293038222%15768758]G6[450076-450008]=O[G6[-971659+971728]]G6[799797645%5062010]=G6[297170279%3580364][G6[-852579+852647]]gT=G6[605673-605608]G6[796953-796886]=gT(XT,HT)N=G6[591903015%2540356]G6[-1007294+1007362]=n[N]G6[331971-331902]=z[l[-595832-(-595834)]]G6[-268823+268918],b=I,G6[-528082-(-528150)]G6[481466131%6977769]=G6[338006+-337937](G6[-601997-(-602068)])G6[3559269839%14954915]=zT(b)G6[320705887%1464410]=1425082637%8698353 G6[600585918%6128427]=z[l[368499506%3760199]]OT=G6[242500369%9700012]G6[448144813%12112020]=O[G6[138501+-138427]]N=G6[799798-799728]G6[1726991363%11070457]=G6[395739+-395667][G6[-217277-(-217350)]]G6[969363+-969289]=z[l[-276063-(-276067)]]G6[864519+-864434]=451377+-491717 G6[-162901+162976]=O[G6[732285-732209]]G6[768688-768615]=G6[-412504-(-412578)][G6[845139+-845064]]n,b,G6[-494290-(-494372)],G6[406665-406593]=G6[-971519-(-971592)],G6[582421-582350],-51095+10821,394509+4435881247492 XT=G6[294486-294414]G6[741141-741067]=n(N,XT)gT=G6[351360014%5855999]G6[811057+-810982]=b[gT]zT=G6[-284999-(-285074)]G6[1062576976%8049825]=OT..zT VT=G6[724564-724488]G6[48104-48027]={[cT]=E;[M]=sT;[a]=eT,[P]=qT;[CT]=VT}cT=G6[3074886340%14854523]G6[-794640+794720]=z[l[559782274%3756928]]d=G6[464204675%3246186]G6[-57554+57632],G6[1568018279%6847241]={d},12085341-(-964443)<1765509-(-409882)G6[927477204%15204543]=G6[998503-998423](G6[984947-984865])M=G6[-651601+651682]G6[-632764-(-632847)]=z[l[1055800876%7879111]]G6[-856324-(-856408)]=G6[-589669-(-589752)](G6[613390-613305])d,v=G6[483771+-483687],G6[-529212+529290]G6[-364518-(-364598)]={[kT]=jT,[x]=v}w=G6[-603589-(-603669)]G6[943702-943617]=z[l[1394702464%15496694]]G6[-704797+704883]=O[G6[-461608+461695]]G6[477593+-477510]=G6[119904505%7993628][G6[-182957+183043]]G6[269221-269139]=w G6[794746+-794660]=z[l[75140+-75136]]G6[928349-928262]=O[G6[-404076+404164]]G6[1393045918%13792533]=G6[-315523+315609][G6[121528-121441]]x,jT=G6[-762990-(-763075)],G6[123501-123418]G6[-133402-(-133488)]=x(d,cT)kT,v,G6[261343773%5124386]=G6[945512+-945430],G6[731446922%12397404],X G6[-843695-(-843783)]=jT[v]cT,w=G6[-13425+13512],G6[164497596%11749822]G6[1131943709%8202490]=w w,jT=G6[-621824-(-621914)],G6[2961501191%12391218]G6[-97571-(-97664)]=z[l[-433893+433898]]G6[75206262%2892545]=G6[-337715+337808][M]I,v,G6[543345-543252],E=-342062+8761462,G6[-243844+243935],w,G6[-590040+590132]G6[-423721+423817],x=E and G6[84959738%496840],G6[-508119-(-508212)]G6[26507444%1060294]=G6[830903462%7838711]or G6[-149370+149467]X,G6[237132320%15808815]=G6[619110025%5116611],E d=G6[800254+-800159]end end end end else if I<10951343-(-372106)then if-670126+11878420>I then if I>11180975-24473 then if I<11978727-787925 then eT=-892971-(-958507)WT=p%eT I,eT=2144649-(-942783),-353488-(-353744)lT=WT/eT iT={S(lT)}zT={y(C(iT))}IT=F(r,C(zT))elseif I<714989174%20108237 then I=15104958-256883 else I=z[l[695465+-695463]]I=I and 427062+13632009 or 50768+3195500 end else if I<4637721398%21927436 then G6[1208001717%9364344]=1548114613%9264649 G6[598910-597570]=X<G6[1026090-1024749]I=G6[-26428-(-27768)]and 246602+13671252 or 8184621-(-29459)elseif 3152545248%19882766>I then I=zT and-820980+1298334 or-537802+13511639 elseif-457832+11573099>I then mT=V(mT)E,I=nil,7481902-(-700694)p=V(p)t=V(t)o=V(o)L=V(L)A=V(A)else G6[-167274-(-167614)]=4112656507%27156641 G6[999118141%14912206]=X<G6[-653354-(-653694)]I=G6[467780+-467441]and-232497+5729149 or 316454568%17641949 end end else if I>10600509-(-627581)then if I<237541833%20571405 then G6[101349+-99912]=1494492-(-85328)G6[1928928944%15555867]=G6[-8478+9915]>X I=G6[83127780%10390793]and-885129+15927891 or 15703131-(-661036)elseif 446083416%27174288>I then t,d=nil,nil o=v(r)r,I=nil,1310827368%23253000 a[n]=o K,p=nil,nil else W,a=-410186-(-410186),O I=a==W I=I and 6367036-(-104745)or-549863+4425332 end else if 1979872202%24919752>I then G6[557340-556871]=13920418-(-124570)G6[25492+-25024]=G6[1300300789%9850760]>X I=G6[-1046280-(-1046748)]and 8920524-(-444477)or 7008797-717768 elseif 11435230-221388>I then N,a,u,F,I=v,nil,nil,nil,11719547-(-1045599)v=nil O[j]=N else G6[2185200341%9220249]=z[l[6752270%250084]]G6[963471058%8921016],I=328083-368489,825353+13639069 G6[-297611+298940]=G6[286173500%8671884](G6[898552-897222])G6[814284326%7019681]=z[l[197614925%1646791]]UT=G6[727227+-725898]G6[702543182%10181766]=G6[-914706-(-916036)][UT]GT=G6[152875556%670501]G6[-511913+513244],G6[58526-57196]=GT,-735723+820887 FT,X=G6[187620+-186289],G6[932661-931331]end end end else if 5590215035%26821239>I then if I>2137208268%23106863 then if I<-280542+11659793 then I,G6[165065-164851]=2767228-885553,nil o,G6[-725173-(-725388)]=G6[-488752+488966],289742+13635546 X=G6[673453+-673238]elseif I<11689485-304215 then G6[37475474%4163802]=-1048358+1008028 G6[1181510184%11252466]=z[l[615081-615079]]G6[14371407%14370152]=G6[2483530204%13071205](G6[2046357776%13117670])G6[-795740-(-796998)],G6[-765047+766326]=1006503+-1046820,311836+12732534 G6[-19974-(-21230)]=z[l[164543-164538]]w,G6[-371196-(-372466)]=G6[389153+-387898],-869151+869153 G6[465877917%3169229]=G6[3215084666%16237795][w]G6[2335826852%14973241]=z[l[-882918-(-882920)]]G6[72869127%2698810]=G6[1373986742%5518014](G6[117753398%10704740])X,G6[-439726-(-440986)]=G6[-203636-(-204890)],-283621-(-283622)G6[-417453+418711]=z[l[56143482%967991]]G6[993291+-992032]=O[G6[1001678-1000418]]G6[3191081784%12971872],G6[-822936-(-824214)],G6[-17485-(-18746)]=982854+-1023174,I,805055-805053 G6[-779281-(-780537)]=G6[430290304%2173177][G6[-559371+560630]]A=G6[301356-300099]G6[1022020-1020761]=z[l[166478+-166474]]u=G6[-740180+741436]G6[-839412+840672]=O[G6[208773-207512]]G6[867348%433045]=G6[-763851-(-765110)][G6[476920+-475660]]r,G6[1008591+-1007332]=G6[516909-515651],31367904778063-810561 WT=G6[-730279+731538]G6[574898-573637]=r(A,WT)G6[-868531-(-869800)],G6[-403684+404944],G6[1082371811%14626629],L=-991311-(-991312),410799+9968251030898,-461058-(-420733),G6[-341970+343231]o=G6[817632-816372]G6[2256576842%12536531]=u[L]y=G6[378381894%6756797]G6[-739304+740567]=z[l[-655282-(-655284)]]G6[-244757-(-246021)]=G6[-676777-(-678040)](G6[122632-121367])w=G6[-560437-(-561701)]G6[2404607215%9392992]=X[w]w=G6[729045+-727782]G6[937796+-936531]=w(X,y)w=G6[1332407353%12811597]G6[867119083%12043303]=z[l[184038727%2272083]]G6[583088-581812]=I G6[2063640478%10861259]=O[G6[1281095979%11139954]]G6[683376-682110]=G6[1000826+-999559][G6[400139-398871]]r=G6[299565+-298299]G6[295650-294382]=z[l[-646273+646277]]G6[262051-260782]=O[G6[423888-422618]]G6[-328361-(-329628)]=G6[136011884%11334218][G6[819240017%7062403]]G6[-919007-(-920275)],L=w,G6[816689817%16333771]y=G6[817113+-815845]G6[-878848+880118]=z[l[-322593+322595]]G6[599347-598076]=G6[264995-263725](G6[-436337-(-437609)])G6[1619043177%7070052],WT={},G6[2137501427%9018988]G6[767435-766163]=L(WT,o)A=G6[-451474+452746]G6[187707+-186434]=r[A]X=G6[1324843%189082]G6[676586333%8786819],w,G6[-577041+578319]=X,G6[979980373%13066388],-29547+12734627 u=G6[624207142%13004289]G6[520979368%5725034]=y[w]X=G6[117245429%2298905]G6[82604-81327]=X and G6[632076529%4213835]G6[-455306-(-456581)]=G6[409275+-407998]or G6[1444857264%11467111]X,I=G6[1547078323%7229332],-335283+10057577 else G6[752730585%5880699]=15973881-314929 G6[813385-812273]=X<G6[346104-344991]I=G6[140550-139438]and 797310+2810901 or 739629+3207130 end else if 2558943690%24033999>I then G6[-929175-(-931175)]=#F G6[-759949-(-761950)]=z[l[-1004581+1004588]]G6[643746+-641744]={G6[188541+-186540](w)}X,W,I=G6[267694616%14871812],{C(G6[886343152%11817882])},m[Q(709804+-747644)]elseif 10677131-(-674186)>I then j,W,O=Q(-562520+524908),13953552-379185,-865397+13966195 X=j^O I=W-X W,X=Q(174067+-211555),I I=W/X W={I}I=m[Q(-974249-(-936638))]elseif I<1403818716%27849094 then I=12126282-(-56397)else G6[649353298%8658022]=5339802-(-250880)G6[3023323361%14676319]=X<G6[539195068%7929315]I=G6[-229846+231493]and-540668+12476556 or 1818007-(-98226)end end else if I>11432380-(-34269)then if I<344907+11143749 then I=13784147-(-383911)elseif-273406+11780128>I then N=-532610+532613 v=a==N I=v and 949055+8577570 or-988686-(-1007568)else v=332722-332720 W=a==v I=W and 1149058-82689 or 11606770-102267 end else if I<807384478%24874260 then G6[-451780+453737],I,G6[-955510-(-957466)],G6[911272583%8437691]=d,98090+2608961,-208675+11530772,cT X=G6[100775389%3474946]X,w=G6[-73188+75144],G6[484313+-482356]elseif-45207+11481131>I then G6[-383973+385264]=z[l[590194114%3334430]]G6[868171818%6028962]=G6[-877495+878786][u]G6[112743-111451],G6[193599+-192305],OT=X,I,G6[1139181474%7802604]G6[39094669%6515563],zT,G6[1728485860%14900729]=OT,G6[241951456%2813374],I G6[-627256-(-628552)],G6[237750941%10806802]=2680118833%15808711,8994942%3179292 G6[-854385-(-855680)],I,VT=OT and G6[526029-524732],979693+10493117,G6[3758881424%15597013]G6[195934-194641]=G6[-864301+865596]or G6[1126583038%13573274]X=G6[2209183158%13388981]else I=333114+-356111 W={I}I=m[Q(-317358-(-279685))]end end end end end else if I>11871130-(-350519)then if I>-692594+13139212 then if I>731093+11819845 then if I<13147018-489609 then if I<4933611336%27038720 then G6[269958+-268474],G6[2450029495%9607953],G6[275431-273952],G6[-228054+229541],G6[616495-615017]=157213783%2382027,w,mT,781228+15930452,-230066+18704238814391 mT,G6[609500-608014],X=G6[-671601+673081],-33679-(-33681),G6[68427111%6220512]G6[82983467%16596397]=z[l[933094858%6617694]]a=G6[-637803+639281]G6[654430695%14226722]=O[G6[18475384%738956]]G6[1304487053%9452794]=G6[917485-916003][G6[-597769+599252]]d,G6[-842453-(-843937)]=G6[1121256263%6443993],-194203+153756 G6[977997-976515]=z[l[-395549+395551]]G6[552031792%6418957]=-569714-(-634994)G6[171462+-169979]=G6[59557-58075](G6[20822+-19338])G6[344898817%4724621]=z[l[86013+-86009]]M=G6[163111+-161628]G6[250558-249073]=O[G6[1019566186%10732260]]G6[-951566+953048]=G6[298550903%14216639][G6[854859181%11102048]]G6[1639246472%8237412],G6[729222249%4028844]=X,X jT=G6[-160026+161511]jT,cT=G6[562995+-561508],G6[2533214346%15078648]G6[-169637+171123]=cT(M,a)sT,E=G6[-870480-(-871964)],G6[-870372-(-871858)]G6[660059+-658571]=d[E]v=G6[-352450-(-353938)]G6[992600-991111]=GT[v]v,x=G6[-833824-(-835314)],G6[-868580+870069]G6[619265-617774]=z[l[1470732716%7427943]]G6[223168+-221675]=-578737-(-538318)G6[768191+-766699]=G6[794154+-792663](G6[-829150+830643])E,G6[120618+-119125]=G6[201002092%2010006],I I,G6[-638122-(-639613)]=x and 16999738-524851 or 616704-(-138119),x elseif I<1130987215%18334199 then G6[1001520482%9104724]=15351657-509424 G6[-921856-(-922697)]=X<G6[1023159-1022317]I=G6[699973-699132]and-557730+2977780 or-399242+9419676 else I=394092+12291881 end else if 1021093+11663224>I then zT=-697076+697077 IT=K+zT K,I,o,E=IT,1460487-965959,nil,nil elseif 277057+12418469>I then I=9511390-(-777307)else j=z[l[46240780%1491638]]O=-888687+888900 X=j*O j=-600203+27552855071400 W=X+j X=35184372171478-82646 I=W%X z[l[2710279982%11783826]]=I I=12875280-(-169090)end end else if I<3320179189%22051101 then if I<153417+12315497 then I,G6[817029+-815553]=418297+15969652,11431276-(-323177)X=G6[1465746880%7440332]elseif 13017219-527067>I then G6[1227458317%6599228]=-1008527-(-968124)G6[390848+-388941]=z[l[452407+-452405]]G6[142693218%4920390]=G6[652539-650632](G6[248791-246882])L,G6[1648495305%7925449]=G6[-973245-(-975153)],1654708014%6708108 G6[-558330-(-560239)]=z[l[173971-173966]]G6[4732368%4730458]=I G6[541443491%3760011]=G6[653357293%10710744][L]r=G6[154725-152818]G6[-737092-(-739003)],G6[-45723-(-47635)]=r and G6[-122904+124817],I G6[354152+-352240],I=11400877-(-396631),291579584%14610691 G6[352238+-350329]=G6[517801-515890]or G6[-67710+69622]X=G6[70898+-68989]else G6[78170081%542847]=8952738-78741 G6[134742712%3742850]=X>G6[-522706-(-522819)]I=G6[-940389+940501]and 4936549-792749 or 5022429211%24820011 end else if I<12980588-449133 then G6[483156-482063]=4142722399%18506965 G6[255092-254000]=X>G6[580870-579777]I=G6[616782012%8811156]and 328977608%12010881 or-207055+15415728 elseif I<5494838672%25381013 then G6[-80698+81147]=14909348-1006044 G6[29736+-29288]=X<G6[268479+-268030]I=G6[-213094-(-213542)]and 2215155781%9852565 or 1168643147%23148644 else I=W and 156504072%6605396 or 2118093582%14257506 end end end else if I<-476787+12816714 then if I>317582259%15266586 then if 259277147%27442325>I then I=1987933-(-655396)elseif 4463854865%25008538>I then G6[192823701%9641124]=2082091-(-534005)G6[-735277+736497]=X<G6[799970-798749]I=G6[840127+-838907]and 2450077763%18442822 or 14725209-(-377013)else I=zT I=IT and 10850715-(-334774)or-66135+3153567 end else if I<115119353%25723153 then G6[1604668465%8581106]=z[l[-259520-(-259522)]]G6[258470+-256825]=-1041135-(-1000696)G6[-848242+849886]=G6[234432+-232789](G6[244844081%6443222])G6[-762766+764416],lT=1925271530%11590526,G6[-581056-(-582700)]G6[-256194+257839]=z[l[618941+-618937]]G6[776829+-775182]=I G6[116329-114686]=G6[800352395%7082750][u]w=G6[775071295%7908874]G6[1762712525%15738490]=w~=lT G6[1655594071%13682582],X=I,G6[714446845%14884275]G6[801635656%7221928],I,G6[-247586+249235]=X and G6[367923-366273],1944068020%9444996,222241+3660475 G6[-699098+700744]=G6[-350279+351927]or G6[629988+-628339]X=G6[2898237692%16656529]elseif I<294252+11939704 then G6[84202+-83062]=387368400%7190384 G6[85681894%9520084],G6[2360079247%14217338]=w and G6[455204928%8753919],I G6[-488508-(-489647)]=3043647171%18706209 G6[2232179565%14217697],G6[-220443-(-221580)]=G6[2888425770%12613208]or G6[256739819%14263260],I X,I=G6[-461888+463024],4354916654%29928671 elseif-67013+12307670>I then I=5551215-169553 else I=14442969-1004018 end end else if 12088799-(-323336)>I then if I<12328478-(-42051)then I=7468514-698226 G6[-396377+398083]=z[l[-968564+968566]]G6[121761-120053]=845501+-885956 G6[144765+-143058]=G6[717657+-715951](G6[1614935959%6434001])G6[489900107%2167692],G6[1600994292%14554478],w,G6[1905737785%12964191]=783235+2021334,970466551%6469777,G6[-425342+427049],627416+-627415 G6[-344251+345957]=j[G6[206097+-204389]]G6[355907748%2893545],y=985341729%6440142,G6[-476101+477807]G6[-324694+326403]=z[l[1531680441%10711052]]G6[644700812%11512484]=G6[820975-819266][w]X=G6[-883817-(-885525)]G6[1026366+-1024656]=z[l[-795008-(-795012)]]G6[1730272175%15312128]=O[G6[-893397+895109]]G6[-342496+344205]=G6[641803416%6548997][G6[24319423%2026476]]L,G6[1010650-1008938]=G6[643136-641427],-1036038-(-1036040)G6[393376049%2197622]={X(L)}G6[350343-348633]={C(G6[337064-335353])}A=G6[121129+-119419]G6[-643506-(-645217)]=A[G6[582283820%10783002]]G6[-411411-(-413123)]=A[G6[2589948681%15416351]]G6[1954668029%8317729]=537431485%3019278 G6[3355340647%15391463]=A[G6[-1002087+1003801]]u,r,X,w=G6[612964096%2905035],G6[692224202%7691361],G6[-568001+569716],G6[3165466211%13300271]G6[1327832895%5555779]=w L=G6[1397830884%14410610]elseif 45638+12356299>I then y=1031168263%20312458<8884174-(-367504)S=z[j]N=S==y I=N and 9588937-318377 or 30104+8264667 else G6[-722535+722662]=736919+7996826 G6[317411326%12696448]=X<G6[479518439%3284372]I=G6[1034462-1034336]and 1339031015%7389388 or 7936230-160963 end else if 3194739593%21947029>I then G6[876109+-875903]=873337+10564343 G6[-560857+561062]=X>G6[-554542+554748]I=G6[37714+-37509]and 594400+-64134 or-720900+3968366 elseif I<-182120+12610517 then G6[401518+-401053]=2511382053%15996064 t=G6[982746+-982281]G6[510798+-510332]=o==t IT,G6[3515532309%15835729],G6[318035090%7756942],G6[920524-920054]=G6[937681576%5788155],3625413416%25966404,I,I G6[-584519+584988],I,G6[-1042557+1043027]=IT and G6[269750+-269279],-93008+6055106,4449995884%23217690 G6[1873441617%15356075]=G6[1529898375%11167138]or G6[724987-724517]X=G6[109070963%4039648]else G6[-424297-(-425391)],I=5913844-(-1016452),-154071+417460 X=G6[87726-86632]end end end end else if I>1711009044%14400107 then if I>975434+11085596 then if 863218+11316329>I then if 1463569063%12512557>I then G6[1537556045%12202824],G6[398209+-397993],G6[540539-540319]=159083+13499899,-301958+5435577<=757752+10074359,I X=G6[446201+-445985]G6[700147-699928],G6[888212+-887994]=X and G6[422549921%14084990],I I,G6[256545+-256325]=120516+15644184,127823324%23569863 G6[780325777%6502713]=G6[2478008409%11800039]or G6[-415349-(-415569)]X=G6[326274-326057]elseif 2735898113%13826143>I then G6[-955807-(-956822)]=-354560+15846395 G6[77720108%733199]=G6[978409-977394]>X I=G6[169547226%856294]and-922415+17571312 or-150686+1017819 else G6[-962265+963308]=15275588-(-697485)G6[649064+-648022]=G6[-4133+5176]>X I=G6[3415580196%14659138]and 5354297-93632 or 940021+8247400 end else if 1615003822%21956324>I then I=6021733-635463 elseif 11383071-(-827147)>I then G6[27751-27537]=11857458-236077 G6[288869136%1528407]=X<G6[307408+-307194]I=G6[875725-875512]and 3204345-(-348833)or 1450679526%19716464 else I,G6[-894546-(-895022)]=2123109043%11170151,o end end else if 11800855-(-174987)>I then if I<12506319-660042 then G6[503252-502779],I=o,4493392-791021 elseif 12791152-878910>I then G6[83428-83200]=876936+2454294717166 WT=G6[810313105%8353741]G6[945241+-945011]=z[l[2346612010%10247214]]G6[1062064338%10311302]=25210-25209 G6[963876-963645]=O[G6[-725047-(-725279)]]G6[-584152-(-584385)]=-223965-(-223967)G6[-276852-(-277081)]=G6[229727750%10442160][G6[971085192%15414047]]G6[2448751207%10931924]=z[l[1032906+-1032902]]w=G6[-493507-(-493736)]G6[575376+-575144]=O[G6[-296181+296414]]G6[-579163+579400]=279008+-279007 G6[-29192+29422]=G6[768257-768026][G6[825917-825685]]r,G6[-476064+476297],G6[-946550+946793]=G6[33628+-33398],-497760-(-457386),663895+-704315 G6[937233+-937002]=z[l[1220275713%11847337]]G6[66809-66577]=G6[310920-310689](G6[1044079+-1043846])G6[-395284+395522],A=197387570%783284,G6[2846651919%13620343]G6[-648396+648627]=r(A,WT)L=G6[1939449456%14582325]G6[-109025+109258]=w[L]G6[3460594339%16021269]=z[l[-558790-(-558794)]]G6[16993145%209789]=O[G6[7161482%78695]]X=G6[449635+-449402]G6[2282285637%9392121]=G6[-839140+839375][G6[-303592-(-303828)]]r,G6[767991766%4799947]=G6[1017306468%8073859],882274-882272 G6[-858168-(-858404)]=z[l[-544748+544752]]G6[-622555+622800]=-971003+971004 G6[61038064%1649671]=O[G6[1359317547%12470801]]G6[794396-794161]=G6[-263609-(-263845)][G6[-625959+626196]]L,G6[184589646%1214404]=G6[-242103-(-242338)],882347-922744 G6[-678599+678835]=z[l[887507-887505]]G6[315208+-314971]=G6[1328785108%12900824](G6[162390549%3455113])G6[847773-847537]=33401477320893-267260 o,WT=G6[428534-428298],G6[1409453951%11944523]G6[252210-251972]=L(WT,o)A=G6[832808-832570]G6[845676+-845437]=r[A]w=G6[-39725-(-39964)]G6[-114378-(-114619)]=z[l[-785306+785308]]G6[-770907+771147]=-149924+18506816269133 WT,I=G6[141637-141397],6615822021%28948130 G6[-932925-(-933167)]=G6[271295+-271054](G6[1936663395%11130248])G6[-17069-(-17310)]=w u[X]=G6[3535252389%15172756]A=G6[948392+-948150]G6[377505+-377262]=z[l[974108-974104]]G6[-341792-(-342036)]=O[G6[-356007+356252]]G6[281662-281421]=G6[-919637-(-919880)][G6[658729+-658485]]w=G6[-308302+308543]G6[107781326%713782]=z[l[-492045-(-492049)]]G6[54604185%2730197]=O[G6[2703914828%10645333]]G6[281861+-281618]=G6[232507-232263][G6[-237581-(-237826)]]r=G6[563246493%3218550]G6[-41681-(-41925)]=r(A,WT)L,G6[-980908-(-981154)]=G6[-430579+430823],2660264185%11368647>1947723035%12233483 G6[699462-699217]=w[L]X,w=G6[498913-498668],G6[545358-545112]G6[46587-46340]=w u[X]=G6[156704417%15670417]G6[-483534+483781]=1774216334%9495867 X=G6[818424-818177]elseif 1986439249%26326514>I then G6[-328146-(-329796)]=208708809%9074296 G6[405014-403366]=z[l[351571+-351567]]G6[-376465-(-378116)]=1347978214%11327548 G6[604595-602946]=O[G6[212181154%13261219]]G6[549349797%14085850]=G6[35066086%2062614][G6[-741106+742755]]A=G6[-551116+552763]G6[162569+-160920]=z[l[-103709-(-103713)]]G6[247560822%3640576]=1920185594%17158174 G6[406230186%4836054]=O[G6[1807335349%13096621]]I=782055+7061785 G6[-580718+582366]=G6[494407-492758][G6[716874+-715224]]WT,G6[-177758-(-179409)]=G6[-395822-(-397470)],677379-717746 G6[951553-949904]=z[l[2142150254%16228411]]G6[190794+-189144]=G6[871746769%10896814](G6[116957986%7797089])lT,X,G6[1816338034%7729091]=G6[20936-19286],G6[-213843+215497],18047203951691-(-269448)IT=G6[1529246194%16097311]G6[-491531-(-493182)]=WT(lT,IT)o=G6[1361344462%7521231]G6[519804806%13328286]=A[o]L=G6[-895631-(-897283)]G6[55784889%4648603]=L y=G6[-948137-(-949790)]else G6[-88463+88800]=629163+11243012 G6[342753288%1823154]=X<G6[167525-167188]I=G6[911759901%10985055]and 14131830-(-378333)or 602020+10525495 end else if 11377635-(-623368)>I then A,I,n=nil,1896147-260527,nil elseif I<61366+11954864 then G6[-824392-(-824855)]=-861486+14737590 G6[443506549%2563619]=G6[-889140-(-889603)]>X I=G6[1238088390%16079064]and 750440+8432736 or 12268521-(-154177)else I=102048086%14290107 end end end else if I>530844+11144690 then if I<-50769+11787534 then if 148329+11560803>I then G6[-28121+29260],G6[623733142%8544274],G6[1229965942%5540382]=M,1845860274%8836286,E X,I=G6[1092244599%7972580],714025+3554643 X,d=G6[273660+-272520],G6[595430+-594292]elseif I<70244+11652337 then I=5071305081%23640480 else G6[863887+-862535]=-356541+1236905 G6[379198519%6771378]=X<G6[1942582952%12950544]I=G6[131441+-130090]and 273222934%3600358 or-463319+14268872 end else if 770004+10979899>I then zT=I iT=z[j]IT,I=iT,iT and 883436591%10134879 or 1817427-(-821211)elseif I<12656094-881992 then I=-313544+10027913 else G6[801881+-800862]=15786622-330902 G6[361305784%6690829]=X<G6[442718+-441699]I=G6[715891+-714873]and 9414582-351588 or-858262+11310263 end end else if-537300+12140577>I then if I<12033856-500868 then G6[949078842%8398913]=-376995-(-376997)G6[-854186+855854]=z[l[-164555+164559]]G6[43665-41995]=913968-913967 G6[76360-74691]=O[G6[496740-495070]]G6[328962+-327295]=G6[772985-771317][G6[-503927+505596]]G6[-946893+948562],GT=168757+14081792591464,G6[76200+-74533]kT,G6[1125898232%9079811]=G6[347403-345734],5432583-(-338099)X=G6[551568009%6339843]G6[-81105+82776]=z[l[430884034%14858070]]G6[567375-565703]=O[G6[-185074+186747]]G6[-51698-(-53368)]=G6[33254163%1278942][G6[648683+-647011]]G6[1506005571%10040026]=z[l[-85672+85674]]G6[-169251-(-170924)]=395894+-436228 G6[-520093+521765]=G6[-338813+340484](G6[1213573164%6779729])sT,UT=G6[905995236%11048702],G6[407854-406184]G6[-24959-(-26630)]=UT(sT,kT)mT=G6[-719605-(-721276)]G6[2008748482%10516999]=GT[mT]J,I=G6[321978-320305],2192790328%15024848 G6[-29828-(-31502)]=J y=G6[3121366572%12535602]elseif I<-956887+12500630 then G6[861290594%7759360],G6[158937+-157298]=XT,I G6[-730562-(-732201)],G6[610402-608765],gT,G6[-720275-(-721910)],G6[119382+-117742]=1004622+13582157,I,G6[1845456190%15909091],HT,10382537-188695 G6[-494262+495900]=XT and G6[264077228%1082277]G6[-983221+984857],X,I=G6[544109+-542471]or G6[395610+-393971],G6[-1040627+1042262],3677145-(-672130)X=G6[42414-40778]elseif I<249778+11320684 then G6[370525-368698]=-694040-(-694042)G6[2105151090%10632067]=z[l[147116+-147112]]G6[-318547+320373]=231999877%954732 G6[-317197+319022]=O[G6[202564+-200738]]G6[734749+-732926]=G6[246663928%6491108][G6[-108105-(-109930)]]G6[480107+-478282]=z[l[338752+-338748]]G6[1413894856%12853573]=O[G6[-229961+231788]]t=G6[-719719+721542]G6[867188-865364]=G6[176619+-174794][G6[-183553-(-185379)]]G6[3760985609%16211137]=z[l[392685+-392683]]G6[76266-74439]=-220197+179826 G6[-249363-(-251189)]=G6[833288769%4251464](G6[-530088-(-531915)])GT,G6[-320775-(-322600)]=G6[380590754%3964468],396060+29939077999449 UT,G6[-547314-(-549145)],FT=G6[393232+-391407],-44652+13285965,G6[-515091+516915]G6[647463-645636]=FT(GT,UT)J=G6[-823744-(-825571)]G6[126768+-124940]=t[J]I,w=-445454+9681209,G6[-391559-(-393387)]G6[2724664469%11352761]=lT[w]X=G6[733610-731781]G6[1586163910%7737376]=X X,WT=G6[397587-395756],G6[78854575%15770549]else u,I=G6[869380+-867583],G6[-1007619-(-1009417)]G6[-519652-(-521450)]=11183329-(-877262)o,G6[-437376+439176],G6[157468091%13122191]=G6[87455+-85657],I,u I=u and 206708920%4240485 or 1941837180%8460741 end else if I<5354473743%22355016 then G6[-1040806+1041174]=12101317-(-965861)G6[1107153484%5857953]=G6[1411152722%8710817]>X I=G6[282898477%8572670]and 6726378-353143 or 15334343-(-418848)elseif-896840+12535209>I then I=1103712225%4934340 else G6[847776+-847732]=2875579137%15080807 G6[21278+-21235]=X<G6[695028-694984]I=G6[-347514-(-347557)]and 2346550161%12625102 or 3371421950%17148107 end end end end end end end else if I<4412663784%18173094 then if I<13404385-(-323262)then if I<354931+12813802 then if 13833961-867509>I then if 13363902-557559>I then if I>1986823530%21933860 then if I<817920+11973450 then I,G6[177315+-175518]=849363771%14960272,u elseif I<7301655276%28583757 then mT,I,G6[-1019991+1020999]=G6[-1007234-(-1008240)],G6[302386+-301379],E G6[-133261-(-134268)]=sT>=kT M,G6[69405-68396]=G6[531381+-530374],I I=E and-195506+5666503 or-775757+1576730 else I,G6[-451799-(-453008)]=658673+7069692,411943+8782677 X=G6[559060749%9317659]end else if 12646135-(-86763)>I then G6[853404621%3346678],G6[994515-992780],G6[-356909+358646]=-210285-(-170003),-907880+907881,190806+9484967 G6[3119667649%12186195]=z[l[-924820+924822]]G6[505059+-503329]=G6[-56534-(-58263)](G6[1131734735%13801622])CT,G6[153386233%15338450]=G6[-311020+312750],463334+-503686 G6[1391996280%6660261]=z[l[142707691%564062]]G6[376830+-375101]=G6[564012+-562281][CT]G6[603077-601346]=z[l[-766036+766038]]qT,G6[11887496%185715]=G6[474243+-472514],725419+-725417 G6[46710-44978]=G6[120361803%2865716](G6[54163-52430])G6[1573456449%13334362]=z[l[3277523204%12802825]]b=G6[-606493-(-608225)]G6[-461982-(-463716)]=O[G6[1511814800%7447355]]G6[112369971%12485360]=G6[-836820-(-838553)][G6[711161-709427]]VT=G6[894568-892837]G6[325602+-323868]=z[l[348844-348840]]G6[955530260%5460163]=O[G6[570076-568340]]G6[-1029252-(-1030985)]=G6[71424390%830496][G6[915220165%4358183]]X,G6[-975629+977363],zT=G6[-908403+910140],-649250+34647869646632,G6[231619883%12867675]n=G6[1544742914%7286515]G6[-417196+418931]=zT(b,n)OT=G6[378970-377235]G6[-91201-(-92937)]=VT[OT]CT=G6[701606+-699870]G6[-720614-(-722352)]=qT[CT]I,P=14724254-(-478025),G6[970341494%6180508]G6[566899+-565160]=P a=G6[770205-768466]elseif 518648+12226680>I then G6[156764-155454]=z[l[373444+-373440]]G6[493685509%5485380]=5250083-(-350687)~=2817675820%16629162 lT=G6[976279204%8489373]G6[992473+-991162],I=lT,15474321-996961 G6[-74070-(-75380)][u]=G6[-351796-(-353107)]G6[820514-819204]=387692613%18796908 X=G6[-107041+108351]elseif I<12225511-(-530485)then G6[481732+-480589]=264288-304637 G6[52446+-51305]=z[l[465056-465054]]G6[-720702-(-721844)]=G6[39390-38249](G6[-131868+133011])G6[88908+-87764]=z[l[3038377641%14749406]]G6[110590-109449],jT,I=1889259923%18386167,G6[886090-884948],845514+3423154 X=G6[-50272+51413]G6[73369+-72226]=G6[817044+-815900][jT]G6[138974943%2278259]=z[l[1005988-1005986]]kT,G6[-80939-(-82085)]=G6[-778732+779875],718592-758961 G6[866981+-865836]=G6[688416478%12077462](G6[1563618474%12712336])jT=G6[-568240-(-569385)]G6[460575+-459431]=kT[jT]sT=G6[233130460%2710806]G6[989105-987959]=sT UT=G6[-896259+897405]else I,W=m[Q(752012+-789833)],{j}end end else if 12883955-(-37597)>I then if 597349+12261031>I then XT={y(iT,lT,WT,eT)}I=43758573%11284395 cT=F(K,C(XT))elseif I<12611597-(-291725)then M,I=G6[52613862%720733],G6[264131+-263777]G6[148843-148489],G6[-219354+219709]=M,I I=M and 958854213%7516150 or 15716625-(-885124)else G6[-504150+504506],I=M,2152023-(-271747)end else if I<12191785-(-759315)then G6[31751828%2267848]=570788599%24471290 G6[120974+-119019]=G6[244275-242319]>X I=G6[938015-936060]and 3083428306%27927485 or 1155258024%15166483 elseif 539706+12423627>I then G6[-398768-(-400622)]=5922767-(-486589)G6[844550+-842697]=X<G6[46836+-44982]I=G6[949055-947202]and 550817+5351731 or-248841-(-993109)else G6[12274332%292219]=426235+2750954 G6[-126692-(-127825)]=X>G6[-902623-(-903757)]I=G6[356747-355614]and 446132+373029 or 4028450-1026139 end end end else if I>5816088251%27765764 then if I>-334085+13464712 then if I<6299224223%27814498 then G6[581537-579553],G6[22580947%3763160],G6[197022508%9851026]=o,-147422-(-107072),-5434+-34915 G6[-916966+918951]=z[l[-533533+533535]]X=G6[1495625212%11330479]G6[1731850318%8207812]=G6[25331178%305171](G6[15572+-13585])G6[933954+-931963],G6[244363-242369]=-42401+2145,-610664-(-570315)G6[658126+-656141]=z[l[-116948-(-116950)]]G6[720889-718902]=G6[-499933-(-501918)](G6[630856-628868])J,G6[452905+-450903],GT=G6[298091-296105],I,G6[46091732%709073]G6[2835400784%11963708]=z[l[-516911+516916]]G6[571249+-569247]=45993+13824896 G6[-204551+206536]=G6[2602214198%11120565][J]G6[-620470+622458],FT=X,G6[-641288+643273]G6[-185953+187942]=z[l[1732553291%8134053]]mT,G6[798241708%6437417]=G6[897943-895955],I G6[-961920+963910]=G6[685316-683327](G6[-697865-(-699856)])J=G6[1479365865%11834911]G6[-619341+621330]=FT[J]G6[-759346+761337]=z[l[522657+-522654]]G6[588555-586563]=G6[-504971-(-506962)]()G6[209293+-207302]=z[l[583696-583692]]o=G6[1004705733%7849248]G6[-755120-(-757113)],FT,G6[92749688%13249670]=o,G6[588686+-586694],X G6[19309141%1930715][FT]=G6[-860435+862428]G6[6235981%623399]=z[l[779446-779444]]G6[872806009%13854032]=G6[408070+-406079](G6[-132611-(-134605)])G6[849887-847891],kT=793417-833736,G6[-800184+802177]G6[-667587-(-669581)]=z[l[-875844+875849]]G6[26026+-24035]=G6[2312290394%9634535][GT]J=G6[807066-805075]G6[1524188912%9962006]=z[l[333903-333901]]G6[-436433+438428]=G6[-664675+666669](G6[24739276%2061440])G6[169257+-167254],GT,I=4553804-770695,G6[-1044473-(-1046468)],289403399%4564782 G6[489011-487017]=J[GT]o=G6[274241744%1746750]G6[-768000+769997]=z[l[-621137+621142]]G6[-29198+31194]=G6[928909457%5954535][kT]GT,sT=G6[-776832-(-778830)],G6[1140741276%6199670]G6[791119-789122]=sT UT,G6[596408-594407]=G6[-980817+982814],sT and G6[1696753997%15286054]G6[-801702-(-803701)]=G6[506522+-504521]or G6[-453617+455619]X=G6[1457184495%9462224]elseif 1632013485%20754533>I then G6[-859595+861008],G6[-259539-(-260948)]=687337489%4773177,18446716617611-1040894 G6[1695780574%15557607]=z[l[-8414+8418]]G6[-695724-(-697136)]=O[G6[-960326+961739]]G6[138807-137397]=G6[-141211+142622][G6[1763503438%12332182]]G6[224359697%6598773],kT,G6[-591183+592596]=74192-74190,G6[-628335-(-629745)],-615153+574820 G6[1883385115%10235781]=z[l[560713790%3664796]]d=G6[-333512-(-334921)]G6[-962522+963934]=G6[763995033%4745302](G6[364315-362902])I,G6[-193726-(-195142)],v=4460683-(-357414),139905+8489996,G6[766538+-765126]G6[165948-164535]=z[l[-619137+619141]]X=G6[765573+-764157]G6[813198328%5767354]=O[G6[4054842800%16550373]]G6[466165-464754]=G6[626664-625251][G6[707375389%6736895]]jT=G6[-700487-(-701898)]G6[845732835%11428803]=jT(v,d)x=G6[1024459+-1023046]G6[-97613-(-99027)]=kT[x]sT=G6[444970-443556]G6[2526733697%15891398]=FT[sT]mT=G6[525493-524078]G6[272907+-271490]=mT GT=G6[141154319%12832082]else G6[460551+-460326],G6[143445+-143225],G6[317093+-316872]=I,v,w v,G6[-744615-(-744840)],X,G6[-806363-(-806589)],G6[1891180298%10222595]=G6[-660010+660231],4927199-(-125576),G6[577676+-577456],108035334%6230592,I G6[-437326+437550]=v and G6[900708+-900482]G6[1609566603%10123059]=G6[890918252%4713852]or G6[1437451077%6360402]X,I=G6[-945471+945693],15636219-(-128481)end else if 220855+12846546>I then j=z[l[494351737%10518122]]O=-387578-(-387779)X=j*O j=-846188-(-846445)W=X%j z[l[355566668%6708805]]=W j=z[l[246804673%3525781]]O=576595-576594 X=j~=O I=X and 1931299906%12705150 or 89461261%25472297 elseif I<210672+12896635 then OT,b,wT,G6[78377+-78322],X=277884+32335369141589,Q(594746+-632442),1382054372262-155939,28839830131275-(-287274),{c(605882-605881,C(i))}j=z[l[824211-824210]]lT,G6[850450-850397]=877681+18533190466885,7200660250133-(-454404)O=z[l[658903-658901]]u,p,G6[1695275617%7670930],w,r,T,d,QT=22126428518999-(-93672),485033+7679231682382,30878289888161-166775,573525183052-(-194239),125055+3828369251959,-244831+8545818758122,-609471+4566595982605,-763006+18446716339723 F=O(b,u)G6[-964393-(-964476)]=26644908434435-455564 W=j[F]u,v=Q(-177511+139800),18063689418375-763308 O=z[l[844432423%5344509]]a=4.4921536684594e+14%12834725124206 F=z[l[3806273366%15599481]]b=F(u,a)j=O[b]x=28294454658995-513084 F=z[l[-864869-(-864870)]]b=z[l[1015445081%10257021]]G6[316255-316193],G6[1543796397%13424316],P,a,dT=-409582+31312530946275,219017+26584637036754,-782628+25237642845964,Q(-470118-(-432255)),-962295+24201972062972 u=b(a,v)G6[-125467+125490],v,Y=13482241282637-457159,Q(679845-717569),3.1384667031924e+14%4828410366551 O=F[u]G6[-1024020+1024124],G6[423804-423719],S=31277103002674-(-591026),-57365+34910935441301,32235748572883-394289 b=z[l[129832+-129831]]M,N=-6917+4982197003285,33503604994695-30102 u=z[l[214457-214455]]UT,n=18506815240335-(-878874),533918+21355818254650 a=u(v,N)ZT,vT,G6[951047-950952],FT,iT=-121200+16103948351162,-997939+18991129664702,873269+29239533183482,2454295165622-(-428480),-725386+10292020110402 F=b[a]u=z[l[-738909-(-738910)]]a=z[l[110796428%6155357]]G6[-291588-(-291663)],N=28840458526214-(-726639),Q(384736+-422458)v=a(N,S)A=565281+5512654809574 b=u[v]y=859746+22367117118029 a=z[l[213542-213541]]v=z[l[-1024082-(-1024084)]]S=Q(714082+-751675)N=v(S,y)E=21555348144937-318452 u=a[N]y=Q(-147983-(-110467))v=z[l[429663-429662]]s6=28667062017951-371578 N=z[l[302157+-302155]]S=N(y,P)a=v[S]P=Q(149409+-187144)N=z[l[889434108%14580887]]S=z[l[1708210526%16747162]]IT=17366407976133-505135 y=S(P,M)bT,rT,M,G6[1064297752%7942520],G6[625513-625496]=-467318+31743625026355,777065+12456979708735,Q(202059+-239567),279340+5739679090500,684846+4435880957155 v=N[y]S=z[l[454736+-454735]]G6[-937022-(-937101)]=1.9108322883194e+15%15923602448407 y=z[l[815989-815987]]P=y(M,n)G6[-533709+533797],n=40055+26311200494437,Q(-832541+794904)N=S[P]y=z[l[308343+-308342]]gT,G6[749589+-749481]=3027821494306-522913,-1006904+22147849110913 P=z[l[130593-130591]]M=P(n,w)S=y[M]J=14106975873014-(-881075)P=z[l[855577-855576]]w=Q(229001-266653)M=z[l[248882726%2705247]]G6[500389+-500320]=32477608579745-939918 n=M(w,T)I6,MT,HT,WT=157552+12327202729724,-404044+18704238988369,-621431+31322275755120,27088934162676-(-729170)y=P[n]M=z[l[-546652+546653]]NT=10913+13201421856098 n=z[l[820833753%13456291]]T=Q(297540+-335089)w=n(T,Y)l6=957808+20710932514876 P=M[w]Y,G6[-1023968+1024000]=Q(713939+-751725),631514+4414755104045 n=z[l[-792967-(-792968)]]w=z[l[-530235-(-530237)]]T=w(Y,x)G6[1213806838%13638279]=142868+10817712088473 M=n[T]w=z[l[56355481%2087240]]x=Q(-642214-(-604543))T=z[l[-974532+974534]]Y=T(x,A)n=w[Y]A,AT,e6=Q(-928302+890565),10002685914967-1039654,-803341+23126830705694 T=z[l[-215582-(-215583)]]fT=2257827973623-345564 Y=z[l[11828+-11826]]o=-864930+29523637954646 x=Y(A,J)J=Q(618721+-656271)w=T[x]Y=z[l[-612801+612802]]x=z[l[1308941447%13778331]]A=x(J,d)G6[1249468103%16018821]=1901981374024-(-552237)T=Y[A]G6[-782557-(-782582)],G6[-588567+588618],d=12971194764644-(-461364),2752547773551-(-1009810),Q(277922-315585)x=z[l[-897349-(-897350)]]K,cT,L,t=35146532092449-162355,-934182+31367904901684,357987+10415686229135,18047205184878-963739 A=z[l[808223+-808221]]J=A(d,r)Y=x[J]r=Q(-149349-(-111617))A=z[l[1612333603%8143099]]J=z[l[775565587%9124301]]d=J(r,K)K=Q(-19681+-18059)x=A[d]J=z[l[152757028%3552489]]d=z[l[33411472%422930]]G6[506892-506794]=-821702+31784378270614 r=d(K,p)A=J[r]p=Q(200084+-237855)d=z[l[516634+-516633]]r=z[l[-79666-(-79668)]]K=r(p,t)t,jT=Q(-430821+393227),-476896+28419280534161 J=d[K]r=z[l[449727071%3101566]]CT=27139736186874-(-65891)K=z[l[-854642+854644]]G6[693907-693823]=-1032507+10706434806964 p=K(t,o)zT,o=34226478126193-(-272848),Q(-622718+585250)d=r[p]K=z[l[271252341%1595602]]G6[-340398-(-340501)]=29203445090891-(-109267)p=z[l[-604199-(-604201)]]t=p(o,E)r=K[t]G6[759869-759834]=26214868282273-(-705550)p=z[l[1633226864%16170563]]PT=23493440808803-(-443224)t=z[l[218080137%952315]]W6,E,Q6=-159153+15465639922130,Q(129810-167674),-770820+31432748219441 o=t(E,L)L,mT=Q(581470-619046),22431876539240-326299 K=p[o]G6[102809+-102763]=22498941239274-874238 t=z[l[-100719-(-100720)]]o=z[l[152212601%4612503]]E=o(L,mT)G6[668551+-668545]=27654989491565-(-787680)p=t[E]eT=658440+14081792101781 o=z[l[119142623%2590057]]mT=Q(-202414+164893)E=z[l[72684+-72682]]L=E(mT,QT)BT=-743125+8383731312148 t=o[L]E=z[l[472845475%3401766]]L=z[l[544163+-544161]]QT=Q(37181+-74832)mT=L(QT,IT)G6[-749346+749364],IT,z6=-943767+17431889331788,Q(-198898-(-161340)),32509297671352-819606 o=E[mT]G6[143473-143409]=35106932232899-971496 L=z[l[364988705%11405897]]mT=z[l[753283+-753281]]QT=mT(IT,zT)G6[-567264+567369],zT,G6[2204630766%13280908],G6[247425020%15464061]=-385434+2709009884807,Q(-808272+770787),1848208252104-(-861844),-552947+23100780419576 E=L[QT]mT=z[l[904269052%4498851]]QT=z[l[293876390%3767646]]IT=QT(zT,iT)iT=Q(636563+-674082)L=mT[IT]QT=z[l[1671898086%7300865]]ST=201703+26748874218688 IT=z[l[-702945+702947]]nT,RT,pT=32749957470145-(-713681),34151152542797-91695,5839696999084-174093 zT=IT(iT,CT)CT=Q(18555-56392)mT=QT[zT]IT=z[l[-714924-(-714925)]]zT=z[l[-683780+683782]]iT=zT(CT,lT)XT=9968251514802-73105 QT=IT[iT]lT=Q(439704-477561)zT=z[l[20097+-20096]]kT=12275578119850-(-733098)iT=z[l[773076903%4629203]]G6[163151-163080]=6346284731828-(-179671)CT=iT(lT,WT)IT=zT[CT]LT,WT=596165+11622703889503,Q(-191781-(-154172))iT=z[l[721341233%2908634]]aT,G6[-859409+859511]=9382467709476-760083,225685+5769111017705 CT=z[l[-716968+716970]]lT=CT(WT,eT)sT=12401025275708-(-360274)zT=iT[lT]CT=z[l[-13224-(-13225)]]lT=z[l[-623806+623808]]eT,oT=Q(84179-121886),570953+15484800886241 WT=lT(eT,cT)iT=CT[WT]lT=z[l[35785117%8946279]]WT=z[l[218606658%2954144]]cT=Q(564193+-601905)eT=WT(cT,XT)yT=576068+18033234384521 CT=lT[eT]GT,F6,XT=23335222777921-(-201265),16976131708729-915544,Q(-786553-(-749015))WT=z[l[49306537%16435512]]eT=z[l[3136086802%13459600]]cT=eT(XT,sT)sT,ET=Q(428898-466629),-301158+29174920105335 lT=WT[cT]eT=z[l[110048+-110047]]VT,qT=33401477274535-220902,406860+6762923071233 cT=z[l[-325935-(-325937)]]XT=cT(sT,jT)jT=Q(-474294+436610)WT=eT[XT]cT=z[l[906948+-906947]]XT=z[l[898027314%6603142]]sT=XT(jT,OT)OT=Q(858966+-896493)eT=cT[sT]V6,KT,i6=7593665054863-(-607553),-462533+22517253273530,33652735502781-601223 XT=z[l[132267-132266]]sT=z[l[-322624+322626]]jT=sT(OT,FT)FT=Q(514582+-552263)cT=XT[jT]DT,xT=339088+2219987113849,25366255779071-282331 sT=z[l[222769-222768]]jT=z[l[-572836-(-572838)]]OT=jT(FT,VT)XT=sT[OT]jT=z[l[-801766+801767]]VT,G6[-771821-(-771891)]=Q(104795+-142543),-371791+20895723786833 OT=z[l[-334802-(-334804)]]FT=OT(VT,UT)UT=Q(-832574-(-794929))sT=jT[FT]OT=z[l[191437+-191436]]FT=z[l[-96853-(-96855)]]VT=FT(UT,gT)jT=OT[VT]FT=z[l[-562995+562996]]g6,gT=856743+32374133991484,Q(19629-57289)VT=z[l[1271309014%9146108]]UT=VT(gT,qT)qT=Q(-404140-(-366363))OT=FT[UT]VT=z[l[2585927219%16470874]]UT=z[l[-911632+911634]]gT=UT(qT,GT)GT=Q(523648-561345)FT=VT[gT]hT=913623+704497487985 UT=z[l[-650773-(-650774)]]gT=z[l[-51656-(-51658)]]qT=gT(GT,HT)VT=UT[qT]HT,G6[-70357-(-70358)],G6[-551188-(-551193)]=Q(-579039+541305),-983667+30999620188886,218037+9888898727495 gT=z[l[834919+-834918]]qT=z[l[-656777-(-656779)]]GT=qT(HT,kT)G6[-524591+524636]=-331841+34037542686250 UT=gT[GT]G6[872825+-872822]=461205+15198009332240 qT=z[l[130521733%10876811]]kT=Q(490881+-528664)GT=z[l[875916+-875914]]HT=GT(kT,fT)G6[-734783+734857],fT=-764419+32124271109234,Q(-750797+713068)gT=qT[HT]GT=z[l[-745957+745958]]HT=z[l[959034+-959032]]kT=HT(fT,hT)qT=GT[kT]hT,G6[199833-199786]=Q(173866+-211436),26730793451972-86309 HT=z[l[-886740+886741]]kT=z[l[1105114882%13813936]]JT=25984865655778-(-480098)fT=kT(hT,ZT)GT=HT[fT]ZT,G6[-766929-(-766958)]=Q(76626+-114313),-710922+8599509346478 kT=z[l[821629+-821628]]fT=z[l[-666178-(-666180)]]hT=fT(ZT,DT)DT,G6[430984662%2123077]=Q(-691345-(-653710)),25760185950970-144415 HT=kT[hT]fT=z[l[927690-927689]]hT=z[l[-599204-(-599206)]]ZT=hT(DT,BT)BT,C6,uT=Q(581522+-619334),-665364+24160050221830,-412324+29939078807833 kT=fT[ZT]YT,G6[-1024315-(-1024349)]=15398003722306-(-316352),715679+5773822779105 hT=z[l[2363035165%14408751]]ZT=z[l[-1032090+1032092]]DT=ZT(BT,RT)fT=hT[DT]j6=-30486+24073799213792 ZT=z[l[1542454201%8569190]]RT=Q(-778886+741097)DT=z[l[-422959-(-422961)]]BT=DT(RT,bT)hT=ZT[BT]bT=Q(-663014-(-625547))DT=z[l[93406-93405]]BT=z[l[141927-141925]]RT=BT(bT,uT)ZT=DT[RT]BT=z[l[-100891+100892]]RT=z[l[-1014807-(-1014809)]]G6[-36635-(-36676)],uT=8446443572754-(-262475),Q(491207+-528956)bT=RT(uT,aT)DT=BT[bT]RT=z[l[1080113412%4887391]]bT=z[l[-545322-(-545324)]]aT,G6[324949+-324921]=Q(785004+-822724),20564861429133-540709 uT=bT(aT,vT)BT=RT[uT]bT=z[l[1558082321%11627480]]uT=z[l[161828462%899047]]U6,vT=258225+33434032851999,Q(320503+-358241)aT=uT(vT,NT)RT=bT[aT]NT,G6[1984522214%13056067]=Q(-280972-(-243501)),5361738161972-(-977548)uT=z[l[-1024963-(-1024964)]]aT=z[l[213301952%8532078]]m6=8056101819665-493162 vT=aT(NT,ST)bT=uT[vT]aT=z[l[-861233+861234]]TT=758322+32786030586225 vT=z[l[760910-760908]]ST=Q(326319+-363801)NT=vT(ST,yT)G6[454206115%2874722]=316313+18350879706568 uT=aT[NT]vT=z[l[350272852%1742651]]yT=Q(269424+-306931)NT=z[l[964070+-964068]]ST=NT(yT,PT)aT=vT[ST]NT=z[l[626643+-626642]]G6[1837465454%12939897]=72555893411754%24185299071446 ST=z[l[-62007+62009]]PT=Q(1008759-1046311)yT=ST(PT,MT)vT=NT[yT]MT=Q(-1022301+984773)ST=z[l[998042-998041]]yT=z[l[939169856%14907458]]PT=yT(MT,wT)G6[278341-278280],wT=7189174830489-964742,Q(-1063386-(-1025746))NT=ST[PT]yT=z[l[2760279769%12779073]]PT=z[l[104162386%13020298]]MT=PT(wT,YT)G6[339913+-339891]=24081768000526-(-147391)ST=yT[MT]YT=Q(-267712+230176)PT=z[l[2928028580%13130173]]MT=z[l[21794-21792]]wT=MT(YT,TT)yT=PT[wT]TT=Q(-874750-(-837167))MT=z[l[-845092-(-845093)]]wT=z[l[-993951+993953]]G6[-914748+914847]=717664+34607197719443 YT=wT(TT,nT)PT=MT[YT]wT=z[l[388340-388339]]YT=z[l[871844+-871842]]nT=Q(-433342+395760)TT=YT(nT,xT)MT=wT[TT]YT=z[l[-427943-(-427944)]]xT=Q(-238398-(-200622))TT=z[l[290061+-290059]]nT=TT(xT,AT)AT,G6[-707489-(-707501)]=Q(868370+-906056),1.3704687961421e+14%19578125913489 wT=YT[nT]TT=z[l[972975-972974]]nT=z[l[179423519%3147781]]G6[-827670+827696]=709570+10349846920977 xT=nT(AT,JT)YT=TT[xT]nT=z[l[807433+-807432]]G6[364620-364557],JT=4414528964956-(-573099),Q(-563392-(-525611))xT=z[l[763939-763937]]AT=xT(JT,KT)TT=nT[AT]KT=Q(-311789+274159)xT=z[l[-727879-(-727880)]]AT=z[l[-251992-(-251994)]]JT=AT(KT,rT)nT=xT[JT]tT=336443+30964894242328 AT=z[l[1850249350%11351223]]JT=z[l[-884917-(-884919)]]rT=Q(63432+-101217)KT=JT(rT,dT)dT=Q(192474+-230282)xT=AT[KT]G6[1007048-1007040]=15728596726039-939131 JT=z[l[385550543%14828867]]KT=z[l[162561926%2580348]]rT=KT(dT,pT)pT=Q(-985094+947618)AT=JT[rT]KT=z[l[2389936977%12193556]]rT=z[l[73534+-73532]]G6[676977-676956]=32897527761226-(-406157)dT=rT(pT,oT)oT=Q(54245+-92089)JT=KT[dT]rT=z[l[480200-480199]]G6[-526353+526446]=629637+32558792269748 dT=z[l[-765621+765623]]q6=5195324574674-(-327073)pT=dT(oT,tT)c6=6.344517851371e+14%30211989889086 KT=rT[pT]dT=z[l[364357-364356]]pT=z[l[88291-88289]]G6[-356493-(-356604)],tT=11148771450097-182442,Q(-400026+362233)oT=pT(tT,ET)ET=Q(389229-426741)rT=dT[oT]G6[274491299%13724564]=26756844118194-716807 pT=z[l[-410509+410510]]oT=z[l[423636-423634]]tT=oT(ET,LT)X6=14018743031386-(-901925)dT=pT[tT]LT=Q(-602400+564782)oT=z[l[722476+-722475]]tT=z[l[-811539+811541]]ET=tT(LT,m6)pT=oT[ET]m6,G6[265854+-265840]=Q(-680389-(-642838)),5967519596076-766802 tT=z[l[156382+-156381]]ET=z[l[1600620266%14820558]]LT=ET(m6,Q6)oT=tT[LT]ET=z[l[547687-547686]]O6,G6[1630611104%12168739],G6[603684584%4989128],Q6=-277476+32051979171377,-644961+20386881158262,34460775574034-732003,Q(70072-107867)LT=z[l[-747692-(-747694)]]m6=LT(Q6,I6)tT=ET[m6]I6=Q(744514-782128)LT=z[l[352046-352045]]m6=z[l[2152157574%15483148]]Q6=m6(I6,C6)ET=LT[Q6]C6=Q(-987781+949930)m6=z[l[-930731-(-930732)]]Q6=z[l[1305743939%15008551]]I6=Q6(C6,i6)LT=m6[I6]i6=Q(-760182-(-722539))Q6=z[l[709216201%4728108]]I6=z[l[-420601-(-420603)]]C6=I6(i6,l6)m6=Q6[C6]I6=z[l[476752561%3972938]]C6=z[l[348052742%16573940]]l6,G6[-766136-(-766156)]=Q(232344+-270094),34647868481014-(-516368)i6=C6(l6,e6)Q6=I6[i6]C6=z[l[826167105%12908861]]i6=z[l[274908-274906]]e6=Q(-453195-(-415712))l6=i6(e6,c6)I6=C6[l6]c6=Q(-2988-34555)i6=z[l[808471373%9083948]]l6=z[l[371994716%3179442]]e6=l6(c6,W6)C6=i6[e6]W6=Q(-149440-(-111757))l6=z[l[2815254001%14437200]]e6=z[l[1014189-1014187]]c6=e6(W6,z6)i6=l6[c6]e6=z[l[791124+-791123]]z6=Q(-459299-(-421584))c6=z[l[1645114857%7651697]]W6=c6(z6,X6)l6=e6[W6]X6,G6[-882317+882353]=Q(-1028749-(-991058)),1.6258246794234e+14%2622298093547 c6=z[l[-711160+711161]]W6=z[l[-641184+641186]]G6[-377997+377999],G6[-866384+866388]=-366113+22556018605864,21800112769207-(-466672)z6=W6(X6,s6)e6=c6[z6]W6=z[l[-352973-(-352974)]]z6=z[l[346588602%4030100]]s6,G6[-910607-(-910644)]=Q(-845432+807960),33428813625365-(-148665)X6=z6(s6,j6)c6=W6[X6]z6=z[l[-158829-(-158830)]]j6=Q(-23490-14275)X6=z[l[-905988-(-905990)]]s6=X6(j6,O6)W6=z6[s6]X6=z[l[1396575265%14250768]]s6=z[l[-708755-(-708757)]]O6=Q(-841108+803255)j6=s6(O6,F6)G6[454853569%2790512],G6[953733-953720]=830417+8142646354686,14654336405565-374166 z6=X6[j6]F6=Q(-815152+777467)s6=z[l[180415+-180414]]G6[2521534511%16060729]=1827434513876-(-212350)j6=z[l[797696+-797694]]O6=j6(F6,V6)X6=s6[O6]j6=z[l[-891461-(-891462)]]O6=z[l[-725048+725050]]V6=Q(-869842-(-832238))F6=O6(V6,U6)G6[385184+-385173],U6=-389010+9719143874879,Q(-548749+511220)s6=j6[F6]G6[-262062-(-262121)]=-249029+5552344979166 O6=z[l[-102315+102316]]F6=z[l[755591+-755589]]V6=F6(U6,g6)g6=Q(-1045011+1007238)j6=O6[V6]F6=z[l[162544+-162543]]V6=z[l[-300244-(-300246)]]U6=V6(g6,q6)O6=F6[U6]V6=z[l[122704163%2115589]]U6=z[l[368292266%15345511]]q6,G6[-781628-(-781705)]=Q(931501-969215),130144+19438838474491 g6=U6(q6,G6[112508+-112507])F6=V6[g6]U6=z[l[404259+-404258]]g6=z[l[456061-456059]]G6[2264480552%14423443]=Q(549512+-587051)q6=g6(G6[-320162-(-320163)],G6[-575713+575715])G6[2834070443%11291117],G6[1868082350%7882204]=-54576+12634545122347,Q(-46701-(-9052))V6=U6[q6]g6=z[l[488618-488617]]q6=z[l[233266+-233264]]G6[502888918%9860567]=q6(G6[621891-621889],G6[-432133+432136])G6[-459088-(-459170)],G6[-1014876-(-1014879)]=-872595+18676146631307,Q(726516-764160)U6=g6[G6[42850657%621024]]q6=z[l[-132334-(-132335)]]G6[60705+-60704]=z[l[-738956-(-738958)]]G6[155478-155463]=31905326643731-(-376822)G6[1344805058%6003594]=G6[138429+-138428](G6[-726885+726888],G6[-702705-(-702709)])g6=q6[G6[1104849308%11160094]]G6[610001151%11090930]=z[l[663016-663015]]G6[419863+-419859]=Q(-463567+425975)G6[916071158%5033358]=z[l[86534+-86532]]G6[833418+-833415]=G6[322198-322196](G6[754222+-754218],G6[951276-951271])q6=G6[1103994849%5282272][G6[-477348+477351]]G6[2439250709%14264624],G6[-186129+186145]=Q(-113102+75333),-918764+3630014401414 G6[1190985014%4726131]=z[l[-645576-(-645577)]]G6[1959039111%12092834]=z[l[191922+-191920]]G6[286241-286237]=G6[-385981+385984](G6[244905-244900],G6[-123910+123916])G6[3253922894%14723633]=G6[377525+-377523][G6[443205376%4388172]]G6[735071439%4537478]=z[l[650209456%4249735]]G6[-1699+1703]=z[l[703069226%10652564]]G6[643482272%2703707],G6[1191368696%7995763]=Q(-153124+115281),7955418704426-(-926798)G6[1636562191%16203586]=G6[383891+-383887](G6[338467006%1692335],G6[3290671%62088])G6[1471919299%9878653]=G6[10069+-10066][G6[361494164%9269081]]G6[-407957+407961]=z[l[-524774-(-524775)]]G6[1039974+-1039964],G6[932823-932816]=304389+6598234400507,Q(956794-994554)G6[-105680+105685]=z[l[-248492-(-248494)]]G6[-238339+238345]=G6[844549-844544](G6[1813+-1806],G6[737708273%16393517])G6[-950026-(-950078)]=2459612417031-(-292978)G6[442991-442988]=G6[206160284%10308014][G6[-393117+393123]]G6[125424935%8361662]=z[l[222549118%10597577]]G6[203019+-203011]=Q(866928+-904547)G6[-891930-(-891936)]=z[l[-347683-(-347685)]]G6[1125474287%16078204]=G6[293492358%3057212](G6[-802083-(-802091)],G6[356253+-356244])G6[339944912%1650218]=G6[606381053%2406274][G6[-780793+780800]]G6[1444810958%6815146]=z[l[473638-473637]]G6[-1042653-(-1042662)]=Q(-797907+760384)G6[518788+-518781]=z[l[832841-832839]]G6[11689+-11681]=G6[452928-452921](G6[3300185934%14667493],G6[-164794+164804])G6[1943128940%16467194]=340641+3289051550554 G6[-667044+667049]=G6[274491+-274485][G6[-859490-(-859498)]]G6[151439-151429],G6[-177232-(-177256)]=Q(-309539+272055),26380217266330-(-442210)G6[-513652+513659]=z[l[-244706-(-244707)]]G6[1088142320%9545108]=z[l[-846735+846737]]G6[-144348-(-144357)]=G6[-374535+374543](G6[-174862+174872],G6[555188-555177])G6[-767418+767424]=G6[138621662%8154215][G6[-671068-(-671077)]]G6[-227410+227418]=z[l[227244-227243]]G6[-462658-(-462669)],G6[3115189590%13369912]=Q(-663820+626231),30725502873570-(-985089)G6[941257-941248]=z[l[-545273+545275]]G6[29731525%900955]=G6[2317863810%9161517](G6[-222622-(-222633)],G6[-26322-(-26334)])G6[-722561-(-722568)]=G6[1735012310%7643226][G6[593294344%2672497]]G6[-359777-(-359786)]=z[l[407326+-407325]]G6[838302475%10887045]=z[l[-279361-(-279363)]]G6[726016368%5902572],G6[1007924-1007835]=Q(-280243-(-242684)),22127801814104-779288 G6[389297-389286]=G6[742775-742765](G6[246451-246439],G6[743381-743368])G6[1665792872%10282672]=G6[-675378+675387][G6[1006588031%9868510]]G6[7181+-7171]=z[l[251723+-251722]]G6[579381+-579368]=Q(386151-423833)G6[827085-827074]=z[l[270144-270142]]G6[-954047+954059]=G6[3019578191%12126820](G6[473390+-473377],G6[-113830+113844])G6[453897-453888]=G6[497847+-497837][G6[2361755872%12430294]]G6[-773911+773922]=z[l[-529822-(-529823)]]G6[861941-861927]=Q(-613373-(-575732))G6[792609+-792597]=z[l[471534+-471532]]G6[-530523-(-530609)]=20300366021408-(-287181)G6[-630083+630096]=G6[-522629+522641](G6[800757434%11605180],G6[325512-325497])G6[-904624-(-904634)]=G6[74556752%10650963][G6[84456+-84443]]G6[175837+-175825]=z[l[-985237+985238]]G6[255202521%5934942]=Q(-1009405+971748)G6[299838+-299825]=z[l[894226-894224]]G6[1121578164%11444675]=G6[665610+-665597](G6[44806799%2036672],G6[1585132750%15540517])G6[-958096+958107]=G6[781704+-781692][G6[320689+-320675]]G6[-514757-(-514770)]=z[l[1010516010%10005109]]G6[2310033950%13750202]=z[l[2754826106%11823288]]G6[143073-143057]=Q(-1010789+973047)G6[893596-893581]=G6[-329779+329793](G6[1662637146%10796345],G6[724600-724583])G6[242427532%3787930]=G6[960608767%5082586][G6[896104596%15721133]]G6[483393909%2358019]=z[l[2260584246%13868615]]G6[1875855031%15502934]=Q(780677-818482)G6[74240415%1237340]=z[l[-401738-(-401740)]]G6[-78946-(-78962)]=G6[-850078+850093](G6[9670-9653],G6[-812767+812785])G6[-802796+802864],G6[228446306%8158796]=-389119+146423984195,Q(-973957+936324)G6[106297+-106284]=G6[-340432-(-340446)][G6[895492+-895476]]G6[-514331+514346]=z[l[67602-67601]]G6[88542-88526]=z[l[420114242%2308320]]G6[357865+-357848]=G6[-975277-(-975293)](G6[31223+-31205],G6[69786+-69767])G6[386645+-386631]=G6[-519709+519724][G6[1100324233%6709294]]G6[2549247682%10490731]=-135516+4746456783358 G6[898915996%10962390]=z[l[-809079-(-809080)]]G6[2168842044%9725749]=z[l[-973259+973261]]G6[1665657389%12812749],G6[292740-292713]=Q(329387-367126),581321+8171975815188 G6[793222+-793204]=G6[-1001763+1001780](G6[3201342097%12653526],G6[473659270%1894637])G6[854801-854786]=G6[537124060%7898883][G6[-486550-(-486568)]]G6[3737322885%15316897]=z[l[812299+-812298]]G6[-1017031-(-1017049)]=z[l[-536967-(-536969)]]G6[3467849587%15691627]=Q(-250023-(-212189))G6[100077+-100058]=G6[1687108185%8150281](G6[-706730-(-706750)],G6[347252+-347231])G6[703366204%3588603]=G6[255199+-255182][G6[174850+-174831]]G6[-563659+563677]=z[l[669938+-669937]]G6[263045-263024]=Q(-714921-(-677426))G6[-878801+878820]=z[l[299293-299291]]G6[400344944%14298033]=G6[11279159%2255828](G6[993964755%7888609],G6[1736825528%10277074])G6[-354642+354659]=G6[-61500+61518][G6[658357-658337]]G6[-425465-(-425484)]=z[l[1366145%52544]]G6[157200092%15720007]=Q(761746-799560)G6[562321252%6857576]=z[l[474021-474019]]G6[482576-482495],G6[-544207-(-544317)]=14023142365271%3505789765117,963666+24650872567940 G6[-6683-(-6704)]=G6[-601192+601212](G6[198143786%3810457],G6[381177+-381154])G6[-978952-(-978970)]=G6[538151+-538132][G6[777545-777524]]G6[2659496894%12910179]=z[l[400949212%10280749]]G6[223585320%10646919]=z[l[599010374%16639177]]G6[615765-615742]=Q(-742349-(-704644))G6[-85842-(-85864)]=G6[304825-304804](G6[-396373-(-396396)],G6[926698-926674])G6[7180-7161]=G6[133471070%767075][G6[483579-483557]]G6[51316-51295]=z[l[-877620-(-877621)]]G6[869740855%6639243]=z[l[842579-842577]]G6[-517300-(-517324)]=Q(-777353-(-739765))G6[-977775-(-977798)]=G6[447945625%6309093](G6[-383714+383738],G6[2125863050%9887735])G6[-118873+118893]=G6[513132-513111][G6[-537577+537600]]G6[1401649129%7338477]=z[l[-974550+974551]]G6[-114264-(-114289)]=Q(-525746+487984)G6[29442-29419]=z[l[879369+-879367]]G6[992258-992234]=G6[435046+-435023](G6[-94720-(-94745)],G6[-712396-(-712422)])G6[-933826+933852]=Q(56374+-93995)G6[-1024412-(-1024433)]=G6[868654-868632][G6[193483-193459]]G6[807943+-807920]=z[l[809014-809013]]G6[3542406664%14518060]=z[l[1216672%4966]]G6[140488405%3121964]=G6[644536488%13427843](G6[51235-51209],G6[-1011520+1011547])G6[202012-201985]=Q(-543501-(-506028))G6[268888+-268866]=G6[154263+-154240][G6[303866-303841]]G6[260030-260006]=z[l[-7255+7256]]G6[-403890-(-403915)]=z[l[-60726+60728]]G6[937757231%7383915]=G6[695518+-695493](G6[1255229859%5505394],G6[-468601-(-468629)])G6[454174611%16220521]=G6[781990-781966][G6[-525332+525358]]G6[-94819+94844]=z[l[328158+-328157]]G6[9258923%3086299]=z[l[945302-945300]]G6[-155205+155233],G6[701827+-701767]=Q(-14785-22772),35184145315281-(-576046)G6[-781869+781896]=G6[-276021-(-276047)](G6[531291-531263],G6[2661310604%15207489])G6[-65333-(-65357)]=G6[626363425%3212120][G6[940135-940108]]G6[541236+-541210]=z[l[3384998657%13222651]]G6[-369500+369529],G6[-939208-(-939250)]=Q(351754-389590),28070023245793-(-262958)G6[680672+-680645]=z[l[73480703%757533]]G6[362059948%9051498]=G6[-165124-(-165151)](G6[214631201%15330798],G6[-75370-(-75400)])G6[2352123511%13755108]=25777985525567-92252 G6[7751510%7751485]=G6[2192180016%9058595][G6[951315154%5344467]]G6[1966930669%9548207]=z[l[404482-404481]]G6[256274228%1408100]=z[l[-439691+439693]]G6[-225768+225808],G6[-926999+927099],G6[355863102%11120721]=719075+6199860580964,23463766825816-995498,Q(-902383-(-864749))G6[439075773%2071112]=G6[13716403%914425](G6[450887+-450857],G6[860013+-859982])G6[1396608843%6179685]=137165+27917757242107 G6[2200966644%12364981]=G6[321400-321373][G6[2373056183%9530346]]G6[755356+-755325]=Q(195572+-233063)G6[535186306%8108883]=z[l[867923-867922]]G6[-267079-(-267108)]=z[l[2003893564%11257829]]G6[863718448%3706946]=G6[806001498%8857159](G6[-309641-(-309672)],G6[212950783%16380827])G6[353828+-353796]=Q(-475031-(-437286))G6[1367470703%9562732]=G6[533525+-533497][G6[598545180%2850215]]G6[-862836+862865]=z[l[-931703+931704]]G6[-1010034+1010064]=z[l[199376522%13291768]]G6[1012841-1012810]=G6[517632948%15685846](G6[708016+-707984],G6[-582584-(-582617)])G6[-55158-(-55186)]=G6[1005923-1005894][G6[102348889%1795594]]G6[-820178-(-820211)]=Q(503754+-541584)G6[-970339-(-970369)]=z[l[-124157-(-124158)]]G6[122557405%13617486]=z[l[-860883+860885]]G6[380337-380305]=G6[-679972+680003](G6[1785771705%7471848],G6[1342143914%9586742])G6[-628669-(-628698)]=G6[413084011%2096873][G6[36876-36844]]G6[-613297+613328]=z[l[92929025%1452016]]G6[-475695-(-475729)]=Q(-982590-(-944836))G6[1273270212%13991980]=z[l[-483625+483627]]G6[78895455%13149237]=G6[675880032%8448500](G6[554168-554134],G6[-268278+268313])G6[-547864+547899]=Q(-548574-(-510874))G6[-253262+253292]=G6[119645-119614][G6[671538-671505]]G6[661240656%15028196]=z[l[153434-153433]]G6[-166951+166984]=z[l[-581641-(-581643)]]G6[-693159-(-693193)]=G6[197663325%5490647](G6[-805117-(-805152)],G6[13320-13284])G6[-816376-(-816412)]=Q(546865+-584433)G6[82825-82794]=G6[-595805-(-595837)][G6[3019-2985]]G6[-138223-(-138256)]=z[l[-914872-(-914873)]]G6[1255407554%13214816]=z[l[-514715+514717]]G6[2532793845%15166430]=G6[859070+-859036](G6[653674+-653638],G6[25573+-25536])G6[-222235-(-222267)]=G6[407518998%3881133][G6[875394775%3979067]]G6[298611996%1901987]=Q(-426488+388963)G6[-800937-(-800971)]=z[l[-680341-(-680342)]]G6[99758+-99723]=z[l[-300680-(-300682)]]G6[429512-429476]=G6[1418027805%16488695](G6[-488333+488370],G6[542863+-542825])G6[2799834218%14892735]=Q(-876137-(-838326))G6[111802455%980723]=G6[246596-246562][G6[-165311-(-165347)]]G6[860664+-860629]=z[l[492397045%12009684]]G6[535660-535624]=z[l[1842355802%12282372]]G6[-926529+926566]=G6[-244302-(-244338)](G6[446227710%5070769],G6[710578-710539])G6[180743576%9512818]=G6[2754189867%14968423][G6[-349552+349589]]G6[-603070+603106]=z[l[-478346-(-478347)]]G6[-366989-(-367062)]=128537+13781374690040 G6[-570465-(-570502)]=z[l[-71009+71011]]G6[533064391%16658261]=Q(278704+-316288)G6[158299+-158261]=G6[678535-678498](G6[833740947%5344493],G6[434448568%11432856])G6[-671442+671477]=G6[50289394%7184194][G6[-851531-(-851569)]]G6[506611+-506545]=304962+30629398220916 G6[2835933031%11965962]=z[l[1576303676%7331645]]G6[-551143+551183]=Q(-36565+-1112)G6[-88059+88097]=z[l[1032289+-1032287]]G6[-93890-(-93929)]=G6[165118+-165080](G6[-189645+189685],G6[2920025576%14244027])G6[784691-784655]=G6[471958203%2987077][G6[136383+-136344]]G6[1574542616%16066761]=z[l[-610364+610365]]G6[-377426-(-377465)]=z[l[-17311-(-17313)]]G6[-80141+80182]=Q(-244780-(-207157))G6[796615-796575]=G6[171626+-171587](G6[-300951-(-300992)],G6[-97454+97496])G6[871603247%11939770]=G6[-933547+933585][G6[-660289-(-660329)]]G6[-457455-(-457494)]=z[l[-521856-(-521857)]]G6[856467514%4369732],G6[343258+-343208]=Q(766799+-804406),1047712+18303263614123 G6[549761241%4543481]=z[l[-220960+220962]]G6[938905+-938864]=G6[5420013%5419973](G6[-376199+376241],G6[1851568663%11221628])G6[-243318-(-243356)]=G6[425548539%2182300][G6[-387201-(-387242)]]G6[-1042823-(-1042863)]=z[l[-787568+787569]]G6[-982598+982641]=Q(821864+-859395)G6[-413542+413583]=z[l[69329+-69327]]G6[-637494-(-637536)]=G6[165439362%1606207](G6[-567655+567698],G6[702902771%6332457])G6[130463+-130424]=G6[2377363400%11057504][G6[2296869306%15110982]]G6[1613780801%11866035]=z[l[-777609-(-777610)]]G6[-449839+449881]=z[l[629983-629981]]G6[889793+-889686],G6[41298-41254]=458440+8727276097815,Q(-816862-(-779106))G6[810457-810414]=G6[592615248%10396758](G6[321394+-321350],G6[-357403-(-357448)])G6[441429+-441389]=G6[391694501%13056482][G6[-891575-(-891618)]]G6[-297412+297454]=z[l[-280645+280646]]G6[614236895%8300498]=z[l[371604+-371602]]G6[570584-570539]=Q(-511022-(-473407))G6[611716596%8048902]=G6[81246-81203](G6[631672-631627],G6[-878134+878180])G6[3022126484%15990087]=G6[361642642%4063400][G6[301805-301761]]G6[-681285-(-681328)]=z[l[-15522+15523]]G6[498829-498783]=Q(-120960+83232)G6[976224293%8067969]=z[l[-1005192+1005194]]G6[-908546-(-908591)]=G6[871895+-871851](G6[126737921%5069515],G6[465827097%3583285])G6[-927489-(-927531)]=G6[-501466+501509][G6[-281306+281351]]G6[-153489+153545],G6[63893-63846],G6[51759+-51705]=-7015+20171855953944,Q(292993+-330502),16234790377030-751807 G6[1167294824%9567990]=z[l[-484448+484449]]G6[801187-801142]=z[l[-809558-(-809560)]]G6[992805640%4750266]=G6[283776+-283731](G6[1280409472%11133995],G6[102257-102209])G6[612977+-612934]=G6[-531821-(-531865)][G6[-528517+528563]]G6[566323-566278]=z[l[304927+-304926]]G6[-321450-(-321496)]=z[l[-943350+943352]]G6[118181-118133]=Q(-622137-(-584434))G6[-671959+672006]=G6[781481084%13473811](G6[1872040604%8587342],G6[-479066-(-479115)])G6[912093+-912049]=G6[-852256-(-852301)][G6[-137145-(-137192)]]G6[468924+-468878]=z[l[419444191%2006910]]G6[57945-57898]=z[l[210627-210625]]G6[-529611+529660],G6[196052+-195985]=Q(486964-524791),2544843321975-(-70186)G6[-614411-(-614459)]=G6[905785+-905738](G6[875935-875886],G6[411075-411025])G6[2004767854%16568329]=G6[415534-415488][G6[-441480+441528]]G6[1639502726%6505963]=Q(-640483-(-602645))G6[212773472%14184895]=z[l[-753243+753244]]G6[-184184-(-184232)]=z[l[3754260470%14897859]]G6[150480175%8360007]=G6[1717699656%10347588](G6[331609+-331559],G6[1458858364%8950051])G6[155972-155921]=Q(607496+-645242)G6[1810517950%10587824]=G6[-844910-(-844957)][G6[747983+-747934]]G6[-1042416-(-1042464)]=z[l[94781-94780]]G6[-915613-(-915662)]=z[l[125805-125803]]G6[-713809+713859]=G6[-909459+909508](G6[-769741+769792],G6[471070-471018])G6[-990388-(-990440)]=Q(981174-1018643)G6[409452459%12042718]=G6[-985937-(-985985)][G6[352936-352886]]G6[-235663+235712]=z[l[-499400+499401]]G6[837797-837705]=-529889+29316975430452 G6[-841231-(-841281)]=z[l[237515-237513]]G6[-43549-(-43600)]=G6[-255460+255510](G6[604555-604503],G6[-382682-(-382735)])G6[-636724-(-636777)]=Q(344802+-382606)G6[-634602+634650]=G6[-590755-(-590804)][G6[-832452+832503]]G6[2207636403%8937799]=z[l[-177613+177614]]G6[-708105+708156]=z[l[-557607+557609]]G6[-358271-(-358323)]=G6[2270768568%14281563](G6[39623733%3962368],G6[2739691554%13046150])G6[93305773%7775477]=G6[-483627-(-483677)][G6[-578018-(-578070)]]G6[1016056+-1016005]=z[l[1231604858%6067019]]G6[396380680%9437634]=z[l[733247-733245]]G6[100246-100192]=Q(895035-932512)G6[-595936-(-595989)]=G6[980350500%5570173](G6[478615590%2357712],G6[1722757351%16564974])G6[-593800-(-593850)]=G6[-727371-(-727422)][G6[-991893+991946]]G6[-313777-(-313829)]=z[l[2548691307%10708787]]G6[2463883015%10266179]=Q(288674+-326194)G6[-784490+784543]=z[l[2159331230%14113276]]G6[665837-665783]=G6[926835+-926782](G6[-692632+692687],G6[-478086+478142])G6[1068797207%4258156]=G6[96167+-96115][G6[7384-7330]]G6[-227070-(-227123)]=z[l[-619034-(-619035)]]G6[1654515609%10027367]=z[l[-466224+466226]]G6[21125-21069]=Q(-731124+693346)G6[1344644527%7347784]=G6[-34057-(-34111)](G6[1035603+-1035547],G6[-177625+177682])G6[1086876844%6709116]=G6[-679866+679919][G6[-600937-(-600992)]]G6[107128854%446370]=z[l[162948493%999684]]G6[-899917+899974]=Q(-1041264-(-1003625))G6[1107418936%16049549]=z[l[1208044994%7190744]]G6[283327-283271]=G6[2412005104%10351953](G6[-943376+943433],G6[497938742%5412377])G6[512162+-512109]=G6[-417517-(-417571)][G6[355623104%16164684]]G6[-1043965-(-1044023)]=Q(-1040523-(-1003027))G6[-244434-(-244489)]=z[l[180730+-180729]]G6[59760120%2298464]=z[l[-797049-(-797051)]]G6[143685+-143628]=G6[-479852-(-479908)](G6[22534414%433353],G6[897768-897709])G6[3041282751%13638039]=G6[1353032938%5433867][G6[-217256-(-217313)]]G6[922089488%8307112]=z[l[389500-389499]]G6[-631917-(-631974)]=z[l[466827922%3590984]]G6[1074510360%4495859]=Q(47085-84702)G6[-529863-(-529921)]=G6[1782458385%10609871](G6[904072871%5107756],G6[835069-835009])G6[-523501-(-523556)]=G6[150591-150535][G6[748607+-748549]]G6[-941263-(-941320)]=z[l[-198393-(-198394)]]G6[-454883+454941]=z[l[-383442+383444]]G6[-1035023-(-1035083)]=Q(-863917+826353)G6[-322486+322545]=G6[815442-815384](G6[449963364%2678353],G6[1148670082%16178451])G6[1255067816%5229449]=G6[1128356562%7781769][G6[22504292%725943]]G6[824445-824387]=z[l[196224-196223]]G6[821845+-821786]=z[l[34913-34911]]G6[1005479-1005418]=Q(-309649+271939)G6[297843298%1177246]=G6[213735011%1032536](G6[-395317+395378],G6[1237-1175])G6[-34235+34292]=G6[530543-530485][G6[799970+-799910]]G6[942136925%4758267]=z[l[2026419371%13975306]]G6[-94956-(-95053)]=26170530513798-234476 G6[-939983-(-940043)]=z[l[1033994+-1033992]]G6[2215725482%10451535]=Q(398722-436519)G6[71117+-71056]=G6[656958-656898](G6[-679530+679592],G6[-203427+203490])G6[-705053-(-705111)]=G6[3136791587%14522183][G6[851742169%14942844]]G6[1342573632%13162486]=z[l[689830-689829]]G6[168107+-168044]=Q(-873021-(-835237))G6[-402619+402680]=z[l[2975599504%15417614]]G6[-696495+696557]=G6[702733561%3904075](G6[1236220037%5108347],G6[-241942-(-242006)])G6[214571-214512]=G6[155207982%8168838][G6[-558942-(-559004)]]G6[915529+-915468]=z[l[1540890744%7100879]]G6[-646022+646086]=Q(841232-879079)G6[407195+-407133]=z[l[515410133%10106081]]G6[240253-240190]=G6[1003317448%4688399](G6[417382282%12647946],G6[2118065801%13934643])G6[9892523%4946229],G6[1042277-1042168]=Q(-155780-(-117938)),8062039863588-(-892294)G6[1929664655%12449449]=G6[280036609%5185862][G6[570959-570896]]G6[1005534163%7031707]=z[l[262674-262673]]G6[423467394%3815021]=z[l[-764317+764319]]G6[1594968608%7668118]=G6[-356971-(-357034)](G6[-129875+129940],G6[16411+-16345])G6[-898755+898821]=Q(379583+-417308)G6[-202531-(-202592)]=G6[-661843-(-661905)][G6[-34328+34392]]G6[641421623%3773068]=z[l[744745+-744744]]G6[209609-209545]=z[l[714874541%7686823]]G6[737141+-737076]=G6[2937576196%12394836](G6[230650+-230584],G6[-958891-(-958958)])G6[205647777%956501]=G6[-277581+277644][G6[-91397+91462]]G6[438512115%2108231]=Q(-980798-(-943319))G6[-868171+868235]=z[l[-925175-(-925176)]]G6[57927+-57862]=z[l[153676+-153674]]G6[35876+-35810]=G6[925395-925330](G6[299217-299150],G6[808515+-808447])G6[-709241+709304]=G6[2007941053%9426953][G6[-375855-(-375921)]]G6[-489315-(-489380)]=z[l[2190427969%11408479]]G6[5850-5784]=z[l[-289002-(-289004)]]G6[-451806-(-451874)]=Q(123187-160674)G6[477346-477279]=G6[-957260+957326](G6[238773-238705],G6[475818-475749])G6[-336424-(-336493)]=Q(-206432-(-168895))G6[446336-446272]=G6[-509889-(-509954)][G6[50982+-50915]]G6[709141120%4516822]=z[l[349469+-349468]]G6[666993979%12826806]=z[l[632522090%7187751]]G6[591477366%6877643]=G6[74219185%12369853](G6[-628760+628829],G6[-919051-(-919121)])G6[1024131910%7367855]=G6[-711569-(-711635)][G6[206310+-206242]]G6[808602-808535]=z[l[2068140886%15787335]]G6[939630-939562]=z[l[-489016+489018]]G6[1384991026%16104546]=Q(-875338+837683)G6[817173+-817104]=G6[171641033%1806747](G6[250232-250162],G6[-614965+615036])G6[-31770-(-31836)]=G6[382115-382048][G6[3813147225%15313844]]G6[1072224551%6701403]=Q(-985235+947394)G6[830168+-830100]=z[l[-397667-(-397668)]]G6[49574914%16524934]=304150+11567813521652 G6[880932216%13148241]=z[l[-972307+972309]]G6[383941+-383871]=G6[399706655%2407871](G6[3103216471%12718100],G6[62934+-62862])G6[-285287+285354]=G6[885074468%6321960][G6[-311696+311766]]G6[1268127561%11424572]=z[l[-172226+172227]]G6[1233423765%15227453]=Q(1006916-1044605)G6[-1027346+1027416]=z[l[356466944%1523363]]G6[150409+-150338]=G6[-627392+627462](G6[583996+-583924],G6[-325186+325259])G6[-434881+434949]=G6[165068742%5002081][G6[854158-854087]]G6[-62112-(-62182)]=z[l[891135-891134]]G6[2056090211%12537135]=z[l[797293-797291]]G6[-610959+611060],G6[48650470%274861]=-626259+17495729384998,Q(733453+-770916)G6[811562094%12112866]=G6[323021+-322950](G6[-13214+13287],G6[235722618%1932152])G6[510486480%10861413]=G6[1101267670%5985150][G6[-892374-(-892446)]]G6[3591998986%14141728]=Q(-918006-(-880484))G6[1034645871%10346458]=z[l[-506976-(-506977)]]G6[910166+-910094]=z[l[932587373%4505253]]G6[3091102381%12266279]=G6[720145+-720073](G6[1941391662%10326551],G6[530193-530118])G6[1100890850%5794162]=G6[768323-768252][G6[-393227-(-393300)]]G6[999041-998966]=Q(-313764+275997)G6[-110387+110459]=z[l[828056-828055]]G6[-987334-(-987407)]=z[l[530664+-530662]]G6[-467049-(-467123)]=G6[69271507%1033902](G6[203587+-203512],G6[-939209-(-939285)])G6[320291164%6672731]=Q(849895+-887537)G6[687610-687539]=G6[343839+-343767][G6[210383+-210309]]G6[905889+-905816]=z[l[781147+-781146]]G6[-80638-(-80712)]=z[l[293940-293938]]G6[466468119%5553191]=G6[-559951-(-560025)](G6[866939-866863],G6[814573665%13806332])G6[-146111-(-146183)]=G6[1710634381%6953798][G6[670019+-669944]]G6[-272835+272909]=z[l[746805961%10372305]]G6[839039+-838964]=z[l[249307+-249305]]G6[130135869%8133487]=Q(-14505+-23098)G6[978142-978066]=G6[-931811+931886](G6[4098418961%16263567],G6[-711888+711966])G6[1021480-1021407]=G6[194997116%1095489][G6[947892740%13939598]]G6[-922295+922373]=Q(-564648-(-526925))G6[1183812859%5664176]=z[l[-87379+87380]]G6[785202176%5065820]=z[l[102794699%1742283]]G6[817920180%8988133]=G6[420674-420598](G6[748558+-748480],G6[2344432901%10754279])G6[548052239%8563315]=Q(-623793-(-586034))G6[1231773247%7845689]=G6[596258+-596183][G6[9911+-9834]]G6[221368+-221292]=z[l[960885+-960884]]G6[9050105%3016676]=z[l[-524190+524192]]G6[1003235+-1003157]=G6[-127941-(-128018)](G6[-235217-(-235296)],G6[-645540+645620])G6[619227+-619147]=Q(-779844+742364)G6[1007860152%5332593]=G6[2444207816%10400884][G6[1877558446%16763914]]G6[3496513457%15335585]=z[l[297808426%3970779]]G6[-1007167-(-1007245)]=z[l[82443-82441]]G6[418345214%5892185]=G6[-804055-(-804133)](G6[128928+-128848],G6[946954-946873])G6[824662675%8006433]=G6[-161364+161441][G6[661574-661495]]G6[1369584378%9130562]=z[l[79308+-79307]]G6[563734+-563653]=Q(-163880+126133)G6[-500838+500917]=z[l[2934801410%15285424]]G6[932626-932546]=G6[795680-795601](G6[-1040679-(-1040760)],G6[-662500+662582])G6[-68351-(-68428)]=G6[161065458%7669780][G6[797014+-796934]]G6[-356668+356747]=z[l[1386470109%9763874]]G6[818654+-818572]=Q(-48818-(-11044))G6[307232432%4267116]=z[l[664647115%2690879]]G6[694222140%2929207]=G6[-410464+410544](G6[597865969%2888241],G6[-760615+760698])G6[-923595-(-923673)]=G6[948367+-948288][G6[-126380+126461]]G6[107448+-107368]=z[l[-569632-(-569633)]]G6[1441177667%9358296]=Q(-604083-(-566451))G6[260932956%2438625]=z[l[677905-677903]]G6[735660154%4378929]=G6[-864036+864117](G6[335492803%1823330],G6[882016042%7229639])G6[22243303%97558]=G6[2676684232%11341882][G6[945974048%11974354]]G6[767280063%8162553]=z[l[-989268-(-989269)]]G6[962219124%4334320]=Q(120489+-157982)G6[1033448253%7770287]=z[l[-611367+611369]]G6[3029016227%16111788]=G6[-797570-(-797652)](G6[-1010890-(-1010974)],G6[2460725807%13520471])G6[33316394%16658157]=G6[457025+-456944][G6[978709+-978626]]G6[-489547-(-489632)],G6[-775744+775835]=Q(122667+-160131),26310974017795-(-302809)G6[200365982%817820]=z[l[160258-160257]]G6[788816-788733]=z[l[-807591-(-807593)]]G6[513308-513224]=G6[2866918820%11421987](G6[207512+-207427],G6[841783946%15588590])G6[-433151-(-433237)]=Q(263719+-301252)G6[2274514767%12429042]=G6[1469574423%14550241][G6[1087723134%14502974]]G6[491901523%3074384]=z[l[41541+-41540]]G6[-410166-(-410250)]=z[l[862030+-862028]]G6[10456495%1045641]=G6[319373271%15208247](G6[758142342%9975556],G6[1297421017%9980161])G6[2388242824%10905218]=G6[1162483123%14531038][G6[2222658215%9663731]]G6[-298788+298875]=Q(172143-209730)G6[29676-29592]=z[l[442648+-442647]]G6[-455133+455218]=z[l[-687623+687625]]G6[-76227+76313]=G6[2707359385%15040885](G6[-261249-(-261336)],G6[3503666920%13958832])G6[379873+-379790]=G6[-457755-(-457839)][G6[933152102%6139158]]G6[-727786-(-727874)]=Q(-178775+141057)G6[679998-679913]=z[l[-382833+382834]]G6[528322-528236]=z[l[3019298885%16498901]]G6[-665005-(-665092)]=G6[175085-174999](G6[-636607-(-636695)],G6[60811339%1216225])G6[401247+-401158]=Q(-62996-(-25365))G6[414865-414781]=G6[1475686675%7027079][G6[123436140%875433]]G6[2281371092%10710662]=z[l[-942747+942748]]G6[682334433%3769803]=-578542+1246262941234 G6[1656967645%9256802]=z[l[-684228+684230]]G6[1439174999%12736061]=-471163+22859532818959 G6[581597340%8680556]=G6[1391532387%6184588](G6[278954537%5811551],G6[556006662%2808114])G6[-1044556-(-1044646)]=Q(-877334-(-839681))G6[-833549+833634]=G6[335977886%3293900][G6[-357671+357759]]G6[1883491543%12230464]=z[l[-1023726+1023727]]G6[322205+-322117]=z[l[2126178940%15867007]]G6[1036906604%8038035]=G6[381809-381721](G6[1361173926%10311923],G6[-471014+471105])G6[-679867-(-679958)]=Q(859110+-896826)G6[212975552%9680703]=G6[-600160+600247][G6[2439470681%12639744]]G6[-763389+763477]=z[l[2186291673%9423671]]G6[382223+-382134]=z[l[103072+-103070]]G6[1613377275%10975355]=G6[996571+-996482](G6[21852+-21761],G6[-446450-(-446542)])G6[507510-507423]=G6[-743790-(-743878)][G6[339822-339732]]G6[125386+-125297]=z[l[3959958341%16032220]]G6[-531325-(-531415)]=z[l[1081308098%6143796]]G6[1555397990%7738298]=Q(-942843-(-904978))G6[514681027%11188716]=G6[3123929899%16705507](G6[-871774-(-871866)],G6[617562+-617469])G6[1104045172%6456404]=G6[296915-296826][G6[1360198285%5355111]]G6[-90915-(-91005)]=z[l[-915094+915095]]G6[-181044+181135]=z[l[1289894437%11414995]]G6[-1007676-(-1007769)]=Q(-946516-(-908750))G6[-604928+605020]=G6[684524-684433](G6[830410-830317],G6[338283-338189])G6[5794+-5705]=G6[990968658%7991682][G6[554148-554056]]G6[-673777-(-673868)]=z[l[3169127017%16005692]]G6[699059+-698967]=z[l[-145064-(-145066)]]G6[2541618042%10416467]=Q(-600575-(-563077))G6[712415+-712322]=G6[862228760%10264627](G6[469731598%2668929],G6[-356678+356773])G6[-415683+415773]=G6[181457-181366][G6[1018464-1018371]]G6[1330931760%8115437]=z[l[3907986001%15631944]]G6[418829535%5235368]=Q(442619-480194)G6[731071-730978]=z[l[-553312+553314]]G6[-799600+799694]=G6[624048+-623955](G6[498033-497938],G6[-87011+87107])G6[208047217%1588146]=G6[515113-515021][G6[338098-338004]]G6[577214373%6413492]=z[l[337617710%2790229]]G6[331416-331322]=z[l[514659+-514657]]G6[-536864+536960]=Q(381741+-419535)G6[-785965-(-786060)]=G6[2272759504%12285186](G6[2208745047%10880517],G6[-132212-(-132309)])G6[2038428336%9019594]=G6[-859518-(-859611)][G6[682461+-682366]]G6[-709621+709715]=z[l[-469212-(-469213)]]G6[-408608+408703]=z[l[283255310%6744174]]G6[892671019%4508439]=Q(654079-691541)G6[909286896%9092868]=G6[237069437%4390173](G6[-797802-(-797899)],G6[465136037%5742419])G6[-356876-(-356969)]=G6[-577838-(-577932)][G6[835318-835222]]G6[848511498%3689180]=Q(146713+-184483)G6[531865835%12663470]=z[l[371886-371885]]G6[-949082+949178]=z[l[-781841+781843]]G6[465302-465205]=G6[739422-739326](G6[5013+-4915],G6[-673506-(-673605)])G6[-988729-(-988823)]=G6[28002435%177230][G6[798759-798662]]G6[2505358297%13841758]=Q(-226669-(-189168))G6[2871181524%11767137]=z[l[-802695-(-802696)]]G6[350779531%4440246]=z[l[243020+-243018]]G6[-311596-(-311694)]=G6[2594812543%11481471](G6[14253+-14154],G6[999354+-999254])G6[824568-824473]=G6[-661865+661961][G6[1017370+-1017272]]G6[1543997857%6771920]=z[l[883601+-883600]]G6[700367-700267]=Q(-138942+101431)G6[796167-796069]=z[l[833791-833789]]G6[-936818-(-936917)]=G6[963922978%3999680](G6[-14165+14265],G6[623083-622982])G6[1169529360%7131276]=G6[415513+-415416][G6[-689397-(-689496)]]G6[822001510%5516788]=z[l[-419351+419352]]G6[158589-158490]=z[l[523052-523050]]G6[-144163+144264]=Q(556051+-593550)G6[467130-467030]=G6[1354942311%5942729](G6[-417516-(-417617)],G6[893487+-893385])G6[1040848-1040751]=G6[542038-541940][G6[-1036303+1036403]]G6[3153440629%13710611]=z[l[179294+-179293]]G6[116118009%589431]=Q(21734+-59563)G6[18976778%141617]=z[l[361090-361088]]G6[197473-197372]=G6[-919456+919556](G6[-19811-(-19913)],G6[1648315553%13968775])G6[68994338%1078035]=G6[-909812+909911][G6[2189917427%15984798]]G6[798367941%6094411]=z[l[238154+-238153]]G6[173123959%2838096]=Q(-935636+897943)G6[-229412-(-229513)]=z[l[-492733-(-492735)]]G6[-132933-(-133035)]=G6[58113-58012](G6[645355-645252],G6[-252693-(-252797)])G6[704417199%9392228]=G6[1659016954%16757746][G6[-974165-(-974267)]]G6[2136644909%13028322]=z[l[77547548%1582603]]G6[1657078310%7299904]=z[l[-649589-(-649591)]]G6[-162701-(-162805)]=Q(-864295-(-826552))G6[757982+-757879]=G6[1053900139%7692701](G6[283955-283851],G6[476966-476861])G6[253488120%2848180]=G6[-373517-(-373618)][G6[-853498-(-853601)]]G6[-672839+672941]=z[l[-392957+392958]]G6[1041705-1041600]=Q(-409511+371945)G6[574235+-574132]=z[l[-757894+757896]]G6[-222488-(-222592)]=G6[266529135%3028739](G6[-750688-(-750793)],G6[192253+-192147])G6[-819735-(-819836)]=G6[516033606%15177456][G6[-883616+883720]]G6[299172+-299069]=z[l[690125-690124]]G6[768374790%9978892]=Q(-148148+110335)G6[-589378+589482]=z[l[171574530%10723408]]G6[-700894+700999]=G6[-135810-(-135914)](G6[958288+-958182],G6[350181+-350074])G6[413159+-413057]=G6[14867239%154866][G6[1763704101%10254093]]G6[470425+-470318]=Q(260673+-298491)G6[-133481-(-133585)]=z[l[-920628+920629]]G6[265395505%5307908]=z[l[792611+-792609]]G6[-858642-(-858748)]=G6[272168+-272063](G6[-982191+982298],G6[-203631+203739])G6[615069+-614961]=Q(597804+-635537)G6[418344+-418241]=G6[48919028%1358859][G6[-321162-(-321268)]]G6[3498284730%15687375]=z[l[545921902%4587579]]G6[1768327792%10915603]=z[l[661514+-661512]]G6[308046235%1480991]=G6[793537+-793431](G6[51801+-51693],G6[856452+-856343])G6[-302268+302372]=G6[891250+-891145][G6[973141-973034]]G6[-416700-(-416806)]=z[l[1009201451%5122850]]G6[-466918-(-467025)]=z[l[215302+-215300]]G6[-642886-(-642995)]=Q(-779088-(-741290))G6[-273019-(-273127)]=G6[151952-151845](G6[239667911%1281646],G6[-675506-(-675616)])G6[2370920002%16019729]=Q(11117+-48606)G6[96972-96867]=G6[517743+-517637][G6[-54867+54975]]G6[4034748779%16603904]=z[l[-267242+267243]]G6[841408-841300]=z[l[1245534902%10126300]]G6[101181397%972897]=G6[235577+-235469](G6[220643+-220533],G6[821872119%3804963])G6[-136627+136733]=G6[38994817%7798942][G6[2809506457%12655434]]G6[714150428%3860272]=z[l[969625+-969624]]G6[2032352509%13027900]=z[l[337255-337253]]G6[-800490-(-800601)]=Q(-780373+742618)G6[1042411-1042301]=G6[3554034359%15123550](G6[1114179705%5018827],G6[2365746595%11769883])G6[80151+-80044]=G6[384666-384558][G6[868765+-868655]]G6[3364628209%16493275]=z[l[-790528+790529]]G6[1131466162%15086214]=Q(528452-565957)G6[-701975+702085]=z[l[545943+-545941]]G6[1623848593%8370353]=G6[-806324+806434](G6[-145112+145224],G6[993450-993337])G6[608566-608458]=G6[178127+-178018][G6[2810495855%12546856]]I={W,j,O;F,b;u,a;v;N;S;y,P,M,n,w,T,Y,x,A,J;d,r;K,p,t,o,E;L;mT;QT,IT;zT;iT,CT,lT,WT,eT,cT;XT,sT,jT;OT;FT,VT,UT;gT,qT,GT,HT;kT;fT;hT;ZT;DT;BT;RT,bT;uT,aT;vT;NT;ST,yT;PT,MT;wT;YT,TT;nT;xT;AT,JT,KT,rT,dT;pT,oT;tT,ET,LT;m6;Q6;I6,C6,i6;l6,e6,c6;W6;z6,X6,s6,j6,O6;F6,V6,U6,g6;q6;G6[-129428+129429],G6[470039-470037];G6[421342-421339],G6[496923-496919],G6[185133-185128];G6[963782+-963776];G6[2465895751%10538016],G6[168223-168215];G6[-728179+728188];G6[37736162%4717019],G6[-434695-(-434706)],G6[750298902%4840638],G6[155704+-155691],G6[951577+-951563],G6[553713+-553698],G6[2672659742%14292298],G6[-296876+296893];G6[20892-20874],G6[-563212-(-563231)];G6[219024116%1440948],G6[1808184%7441];G6[948309+-948287],G6[397435-397412];G6[-426611-(-426635)],G6[-172991+173016];G6[70084474%10012064],G6[-831810+831837];G6[3234334028%12937336];G6[88309229%1471820];G6[-216918+216948];G6[-848210-(-848241)];G6[-557823+557855];G6[896529873%7471082],G6[1416762287%15918677];G6[633677591%8925036],G6[1687373444%8609048],G6[-913421+913458],G6[231964-231926],G6[12042314%481691],G6[630558+-630518];G6[915686+-915645],G6[-780653+780695],G6[818529641%13418518];G6[-639256+639300],G6[975454065%10838378],G6[128458+-128412],G6[-718893-(-718940)];G6[359127+-359079],G6[263222-263173],G6[1038813+-1038763];G6[215456+-215405],G6[272606+-272554],G6[-944770+944823];G6[904840034%16451636];G6[480201895%3334735];G6[-116974+117030];G6[130027077%1226670],G6[535298+-535240];G6[-924336-(-924395)],G6[98669510%815450];G6[727380781%4041004],G6[-819200-(-819262)];G6[2419393525%14487386];G6[176325220%12594654];G6[1014511241%4696811];G6[-147457+147523];G6[111353830%2369229];G6[416093581%7850821];G6[-203847+203916];G6[1000067-999997];G6[-859066-(-859137)];G6[1001573+-1001501],G6[982863+-982790];G6[134739672%2283722];G6[909974841%6408273],G6[198607-198531],G6[375987-375910];G6[-298891+298969],G6[2915896783%14877024],G6[527576-527496],G6[-203190-(-203271)];G6[-676647-(-676729)];G6[933285233%5333058],G6[-731601-(-731685)];G6[1028567+-1028482];G6[503314-503228],G6[-777247+777334],G6[358326527%8333173],G6[524083-523994];G6[236463822%13136874],G6[864505-864414];G6[-259899+259991],G6[349165-349072],G6[77614834%2771955],G6[466660+-466565];G6[586048596%5426375];G6[615501+-615404],G6[829859975%13172379],G6[1666221422%7539463];G6[-90493+90593];G6[62467541%15616860],G6[155865+-155763],G6[1035097255%6311568];G6[1369946575%6954043],G6[318667-318562];G6[-920074+920180],G6[-540056+540163],G6[53745+-53637]}N,W=1118698957%13008125,Q(-400944+363344)j=s()z[j]=I v=-863311-(-863312)a,S={v,N},526630026%3442025 O=s()I=g(-664537+13850293,{j})z[O]=I y=758546082%6068367 I=m[W]N=1505530489%15362556 v={N;S}S=822856-822654 N={S;y}u={a,v;N}a={I(u)}I,b,W=204007+9487826,a[753931+-753928],a[430224849%12653672]u,F=W,a[186996-186994]else I=3666513413%20660384<=376245723%19084565 z[j]=I b=Q(-383477+345674)F=m[b]b=Q(839732-877400)O=F[b]F=s()z[F]=O b=s()u=s()a,P=I,Q(541714-579362)O=g(9468657-(-307129),{})M=q(2634716600%16761997,{u})z[b]=O O=-946591+15782982>=1639928410%26618036 z[u]=O y=m[P]P=y(M)O,I=P,P and 2064034277%21803348 or 741097+1100667 end end else if I>2216695468%19853049 then if-118729+13140144>I then G6[1036500-1036296],I=15961853-511473,8798090-28154 X=G6[-104641-(-104845)]elseif I<4297758068%22791085 then G6[316917%78757]=-704355+8067346 G6[639406-637518]=X<G6[-46623+48512]I=G6[345743+-343855]and-332564+5816499 or 5971864-(-838298)else WT=-318566-(-384102)lT=p/WT iT={S(lT)}zT={y(C(iT))}IT=F(r,C(zT))iT=K>=d IT,zT=iT,I I=iT and 1945331632%21241705 or-957822+15122511 end else if I<5151068103%27042614 then I=297677541%6131732 elseif 2340642795%13454679>I then iT=p+o p,E,t,o,I,zT=iT,nil,nil,nil,1335783407%16469978,nil elseif 828272+12166451>I then I=10444411-539023 XT={y(iT,lT,WT)}cT=F(K,C(XT))else G6[256563-255797],G6[183248064%1138182],G6[-851797+852560]=18203+-18202,1274362201%5663832,1132331812%4737790 G6[1734750323%12570649]=j[G6[18046-17284]]G6[1028344074%14282546]=j[G6[1450739818%9124145]]u,y=G6[-640884+641646],G6[2033236181%13926270]G6[982716+-981952]=z[l[105874+-105870]]G6[620122-619357]=O[G6[745362262%3764452]]G6[498374+-497611]=G6[435796-435032][G6[1827439760%11789929]]G6[-572630+573399],G6[-924093-(-924860)],G6[1177420706%5256339],X=I,I,563512+2775200,G6[1874684763%7498736]G6[661701281%5379679]=X r,G6[502508249%12256280]=G6[56226802%355861],85262903%19748919 G6[571046386%2493649]=r[u]X,I=G6[500040-499275],1000377011%4972375 G6[-848092-(-848860)]=X and G6[164274-163504]G6[33031+-32265]=G6[-354973-(-355741)]or G6[284523265%8891328]X=G6[-597673+598439]end end end end else if 13448052-74964>I then if I>504481+12776626 then if I>628042+12683615 then if I<-181975+13512394 then G6[-884744+885751]=I G6[2729912119%12756594]=jT+sT G6[878768745%8615370],sT=not E,G6[195809462%3996091]G6[753415-752411]=kT>=sT mT,M=G6[354332348%1501404],G6[32736873%743997]G6[185639404%2508627],I=M,M and-627986+1537546 or 3030922037%23216357 elseif 3739027797%15786796>I then o=Q(-243892-(-206312))A=s()z[A]=J CT,E=Q(-697984-(-660164)),-736218+736318 t=m[o]o,L,cT=Q(243106+-280646),-219379+219634,-563825+573825 p=t[o]o=455876377%4955178 t=p(o,E)E=711227-711227 p=s()IT=45965182%2419220 z[p]=t t=z[y]o=t(E,L)t=s()z[t]=o L=900806089%5774398 o=z[y]mT=z[p]E=o(L,mT)o=s()z[o]=E L=z[y]eT,QT=-344173+344173,199821+-199820 mT=L(QT,IT)L=-685896-(-685897)E=mT==L L=s()IT=Q(613101-650920)z[L]=E mT=Q(941186-978771)iT=m[CT]lT=z[y]WT={lT(eT,cT)}CT=iT(C(WT))iT=Q(-633673+595854)zT=CT..iT QT=IT..zT E=Q(-895551+857815)E=Y[E]E=E(Y,mT,QT)mT=s()z[mT]=E IT=Q(-472214+434566)zT=H(6637739-496809,{y;A;P;F;j;x,L;mT;p;o,t,M})QT=m[IT]IT={QT(zT)}QT=z[L]E={C(IT)}I=QT and 4543760-(-952726)or 12494898-754417 else y=3442382120%16549914 S=a==y I=S and 9876875-(-821224)or 530707+6750748 end else if I<962103+12332815 then G6[442192-441415],G6[150537+-149762],G6[805471-804702]=31743624181504-(-377533),-549070-(-508745),857015-897345 G6[-824596+825363]=z[l[1310996507%5775315]]G6[1000618-999846]=447497520%6130103 G6[-12041+12809]=G6[-318999-(-319766)](G6[-538890-(-539659)])w,G6[137126130%2405708]=G6[384661+-383893],-19331+19333 G6[-717218+717987]=z[l[746019+-746014]]G6[-256963-(-257730)]=G6[-859097+859866][w]X=G6[1383428792%13175505]G6[554456-553686]=z[l[-179890+179894]]G6[-713955+714737]=385306-425636 G6[213955+-213184]=O[G6[-600308+601080]]G6[1029961136%13037473]=G6[748214+-747444][G6[1358410986%9634115]]G6[2091899978%10838856]=z[l[-878377-(-878379)]]u,G6[-470187+470959]=G6[3102140029%16588980],252585+-292875 G6[-693685+694456]=G6[-890018-(-890788)](G6[831925624%12604922])o=G6[1231758759%11300532]G6[-968947+969719]=z[l[877678400%8955902]]G6[934834-934061]=O[G6[789803+-789029]]G6[637773294%9243080],G6[-751961-(-752756)]=-744441-(-704009),-983281-(-942846)G6[286651+-285881]=G6[310824+-310052][G6[3681026285%16581196]]G6[511492-510720]=z[l[86095361%9566151]]r=G6[-83428+84198]G6[177836+-177063]=G6[904207-903435](G6[81830+-81056])G6[565789+-565017]=z[l[494939+-494937]]G6[1210807448%10174846]=G6[308998392%15449881](G6[833175+-832400])G6[118691081%8477879],A=-684324+34151153135426,G6[982263+-981490]WT,w=G6[406300942%2404143],G6[-848075-(-848849)]G6[54659132%1366459]=X[w]G6[2601426186%12689880],w,lT,G6[514841-514056]=864388+-864386,G6[1884495904%16106796],G6[292453965%2119226],1470702706%6970155 G6[2286102042%11317333]=r(A,WT)L=G6[-633708-(-634484)]G6[331793-331015]=u[L]y=G6[-952129+952907]G6[244852711%2246348]=w(X,y)G6[681357687%10815189]=z[l[61582314%521884]]w=G6[529262251%16539421]G6[1049143981%12489800]=G6[2965911530%11863643](G6[246817678%3856514])r=G6[474875428%8959899]G6[749722326%14417722]=z[l[2569357234%14353951]]G6[-403906-(-404686)]=G6[45526-44744][r]u=G6[-17576-(-18356)]G6[647600-646817]=z[l[715123-715119]]G6[2287860072%9453964]=O[G6[-821703+822488]]G6[496885-496103]=G6[-793285+794068][G6[511738750%9476629]]G6[-848974-(-849758)]=z[l[24803002%751606]]L=G6[505075+-504293]G6[311304+-310519]=O[G6[91276863%1789727]]I=899592-(-30044)G6[721888103%10312676]=G6[46853944%4685316][G6[213534+-212749]]A,G6[-378553-(-379342)]=G6[425985+-425202],387556+-427813 G6[1099414520%4505794]=A(o,lT)WT=G6[2296517149%13751595]G6[561930479%9688443]=L[WT]r=G6[377313-376528]G6[2254785266%10840310]=u[r]y=G6[764870-764084]G6[-594591+595378]=z[l[-302005+302007]]G6[-242443-(-243231)]=G6[2535828547%14087932](G6[201701+-200912])u=G6[-668043+668831]G6[-487822+488609]=w[u]u=G6[2885717107%12023818]G6[-906167+906957]={u(w,y)}G6[-288840-(-289629)]={C(G6[58604+-57814])}X=G6[92423+-91634]G6[581013-580222]=z[l[-543139+543146]]G6[740180-739388]={G6[896270561%9958553](X)}G6[-394966-(-395756)]={C(G6[-891985-(-892777)])}w=G6[2119304625%8376695]G6[-883338-(-884130)]=z[l[892654+-892649]]G6[190363605%8276644]=z[l[1371231552%6788275]]G6[209282048%14948661]=G6[650565+-649772](G6[-896353-(-897148)])G6[-517273-(-518064)]=G6[292673-291881][G6[2042783078%13802583]]X=G6[333605-332814]elseif I<539906+12760743 then G6[-339858+340753],G6[276777-275879]=not GT,I G6[2305-1411]=J+FT FT,UT=G6[281506+-280612],G6[-1008196+1009091]G6[457531+-456634]=UT G6[-124577-(-125473)]=FT<=t I,IT=UT and 3112758689%25395908 or 9395206-(-889995),G6[1064472512%5544123]else G6[309137+-308064]=15494289-(-959738)G6[-103555-(-104627)]=G6[-19251-(-20324)]>X I=G6[2765535096%15536708]and-211868+5711524 or 14105094-929171 end end else if I>4734432723%21362919 then if 13704994-469162>I then I=2328603424%28573398 elseif I<1366092628%17569315 then Y,S,P,M=609194-609192,477192+-477191,257948546%8060892,2315981606%12451514 I=z[j]N=v[S]S=z[j]y=v[P]w=z[j]P=643451-643450 T=v[Y]n=w[T]T=z[j]x=-883949-(-883950)Y=v[x]w=T[Y]x=3099539969%12107578 Y=v[x]x,A=649564-649563,-100525-(-100527)T=Y+x x=v[A]A=-412640+412641 Y=x-A I[N]=n S[y]=w v[P]=T I=6641042-234030 v[M]=Y else G6[-328804-(-329007)]=-116756+11057702 G6[142183+-141981]=G6[50319-50116]>X I=G6[-415196+415398]and 487053+2318787 or 372744+12644689 end else if I<985725+12195114 then G6[-158381-(-159460)]=-709275+668978 G6[-975431-(-976508)]=z[l[97667+-97665]]G6[2452630582%15721984]=G6[2625064219%15532918](G6[1138355419%13882370])y,G6[466521117%3455704]=G6[-473783-(-474861)],736803+25760185069752 G6[-655152+656232]=z[l[-1009763-(-1009768)]]WT,G6[175048145%10296886]=G6[826412+-825335],-882575-(-882576)G6[212292+-211213]=G6[-951796-(-952876)][y]w=G6[512223-511144]G6[48648+-47567]=z[l[79126399%15825279]]G6[323919+-322837]=O[G6[1851582679%11154106]]G6[153953677%841271]=-867785-(-867787)G6[-380660-(-381740)]=G6[817996777%5489904][G6[209112610%2519416]]G6[-94634-(-95716)]=z[l[1591650159%14602295]]G6[397668031%8115652]=O[G6[715952027%5637409]]G6[137254561%703864]=G6[-795601-(-796683)][G6[529619+-528536]]G6[985766+-984684]=z[l[82336085%1614433]]u,G6[2098964263%8429571],r=G6[778255+-777175],-170956+130673,G6[357834-356753]G6[1234228227%13130076]=G6[373115-372033](G6[1044867+-1043783])A,G6[48390470%1728192]=G6[-158851+159934],342453+-382777 G6[101774+-100692]=r(A,WT)L=G6[-67801+68883]G6[665681539%12103281]=u[L]G6[1505761582%7036264],y=872842.5-872842,G6[895318-894234]G6[-647699+648784]=w[y]X,y,G6[396784-395693],I=G6[216038-214953],G6[-994232+995318],-63006-(-63009),4905771-273248 G6[2573988811%11142804]=X(y)w=G6[-326789+327876]G6[69639709%6963862]=z[l[-738758+738762]]G6[-399799-(-400889)]=O[G6[809522+-808431]]G6[535989497%7999827]=G6[2860806693%12547393][G6[-53389-(-54479)]]X=G6[-619161-(-620249)]G6[938390-937301]=X()G6[3536885036%16150155]=z[l[822819917%5174968]]w=G6[-342439-(-343528)]G6[1044389140%11868046]=z[l[167021+-167019]]G6[622435001%11744036]=G6[1302178372%16277216](G6[803646+-802552])G6[-793303+794393]=G6[984619+-983528][G6[1035276+-1034183]]X,G6[-330958+332049]=G6[2344722870%14124830],{}w=G6[3016305964%13171637]elseif-55941+13252305>I then X,O=i[43870+-43869],-81451-(-121913)W=z[l[433394-433393]]j=X+O I=W[j]W={I}I=m[Q(-740984-(-703223))]elseif I<13363560-147626 then G6[-5945+6127]=5936254018%23146688 G6[-816683-(-816864)]=X<G6[622125-621943]I=G6[513200+-513019]and 344365+13397880 or 870393102%19601289 else G6[-137018-(-137237)]=1749815577%17923209 G6[601990-601772]=X<G6[140947326%1028811]I=G6[-919144-(-919362)]and 682691+1903373 or 621651276%5795693 end end end else if 14322316-795933>I then if I>-186024+13622884 then if I<369278+13100013 then I=961313212%26271868 elseif 742973+12769307>I then G6[1835599575%14684790]=-794006+15493000 G6[883394060%5773812]=X<G6[-501063+501888]I=G6[1913863051%13768793]and-125576+10783237 or 445236403%16119304 else I=3358116776%16837422 end else if 13902667-494722>I then G6[3883-3710]=VT G6[17653726%2942259]=z[l[-344996+345000]]G6[1582018302%13074530][u]=G6[795417+-795244]G6[668615072%10960900],I=zT,2989010147%19686793 X,G6[-296442+296615]=G6[2762322010%12222663],369236761%8877601 X=G6[233482053%11674094]elseif I<573930+12845956 then I=15945797-285607 elseif I<-1016622+14445978 then G6[-411272-(-411722)]=-480229-(-439864)G6[-947141+947589]=z[l[745128650%6158088]]G6[663769+-663318]=-622410-(-582098)G6[1355171219%10038302]=G6[-219179-(-219627)](G6[-194417-(-194867)])G6[229310-228862]=z[l[-527892-(-527894)]]G6[-160400+160850]=G6[1029422+-1028974](G6[752032+-751581])G6[711746-711289],I,w,y=1017360202%10939357,-101231+6063329,G6[904571+-904121],G6[1832059097%14540148]G6[-434750-(-435201)]=z[l[-141363+141368]]G6[823065+-822611]=735167+-775532 G6[-936880-(-937328)]=G6[674987-674536][w]X=G6[-273075+273523]G6[982806968%7925859]=z[l[-53986+53991]]G6[-592182+592633]=G6[380584-380132][y]w=G6[655805-655354]G6[476574412%3135355]=z[l[1308876926%5895842]]G6[234191937%13010638]=G6[183463342%14112530](G6[-986784-(-987238)])G6[1967637959%7686084],G6[298993456%2533839],y=299658-339970,X,G6[831322+-830869]G6[59093-58641]=z[l[4030093205%16449360]]G6[355508-355056][y]=G6[-564248-(-564702)]G6[2085863954%9188826]=z[l[-356120+356122]]G6[1102625079%11606575]=G6[240175840%14127964](G6[308582+-308127])G6[-259257-(-259709)]=z[l[-942293-(-942298)]]G6[-385786+386241],y=w,G6[-492979+493433]G6[159860-159408][y]=G6[112013-111558]G6[-987350+987805]=z[l[463165-463161]]G6[550224+-549768]=O[G6[165979270%4255867]]G6[1425166405%13074917]=G6[146724+-146269][G6[-293615-(-294071)]]G6[450186377%2831358]=10876344-(-149658)X,y=G6[279603+-279148],G6[-742449+742901]G6[-716154-(-716610)]=y()u=G6[511879+-511423]else X,I=G6[2803559270%10951402],G6[-430749+431108]I=621540576%8406654 end end else if 13059735-(-608934)>I then if I<2307136933%23645313 then G6[578096-576809]=190188959%8269085 IT=G6[991292-990005]G6[500384-499096]=o==IT lT,G6[115478790%2025921],G6[443703782%5762370],G6[-509011+510301]=G6[179372288%991000],-1037828+1097866,I,I I,G6[965578-964286],G6[-423239-(-424530)]=11617268-144458,988394+12892926,lT and G6[686131051%7978253]G6[799060-797771]=G6[530903-529612]or G6[464185158%2081542]X=G6[1802231814%16534225]elseif 947381+12659763>I then t,n=Q(-715998-(-678339)),w I=a[n]A=I J=u(A)r=z[l[236836+-236835]]o=-426801+190296802185 K=z[l[550582733%5145633]]p=K(t,o)d=r[p]I=J==d I=I and 4141885279%17579695 or 4606440774%24181340 else N=-283581+5728483~=14935661-267183 I=N and-263768+16019741 or 1964750649%14038380 end else if 781550+12901939>I then G6[996884968%4171062]=4273345-1015347 G6[429426+-428277]=X<G6[-267345-(-268495)]I=G6[-1019939+1021088]and 813900+9943452 or 425574+2387100 elseif 3861873814%18590192>I then I,X=G6[-345149-(-346951)],G6[86387274%1093487]I=-851626+15344625 else G6[495527358%9349566]=4734295084%21363129 G6[445392907%1997276]=X<G6[111935799%10175949]I=G6[1016939-1016580]and 1812258-(-626698)or 533472+11084544 end end end end end else if 2548673819%14482865>I then if I<13015691-(-956968)then if 14334951-522823>I then if I<804476+12973473 then if 171169+13567841>I then I,G6[-649963-(-651753)]=14583499-90500,1582260334%10898110 X=G6[677749940%7530535]elseif I<5235799956%27057282 then I,G6[94851373%624021]=16392191-438983,4761929810%19313031 X=G6[6798+-6617]elseif 1959778565%22894318>I then G6[668871-667778]=11343201-(-411252)G6[84654-83560]=z[l[-127227-(-127231)]]X,I,G6[426011684%7607332]=G6[122638-121545],-358017+621406,7108498-1033222<=6524200-141568 t=G6[-864083-(-865175)]G6[279446205%7984146]=t G6[-560442+561536][u]=G6[233915325%3544155]else G6[2191480104%11719138]=-31872+2962041 G6[-1038305-(-1039602)]=G6[-496940-(-498238)]>X I=G6[1001950687%12845505]and 4236009-(-261689)or 918373+597752 end else if 3766115384%17953739>I then K=Q(-966769+929245)J=m[K]K=Q(-869297-(-831684))m[K]=J I=3492147595%17329544 elseif 5502660770%25769314>I then G6[379761137%5933752],I=mT,17362+5958044 else G6[10839028%471203]=-314732+274340 G6[-319841-(-321195)]=z[l[161495778%3105688]]G6[-711667-(-713023)],G6[-319513-(-320879)],G6[-48049-(-49425)],G6[26411066%2031516]=-229719+189378,-364312+324051,808903-849279,926232+-966562 G6[488016+-486661]=G6[608676589%3028235](G6[1276577358%10910906])kT=G6[1875995035%10659055]G6[1322455660%6237992]=z[l[-348468+348470]]G6[-1033680-(-1035034)]=12834713344025-721089 G6[434956+-433599]=G6[-888204-(-889560)](G6[639392214%6147989])G6[770537-769163]={L;u}G6[287506208%1444748]=z[l[972594-972592]]jT,J=G6[1522351690%7318992],G6[281798337%7415710]G6[311693+-310335]=G6[17257396%3451208](G6[-47902+49261])o=G6[871649-870291]G6[-949817-(-951176)]=z[l[138084575%7671365]]G6[985787-984396]=-217469+16897310 G6[738354+-736998]=G6[155142514%917995][o]G6[19874482%6624374]=z[l[234087813%7315244]]WT=G6[-753921-(-755277)]G6[-1038066+1039425]=G6[9679-8319][J]G6[1036243-1034865]={L;u}G6[283524237%1254526]=z[l[760465+-760461]]G6[309669598%1563981]=G6[3370086009%15530344][L]G6[381077562%3810762]=z[l[696113-696109]]FT=G6[-942575+943934]G6[2454899213%13127796]=G6[78629972%7862861][u]UT,G6[869662+-868290],mT=G6[2604678904%10336022],940364187%4098961,G6[-664954+666315]G6[347262-345900]=mT(kT,jT)sT=G6[-677305-(-678667)]G6[4219280068%16546191]=UT[sT]G6[3461528477%16251301]=z[l[756841957%8904023]]G6[1655755060%11418991]=G6[601073-599709](G6[933956+-932590])G6[-507713+509077],GT,UT=5361738545602-(-593918),G6[450876-449513],G6[1360262396%12479459]a=G6[878499704%6365930]G6[-999234+1000600]=FT[UT]UT=G6[384527+-383161]G6[1954174118%15633382]={UT(FT,GT)}G6[-25420+26789]=z[l[-576358-(-576365)]]G6[2332188707%9519132],G6[-664967-(-666340)]={C(G6[1991829726%9012798])},{L,u}J=G6[895422+-894055]G6[-808358-(-809728)]={G6[-421994+423363](J)}G6[801291-799923]=WT(C(G6[576339+-574969]))o,G6[-895291+896668]=G6[-862909-(-864277)],99885741%8827195 G6[549271084%6313445]=o()G6[282322346%6721928]=z[l[261037986%1035865]]G6[-739189+740560]=G6[-823173+824543](G6[2756090452%11982996],G6[590294-588921])G6[489142369%2928988]=3035008726%12236812 G6[-699692+701062]=z[l[-294999+295009]]WT=G6[-215604+216973]G6[202156+-200784]=G6[618270-616900](G6[74219873%4123250],G6[-217985+219359])o=G6[1920515967%8313916]G6[-493448+494818]=z[l[251657+-251654]]G6[-874977+876352]=-343999+303702 G6[1793068013%12899760]=G6[200173383%4258979]()WT=G6[-412478+413851]G6[537642-536272]=z[l[-792746+792748]]G6[-117441-(-118815)]=G6[872311+-870941](G6[-1012848+1014223])FT=G6[-691924-(-693296)]G6[122692+-121322]=z[l[574669+-574667]]mT=G6[289365-287991]G6[1342243087%12428164]=G6[433311-431941](G6[152110354%10864927])M=G6[2876410459%13504268]G6[3685942307%15819489]=z[l[25155-25147]]G6[-818475+819851]=G6[-35252+36622](G6[3392740102%15214075],G6[912755272%14721837])G6[904916-903538],G6[-487839-(-489216)],J=FT,o,G6[2072425808%9963579]G6[-459764-(-461134)]=z[l[68685313%297339]]G6[548153-546783][WT]=G6[-333266+334643]G6[273413-272043]=z[l[-767235+767238]]G6[-892580-(-893957)]=G6[523760+-522390]()G6[-70861-(-72231)]=z[l[-872797-(-872801)]]o,G6[545317344%4825805]=G6[-463913-(-465290)],J G6[533538+-532168][o]=G6[620808+-619430]G6[476373-475003]=z[l[362742+-362739]]G6[-213943-(-215321)]=G6[152635610%1387584]()G6[651709367%4315947]=z[l[2051042224%16675140]]FT=G6[-1009038+1010416]G6[1331599328%13727814][FT]=G6[995824+-994445]G6[458864234%10925306]={L,u,WT;o,FT}G6[9132-7762]=z[l[67690-67687]]G6[260514233%12405374]=G6[281225-279855]()G6[578164-576794]=z[l[343864+-343853]]G6[1700682331%7558582]=-664772+15935839 G6[-787822-(-789202)]=G6[648137-646767](G6[948045-946664],G6[601962764%9120627])GT=G6[225774718%16126667]G6[985282-983912]=z[l[270055-270051]]J,G6[940642-939261]=G6[-70876-(-72255)],GT G6[-290167-(-291537)][J]=G6[607843061%7598021]G6[1009410-1008029]=z[l[178463-178458]]G6[246888+-245518]=G6[957250730%3971989][mT]G6[669718+-668337]=z[l[3341325589%16379047]]G6[-831865+833247]=G6[462260+-460879](o)UT=G6[49078-47708]G6[1851843361%12771324]=z[l[927057-927056]]G6[-855569+856952]=G6[-436057+437438](FT)FT,G6[-133127+134519],o=G6[-428474-(-429857)],{L;u;J},G6[904932-903550]G6[37646794%228154]=z[l[567203+-567199]]G6[148064528%3443329]=G6[-496668+498052][L]sT=G6[-801743+803124]G6[607493+-606108]=z[l[-501931-(-501935)]]G6[999138-997754]=G6[-211619-(-213004)][u]kT=G6[58606+-57222]G6[2673387324%13570487]=kT(M,a)jT=G6[1121244669%11441258]G6[483506670%5557532]=sT[jT]mT=G6[954504-953118]G6[57123-55736]=UT[mT]GT=G6[344444595%2969338]G6[1015033328%15615876]=z[l[-933651-(-933652)]]G6[138763+-137374]=G6[73778020%9222079](WT)WT=G6[-986732+988121]G6[2236361289%11587357]=z[l[567594+-567585]]G6[451516-450126]=G6[-916673-(-918061)](G6[669799-668408],G6[775249476%14908617])mT=G6[268424203%3780603]G6[-160862-(-162250)]=GT(mT)G6[2155365062%8656079],I=344815+9572375,14702144-(-669988)G6[437202780%12144483]=z[l[-1035910+1035911]]G6[1919608441%10489656]=G6[23057460%3842678](J)J,UT,X=G6[-405785+407178],G6[596915370%12181918],G6[-749202-(-750593)]end end else if I>25328+13876133 then if I<2977526175%28772680 then G6[755840427%12190953]=1044882-355506 G6[575844-574504]=G6[789285-787944]>X I=G6[2597350992%13184516]and-396636+1140975 or 646991+9083215 elseif 734199573%17148427>I then G6[2501525734%15933276]=1621578712%7716559 G6[240393-238992]=G6[-180491-(-181893)]>X I=G6[-1040137+1041538]and 4132312366%16787781 or 2913943289%18714742 else I=9379498-(-334871)end else if I<13967068-129610 then G6[1026417688%10367838]=3224250492%17219263 G6[-195697-(-197422)]=X<G6[-737275-(-739001)]I=G6[1904316891%8138099]and 6398971-(-592196)or 1511188-(-171171)elseif I<13816853-(-53787)then G6[539791860%8056578]=-312733+2728011 G6[43843030%1019579]=X>G6[-834311-(-835445)]I=G6[-1013544+1014677]and 569398647%15456522 or 546100+7648731 else G6[-485936+486377]=999122+12366469 G6[985681-985241]=X<G6[1926768609%10645128]I=G6[-567272+567712]and 2283147-500202 or-360568+5798002 end end end else if I<15108692-1000361 then if I>3823728382%17395698 then if 315969+13770337>I then G6[-598354+599564]=2258664841%15034878 G6[614271-613062]=G6[584864779%2909769]>X I=G6[1035567-1034358]and 13763526-964670 or 532286+1522740 elseif 13163432-(-935066)>I then G6[384060-382451]=174507+4960361 G6[983746+-982138]=X>G6[403944+-402335]I=G6[1715775204%9375812]and 1484925605%17618704 or 650696514%23734568 else I,G6[210111671%4040600]=2147993-1016165,w end else if I<15003257-1010121 then I=976705+5466439 elseif 738776+13289677>I then G6[520391-519235]=4275412-925379 G6[15035+-13880]=G6[154341895%892143]>X I=G6[359530101%2078202]and-294019+8057171 or 92627+15742760 elseif I<4317225060%26562790 then G6[667132+-665247],G6[-158836+160727]=d,93495+11228602 w,G6[896486+-894600],G6[629238-627349]=G6[723674-721789],cT,d and G6[877923091%3751800]X,G6[2286405783%13370783]=G6[3255772262%14033493],I G6[200259-198369],G6[177769+-175881]=15350060-565445,I G6[-844699-(-846586)],I=G6[629897+-628008]or G6[-287633-(-289523)],12503079-264125 X=G6[2955496072%12576571]else j=3332529577%23893724>243576+5189754 I=z[l[882944876%16350831]]W=I(j)I=z[l[535921-535918]]j=W W=I(j)u,O,F,b=-960926+920604,W,457642-498066,778265-818619 I=z[l[182267540%8284888]]a=G(5403456-(-421531),{})W=I(F)I=z[l[491349+-491345]]F=I(b)I=z[l[3373828094%16457698]]b=I(u)I=X u=z[l[-751490+751495]]O[W]=I O[F]=u W,I={j},m[Q(-600885-(-563053))]O[b]=a end end else if I>4653374827%25631021 then if 13436028-(-727250)>I then G6[-99447-(-99561)]=3986597924%23637783 X,I=G6[781257668%10146202],-274319+4043207 elseif 6084345858%25830551>I then cT,eT=2328812071%11942626,1049010199%12197793 WT=K+eT jT=10332878864658-421447 eT=K+cT sT=Q(295403-332966)lT=M(A,WT,eT)eT=z[l[424287662%2090087]]I=1943084548%24439849 cT=z[l[-679045-(-679047)]]XT=cT(sT,jT)WT=eT[XT]iT=lT~=WT IT=iT else I=1687758892%10906773 end else if I<213514+13914739 then G6[-755579-(-757198)]=z[l[963022-963021]]G6[471859020%8426025]=G6[1431129883%15555742](x)G6[-952838-(-954457)]=z[l[1017221+-1017220]]G6[766575280%6906069]=G6[870360-868741](M)M,x=G6[1001930-1000309],G6[977292-975672]G6[407905-406286]=z[l[1043923+-1043922]]G6[-360343+361965]=G6[-365567+367186](eT)eT=G6[907563-905941]G6[52610-50991]=z[l[-927323-(-927324)]]G6[-920117-(-921740)]=G6[797943-796324](a)G6[-944790+946409]=z[l[1815553301%16505030]]G6[606326+-604702]=G6[611128713%3867893](CT)G6[566176879%8088218],a,CT=12630810-560244,G6[1041125-1039502],G6[530527-528903]X=G6[-925141+926760]G6[-73895-(-75520)]=z[l[1091515957%6346023]]G6[-319275+320901]=G6[-238909-(-240534)](qT)qT,G6[1844706965%13664484],I=G6[459513+-457887],nil,745503-(-806209)P=G6[-926499+928124]elseif I<15134176-981985 then G6[688243-686514]=4600873-488611 G6[626689254%10273566]=G6[673630685%8748428]>X I=G6[1051300967%11812351]and 10946170-258178 or-916992+9234585 else I=-711762+14888593 end end end end else if 15424211-963044>I then if I>301319+13989180 then if I>511479482%24852542 then if 112455+14327452>I then I=537970847%12396940 elseif I<1027598+13422140 then DT=z[l[-175879-(-175880)]]BT=DT(L)O6,ST,DT=46267+-86631,-184932+144582,nil sT,L,g6=DT,BT,-177934+137551 RT=z[l[980505-980504]]bT=RT(WT)WT=bT RT=z[l[-459104-(-459105)]]uT=RT(u)j6,u=-558877+518528,uT aT=z[l[480737+-480736]]vT=aT(jT)YT,jT=nil,vT aT=z[l[-512335-(-512337)]]RT=nil o=RT NT=aT(ST)I,ST=4311662959%31594063,nil yT=z[l[67548349%11258058]]PT=yT(GT)aT,mT=nil,ST MT=z[l[1005353+-1005352]]wT=MT(FT)AT,u,kT=-207866-(-167516),YT,aT TT=z[l[623225-623224]]FT=wT nT=TT(J)MT,GT=4238608499%21770744,PT X,G6[1636558327%13198051],pT,o,yT,J=MT,-990059-(-949803),u,NT,nil,nT UT=yT TT=z[l[397836-397834]]xT=TT(AT)TT,JT,mT,AT=1177266340%4824861,nil,xT,nil sT=TT KT=z[l[-164213+164214]]Q6,r=-112292+72019,AT r=JT rT=KT(A)KT=z[l[372777240%5917099]]dT=KT()L=dT KT=z[l[-1031375+1031379]]KT[L]=pT A=rT KT=z[l[188909205%11112306]]pT=KT()u,oT=pT,r KT=z[l[314176-314172]]KT[u]=oT oT=z[l[847320-847317]]tT=oT()oT=z[l[2629093044%13413740]]KT,A=944210-944208,tT r=KT ET=r oT[A]=ET oT=sT kT=oT LT=z[l[-20234-(-20239)]]ET=LT[o]WT,i6=ET,592164+-632429 LT=z[l[-622035-(-622037)]]m6=LT(Q6)o=m6 LT=WT[o]r=LT Q6=z[l[247955-247952]]I6=Q6()Q6=z[l[-729409-(-729411)]]C6=Q6(i6)WT=I6 Q6=z[l[1847416090%11403803]]GT,i6=C6,r Q6[WT]=i6 i6,Q6=-408323-(-408324),-833254+833254 sT=i6 l6=z[l[322126-322123]]r=Q6 e6=l6()o=e6 l6=z[l[245895-245892]]G6[2314919537%9410242]={}c6=l6()W6,FT=r,c6 l6=z[l[1415779994%7297835]]l6[o]=W6 l6={}W6=z[l[144200-144196]]r=l6 z6=r W6[FT]=z6 X6=z[l[547348563%5822857]]W6=sT jT=W6 z6=X6[GT]X6=z[l[147293730%9205858]]s6=X6(j6)J=z6 X6=z[l[983989-983987]]UT=s6 j6=X6(O6)O6,GT=419432+-419432,j6 X6=J[GT]r,sT=X6,O6 V6=z[l[323760947%11991146]]F6=V6[UT]GT=F6 V6=z[l[-76469+76471]]U6=V6(g6)UT=U6 V6=GT[UT]g6=jT<sT J,E=V6,g6 G6[-820926+820927]=z[l[-366751-(-366756)]]q6=G6[944746111%8588601][mT]UT=q6 G6[-30006+30007]=z[l[1017786-1017784]]G6[-591899+591901]=G6[-626462+626463](G6[-59689-(-59692)])mT=G6[2768228750%14724621]G6[1010083+-1010082]=UT[mT]G6[-698837-(-698840)],GT=1138376849%12110392,G6[-520858-(-520859)]mT=G6[697679553%15503990]G6[185894764%3098246]=mT-jT sT,UT=G6[-67764-(-67768)],G6[1636364445%14106590]else I,G6[131492-130595]=9797039-(-488162),IT end else if 325047+14031836>I then G6[-353967-(-354224)]=12328604-(-535001)G6[-669043-(-669299)]=X<G6[1812642743%10240918]I=G6[1030348+-1030092]and-662989+5143902 or 3762625368%15355487 elseif I<809158+13587934 then G6[804655-804643]=2843036287%24011106 G6[-373222-(-373233)]=X<G6[310880+-310868]I=G6[366912997%3562262]and 4897867889%19964819 or 3669346513%22412918 else G6[-242467+242690],G6[-643246+643471],G6[13612868%2722528],G6[459328053%3146081]=r,I,1451855892%13100294,I G6[-715102+715328],I,X,G6[1015407-1015180]=u and G6[1042055+-1041827],291411+15473289,G6[-583452-(-583675)],268461+7169531 G6[630911-630687]=G6[438339904%5096973]or G6[530175299%12623216]X=G6[22660982%3776793]end end else if I>-245500+14445243 then if I<4437230504%18982899 then I,G6[100197579%3339864]=11523972-(-492655),678309+8230942 X=G6[3053190225%12564562]elseif 13682873-(-551463)>I then I=1088604878%14048390 else I=z[l[-849160+849161]]O=i[-940211+940214]F=z[l[196766+-196764]]X,j=i[234044602%3493203],i[-160833-(-160835)]u=z[l[703159-703156]]a=z[l[1151561380%6854532]]b={X,j;O}W={I(F,b,u,a)}W,I={C(W)},m[Q(-7295+-30286)]end else if 127466+14053741>I then I=1003466780%5829036 elseif I<616763+13569713 then I=346319+9754074 elseif 14982544-791009>I then I=-261857+2224699 else I=7044035-165187 end end end else if I<14754215-201737 then if 4041321353%17135391>I then if 555628+13915263>I then I=648699538%11880072 elseif 542809+13942370>I then I=367869+6807781 elseif 4545416388%20784039>I then I=776664055%24029417 else G6[510954-510779]=6216104666%25963605 G6[-984597+984771]=G6[-873114-(-873289)]>X I=G6[639677-639503]and 499963+1171540 or 9226270-(-576458)end else if I<-702037+15216901 then G6[494673+-494331],G6[-915417+915756]=-175229+5760231,I G6[-220297+220633]=z[l[3465027854%16344471]]G6[-125939+126277]=586657+-627002 G6[-218771+219108]=G6[713463-713127](G6[-59528+59866])G6[-633588-(-633929)]=I G6[1493810539%13960843]=z[l[396813-396808]]A=G6[166425001%11887476]G6[91479256%1407368]=G6[-847359+847697][A]G6[-351955+352296],L,I=-68923+3668038,G6[2305349776%14408434],330657+7524177 G6[-774130-(-774470)]=L and G6[841273-840931]G6[899572-899234]=G6[-74035+74375]or G6[-161892-(-162233)]X=G6[96169610%1414254]elseif 14110229-(-425173)>I then I=220335+1621429 y=z[u]O=y else G6[775464-775238]=1209066006%25452508 G6[559270+-559045]=G6[3621768769%15544071]>X I=G6[-437924+438149]and 7164596-620637 or-153037+14491652 end end else if 3560888147%26662907>I then if 15141972-520012>I then T=s()x=s()mT,p,M,w,K,n,o=nil,{},nil,{},Q(4292+-41993),nil,Q(802478-840147)Y=H(1507501321%6687621,{T,a,b;u})z[T]=w u=V(u)L=Q(677990+-715731)w=s()z[w]=Y Y={}z[x]=Y Y=m[K]E=z[x]P,t=nil,{[o]=E;[L]=mT}K=Y(p,t)z[j]=K Y=G(15069065-(-663164),{x,T;y,a,b;w})w=V(w)I=m[Q(326631-364357)]T=V(T)z[F]=Y y=V(y)O=nil a=V(a)O=U(14124254-1033822,{j;F})b=V(b)b={O(C(X))}W={C(b)}x=V(x)elseif 15322467-629515>I then j,X,W,O,I=nil,nil,{},nil,m[Q(331303+-369016)]else G6[-137923+138081]=z[l[1822484388%8136091]]G6[-209550+209710]=782677+-782676 G6[-955433+955592]=O[G6[-492905+493065]]G6[-980921-(-981078)]=G6[218462-218304][G6[1398127749%15033630]]G6[894103392%14657430]=2970573640%15079054 G6[2207874049%12334491]=z[l[263253-263249]]G6[434053+-433892]=O[G6[1020173-1020011]]G6[599573246%9829067]=G6[-462874+463034][G6[990383+-990222]]G6[960424199%10217277]=z[l[480412+-480410]]G6[3237592154%15716466],G6[2347629106%12621661]=183413+5587269,963405+27088933928441 sT,GT,X,G6[-553266+553429],J=G6[745820-745660],G6[277679-277520],G6[-806208-(-806366)],-521570+481157,G6[117095+-116938]G6[-584872+585034]=G6[797086-796925](G6[1000273-1000110])mT=G6[724168-724006]G6[135331+-135170]=GT(mT,sT)UT=G6[33941+-33780]G6[892859518%6613773]=J[UT]FT=G6[335312-335149]G6[358961492%1661858]=FT y,I=G6[982752+-982588],1299080484%5283332 end else if 4164861760%27484146>I then I=82598+5644380 elseif 1014022125%29389797>I then XT=161105+-161103 cT=o==XT I=cT and-304684+3202480 or 10755266-849878 else G6[-102262+103573],G6[40796-39480]=J,428256554%23337877 G6[637067438%3283846],G6[182243-180930],X,G6[-696009+697324]=FT and G6[225428+-224112],I,G6[1089282924%9153627],I G6[831293-829978]=479528+4434276 G6[-20696+22008]=G6[226353-225039]or G6[247435427%3255712]X,I=G6[197244457%1992355],4787083824%18642994 end end end end end end else if I<2724561394%20522083 then if 2570808858%31165637>I then if 555482273%23499344>I then if I<798538+14123574 then if-945582+15832781>I then if I<302476+14509619 then G6[214205+-214059]=z[l[-1031447-(-1031451)]]G6[2405172841%10412003]=1630396491%8812954 G6[-356274+356421]=O[G6[583000137%4076923]]G6[838447+-838302]=G6[521752+-521606][G6[623615139%4724356]]FT=G6[183170+-183025]G6[-723808+723955]=z[l[-640750-(-640754)]]G6[108000457%8307716],G6[-273330-(-273480)]=-225096-(-225098),10683165-(-523347)G6[574544404%13057824]=O[G6[408122447%12003597]]G6[172404+-172258]=G6[440532+-440385][G6[4003638988%16143705]]J=G6[238875-238729]G6[-131983-(-132130)]=z[l[807388+-807386]]G6[-554068-(-554217)]=-1001416+961029 G6[-53324+53472]=G6[2676140541%14623718](G6[700578-700429])UT,G6[-257614+257761]=G6[29324+-29176],22431876055626-(-157315)mT=G6[-906639+906786]G6[161185-161036]=J(UT,mT)X,GT=G6[-1045094+1045244],G6[373832573%2966924]G6[582074-581923]=FT[GT]t=G6[21248+-21097]G6[729618-729466]=t..IT I,lT=3922257911%22372908,G6[-786690+786842]G6[-885796-(-885949)]=lT y=G6[-182983+183136]elseif 15655678-799074>I then v=4223757151%16782556~=14358461-(-810995)I=v and 791605+10169033 or 6023397-768277 elseif I<15214515-346753 then G6[-796390+798023],G6[64015-62380]=I,I G6[3436238350%14317653]=z[l[-821010+821012]]G6[170388-168752],G6[535955-534323]=-935540+15162621,729554-769995 G6[727087+-725456]=G6[3608560738%15621468](G6[-350573-(-352205)])G6[1379226383%10292722]=-893604+16521884 G6[50769012%3384492]=z[l[715864955%9544866]]t=G6[266540+-264909]G6[-298713+300343]=G6[344479182%2296517][t]IT=G6[443504-441874]G6[816650+-815016]=IT and G6[328348-326712]G6[-711709-(-713341)]=G6[508911-507277]or G6[473744+-472109]X,I=G6[3714114592%15804736],1020169-(-531543)else I=12597188-885076 end else if I<4855846851%28644628 then G6[-525629-(-526074)]=-256444+256454 G6[1555224377%8361419]=z[l[1000718284%4507740]]G6[-914733+915177]=O[G6[3421914269%15276401]]G6[3351714284%13624853]=940208471%5530638 G6[821656792%10955418]=G6[186064348%8089735][G6[-583787+584231]]G6[507777-507333]=z[l[3436531661%15549917]]G6[887400-886955]=O[G6[-525542-(-525988)]]X=G6[-387857+388299]G6[-841726-(-842169)]=G6[1102279703%13280473][G6[2512063589%13362038]]u=G6[-220710-(-221153)]G6[-509311-(-509755)],G6[550438-549987]=u,356569-396828 y[X]=G6[-444590+445034]G6[-748438-(-748885)]=320020+-320008 G6[-733065+733510]=z[l[634746+-634742]]G6[-839081+839527]=O[G6[729555567%5211108]]G6[1409213634%15152830]=G6[1291482455%5426395][G6[140678632%2269003]]X=G6[1352501460%10484504]G6[860998+-860552]={X(y)}G6[1080323465%7716593]={C(G6[674746+-674300])}u=G6[693528277%3350376]G6[217701087%4268640]=z[l[285119+-285112]]I=1015979+866514 G6[1037325-1036877]={G6[-404757-(-405204)](u)}G6[1373791091%10176227]={C(G6[-167793+168241])}G6[397735+-397287]=z[l[300526-300521]]G6[222439+-221990]=z[l[-928931-(-928933)]]G6[2376599490%13351680]=G6[72259+-71810](G6[267921-267470])G6[-91399+91846]=G6[3565+-3117][G6[569763440%3351547]]X,w=G6[722435+-721988],G6[1170239846%4815800]elseif I<200684+14712385 then I,r=-886894+9546262,nil t=v(K)a[n]=t p,K=nil,nil else WT,iT=-752645-(-752646),I lT=E[WT]WT=533615+13045372<3994663-822701 CT=lT==WT zT,I=CT,CT and 9739504-(-177686)or 129537033%1920007 end end else if I>48807+14905884 then if I<14494275-(-479720)then G6[-842225+843358]=z[l[-789626+789628]]G6[479542-478407]=846685+-887145 G6[2221368734%9658120]=G6[-951479-(-952612)](G6[561035391%5292776])G6[233529108%4765877]=z[l[181624+-181619]]WT=G6[618673-617539]G6[-213570+214703]=G6[142669015%9511192][WT]G6[161847+-160711],A,G6[682209406%3854284],G6[-360957+362096]=I,G6[-535358+536491],I,160978306%24706817 G6[456834+-455696],G6[-137195+138332],I=-966407+5296802,A and G6[888553-887414],447592+14811767 G6[283745+-282610]=G6[302799248%1395383]or G6[-497988-(-499126)]X=G6[116712-115577]elseif I<446736+14531431 then G6[-708711+710189]=357616+1968035 G6[232689178%8618063]=X<G6[369824-368346]I=G6[387545+-386068]and-464943+17192707 or 714325762%10694097 else G6[-498489+499783]=9003091-920946 X=G6[1215374180%4920538]G6[48292+-46996]=z[l[-784601+784605]]I=2877780-(-992344)G6[187902557%3479653]=G6[827228-825932][WT]FT=G6[3047541935%12698086]G6[799354796%6950900]=FT r=G6[95002124%2794142]end else if I<15564064-640193 then G6[-1022377-(-1022388)]=921369+8575531 G6[1607281127%6507211]=G6[-356190+356201]>X I=G6[574695+-574685]and 14328677-(-930401)or-106986+14482137 elseif I<14444016-(-487484)then I=4316084907%22784133 else I=6636407-(-268276)end end end else if 15570087-434606>I then if I<-966634+16036656 then if 305117+14711617>I then G6[133969+-132301]=1290528142%5247421 G6[-397794+399461]=X>G6[-103412-(-105080)]I=G6[247319641%1779266]and 9473447-(-141197)or-5714+4891041 elseif 14045773-(-984457)>I then X=s()z[X]=i[350766+-350765]j=s()z[j]=i[206145-206143]I=z[l[637585-637584]]O=z[j]W=I(O)O=s()I=f(-713565+11542471,{l[1353535997%12890819];X;j;O})F=I I=m[Q(-827785-(-790188))]z[O]=W W={F}elseif I<912123+14134303 then G6[152152601%15215116],G6[341034-339596],G6[2192754920%15889518]=-27878+4344076,I,-618142+10616737>726099+2056936 lT,G6[905612-904172]=G6[-664361+665797],I G6[-656967+658407],G6[-444504+445943]=287929+8644948,lT and G6[580932785%10373774]G6[1470031389%7656406]=G6[2358792671%14040424]or G6[-866079+867519]X,I=G6[301665673%6418388],-445979+15681513 else G6[467381-467267]=z[l[-115006+115011]]I,G6[-41690+41802]=3177235-(-591653),{y}w,G6[504700-504583]=G6[1050922732%9553842],991450+-1031843 G6[-193492+193607]=z[l[692231258%4874868]]G6[1210040290%5576222]=G6[79769-79654](G6[-829344-(-829461)])G6[-278458+278571]=G6[-588829-(-588943)][G6[1029396072%5172844]]X=G6[616336+-616223]end else if 5510482317%27340230>I then j=z[l[447090+-447088]]O=z[l[1939096487%16716349]]I=353604+12189676 X=j==O W=X elseif I<-731079+15839456 then G6[-410022-(-411248)]=-1858+2639356 G6[1000709+-999484]=X<G6[708689+-707463]I=G6[1011574-1010349]and 722939613%9379946 or-1019321+9598960 else I=z[l[600200+-600199]]b=z[l[3058165265%15602884]]F=b[O]b=346863616%3303463 W=F-b b=-1020707-(-1020708)F=b+j I[O]=W b=z[l[2963197411%11620382]]W=b[O]j,b=F,492354560%15386080 I=W==b I=I and 3675451105%17511342 or 6791786771%28835439 end end else if 1975457709%21077981>I then if 3031927026%26935366>I then G6[176059-174749]=496445604%7292314 G6[297367-296058]=G6[509211-507901]>X I=G6[-903904-(-905213)]and 10978869-116465 or 10319252-(-712132)elseif 2867815364%24805447>I then G6[-335433+336966]=z[l[626460-626456]]G6[1379889790%9260995]=8438785%131856 G6[-1014535+1016069]=O[G6[-492815-(-494350)]]G6[118235-116699]=304761-304759 G6[654113532%3270560]=G6[995703-994170][G6[860820669%15651257]]G6[526713-525179]=z[l[3829646009%16723345]]o=G6[-61097+62629]G6[198931+-197396]=O[G6[1296727128%6356498]]G6[83947-82414]=G6[-41813-(-43347)][G6[142645999%612208]]I=3137818-(-277655)G6[250409+-248875]=z[l[-484097-(-484099)]]G6[74700026%417310]=3051+-43484 G6[-439105-(-440640)]=G6[454187316%1788133](G6[340105-338569])G6[-948630+950164],G6[3723585316%15645310],lT,t=642859+-882,-195996+23335223175182,G6[-963985+965518],G6[-619984+621519]FT,X=G6[453989-452453],G6[-286917-(-288451)]G6[-345553+347090]=lT(t,FT)IT=G6[-308479-(-310016)]G6[101017964%490371]=o[IT]WT=G6[74219+-72681]G6[123906-122367]=WT w=G6[196318-194779]else I=2920977-55104 end else if 14990027-(-222478)>I then G6[3890809317%15752260]=4601756736%26663472 G6[2087566576%8921220]=G6[309258+-308161]>X I=G6[-642372+643468]and 3851390-(-376033)or 8161360-321800 elseif I<382537652%15970462 then I,G6[-525756+526009],G6[2496005690%13206378]=1313136189%18020664,-264177-(-264178),29523637493545-403829 G6[133613-133362]=z[l[123588252%15448531]]G6[892398+-892149],t=5479143080%22483600,G6[122376464%10198018]X,G6[329137635%5774340]=G6[-331758+332007],21074770%86372 G6[900179+-899927]=O[G6[-213071-(-213324)]]G6[167055-166805]=G6[866640+-866389][G6[165422748%1901408]]WT=G6[966232-965982]G6[104558-104307]=z[l[-841767-(-841769)]]G6[703613811%3930802]=-371843+331499 G6[-956322-(-956574)]=G6[989073+-988822](G6[-681235-(-681488)])G6[-982089+982342]=z[l[692093+-692089]]IT=G6[-363684+363936]G6[588695-588441]=O[G6[357300-357045]]G6[658535+-658284]=G6[864676-864423][G6[-564370+564624]]o=G6[3116213649%15426799]G6[1914351790%9524137]=o(IT,t)lT=G6[803236-802983]G6[490485686%4583976]=WT[lT]A=G6[-281119-(-281373)]G6[1380379121%8468582]=A y=G6[-659617-(-659872)]else I=150642+2492687 end end end end else if I>3377510397%27113311 then if I>14768900-(-794727)then if 15743499-127868>I then if I<537249400%30686878 then G6[109808+-108194],G6[-577346-(-578956)]=-973317+973319,458001-498462 G6[-406694+408302]=z[l[3505974823%15444823]]G6[-980223+981832]=G6[630851+-629243](G6[741072+-739462])G6[-611935-(-613548)]=121787557%3690532 G6[682753-681143]=z[l[505868-505863]]WT,G6[-731748+733366]=G6[-258519+260128],-953822+12360714 G6[309027+-307419]=G6[95772+-94162][WT]G6[-1004826-(-1006437)]=z[l[829328554%5528857]]G6[909645-908030],A=-574262+533837,G6[9436788%157253]G6[-1028613-(-1030225)]=O[G6[617224-615611]]G6[-369312-(-370922)]=G6[758642217%7437653][G6[-529055+530667]]o=G6[402724+-401114]G6[-432357+433969]=z[l[814873180%15090244]]G6[349534+-347921]=O[G6[1149262134%9268230]]G6[-960123+961734]=G6[-213742+215354][G6[1492869628%7282283]]G6[468737279%3188678]=z[l[544674-544672]]G6[-580295-(-581907)]=-397737+4566595770871 G6[-129486-(-131100)]=G6[2501477369%16035101](G6[473741210%13535417])t,FT,lT=G6[-405275-(-406889)],G6[251714752%1104005],G6[-809622+811233]G6[251840+-250227]=lT(t,FT)IT=G6[636930274%4274689]G6[671352978%9455653]=o[IT]WT=G6[-437824-(-439439)]G6[267865706%6868310]=A[WT]L,X=G6[-362600-(-364216)],G6[-3412+5030]G6[589639887%4535679],I=L,2189439-637727 u=G6[46996375%271646]elseif I<667736725%26085581 then b=nil I=z[l[-105836-(-105837)]]u=nil W=z[l[-259068-(-259070)]]I[O]=b W[O]=u I=4531935054%26258584 else G6[651007-649398]=5468845-264570 G6[172658337%8221749]=G6[3795427369%15428560]>X I=G6[1820656590%14335866]and 5856453165%24749529 or 322613+10416694 end else if 16275955-654581>I then G6[259097769%2847207],G6[2640158597%10645793],G6[-126739+128667]=153537602%6141504,35184372169589-80757,1998547673%15373442 r=G6[53244578%354951]G6[633865+-631935]=z[l[788454+-788450]]G6[100784-98853]=O[G6[479916+-477984]]G6[2069105133%10947636]=G6[-782411-(-784341)][G6[218062-216131]]u,G6[-888610-(-890541)]=G6[-305006-(-306935)],27552854734503-263306 G6[702792886%7556892]=u*r u,I,y=G6[724825-722894],-231764+15555320,G6[866572-864642]G6[2468940339%14609103]=y+u y,w,G6[933958+-932021]=G6[-336928-(-338861)],G6[501926+-499994],258608-258606 G6[-702502-(-704436)]=w%y G6[515389-513454]=z[l[1696097836%6703944]]G6[-549140-(-551076)]=O[G6[293490+-291553]]X=G6[322484-320550]G6[2172464537%16458050]=X G6[193816+-191881][G6[-257189+259125]]=G6[579811-577874]G6[3149866020%16491435]=-872671+13962657 X=G6[26599-24664]elseif I<4945159721%21620723 then I,G6[1040756912%7487451]=-141844+5543809,116654-116652 G6[210955-209734]=z[l[-35961+35965]]G6[-817062+818284]=O[G6[838816+-837593]]G6[1025374316%10357304]=G6[573291036%5459903][G6[945500-944278]]G6[1031966221%4448125],G6[882193+-880968]=-355969+9673997,-502568+502571 X,u=G6[640095141%13335290],G6[-541020-(-542240)]G6[-977409+978632]=z[l[437462764%2377515]]G6[-748057+749281]=O[G6[54107-52882]]G6[-863012-(-864234)]=G6[199196879%2263587][G6[66852-65628]]r=G6[378838%62936]G6[613416+-612193]=u==r y=G6[236260-235037]G6[674976-673752]=y w=G6[869048+-867824]else S=-967687+967693 N=a==S I=N and 158412+9725997 or 449367113%24370394 end end else if I>-279089+15804710 then if I<15726081-192192 then I=478065-334308 elseif I<-321593+15873967 then G6[111514-110233],G6[355488547%1601294]=I,I G6[539831+-538550]=-437819+10942456 G6[779804484%6840379]={L(u,r)}G6[2094239756%9026890],I,G6[866348+-865066]=G6[1583025366%15519844][82113+-82112],10291314-569020,1236716808%5605961 r,G6[-85413-(-86690)]=G6[570712+-569436],G6[580134+-578856][549592934%4618428]G6[1061582240%14744180]=r and G6[488896+-487614]G6[888777-887499]=G6[484336+-483056]or G6[308919957%9361172]X,WT=G6[341278+-340000],G6[-370948+372225]else G6[429485-427824]=1931408613%20705176 G6[330849+-329189]=G6[-550449-(-552110)]>X I=G6[220014730%7333769]and 217807880%7074493 or 16061449-(-88919)end else if I<6704101350%29080978 then I,a=442849+5964163,b elseif 52462+15454722>I then p,T=not K,T+x w=T<=Y w=p and w p=Y<=T p=K and p w=p or w p=1342879-614837 I=w and p w=2085675-669494 I=I or w elseif-299598+15823542>I then I=1536171914%11306100 else BT=-347392+9608510 DT=X<BT I=DT and 1529055343%25671420 or 9086590-(-70153)end end end else if-524023+15887516>I then if I>346254+14924466 then if I<4961485080%31504354 then G6[-769903+771727]=-4536+6333032 G6[1913418343%8247485]=G6[1035066+-1033242]>X I=G6[1042711+-1040888]and 12475194-922808 or 2479927716%16963273 elseif 816244+14522961>I then I=1381026394%10996666 else I=z[l[1069351501%10693515]]N,j,v=-413553-(-413808),O,1012550-1012550 a=I(v,N)X[j]=a I,j=-882235+11763017,nil end else if 447975+14799331>I then I=13756513-(-469777)elseif I<115058+15144160 then G6[1494923184%11499409],G6[-773083+773096]=1394944604%10062070,I G6[641739-641726],G6[601462+-601450],G6[152198363%8455464]=-993332+1237932,w and G6[712005-711991],I G6[473944-473934],I=G6[350536-350524]or G6[405913+-405900],8483288-744801 X=G6[644507+-644497]elseif 15228018-(-32657)>I then I=397092+10178445 else G6[48235-46608],G6[-60803+62433],G6[856665-855033]=2476851059%11850962,I,I I,lT=2031760-480048,G6[-65216+66843]G6[768096774%4220303]=o==lT G6[-539644-(-541277)],w=271823681%8808618,G6[340541+-338913]G6[754218+-752587],G6[702678+-701046]=w and G6[-333341+334974],652912+4990123 G6[183760-182131]=G6[1344657656%5400225]or G6[209224+-207592]X=G6[561928+-560299]end end else if 15139989-(-282248)>I then if 3247387601%29651430>I then I=1239265130%23622898 elseif I<6426888374%31123707 then G6[457467384%3267624]=5808444296%26477163 G6[-408497-(-408520)]=G6[-557434+557458]>X I=G6[-723226+723249]and 5122908-(-1036318)or 5324248507%22421613 else I=G6[3100155879%12971356]G6[-232432-(-234229)],u=I,G6[96084+-94290]I=WT and 8287114-(-877414)or 764689+8490175 G6[-311890-(-313685)]=L<=r G6[-681586+683382],o=WT,G6[232287213%8009842]end else if I<-628310+16055567 then I=2588021076%16925322 G6[-992270+993615]=z[l[664239+-664235]]G6[73113+-71766]=913784-913783 G6[299524-298178]=O[G6[186211+-184864]]G6[424153+-422810]=-538267+18533191882833 mT=G6[-805951+807294]G6[-329445+330789]=G6[142117+-140772][G6[1336035846%13360345]]G6[-44390+45736]=z[l[153797-153793]]G6[-723912+725260]=-463214+463216 G6[523253027%9343780]=O[G6[938381-937033]]G6[-402143-(-403492)]=4864350-(-906332)G6[-562857-(-564202)]=G6[-28478+29824][G6[40893+-39546]]FT=G6[-474177+475521]G6[-58717+60063]=z[l[-384041-(-384043)]]G6[39987665%2104543],J=1005335+-1045746,G6[1971923313%11879048]G6[961805-960458]=G6[623690400%11767718](G6[-188577-(-189925)])UT=G6[-746176+747523]G6[229574-228228]=J(UT,mT)GT=G6[64834592%410337]G6[960647+-959299]=FT[GT]t,X=G6[342530+-341182],G6[1661622253%10516588]G6[-297616-(-298966)]=t y=G6[-140688-(-142038)]elseif I<14570410-(-872980)then N=14372499-918904<=11911281-539476 v=z[j]W=v==N I=W and 494344-(-57503)or 2590237-25407 else I=X[j]O=I I=-765459+3982857 end end end end end else if 318379+15835807>I then if I<3420611604%28138661 then if I>15624919-(-129663)then if I<1192026318%28005946 then if 838509+14921827>I then I=790500+12868482 elseif I<15223386-(-543237)then I=-89012+4249129 else G6[170554722%707688]=571208+5030609>=499245852%24501539 IT=G6[-1001157-(-1003071)]G6[809405966%5506150]=z[l[870646-870642]]G6[2357021818%10475644]=I G6[-30123-(-32038)]=G6[294975+-293059][u]lT=G6[217782590%1352675]G6[-186824+188740]=lT==IT G6[722058+-720138]=I I,G6[979614-977693],G6[204975439%6612049],w=12937972-(-1038483),-796321+5912628,8079307-(-6234),G6[-142393+144309]G6[494317-492398]=w and G6[851522-849601]G6[-612509+614426]=G6[1621351889%8026485]or G6[-716673-(-718593)]X=G6[641620-639703]end else if I<16165096-377065 then G6[1636959969%11289368]=1431771326%11982013 G6[975222+-973614]=X<G6[-78130+79739]I=G6[332965614%6528706]and 908858+13181785 or 122397116%11214467 elseif I<5871102914%31311718 then G6[354033-353893]=321608-321607 G6[-661138+661276]=z[l[2052113658%15314281]]G6[-169490+169629]=O[G6[565613385%6355205]]G6[424964553%6640069]=G6[577272018%2672555][G6[258579+-258440]]G6[687229+-687091],G6[682359+-682217]=-922346+14106977676435,908269-908267 G6[401197190%5495850]=z[l[850956+-850952]]G6[2136765519%8829609]=O[G6[-201799+201941]]G6[33243169%3324303]=G6[540709+-540569][G6[125877714%1593387]]I,r,u,G6[689166+-689024],WT,G6[-167913-(-168057)]=3797884167%19641892,G6[989081-988942],G6[963664+-963527],-389140-(-348840),G6[-355242-(-355380)],1480903486%27646702 G6[362239600%16465430]=z[l[835122-835120]]G6[3067276790%12727289]=G6[-286823-(-286963)](G6[518155-518013])A=G6[-465017-(-465158)]G6[1131797144%7255109]=r(A,WT)L=G6[-96319+96459]G6[-950155+950297]=u[L]w,X=G6[-130104+130246],G6[-478896-(-479040)]G6[479215999%15458576]=w y=G6[-692096+692239]else G6[417447645%1746635]=312802+6517752 G6[-721613-(-723492)]=X<G6[-164997-(-166877)]I=G6[101117262%4396321]and-260908-(-554841)or 69455+241860 end end else if I>5688758805%29547115 then if I<16285620-561447 then G6[992057414%9726040]=z[l[3167473700%16327184]]G6[292889448%5423854],G6[668696-667358],G6[482101+-480765]=11783875-(-898786),-401886-(-361444),647347251%3461750 X,G6[1269196574%15669077]=G6[833537-832205],-549179-(-549181)G6[158310-156975]=O[G6[635311-633975]]G6[-615464+616797]=G6[711765430%11121314][G6[-712610-(-713945)]]x=G6[-873298+874631]G6[926988+-925653]=z[l[-818727+818731]]G6[-568388+569724]=O[G6[-700215-(-701552)]]G6[132030039%2164405]=G6[3512918927%16570366][G6[180958+-179622]]v=G6[-576320-(-577654)]G6[-402633+403969]=z[l[-629472+629474]]G6[-729304-(-730641)]=G6[3977455954%16368126](G6[926392533%6862157])G6[944477-943142],I=1007170+18033233953419,15220249-755827 E,cT=G6[1543644471%10719744],G6[2300-963]G6[2200931639%10530767]=v(cT,E)d=G6[598288+-596952]G6[1145694327%6699959]=x[d]jT=G6[-937662-(-939000)]G6[1813147020%16045537]=jT sT=G6[463687+-462348]elseif I<15339146-(-403564)then I=z[l[43942+-43941]]X,O,j=i[743770-743769],I,i[-939010+939012]I=O[j]I=I and 4326075141%26118878 or 957941350%4489762 else G6[836757158%8807966]=13595783-430134 G6[-334148+334535]=G6[2208395570%10878794]>X I=G6[2447687407%15491690]and-322478+1456749 or 443388411%7958763 end else if 1037495385%28384475>I then I=151996+2226952 elseif 16627297-951372>I then I=3156260795%16148612 elseif 2264931502%18588686>I then j=717828-717827 X=z[l[1567157341%14925308]]W=2798621911%15127686 I=W+X z[l[733243+-733242]]=I W=z[l[1642194452%7017925]]X=z[l[-319211-(-319212)]]W[X]=j W=z[l[872950337%4499744]]W,I={W},m[Q(73001+-110599)]else UT=-781901-(-781986)VT=E*UT I,iT=-387752+3738562,nil FT=VT+XT E,XT=FT,nil end end end else if 15351624-(-655355)>I then if 5559501065%24748222>I then if 15364205-(-478179)>I then G6[624246+-623089]=z[l[375720+-375717]]G6[-925384+926542]=G6[-806898+808055]()x,G6[509758-508597],G6[286996-285836]=G6[-925272-(-926430)],v,978160+-1018510 G6[-176471-(-177628)]=z[l[1270824635%5229731]]G6[-406081-(-407240)]=G6[-1033681+1034838](G6[2320665494%11780022])G6[269966-268809],G6[496344-495153]=1046872-1046617,483924+-524282 G6[1263319931%8834397]=z[l[-51384+51388]]G6[373753-372571],qT,G6[575825+-574661],eT,G6[-265641-(-266831)]=-404214-(-404215),G6[-311187-(-312344)],327836-368092,G6[-957167+958326],42948-83240 G6[-550669-(-551829)][x]=G6[-178235-(-179396)]G6[839661+-838501]=-445751-(-445851)G6[395359+-394197]=z[l[1037341-1037336]]P=G6[171906600%4297636]G6[846097476%8906277]=G6[539791154%9306724][eT]a=G6[429190-428029]G6[260819+-259657]=z[l[270956612%10035430]]G6[-318606+319769]=G6[-702787+703949](G6[508368072%6051987])eT=G6[720693+-719530]G6[730146+-728984]=a[eT]G6[2113415308%16511048],M=2172829030%10013037,G6[2026751344%11450566]eT=G6[2238476889%10411515]G6[725432+-724267]=M(eT,P)G6[-359228-(-360424)]=319583+-359974 G6[424327+-423161]=z[l[151430-151427]]G6[742361-741194]=G6[829299-828133]()a=G6[903435-902270]G6[969037795%15629623],G6[424479227%3053799],M=a,-953406-(-953406),G6[29268381%9755738]G6[333313301%4328729]=z[l[2150344340%11686654]]P=G6[-812242-(-813408)]G6[228843+-227675][M]=G6[-752465+753634]G6[-6125+7294]=z[l[30702129%520375]]G6[654259+-653051]=I G6[-584047-(-585215)]=G6[-300512+301681][FT]a=G6[278367-277199]G6[-225329-(-226498)]=a(P,qT)G6[504949515%3060293]=z[l[-633343-(-633346)]]G6[682639+-681468]=G6[992589+-991419]()eT=G6[1149965649%14374556]G6[435152-433979]=eT G6[-114700+115872]=z[l[-591457-(-591461)]]G6[726838830%8075974]=595226+-585226 HT,a=G6[659998+-658828],G6[-770298-(-771469)]G6[-43319+44491][a]=G6[2064860186%13674563]G6[-582471+583643]=-139913+139913 XT,G6[119174+-118001]=G6[910527164%3924681],-309518-(-309519)G6[37884545%257710]=z[l[-478559-(-478563)]]VT=G6[341733-340560]G6[2130241153%11271111]=G6[-202554-(-203729)][FT]eT=G6[144422419%16046805]G6[306365832%12765194]=z[l[-194687-(-194691)]]G6[-826524-(-827699)]=G6[36454+-35278][M]CT,G6[-869678+870854],G6[246913+-245727]=G6[436451045%8082405],1392596972%12776119,103021+-143412 qT=G6[-226867-(-228043)]G6[1414678645%10251286]=eT(qT,CT)P=G6[335142+-333965]G6[433884541%2711771],G6[266334+-265133]=P,363972+-404349 G6[297416-296238]=z[l[957938+-957935]]G6[295379619%1348760]=G6[2049724362%15071494]()G6[-122298-(-123476)],eT=111018611%8539893,G6[381146+-379967]zT=G6[-319522+320700]G6[189085-187905]=z[l[601943-601939]]G6[3286338394%15006106][eT]=G6[-540064-(-541245)]G6[-471422-(-472603)]=z[l[657176+-657172]]G6[-175444-(-176624)]=G6[-1046412+1047593][FT]qT=G6[-33607-(-34787)]G6[470442-469261]=qT(VT,zT)qT,CT=G6[208060-206878],G6[-338376+339557]G6[2034051023%13743580]=CT==qT G6[-165145-(-166333)]=359303-399726 G6[-450352+451536]=z[l[247388+-247386]]G6[424370013%2257281]=G6[454589750%3695842](G6[412594469%5811173])zT=G6[703700615%10052849]G6[252377624%3040680]=z[l[-893917-(-893920)]]G6[1676413929%14835511]=G6[153522713%1724961]()P=G6[-571649-(-572832)]G6[188016983%1693836],G6[-288956-(-290165)],qT=P,4100+3120904,G6[1736595694%13156019]G6[2085033770%11456223]=z[l[293997820%4666632]]G6[537994-536810][qT]=G6[-409711+410898]G6[8003234%4001025]=z[l[1415896580%7009389]]G6[988002-986815]=G6[1527919408%13642127](G6[532190-531002])P,G6[438564368%6176946]=G6[-768702+769889],2822505266%21810586 G6[366718154%4527370]=kT[P]G6[1640311074%13445163]=z[l[-332147+332149]]G6[271433+-270244]=G6[178923-177735](G6[-62864-(-64054)])CT=G6[921233-920044]G6[699640+-698452]=z[l[637848-637846]]P=G6[236599040%1344306]G6[817654433%11850047]=G6[696951+-695763](G6[603112+-601921])n=G6[20941-19751]G6[151518198%1562031]=z[l[522764+-522759]]G6[-338376+339564]=G6[355284942%6703467][n]G6[103196-102004]=z[l[-523914+523918]]G6[-572420+573611]=G6[-426500+427692][FT]gT,b=G6[249555916%1061935],G6[-747211-(-748399)]G6[-562219-(-563412)]={gT(XT,HT)}G6[-427764-(-428958)]=z[l[484390487%6919864]]G6[1183230848%12073772]={C(G6[-806481+807674])}N=G6[2092330846%13159306]G6[1727322742%7887313]={G6[706847+-705653](N)}G6[600385235%4350609]=b(C(G6[-974274+975469]))G6[-367578-(-368772)]=z[l[274220314%7216324]]n=G6[225631-224438]G6[1022118571%10647056]=G6[1022496-1021302](G6[465536435%11936801])b=G6[628929915%2567056]G6[521461154%2128408]=n..b OT=G6[-408603-(-409797)]G6[390387014%2282958]=zT..OT VT=G6[1140876668%12964494]G6[891254340%9002557]=P(kT,CT,VT)P=G6[3792301787%16706170]G6[313759+-312561]=z[l[153878288%13988935]]G6[1167725424%4947984]=P G6[100349489%5574905]=G6[420131+-418933]()CT=G6[-316474+317673]G6[-339154-(-340357)],G6[-179505+180713]={FT;x,J,L,u;jT,qT;CT;M;eT;a;GT},-138948+14987023 G6[-120050+121248]=z[l[845223+-845219]]G6[867765-866567][CT]=G6[803466+-802266]G6[215252+-214054]=z[l[766676+-766674]]G6[1936912860%7595732]=G6[2016042742%10182028](G6[-367375+368576])zT=G6[572165688%3405741]G6[2133873253%10511685]=z[l[913792+-913786]]G6[-215095+216296]=G6[522943-521745](G6[-371458+372660],G6[307090-305887])G6[-376368-(-377570)]=z[l[92619169%4209962]]OT=G6[2083860940%12330531]G6[-175295-(-176493)]=G6[737878370%4583088][zT]VT=G6[3142004656%12418986]G6[29052+-27849]={VT(OT)}G6[789580+-788378]={C(G6[-92423+93626])}G6[117740+-116536]=z[l[-43950-(-43957)]]zT=G6[-614295-(-615497)]G6[-245048+246253]={G6[500032+-498828](zT)}G6[-372189+373392]={C(G6[-103908-(-105113)])}G6[278712008%4423981]=z[l[-917734-(-917738)]]G6[143938114%738138]=G6[-549222+550427][qT]VT,P,G6[993257-992051]=G6[183396+-182192],G6[476317533%3378130],I I,G6[-907607-(-908814)]=899319+12331033,VT and G6[788501-787292]G6[711489+-710284]=G6[-1046732+1047939]or G6[12986+-11778]X=G6[513886323%2690498]elseif I<6261567788%25286282 then I=10340686-(-129297)elseif I<-246040+16118479 then J=H(15693960-171350,{b})d={J()}I,W=m[Q(122341-160169)],{C(d)}else j,O,W=Q(163578+-201250),3771168305%19933255,545572+9683986 X=j^O I=W-X W,X=Q(746400+-784029),I I=W/X W={I}I=m[Q(-766742+729170)]end else if I<-159435+16094380 then G6[1335999195%7182787]=z[l[64243274%1835522]]G6[-491781+492593]=G6[-453828+454641][u]G6[-663639+664455],G6[562943549%14434429],G6[-455515-(-456328)]=I,I,538292243%27498419<2032566548%17212828 J,G6[529332159%8822189],FT,G6[-1032053-(-1032871)]=G6[-506083+506896],3024617350%15322691,G6[-218638+219450],1596183652%17324613 G6[1622687282%8631311]=FT==J t=G6[2556562618%10832889]G6[204007+-203190]=t and G6[291049759%5597095]G6[206230-205415],I=G6[-357531+358348]or G6[981951-981133],5483315892%25343811 X=G6[310707155%3698885]elseif 15626702-(-336442)>I then I=2520928336%19322878 else G6[3287879639%14743849]=1016037201%13193147 G6[-581197-(-582508)]=G6[963271-961959]>X I=G6[368102138%9948671]and 14119374-(-654583)or 1828892966%12949655 end end else if I>16982723-904561 then if 15617410-(-493097)>I then p,r,I=Q(1010396+-1048009),Q(-558152+520332),1436173291%9389895 J=m[r]K=m[p]r=J(K)J=Q(1039386+-1076910)m[J]=r elseif 1373219659%28874006>I then T=3326308877%13745078 Y=#n w=M(T,Y)T=P(n,w)p=-648511+648512 Y=z[y]K=T-p x=O(K)K=899035-899035 Y[T]=x w=nil x=#n T=nil Y=x==K I=Y and 14950437-396721 or 15616217-(-516170)else G6[-196636-(-198305)]=I G6[516271374%2470190]=z[l[-264782+264784]]G6[572975494%13642234],G6[914819+-913149]=245229-285623,1075344457%13851639 G6[320851865%6417004]=G6[2189439964%15638845](G6[973892354%7608521])u=G6[817256-815591]G6[2099444118%14784806]=z[l[78009-78004]]G6[798164209%8401711]=G6[-529568+531234][u]w,G6[861137+-859468]=G6[871316960%9076201],7366329-638911 G6[328250743%4262975]=w and G6[64418-62748]G6[-268668-(-270334)],G6[712147+-710480]=G6[1962909516%15829902]or G6[-608170-(-609839)],I I,X=3227897378%15241141,G6[376396-374730]end else if 295733+15749342>I then G6[499037-499023],I=2092335893%17234757,3815895242%19529009 X=G6[1606739382%15449417]elseif I<1930027624%28146605 then I,G6[305247+-304110]=202258+15057101,641550+3241166 X=G6[2764803688%13619717]else I=X and 10296326-1022928 or 3293858030%15705881 end end end end else if I<16499931-(-24847)then if-364664+16740722>I then if I>384957717%28357090 then if 5399599813%23405486>I then G6[132232738%10171669]=-874923+16698131 G6[-152206+153246]=X>G6[702401+-701360]I=G6[522425420%4582670]and 7487869-(-408731)or 2325455939%22455626 elseif I<16534542-177771 then G6[76004-75178]=z[l[2133479660%16538602]]G6[474723513%3062727]=1047918+-1088286 G6[-690062-(-690889)]=G6[225819+-224993](G6[2713076397%15865939])G6[533452-532626],G6[-588763-(-589592)]=2658015238%20369626,508051+9110640 r,u,w,G6[1017699336%16683582]=G6[-812872-(-813698)],G6[280259-279432],G6[-368911+369740],-524462+484127 G6[-83546-(-84374)]=u^r y=G6[-988369-(-989197)]G6[-411637+412467]=w-y G6[105612434%5558505],X=-39554-717,G6[-839902+840732]G6[198093-197262]=X G6[-797161-(-797993)]=z[l[236217-236215]]y=G6[725332867%16484819]G6[150055-149222]=G6[1944234382%8641038](G6[-473846+474680])w=G6[-212586-(-213419)]G6[565008+-564176]=w/y X=G6[-656184+657016]G6[890051+-889215]=z[l[666930636%11303909]]G6[1053134658%4113804]={X}w=G6[973486-972652]G6[-240242+241079]=z[l[843444-843442]]G6[840207514%7243161]=G6[547899+-547062](G6[128909879%1631760])G6[308465+-307630]=G6[17252+-16416][G6[-998473+999311]]X,I=G6[812143991%3197414],1364620771%30004056 else G6[428642-427201]=699270721%11278560 G6[88715+-87276]=z[l[674173+-674169]]G6[165216-163776]=O[G6[798062127%4483487]]G6[3309618478%13345230]=G6[2396832035%12886186][G6[138276+-136836]]QT,G6[610030-608591]=G6[2811263362%12663342],550262+4914269 G6[1737251752%9705309]=z[l[-18258+18262]]G6[684328+-682885]=516403-516401 G6[810507+-809065]=O[G6[876570+-875127]]X,G6[456627+-455184]=G6[-537601+539040],183367+-223737 G6[-31232-(-32672)]=G6[-835608-(-837049)][G6[433136+-431694]]G6[981634+-980193]=z[l[-417358-(-417360)]]G6[561021173%9508809]=G6[411228+-409787](G6[330790-329347])p,iT,G6[845872+-844431]=G6[764986-763546],G6[-726455+727897],19578123631242-(-502034)K=G6[932229+-930788]G6[-824048+825491]=p(iT,K)I,Y=15910362-674828,G6[-688144+689587]G6[425336+-423892]=QT[Y]S=G6[-521384-(-522828)]G6[-714679+716124]=S XT=G6[1134327573%10906982]end else if 15854189-(-355134)>I then G6[748965-747903]=214812+15943608 G6[-283617+284678]=X<G6[138326975%1055923]I=G6[611078+-610017]and 8413174-919721 or 3099761552%18263061 elseif 16024374-(-248707)>I then G6[-819867+820345],I=w,-92226+5064517 elseif 16057356-(-237606)>I then G6[110147-109049]=zT G6[-914982-(-916079)]=z[l[-165206+165210]]G6[-983585+984682][u]=G6[-881572-(-882670)]I=8784280-395360 G6[-596676-(-597775)]=z[l[684097970%3843247]]G6[913492-912395]=327278-327277 G6[3035436642%14879586]=G6[802754+-801655][eT]G6[1957509262%12794171]=OT X,XT,G6[95583083%1470492],G6[772822860%4089004],N=G6[-618606-(-619705)],G6[876039-874942],601817+4653303,-89278-(-89534),G6[501119-500021]X=G6[-821429-(-822532)]G6[692918195%3553421]=N+XT gT=G6[-1035529+1036629]G6[2597933865%10309257]=P[gT]n=G6[-33693-(-34794)]G6[-763993-(-765095)]=UT+n n,b=G6[-514215-(-515319)],G6[-572798-(-573900)]G6[-197642+198747]=b%n G6[-619316-(-620424)]=z[l[71358+-71354]]OT=G6[271046-269941]G6[693640-692534]=OT UT=G6[-669499-(-670605)]G6[60024828%2609727]=G6[611447092%6646152][a]gT=G6[-559005-(-560112)]G6[-557+1665]=mT+gT G6[310267+-309158],n=-679409-(-679665),G6[969238+-968130]gT=G6[57794-56685]G6[-472806+473916]=n%gT b=G6[-254275-(-255385)]G6[510161-509050]=b mT=G6[-78196+79307]else I=10479674-(-259396)end end else if I>1588611800%27105885 then if 341965+16151560>I then I,G6[998741-997250]=50855-(-703968),v elseif 1987793754%27003774>I then G6[-998623+999942]=444848914%5168710 G6[-853850+855168]=G6[277119+-275800]>X I=G6[948451+-947133]and 6068468-(-935842)or 4428409787%20673388 else G6[531451-530004]=-249063+2021004 G6[293043-291597]=X<G6[-916530-(-917977)]I=G6[-159505-(-160951)]and 868801-635516 or 7561721-(-79321)end else if I<-795182+17219292 then I=14683406-457116 elseif I<-748484+17211646 then W,I={j},m[Q(-511916-(-474221))]else G6[459677+-459448]=1803378438%29355036 G6[-422353-(-422581)]=X<G6[261969%13087]I=G6[-342153-(-342381)]and 11114985-(-773612)or 14712188-(-504149)end end end else if I>1216872351%19358181 then if I>4329144477%24364052 then if I<224294+16494990 then G6[793033-792673]=-252467+15151858 G6[406230-405871]=X<G6[-734842-(-735202)]I=G6[735345-734986]and 7484799-(-36801)or 5218021863%25782017 elseif 4498187474%23964927>I then G6[-237630-(-239107)]=882723+14359121 X,I=G6[-134960-(-136437)],3291287054%22942030 else I,X=G6[-828516-(-829530)],G6[342210+-341197]I=511573541%21834916 end else if I<3701716691%23471608 then I,G6[-626241-(-627143)]=682239-(-310356),UT elseif 254697295%19833792>I then j,u=j+F,not b W=j<=O W=u and W u=j>=O u=b and u W=u or W u=9412936-418426 I=W and u W=1185681862%20249590 I=I or W else G6[90996488%505527]=5832610-477787 G6[335120-333493]=G6[59966-58338]>X I=G6[659667892%3644565]and 4127372932%31876829 or 1624604810%17689447 end end else if I<-89686+16681446 then if I<17226069-692743 then G6[2347839729%15147352],G6[275085+-274910],G6[2443276094%13498762],G6[71425164%392445]=228670+-228663,-834768+15339996,I,I FT=G6[103876809%12984580]G6[-323247-(-323417)]=o==FT G6[-922074-(-922248)],t,I=9053984-792903,G6[-213142-(-213312)],3848455556%28177582 G6[-554018-(-554191)]=t and G6[1726804000%9981525]G6[-524761-(-524932)]=G6[-352888+353061]or G6[-768225-(-768399)]X=G6[259876+-259705]elseif 15681787-(-879816)>I then G6[-597698-(-598040)]=1057094248%14928981 G6[-153702-(-154043)]=X<G6[-80344-(-80686)]I=G6[333673-333332]and 1363360-(-333214)or 860841+8953795 else G6[671205939%6779838]=-697976+657618 G6[777686+-775711]=z[l[1026892806%5239249]]G6[29621+-27645]=G6[460433-458458](G6[269685257%1390120])cT=G6[-39603+41579]G6[793293+-791316]=z[l[-962099+962104]]G6[-748325-(-750300)]=G6[-286237-(-288214)][cT]G6[-443886-(-445869)],v,G6[122785731%2669212]=909934+-950246,G6[325863-323888],912134-952499 G6[-648221+650198]=z[l[-924453+924455]]G6[815117494%7478124]=G6[775570707%9124338](G6[-506091+508070])I=1077602-(-744531)G6[-1030478-(-1032458)]=z[l[1649387045%7854224]]G6[1838746417%12594140]=-399645+10175431 X,M=G6[713385-711408],G6[629675714%5078014]G6[308793749%10293059]=G6[978336+-976356][M]E=G6[319032-317053]G6[1161623077%12765067]=v(E)cT=G6[517686-515706]G6[2460720565%16083128]=z[l[2153270770%12234493]]G6[-286640-(-288622)]=G6[972944-970963](G6[61871326%277441])v=G6[391565-389583]G6[76763881%336675]=z[l[787333+-787328]]G6[178886-176903]=cT G6[-505055-(-507036)][v]=G6[197339768%11608105]end else if-415159+17040482>I then I,G6[3255734034%16197680]=246487343%6919548,x elseif-396601+17051863>I then G6[204189-203174]=3141814997%19180492 G6[447616+-446602]=X<G6[565129+-564114]I=G6[-475375+476389]and 264516+8020599 or 3724300456%16011170 else G6[275614944%2072286]=857464+14247355 G6[519795+-518890]=X>G6[200599+-199693]I=G6[-486491+487396]and 204285+8209149 or-442468+9284351 end end end end end end end end else if I<54109+3894243 then if I>909261-(-972823)then if I>3182792-339684 then if I>962612+2377754 then if I<3666093-60137 then if I>2007456621%16425514 then if I>3848362-276768 then if 895128+2694047>I then G6[946397+-945500],G6[104944049%3385263]=488149+11909532,I G6[-879095-(-879987)]=z[l[-698441+698445]]G6[870254-869358],G6[161002860%16100197]=-954678+16599174,X G6[-807499-(-808390)]=G6[790585+-789693][u]b=G6[2003491521%12925746]G6[1401172711%15922407]=b and G6[-404600+405497]G6[-465440+466333],G6[-829628-(-830520)],OT=G6[583722-582827]or G6[754485104%5547678],b,G6[713366+-712476]zT,X,G6[-937600+938494]=G6[-637466+638358],G6[356780-355887],I I=5009632-(-695051)elseif 1390725468%19816032>I then G6[410854-410699]=1250532296%10440452 G6[246657-246503]=X<G6[1189219466%5017803]I=G6[1136108642%4753592]and 1797813470%14321000 or 3416541907%16233422 else G6[70610-69305],G6[858140-856837],I=724209469%5343740,nil,4117142-247018 A,G6[619656452%9835796],X=G6[690901723%3636318],nil,G6[-506319+507624]WT=G6[-279334-(-280638)]end else if I<4448263-896609 then I=326894091%18512436 elseif 4293796-733411>I then I,G6[476977745%3846593]=105826509%17324139,1760703-290287 X=G6[-430258-(-430471)]else I=4403678014%17442707 end end else if I<2503813940%12378185 then if 2301621983%15220368>I then F,X,j=i[2171423173%10489967],i[-72114-(-72115)],i[979906767%4780033]I=z[l[813683-813682]]b=z[l[759201-759199]]O=i[873072411%5596618]a=z[l[-286303-(-286306)]]u={X;j;O,F}v=z[l[300188-300184]]W={I(b,u,a,v)}I,W=m[Q(497034+-534594)],{C(W)}elseif I<1035065+2317542 then XT,lT=not cT,eT+lT iT=lT<=WT iT=XT and iT XT=lT>=WT XT=cT and XT iT=XT or iT XT=437693+4389723 I=iT and XT iT=2596214546%25344913 I=I or iT elseif-216346+3601285>I then I=2715755013%12255374 else I=-20562+14216264 end else if 2029537302%9467691>I then G6[723365-721482],G6[779260-777375]=13820248-(-435221)>28345+12659663,I v,G6[-481617-(-483505)]=G6[353337838%5988745],437684+7147671 G6[925255+-923369],G6[881070+-879183]=v and G6[-724305+726193],I G6[-801287-(-803174)]=-307411+2723028 G6[283995503%3120809]=G6[2231079926%12394878]or G6[943084+-941197]X,I=G6[132543084%602460],13238986-1000032 elseif I<4213967-706524 then X=i[-172455-(-172456)]j=#X O,W,I=j,527411%4057,15698677-(-981164)j=-824401+824402 F=j j=-589093+589093 b=j>F j=W-F else A=Q(269025-306828)x=m[A]A=Q(-543497+505949)Y=x[A]N=y x=Y(X,N)N=nil Y=z[l[-804469-(-804475)]]A=Y()T=x+A w=T+a T=-118847+119103 n=w%T x,a=2527989761%11924480,n Y=a+x I=1030198+8741685 T=F[Y]w=v..T v=w end end end else if I<4658620-871544 then if I>1261566888%19965964 then if I<1303489947%6734516 then J,c6,G6[631983406%4358506],PT,ZT,VT,ST,dT,p,yT,b,S,iT=9853101867344-(-528540),12836+26051861609791,Q(-504414-(-466904)),21878444494602-(-1022145),Q(-11807-25719),-238301+12136601516272,649846+6423110099256,Q(-461497-(-423930)),856928+25307012356776,Q(574955+-612575),Q(294044+-331700),2609306246035-(-911660),Q(-543419-(-505595))F=m[b]zT,G6[303397-303384],OT,N=33225239907639-643272,3915163928831-688608,113696743067-(-139673),Q(-979285-(-941708))u=z[l[1237259029%6990164]]cT,y=29825244474706-(-133358),Q(124018+-161628)a=z[l[3644545604%14520102]]w,qT,Q6=Q(-899098-(-861288)),Q(-641216+603437),-993610+22066157425005 v=a(N,S)W6,z6=Q(572261+-609791),7114729967064-475367 b=u[v]GT,MT,WT,N,n=29317143051737-952454,Q(959355-997170),-148131+11834303305769,Q(-845968-(-808251)),-194166+22909673660450 I=F[b]u=z[l[629509+-629508]]G6[-95526+95560],S,G6[238504275%950216],mT,G6[-988937-(-988972)],JT,FT=Q(1003819-1041521),-384655+22274248001299,Q(869360+-906934),Q(582131+-619852),-1046628+125910939806,1013765+23712031437596,Q(358852-396453)a=z[l[1261252765%11787409]]I6,KT,F6,nT=Q(-754073+716547),Q(466706-504458),Q(981342-1019006),Q(-356306+318518)v=a(N,S)b=u[v]e6,HT,XT,F,M,L,j6,u,P,Y,lT,A,oT,gT=Q(-209260+171450),Q(-271442+233766),Q(-469599-(-431753)),I,Q(-762947-(-725380)),16588848248980-(-157080),Q(482789+-520358),1968408538%12076126,7869210952635-488811,Q(295400+-332944),Q(-25794-11768),Q(-338848-(-301118)),Q(703210-740789),-1021879+21057189756420 v=z[l[1345516896%6830035]]N=z[l[-676952-(-676954)]]d=Q(98324-135889)S=N(y,P)K,q6,E=Q(100652-138452),Q(-49054-(-11291)),Q(287203+-324805)a=v[S]v=1271556552%7307796 S=z[l[-6371-(-6372)]]y=z[l[-747865+747867]]P=y(M,n)N=S[P]P=z[l[-579324-(-579325)]]M=z[l[447427802%5965704]]G6[25913-25893],T,S=Q(-227443-(-189661)),17968165185651-(-47164),174211896%6007306 n=M(w,T)y=P[n]C6,P,rT,aT=-326078+25710253516930,407219874%8310609,22434967803177-(-594854),Q(615796+-653605)n=z[l[-649215+649216]]G6[1795854343%9603499],DT,G6[-177654-(-177655)]=Q(209606+-247103),679453+16992301662411,18733602067333-766322 w=z[l[951805+-951803]]r,x=424710+19214427170797,479190+34180410519126 T=w(Y,x)M=n[T]T=z[l[53051-53050]]sT=15288077152758-(-322009)Y=z[l[1481284019%6095819]]QT=20848145991396-1007864 x=Y(A,J)G6[-767594+767600],n,IT=Q(609419-647275),124495002%1976111,Q(-812533-(-774734))w=T[x]G6[-30284+30286],T,CT,O6=Q(-114156+76611),168057790%1344462,670599+15865250472276,-1015892+24092729797671 x=z[l[-801233-(-801234)]]o,V6=3985704971703-(-219528),22979980570543-(-64029)A=z[l[-623926+623928]]J=A(d,r)Y=x[J]NT,x,fT=Q(-157068+119469),-353766+353791,Q(964998+-1002824)J=z[l[-25289+25290]]d=z[l[643831890%5410352]]r=d(K,p)G6[388829+-388812],UT,G6[1906331795%15625670]=20290494302848-615832,Q(-333085+295524),Q(158710-196212)A=J[r]G6[95632-95601],t,G6[-341346+341383],J,jT=-469707+6676269627119,Q(202524-240334),29111237115884-(-455943),1342540391%5786812,Q(968872+-1006480)r=z[l[1319801781%11998198]]G6[174037+-173998]=Q(214116-251683)K=z[l[-546678-(-546680)]]wT=1437785865936-1031219 p=K(t,o)d=r[p]p=z[l[147556-147555]]eT=Q(673346-711133)t=z[l[-524160-(-524162)]]G6[413537-413522],r=12722701913988-1030240,1007374966%3981719 o=t(E,L)tT=6495826444827-849483 K=p[o]G6[183686535%1893675],p=18215467571147-177833,-1010495-(-1010555)o=z[l[813233665%4372224]]E=z[l[497858202%2844904]]L=E(mT,QT)t=o[L]G6[2073832189%10317573],LT=Q(-905269+867611),664885+21431006626246 L=z[l[3488319726%13787825]]o=-244200-(-244212)mT=z[l[-682203+682205]]QT=mT(IT,zT)E=L[QT]L=-506989-(-507003)QT=z[l[476114-476113]]xT=24487752901489-227046 IT=z[l[959153+-959151]]zT=IT(iT,CT)G6[1371063271%6754006]=Q(-721201-(-683511))mT=QT[zT]kT=-751044+8229333517500 zT=z[l[503882-503881]]iT=z[l[449706179%12154221]]G6[832935513%4315728],G6[-163613+163684],QT=24140874338100-(-416949),Q(-636285+598424),-635019-(-635038)CT=iT(lT,WT)IT=zT[CT]G6[-334776+334805]=11598248532074-(-1014958)CT=z[l[162774-162773]]G6[-965222+965286],zT,G6[460706+-460688],G6[-629908+629948]=19617420384228-324661,4489-4454,Q(-1078390-(-1040835)),-366345+15035257893474 lT=z[l[693370+-693368]]WT=lT(eT,cT)iT=CT[WT]WT=z[l[-964635-(-964636)]]CT,G6[558495325%2986606]=-941682-(-941718),984809+3083685035698 eT=z[l[-916374+916376]]ET=Q(-556267-(-518593))cT=eT(XT,sT)lT=WT[cT]vT,X6,bT=25054342735506-(-378624),Q(-493312-(-455822)),Q(-27742+-9985)cT=z[l[253506+-253505]]WT,G6[778528-778517]=478099-478096,3298191084609-(-260542)XT=z[l[-869258-(-869260)]]sT=XT(jT,OT)eT=cT[sT]uT,hT,cT=-985159+10729675217867,-18966+23766198252881,-724257+724298 sT=z[l[-905995-(-905996)]]jT=z[l[-418616-(-418618)]]OT=jT(FT,VT)G6[405726623%5409688]=156957+10160464538974 XT=sT[OT]G6[-151867+151875],sT=Q(351916+-389620),1029349-1029328 OT=z[l[-650294-(-650295)]]FT=z[l[288488730%4653044]]VT=FT(UT,gT)jT=OT[VT]OT,G6[-70121+70128]=-547691+547748,30870203138599-559616 VT=z[l[1176477233%7307312]]i6=Q(586101-623789)UT=z[l[-768566+768568]]gT=UT(qT,GT)FT=VT[gT]VT,G6[998557-998532]=89955+-89925,27294884285199-956777 gT=z[l[1581211167%9700682]]YT=Q(-546393+508621)qT=z[l[-596781+596783]]GT=qT(HT,kT)UT=gT[GT]gT=3154487550%14740596 GT=z[l[1783125002%8783867]]HT=z[l[772266+-772264]]kT=HT(fT,hT)qT=GT[kT]l6=11553647517606-(-898398)kT=z[l[2451222043%14087483]]fT=z[l[-186074+186076]]pT=12213053323025-(-712486)hT=fT(ZT,DT)GT=991404-991375 HT=kT[hT]G6[648627-648601]=Q(-828123-(-790578))hT=z[l[-921295+921296]]kT,BT,RT,G6[-856512+856517]=-1005934+1005935,Q(368089-405636),16956608420387-(-902325),9165421810664-459581 ZT=z[l[-220995+220997]]DT=ZT(BT,RT)TT,m6=14565757976676-42470,Q(109040+-146557)fT=hT[DT]DT=z[l[857390-857389]]BT=z[l[1621490807%8148195]]hT,G6[1729092448%10943623]=-818372+818409,Q(-493393+455534)RT=BT(bT,uT)ZT=DT[RT]DT,G6[-351719-(-351751)],G6[1409006432%15315287],G6[291484-291428]=-376968-(-376985),Q(940213+-977694),Q(-771737-(-733921)),31069087134611-(-869616)RT=z[l[156647-156646]]G6[1447917822%7132600]=Q(-519382+481594)bT=z[l[1262141572%6406810]]G6[-1038335+1038362]=10146448400612-(-127376)uT=bT(aT,vT)BT=RT[uT]RT=-846292-(-846323)uT=z[l[2807093805%12366052]]aT=z[l[95551+-95549]]vT=aT(NT,ST)bT=uT[vT]uT=594595936%7432449 vT=z[l[36394851%3639485]]G6[1014225-1014175]=26802673867305-26985 NT=z[l[591469076%2474766]]ST=NT(yT,PT)aT=vT[ST]ST=z[l[1498132977%9856138]]yT=z[l[469655+-469653]]vT=696858+-696814 PT=yT(MT,wT)NT=ST[PT]PT=z[l[212404161%2655052]]ST=1857408490%8006071 MT=z[l[189304-189302]]AT=Q(841256-879078)wT=MT(YT,TT)yT=PT[wT]PT=-25450-(-25455)wT=z[l[698138-698137]]YT=z[l[-91454-(-91456)]]TT=YT(nT,xT)MT=wT[TT]TT=z[l[-16100-(-16101)]]nT=z[l[3694806%923701]]xT=nT(AT,JT)wT=-449826+449868 YT=TT[xT]xT=z[l[1634624512%7396491]]U6=Q(981600-1019265)AT=z[l[329789-329787]]JT=AT(KT,rT)G6[410646+-410605]=Q(1022706+-1060404)nT=xT[JT]TT=2251067678%15741732 JT=z[l[715348481%4706240]]KT=z[l[-967947-(-967949)]]xT,G6[-974843-(-974867)]=-855712+855757,Q(-1048017-(-1010230))rT=KT(dT,pT)G6[201291649%2368137]=Q(304925-342781)AT=JT[rT]G6[493997-493923],JT,G6[-97668-(-97680)]=11470578276688-(-719757),72007-71969,Q(-283330-(-245514))rT=z[l[-200492+200493]]dT=z[l[383504195%14203859]]pT=dT(oT,tT)KT=rT[pT]s6=697107+32401792702429 pT=z[l[2731972865%10671769]]rT,G6[2808229782%16616744]=-116787-(-116797),9340089168641-(-794108)oT=z[l[116878944%2486786]]tT=oT(ET,LT)G6[152910-152891]=-909004+20871773471939 dT=pT[tT]tT=z[l[1826208847%9223277]]pT=225936884%4707018 ET=z[l[345765+-345763]]LT=ET(m6,Q6)oT=tT[LT]tT=862806005%6586305 LT=z[l[-431174+431175]]m6=z[l[1079051514%14013656]]Q6=m6(I6,C6)ET=LT[Q6]Q6=z[l[2164816397%16525316]]LT,G6[-737022-(-737032)]=-52582+52609,Q(498813-536628)I6=z[l[584913316%3701983]]C6=I6(i6,l6)m6=Q6[C6]Q6=-307280+307303 C6=z[l[-963190-(-963191)]]i6=z[l[70193+-70191]]l6=i6(e6,c6)I6=C6[l6]l6=z[l[-865676+865677]]e6=z[l[-159185-(-159187)]]C6=752069+-752007 c6=e6(W6,z6)i6=l6[c6]c6=z[l[33210-33209]]g6,l6=-361441+9051724813400,74066-74055 W6=z[l[78773973%4633763]]z6=W6(X6,s6)e6=c6[z6]z6=z[l[822801313%5713898]]c6,G6[987750969%4572921]=-929390+929429,-819451+34634202021882 X6=z[l[81585713%1007231]]s6=X6(j6,O6)W6=z6[s6]G6[-169862+169928],z6=-920208+14995558344150,-703676-(-703719)s6=z[l[323448503%12440327]]j6=z[l[-1030488-(-1030490)]]O6=j6(F6,V6)X6=s6[O6]s6=1496806387%15273534 O6=z[l[-112179+112180]]F6=z[l[601124-601122]]V6=F6(U6,g6)G6[556985717%4760561]=34651140073981-256758 j6=O6[V6]O6=563549-563486 V6=z[l[138001+-138000]]U6=z[l[347133250%10847914]]g6=U6(q6,G6[16473121%411828])G6[100434124%1210049]=Q(-94816+57114)F6=V6[g6]g6=z[l[-780155-(-780156)]]q6=z[l[889746-889744]]G6[1214034669%5100986]=q6(G6[-795948+795950],G6[248084961%7517726])U6=g6[G6[1026705-1026704]]G6[350935-350914],V6,g6=23452375932117-815661,800692015%12131697,-679799-(-679814)G6[-357567-(-357568)]=z[l[95338241%2979320]]G6[1972532447%9348495]=z[l[-233258+233260]]G6[104719-104716]=G6[789607-789605](G6[806090674%4265030],G6[-569685+569690])q6=G6[214791+-214790][G6[830912603%3391480]]G6[975652+-975651]=-51710+51766 G6[-274008+274011]=z[l[3322824001%13291296]]G6[-443678-(-443730)]=902988+17149807286246 G6[-639628+639632]=z[l[435922+-435920]]G6[808071662%12060771]=G6[475995244%2266644](G6[367368-367362],G6[767465797%3935722])G6[1037296-1037294]=G6[-363051-(-363054)][G6[309929+-309924]]G6[1275117100%6281365]=z[l[412103+-412102]]G6[657196+-657193]=991065842%8328284 G6[-338739-(-338745)]=z[l[-595849-(-595851)]]G6[157074-157067]=G6[3125306131%13647625](G6[712094-712086],G6[2946410649%15926544])G6[-478737+478741]=G6[-868455+868460][G6[709107280%14471577]]G6[-124443-(-124524)]=Q(918596-956376)G6[192045013%1185463]=z[l[-972605-(-972606)]]G6[-375868-(-375876)]=z[l[-398694-(-398696)]]G6[2589100111%11306114]=-124130-(-124162)G6[-533945-(-533954)]=G6[-1040694+1040702](G6[836928-836918],G6[125994+-125983])G6[-954531-(-954537)]=G6[-439681+439688][G6[956913945%5437011]]G6[-375309+375318]=z[l[833220-833219]]G6[160272-160265]=3187129974%16344256 G6[395282-395272]=z[l[750838662%3412903]]G6[953073+-953062]=G6[561219+-561209](G6[111409+-111397],G6[-495879-(-495892)])G6[985347656%7946352]=G6[1185475714%13946773][G6[15007-14996]]G6[632073192%3113661]=214422-214370 G6[-821179-(-821190)]=z[l[-222933-(-222934)]]G6[-741010-(-741022)]=z[l[1001483+-1001481]]G6[1035130-1035117]=G6[350145-350133](G6[1179708830%8937188],G6[-45966+45981])G6[-194396-(-194406)]=G6[356073+-356062][G6[566929+-566916]]G6[1742724141%9790585]=75460+-75402 G6[648132+-648119]=z[l[689555-689554]]G6[541845689%3061275]=z[l[772149+-772147]]G6[1470988464%15164829]=Q(-992109-(-954536))G6[1449240756%12386673]=G6[753343+-753329](G6[105549-105533],G6[951325+-951308])G6[663220-663208]=G6[-335922-(-335935)][G6[-554269+554284]]G6[897001-896988]=325112+-325061 G6[272667+-272652]=z[l[-65900-(-65901)]]G6[-825165+825181]=z[l[908355+-908353]]G6[778638537%14157064]=G6[1256581078%12692738](G6[-668011+668029],G6[-833863-(-833882)])G6[11798+-11784]=G6[426573+-426558][G6[-340586+340603]]G6[-1026702+1026717]=1927272543%12934715 G6[1628667422%12064203]=z[l[1244813761%6915632]]G6[1005714-1005696]=z[l[-242468+242470]]G6[1515134584%11223219]=G6[1252594273%6698365](G6[3538055270%14152221],G6[222909+-222888])G6[746909704%8891782]=G6[-996617-(-996634)][G6[3006836215%13856388]]G6[22075097%11037540],G6[-944980+945057]=625672+-625668,Q(-1009750-(-972151))G6[496780+-496761]=z[l[678660+-678659]]G6[912159-912139]=z[l[567350491%12071287]]G6[509395260%2149347]=G6[604404+-604384](G6[153315340%3739398],G6[-304464-(-304487)])G6[3407894034%13312086]=G6[341013+-340994][G6[-925512+925533]]G6[738802+-738783]=881888-881862 G6[-264761+264782]=z[l[-509835+509836]]G6[563684696%4736846]=z[l[425114+-425112]]G6[-400821+400844]=G6[-241632+241654](G6[-1016759-(-1016783)],G6[2315254696%9527797])G6[1046421600%5507482]=G6[818229+-818208][G6[538128+-538105]]G6[451373599%14560438]=2077690152%13669014 G6[561133-561110]=z[l[206205327%2610194]]G6[69046794%13809354]=z[l[1436184427%14806025]]G6[966915+-966890]=G6[-515441-(-515465)](G6[710890425%7328767],G6[77995-77968])G6[492405520%6312891]=G6[1413898407%7288136][G6[3875134288%16775473]]G6[19480033%177091]=1438767805%14987164 G6[-509895-(-509920)]=z[l[482855-482854]]G6[88675046%351885]=z[l[-436725+436727]]G6[-787463+787490]=G6[109855244%9986838](G6[2441889225%14622091],G6[-642320-(-642349)])G6[941109576%8878392]=G6[-892447-(-892472)][G6[-1036902-(-1036929)]]G6[282379+-282354]=-500388-(-500422)G6[737158+-737131]=z[l[1280173986%8259187]]G6[64216649%393967]=z[l[-203672+203674]]G6[17590679%114225]=G6[-883283-(-883311)](G6[869516-869486],G6[762458+-762427])G6[-196011-(-196037)]=G6[428851-428824][G6[-246757+246786]]G6[628205+-628176]=z[l[-276965+276966]]G6[636316+-636289]=-504959+505006 G6[-404803+404833]=z[l[885586-885584]]G6[-92638-(-92669)]=G6[1514022036%6154561](G6[157559-157527],G6[14762723%14762690])G6[-793980+794008]=G6[699051-699022][G6[639131-639100]]G6[84633+-84602]=z[l[150807091%655683]]G6[968296+-968264]=z[l[1022068742%6194356]]G6[760708429%5719612]=G6[-219513+219545](G6[220178+-220144],G6[-544185+544220])G6[606148-606119]=88897698%368870 G6[2167139576%15154822]=G6[-702150+702181][G6[-450217-(-450250)]]G6[-822707-(-822738)]=-88943-(-88992)G6[929735241%12912989]=z[l[1989781228%10527943]]G6[144279-144245]=z[l[-549753+549755]]G6[204133-204098]=G6[426710-426676](G6[1538562987%10055967],G6[-692143-(-692180)])G6[889277+-889245]=G6[-897045+897078][G6[-203880-(-203915)]]G6[13481-13448]=677997-677944 I={[b]=u,[a]=v;[N]=S;[y]=P;[M]=n,[w]=T;[Y]=x,[A]=J;[d]=r,[K]=p,[t]=o;[E]=L,[mT]=QT;[IT]=zT;[iT]=CT,[lT]=WT,[eT]=cT,[XT]=sT;[jT]=OT,[FT]=VT;[UT]=gT;[qT]=GT;[HT]=kT,[fT]=hT,[ZT]=DT;[BT]=RT;[bT]=uT;[aT]=vT;[NT]=ST,[yT]=PT,[MT]=wT;[YT]=TT;[nT]=xT;[AT]=JT,[KT]=rT;[dT]=pT;[oT]=tT,[ET]=LT,[m6]=Q6;[I6]=C6;[i6]=l6,[e6]=c6,[W6]=z6;[X6]=s6,[j6]=O6,[F6]=V6;[U6]=g6,[q6]=G6[206457782%10866199],[G6[710645-710643]]=G6[-6498+6501],[G6[1831426069%7182063]]=G6[68986+-68981];[G6[378486+-378480]]=G6[820069+-820062];[G6[-84083+84091]]=G6[424495-424486],[G6[303558-303548]]=G6[1295500386%10364003],[G6[582216+-582204]]=G6[220603-220590],[G6[75221-75207]]=G6[-298880-(-298895)],[G6[-1030681+1030697]]=G6[-399587+399604],[G6[-231731-(-231749)]]=G6[864201+-864182],[G6[744510+-744490]]=G6[-191560+191581];[G6[-200937-(-200959)]]=G6[275374+-275351],[G6[-763353-(-763377)]]=G6[699084+-699059];[G6[-507981+508007]]=G6[494915-494888],[G6[120446+-120418]]=G6[85597+-85568];[G6[147901963%979483]]=G6[537719-537688],[G6[-321733+321765]]=G6[1098594259%5520574]}b,N,w,u=I,Q(-352714+315058),6621735763244-274721,Q(404460-441992)I=m[u]lT,n,u=30326011715734-(-1037971),11662883766192-633466,I I=z[j]a=I v=m[N]S=z[l[152627602%4923471]]M,K=Q(184311+-221825),-522049+4262346604289 y=z[l[-376836-(-376838)]]QT,x,mT,FT=Q(925597-963071),Q(640227-678029),137624+27242326595573,-15456+10459907542886 P=y(M,n)N=S[P]n,S,WT=Q(705740-743232),Q(872590-910393),Q(173899-211546)I=v[N]G6[-925257+925280],E,G6[2022895708%14874233],LT,r,v=Q(-286491-(-248799)),951553+13504884822927,21423160282278-(-809553),Q(-229217-(-191590)),Q(917814+-955493),I N=m[S]e6,G6[1737548269%8687741],ST=699587+6270118633124,Q(1007255+-1044801),Q(189784+-227493)y=z[l[63016161%3150808]]dT=25598400737145-852201 P=z[l[-1044929-(-1044931)]]AT=6348007511221-(-472791)M=P(n,w)S=y[M]G6[782123313%10291096],T,y=Q(521248+-559028),15357871980555-(-777188),Q(993966+-1031546)I=N[S]S=m[y]P=z[l[191635+-191634]]w,G6[581322+-581300],Y,t,RT,N,d=Q(1016109+-1053603),9109449406913-158000,-389700+33729039953822,24128942296631-(-171436),Q(351813-389615),I,1016049+24596528081868 M=z[l[210493-210491]]G6[848269-848267],O6,o=858665+32788149903739,Q(858778+-896445),Q(727974+-765673)n=M(w,T)IT,uT=33180666509476-(-426934),Q(226676-264368)y=P[n]I=S[y]G6[-305691+305775],A,T,S,UT,P,jT=365376+31580094015025,-366315+26911521540062,Q(-167986+130361),I,-177534+31839480967016,Q(315055-352858),922063+19282514481476 y=m[P]cT=Q(-20702+-16811)M=z[l[2536076225%14409524]]iT=32238486082963-(-992529)n=z[l[913694-913692]]w=n(T,Y)l6=Q(-932313+894453)P=M[w]I=y[P]y,G6[116521-116448],Y,G6[797011-797004],qT,p,T=I,Q(-502975+465144),32331988174633-(-521126),Q(461879+-499737),769653+32005215517634,Q(587923+-625525),Q(881043-918888)M=z[l[610457761%5087148]]n=z[l[-677771-(-677773)]]J,nT,VT,eT,G6[899926-899863]=Q(845532+-883158),7.1683771921661e+14%10240539016026,Q(-406967+369361),7161716558206-375928,Q(-83744-(-45919))w=n(T,Y)P=M[w]M,G6[-278135-(-278196)],s6=-657466+657531,Q(-218343+180564),Q(-367065+329475)w=z[l[902996543%14803222]]T=z[l[745344-745342]]g6=Q(-702348+664531)Y=T(x,A)n=w[Y]w,BT=-982084-(-982152),5726493465470-(-356076)Y=z[l[854500369%6891132]]ZT=20273219964309-665781 x=z[l[155949+-155947]]A=x(J,d)T=Y[A]G6[886099+-886084],zT,Y,YT,G6[-893264+893273],HT,TT=Q(75016+-112715),Q(-747708-(-709875)),300722017%1348529,-812546+17450654074304,Q(-858048+820378),87367+30750401127080,Q(-279247-(-241727))A=z[l[713189041%4122480]]J=z[l[-395265+395267]]ET,yT,G6[576280+-576210]=283050+21220005074159,-351387+16313661995591,-876772+13876308277793 d=J(r,K)G6[484230344%4525517]=Q(-828624+790915)x=A[d]q6=11428129710176-(-636009)d=z[l[-793404+793405]]A,G6[2417813086%11624101],fT,G6[598968087%2825321]=1885389153%7452131,-897568+22470646029055,17526881286042-22457,Q(-759709+721913)r=z[l[354262250%13120824]]K=r(p,t)J=d[K]G6[17821688%247523]=-890166+12792978648187 K=z[l[1001858+-1001857]]C6,d=Q(688456+-726046),852562777%6875506 p=z[l[707748-707746]]gT,G6[2403646081%16463329],G6[-666826+666870]=Q(196538+-234143),Q(-256928-(-219374)),20532555255406-747797 t=p(o,E)G6[-892665-(-892698)],G6[405978961%2218464],W6=Q(-960010+922253),Q(-632865-(-595157)),7809717675229-(-551255)r=K[t]CT=Q(812201-849679)t=z[l[617006-617005]]L,G6[-938366+938420],V6,JT=Q(891631+-929233),5533520155690-(-521702),Q(-215856+178303),Q(190443-228089)o=z[l[-663196+663198]]xT,oT,G6[-873003-(-873009)],K=Q(-927769+890295),4892676433717-990799,21888037130143-(-743473),-542037-(-542044)E=o(L,mT)p=t[E]t=-726499+726558 E=z[l[-407482+407483]]L=z[l[2530098612%11448410]]mT=L(QT,IT)o=E[mT]mT=z[l[-709531+709532]]G6[1349628421%7625019],G6[739497747%4963072]=22013642381089-978711,Q(699744-737380)QT=z[l[-94660-(-94662)]]IT=QT(zT,iT)GT=Q(-400986+363350)L=mT[IT]G6[893486886%4234535],E,G6[292472586%2104119]=Q(-1015426-(-977922)),936535+-936459,Q(-767464+729838)IT=z[l[617327-617326]]mT,OT=701624625%6436923,Q(-344091-(-306383))zT=z[l[758150-758148]]iT=zT(CT,lT)QT=IT[iT]XT=384788+27924317164471 iT=z[l[-398984-(-398985)]]IT,DT=840650240%5494446,Q(903778+-941570)CT=z[l[51977638%12994409]]lT=CT(WT,eT)G6[720135325%10911140]=Q(-1076982-(-1039182))zT=iT[lT]lT=z[l[-127553-(-127554)]]iT,aT=-628757+628813,80539+30419667762362 WT=z[l[-250650-(-250652)]]eT=WT(cT,XT)CT=lT[eT]G6[600964635%13975920],MT,kT,G6[153874867%7693742]=Q(-207016+169442),107866+29869496832251,Q(-25679+-11787),Q(350247-387925)eT=z[l[-390599-(-390600)]]lT,G6[-801691-(-801756)],sT,bT=137913233%4597105,Q(468985+-506532),Q(-908656-(-870849)),-398336+9637392885127 cT=z[l[642159548%3868431]]XT=cT(sT,jT)WT=eT[XT]G6[693631261%16515029],eT,G6[1050500954%13297480]=Q(-779872-(-742018)),599985+-599966,291827+10142581776000 XT=z[l[453288-453287]]sT=z[l[-882422+882424]]jT=sT(OT,FT)cT=XT[jT]jT=z[l[3740174484%16052251]]XT,hT=283237-283162,Q(-275028-(-237219))OT=z[l[-969875+969877]]pT,G6[331654+-331578],KT=Q(250524+-288251),25662076004216-(-18229),950257+24072387816408 FT=OT(VT,UT)PT=Q(-424972+387431)sT=jT[FT]FT=z[l[1973276031%7799510]]jT=-921911-(-921958)VT=z[l[-394662+394664]]UT=VT(gT,qT)z6,wT=Q(829760-867398),Q(-87667+50081)OT=FT[UT]UT=z[l[846363+-846362]]FT=-691102-(-691125)gT=z[l[36922+-36920]]qT=gT(GT,HT)NT=138847+17324743229732 VT=UT[qT]qT=z[l[-439028+439029]]GT=z[l[2785387458%12163264]]UT=652851+-652785 HT=GT(kT,fT)gT=qT[HT]HT=z[l[463753+-463752]]G6[481556+-481553],G6[-923310-(-923396)]=Q(-780439+742924),-593264+4787700373029 kT=z[l[1011378881%16053633]]fT=kT(hT,ZT)GT=HT[fT]fT=z[l[877607+-877606]]hT=z[l[153452+-153450]]qT,HT,X6=297657+-297651,-1045172+1045208,28942+17540306038489 ZT=hT(DT,BT)I6=29489205169785-628950 kT=fT[ZT]G6[444408+-444372],fT,m6=-114954+11659602122303,60229815%406958,17325549356758-403283 ZT=z[l[1549909649%8423422]]DT=z[l[157728828%886117]]BT=DT(RT,bT)G6[1211795752%8474096]=5320932374981-307224 hT=ZT[BT]ZT,rT=6016649%25280,Q(-513491-(-475817))BT=z[l[326559+-326558]]RT=z[l[154637-154635]]vT=Q(716332+-754038)bT=RT(uT,aT)G6[311403-311324]=Q(998624+-1036473)DT=BT[bT]BT=1018892+-1018837 bT=z[l[1280611515%14072654]]uT=z[l[429629+-429627]]aT=uT(vT,NT)RT=bT[aT]aT=z[l[1015283+-1015282]]j6,U6=4266413580478-(-583428),12681946031779-(-684142)vT=z[l[710880-710878]]NT=vT(ST,yT)G6[673292+-673282],bT,G6[30433-30403]=28785306746795-445263,96179814%5062094,22771585837538-491639 uT=aT[NT]G6[463990-463953]=Q(732800+-770575)NT=z[l[-750123+750124]]G6[-531641+531654]=Q(-860236+822397)ST=z[l[-636450-(-636452)]]Q6,G6[7481-7476],aT,G6[1207625491%6492610]=Q(-839277+801699),Q(-1068837-(-1031276)),646729999%11758726,Q(665396+-702882)yT=ST(PT,MT)vT=NT[yT]NT=718142-718116 yT=z[l[863197-863196]]PT=z[l[1353995552%9026637]]MT=PT(wT,YT)ST=yT[MT]yT=638132+-638098 MT=z[l[-469241-(-469242)]]G6[1056686509%11872882]=Q(-990386-(-952707))wT=z[l[-583877+583879]]YT=wT(TT,nT)PT=MT[YT]MT=72230884%6566443 YT=z[l[475896-475895]]F6=4863832706583-(-490177)TT=z[l[730616-730614]]nT=TT(xT,AT)wT=YT[nT]YT=-37859+37933 nT=z[l[-752330-(-752331)]]xT=z[l[-80390+80392]]AT=xT(JT,KT)TT=nT[AT]AT=z[l[489105756%3155521]]JT=z[l[451377+-451375]]KT=JT(rT,dT)nT,tT=640228-640207,Q(-445347-(-407882))xT=AT[KT]AT=1821147640%16555887 KT=z[l[106603-106602]]rT=z[l[2561046964%13201273]]dT=rT(pT,oT)JT=KT[dT]KT=62567+-62528 dT=z[l[-290410+290411]]pT=z[l[-602816+602818]]oT=pT(tT,ET)rT=dT[oT]oT=z[l[78158287%1371198]]tT=z[l[980686+-980684]]dT=-957827-(-957904)ET=tT(LT,m6)pT=oT[ET]ET=z[l[282131-282130]]G6[262886-262872],i6,oT=11785768743536-138496,25482352244411-804961,329765-329762 LT=z[l[170024+-170022]]m6=LT(Q6,I6)tT=ET[m6]m6=z[l[-1043591+1043592]]Q6=z[l[-101667+101669]]ET=-899734+899813 I6=Q6(C6,i6)LT=m6[I6]m6=264575+-264523 I6=z[l[433254844%8495193]]G6[1162350006%5588221]=3207004722715-(-815034)C6=z[l[-830373-(-830375)]]i6=C6(l6,e6)Q6=I6[i6]i6=z[l[608867-608866]]c6,I6,G6[464901+-464880]=Q(714346+-752137),733633-733608,Q(-756897-(-719269))l6=z[l[513040+-513038]]e6=l6(c6,W6)C6=i6[e6]e6=z[l[714018609%4353772]]i6=-427329-(-427377)c6=z[l[-498851-(-498853)]]W6=c6(z6,X6)l6=e6[W6]G6[59901128%9983510],G6[371266-371254],G6[950186717%10001965],e6=650248+29200883468565,407012+17454066575835,32879606694588-(-669970),26727+-26719 W6=z[l[-448111-(-448112)]]z6=z[l[486724674%15210146]]X6=z6(s6,j6)c6=W6[X6]X6=z[l[1832025923%12901591]]W6=-635828+635855 s6=z[l[2776586747%15008577]]j6=s6(O6,F6)z6=X6[j6]j6=z[l[-98531+98532]]X6=-925142-(-925205)O6=z[l[418553-418551]]F6=O6(V6,U6)s6=j6[F6]j6,G6[677219-677203]=2138970621%15962467,633370+13874152877858 F6=z[l[690640-690639]]V6=z[l[-847533-(-847535)]]G6[2919003872%12316472],G6[143177-143159]=29443258796662-(-650008),-851904+23180561656298 U6=V6(g6,q6)O6=F6[U6]F6=-584495-(-584568)U6=z[l[-200641-(-200642)]]g6=z[l[717677-717675]]q6=g6(G6[-560291-(-560292)],G6[-556509+556511])V6=U6[q6]U6=-485456+485473 q6=z[l[154770+-154769]]G6[-981877-(-981881)]=31964461736709-(-382751)G6[597215+-597214]=z[l[920910+-920908]]G6[9357546%668396]=G6[266137361%16633585](G6[2033601523%9592460],G6[2924622760%12085218])g6=q6[G6[182529-182527]]q6=-422820-(-422904)G6[-253522+253524]=z[l[165027295%2037374]]G6[358368+-358365]=z[l[-430630-(-430632)]]G6[304331+-304327]=G6[238998131%14937383](G6[30653-30648],G6[567289-567283])G6[-255718+255719]=G6[-590728-(-590730)][G6[-624001+624005]]G6[462552-462550]=-557184-(-557264)G6[-907568+907572]=z[l[2464850075%15699682]]G6[78865441%838994]=z[l[-607036-(-607038)]]G6[-333172+333178]=G6[876822707%3684129](G6[539079+-539072],G6[-951128+951136])G6[2574607973%16610374]=G6[14417180%497144][G6[565546785%8976933]]G6[-184873+184879]=z[l[-804298-(-804299)]]G6[140293-140286]=z[l[114660590%1170006]]G6[22884+-22880]=1425271383%7021041 G6[788985+-788977]=G6[2566362858%15185579](G6[-965069-(-965078)],G6[-212051+212061])G6[-247531+247536]=G6[-349018+349024][G6[167125-167117]]G6[3047251358%16038165]=z[l[33410-33409]]G6[825865095%7440226]=z[l[206384982%5033780]]G6[-693343-(-693349)]=151003643%626571 G6[1069735105%7480665]=G6[-373747+373756](G6[1900208153%9406971],G6[30550522%3055051])G6[810863+-810856]=G6[-331767-(-331775)][G6[949932-949922]]G6[738474-738466]=-695893-(-695942)G6[733616+-733606]=z[l[-837278-(-837279)]]G6[676523817%5685074]=z[l[508376-508374]]G6[1611124057%6855847]=G6[-620517+620528](G6[72448-72435],G6[-622984-(-622998)])G6[-902667+902676]=G6[-16191+16201][G6[2612168444%11982424]]G6[77229-77219]=-670328+670372 G6[354335+-354323]=z[l[-1016811+1016812]]G6[-443928+443941]=z[l[-969137+969139]]G6[920843-920829]=G6[1577213586%7136713](G6[344877-344862],G6[859703+-859687])G6[-919887-(-919898)]=G6[-187530-(-187542)][G6[-869502+869516]]G6[2010214572%8375894]=-430116+430194 G6[223168-223154]=z[l[3295228236%14910535]]G6[-851176-(-851191)]=z[l[-842910+842912]]G6[109486246%2606815]=G6[1210377246%7517871](G6[563424+-563407],G6[1969687122%8526784])G6[-878965-(-878978)]=G6[-628367-(-628381)][G6[1985495584%9638328]]G6[2450472017%11838029]=646256+-646194 G6[-602167+602183]=z[l[2991495101%13597705]]G6[-860437-(-860454)]=z[l[108574837%2934455]]G6[172324-172306]=G6[10411761%743696](G6[72769694%6615425],G6[459557-459537])G6[522285+-522270]=G6[165953+-165937][G6[696299-696281]]G6[904906-904888]=z[l[587641159%2379114]]G6[3313029509%16320342]=Q(-414269-(-376450))G6[209776-209757]=z[l[-29689+29691]]G6[1078706348%6420871]=G6[-984054+984073](G6[564596+-564575],G6[980823-980801])G6[-327108-(-327125)]=G6[-295648+295666][G6[631621+-631601]]G6[226067+-226051],G6[-82560-(-82627)],G6[85435411%2441011]=1883247154%14159753,Q(-575215+537389),-721912+2552451369116 G6[458271+-458251]=z[l[-604762-(-604763)]]G6[805930+-805912]=371011601%2108020 G6[-945971-(-945992)]=z[l[814322+-814320]]G6[-383550-(-383572)]=G6[787315+-787294](G6[-18322-(-18345)],G6[83693-83669])G6[986974-986955]=G6[-771136+771156][G6[105423-105401]]G6[679694+-679672]=z[l[1040606426%10102975]]G6[656595960%2984527]=1306131697%10449053 G6[-218119-(-218142)]=z[l[200430-200428]]G6[973117+-973093]=G6[-143427-(-143450)](G6[866209+-866184],G6[2286964232%9649638])G6[-308026+308047]=G6[533577110%4409728][G6[218431-218407]]G6[604003982%4253549]=z[l[-811816-(-811817)]]G6[979817-979789],G6[-141071+141093]=3794574108393-24579,757672+-757621 G6[621697112%9279061]=z[l[-945749-(-945751)]]G6[4488197%31831]=G6[-353307-(-353332)](G6[699223+-699196],G6[288867+-288839])G6[-376505-(-376534)]=Q(-133962-(-96194))G6[893237143%13956830]=G6[1860874884%14314422][G6[-142972-(-142998)]]G6[-205993+206019]=z[l[361676617%6458511]]G6[822702282%4352922]=761867965%14651307 G6[571005+-570978]=z[l[720420+-720418]]G6[805428-805400]=G6[1310021033%9849782](G6[-23849+23878],G6[933426-933396])G6[671343+-671318]=G6[-110836+110862][G6[52579137%4779919]]G6[478358-478332]=432532+-432519 G6[-285264+285292]=z[l[-777443-(-777444)]]G6[1002464+-1002435]=z[l[893859-893857]]G6[-593827-(-593857)]=G6[406614+-406585](G6[-705368-(-705399)],G6[777882+-777850])G6[463616089%5094682]=G6[865832-865804][G6[148309+-148279]]G6[726797+-726767]=z[l[258583465%4536552]]G6[-688418-(-688446)]=2441192714%13195636 G6[952928031%5955800]=z[l[823710+-823708]]G6[788321111%4171011]=G6[88381742%4651669](G6[2065277321%8327731],G6[288882+-288848])G6[1416-1387]=G6[-999324-(-999354)][G6[501747032%4181225]]G6[185093-185061]=z[l[2179724289%8514548]]G6[625109964%3360806],G6[598838+-598808]=23177587592552-893760,-452593+452630 G6[2551115733%11338292]=z[l[-986386+986388]]G6[123969+-123935]=G6[-439078+439111](G6[-187749-(-187784)],G6[514225+-514189])G6[766484-766453]=G6[338630+-338598][G6[506580-506546]]G6[1550962388%12022964]=640888-640853 G6[599265-599231]=z[l[596264+-596263]]G6[240813393%5235073]=z[l[-245682-(-245684)]]G6[-965052-(-965088)]=G6[682094035%13641880](G6[80210-80173],G6[2251729688%15529170])G6[1098307161%4410872]=G6[1087820053%9297607][G6[687246-687210]]G6[537570-537536]=-957502-(-957524)G6[712151+-712115]=z[l[101146189%8428849]]G6[3550760833%15994418]=z[l[-471565+471567]]G6[534607+-534569]=G6[-470440-(-470477)](G6[-347405-(-347444)],G6[-952074-(-952114)])G6[-229791-(-229826)]=G6[897325-897289][G6[-45694-(-45732)]]G6[451893484%7288604]=-142332+142390 G6[538782+-538744]=z[l[452795213%2727682]]G6[537324429%2336193]=z[l[186546+-186544]]G6[579907-579825],G6[369614+-369542]=11900864503599-(-505462),705032+8596490915227 G6[1971743902%7793454]=G6[1911023131%16474337](G6[169755-169714],G6[806028-805986])G6[362427-362390]=G6[-270225+270263][G6[-778360+778400]]G6[-940832-(-940872)]=z[l[-154087-(-154088)]]G6[996686+-996645]=z[l[-151920+151922]]G6[-413379+413421]=G6[2598509997%12614126](G6[246590-246547],G6[973185803%5149131])G6[556065+-556027]=2318990659%12812103 G6[1021861-1021822]=G6[-600385+600425][G6[-435611+435653]]G6[1410243752%15328736]=-1045758+1045782 G6[-258992+259034]=z[l[13440565%6720282]]G6[1035654663%5785780]=z[l[1914428564%11002463]]G6[314840576%4312884]=G6[308732-308689](G6[-247254-(-247299)],G6[1196446366%6646924])G6[2993492783%14819271]=G6[1438390714%10576402][G6[3365856200%13626948]]G6[443123284%7912915]=z[l[-381347-(-381348)]]G6[2497455418%12006997]=-920357+920386 G6[737124+-737079]=z[l[805541-805539]]G6[138432126%1730401]=G6[-731462-(-731507)](G6[378648785%14563413],G6[-945554-(-945602)])G6[231340+-231297]=G6[627770-627726][G6[704478-704432]]G6[1071432952%12038572]=1128570045%4460751 G6[1049251372%9203959]=z[l[706845-706844]]G6[-94001-(-94048)]=z[l[106752+-106750]]G6[200160683%11774155]=G6[377424367%2358902](G6[-804522+804571],G6[-595166+595216])G6[390612+-390567]=G6[1015663+-1015617][G6[486901+-486853]]G6[292677-292629]=z[l[-510871-(-510872)]]G6[-990255+990301]=1731369708%16031201 G6[2235685277%13632227]=z[l[2422515587%11061715]]G6[922899+-922849]=G6[350092+-350043](G6[740590431%12343173],G6[-430283-(-430335)])G6[973072+-973025]=G6[282088268%1819924][G6[1852123778%9596496]]G6[1167599936%5613461]=91033+-90980 G6[-684511+684561]=z[l[1047486+-1047485]]G6[492848055%2036562]=z[l[1076819178%16071928]]G6[443396-443344]=G6[1063067595%12655566](G6[1035104266%7238491],G6[2044162494%11748060])G6[178937329%2982288]=G6[-347942+347992][G6[-724581+724633]]G6[745416536%14064462]=-530822+530842 G6[-653216+653268]=z[l[-962208-(-962209)]]G6[2981399003%13429725]=z[l[49089-49087]]G6[89395+-89341]=G6[832549-832496](G6[255906-255851],G6[-587689+587745])G6[2569151361%11625119]=375161+7312845870036 G6[1171395458%12872477]=G6[1002388-1002336][G6[1667623410%8870337]]G6[-143598-(-143650)]=-735111+735151 G6[-422463-(-422517)]=z[l[449461+-449460]]G6[-736593-(-736648)]=z[l[-641915+641917]]G6[-205435-(-205491)]=G6[969903-969848](G6[938593-938536],G6[592592-592534])G6[176700+-176647]=G6[-960494+960548][G6[-379243+379299]]G6[1444696623%7981749]=-999012+999094 G6[1115584163%5337723]=z[l[901947+-901946]]G6[629933-629876]=z[l[616790-616788]]G6[-64046-(-64104)]=G6[456030+-455973](G6[461637-461578],G6[-796803+796863])G6[910575705%3908050]=G6[282294+-282238][G6[951205+-951147]]G6[-609692+609750]=z[l[-217683-(-217684)]]G6[772607-772551]=740278+-740274 G6[195112-195053]=z[l[-826069+826071]]G6[319108-319048]=G6[31319-31260](G6[1021348-1021287],G6[2339375870%10443642])G6[-886743+886800]=G6[-977425+977483][G6[-820755+820815]]G6[114366-114306]=z[l[115984441%1288716]]G6[178076473%5396255]=-706109+706166 G6[1748979943%7474273]=z[l[533306839%10883813]]G6[9119912%364794]=G6[136107-136046](G6[688299-688236],G6[-781642-(-781706)])G6[-949496+949555]=G6[1314246474%7776606][G6[-515705+515767]]G6[112322-112260]=z[l[-790016+790017]]G6[707089425%2874347]=z[l[38546-38544]]G6[199697054%8682478]=966542+-966475 G6[-294423-(-294487)]=G6[100887685%2967283](G6[-172068-(-172133)],G6[862776+-862710])G6[-935590+935651]=G6[3284451122%12982020][G6[-483897+483961]]G6[117854+-117792]=-285763+285775 G6[741437-741373]=z[l[-34190-(-34191)]]G6[2821073276%11150487]=z[l[607623-607621]]G6[-437424-(-437490)]=G6[-560499-(-560564)](G6[251345+-251278],G6[124022-123954])G6[-171299+171362]=G6[476312537%5234203][G6[56262280%1654771]]G6[-77816+77882]=z[l[1030882861%9817932]]G6[-1003452+1003519]=z[l[1912095780%12178954]]G6[109709-109645]=4008407%1336122 G6[553730+-553662]=G6[455915+-455848](G6[3021773373%11943768],G6[1277643533%5090213])G6[2393679465%12212650]=G6[605598+-605532][G6[-602671-(-602739)]]G6[99155034%4507044]=-917891-(-917936)G6[2111650112%9261623]=z[l[-626194-(-626195)]]G6[1008810-1008741]=z[l[-584590+584592]]G6[-365471+365541]=G6[602256+-602187](G6[1024041547%11506084],G6[-508051-(-508123)])G6[-1035073-(-1035140)]=G6[607991-607923][G6[-936068-(-936138)]]G6[1250617376%12260954]=1495983275%14666502 G6[-869755-(-869825)]=z[l[854726017%13355094]]G6[279150+-279079]=z[l[2192441656%13876213]]G6[563375-563303]=G6[2767888551%14121880](G6[1366898768%12540355],G6[-1033384+1033458])G6[903757493%5510716]=G6[814539-814469][G6[1588545268%11186938]]G6[-111305-(-111375)]=149105638%5325200 G6[-324893+324965]=z[l[81370+-81369]]G6[391848853%13061626]=z[l[-7931-(-7933)]]G6[661242-661168]=G6[-341530+341603](G6[4267017%4266942],G6[272078965%2804937])G6[966965925%4694009]=G6[-957452-(-957524)][G6[1054557204%9586883]]G6[-941251-(-941325)]=z[l[1719715021%7852580]]G6[623010827%11980976]=z[l[551694+-551692]]G6[3194949744%15661518]=401229-401165 G6[994312%497118]=G6[475825-475750](G6[34289396%250287],G6[610432-610354])G6[1037254-1037181]=G6[282425+-282351][G6[-262125+262201]]G6[458951-458877]=59900-59885 G6[563037-562961]=z[l[-387403+387404]]G6[-127441-(-127518)]=z[l[69248+-69246]]G6[1072289878%10021400]=G6[411890127%7488910](G6[-150888-(-150967)],G6[1633322328%12188972])G6[-332843+332918]=G6[-1041303-(-1041379)][G6[-827247-(-827325)]]G6[865210989%9944953]=z[l[16768+-16767]]G6[1182436222%4806651]=-763328+763358 G6[2344969659%16172204]=z[l[910774-910772]]G6[587592584%9632664]=G6[437701+-437622](G6[-54340+54421],G6[207625042%2883680])G6[1048192+-1048115]=G6[254962-254884][G6[352382736%2481568]]G6[943859-943781]=430208-430194 G6[-1046790-(-1046870)]=z[l[1010683-1010682]]G6[-11053-(-11134)]=z[l[16103+-16101]]G6[58909260%429994]=G6[-287272-(-287353)](G6[-995218-(-995301)],G6[490468-490384])G6[-442426-(-442505)]=G6[1509694490%10270030][G6[1853327029%9407751]]G6[-57390-(-57472)]=z[l[906326-906325]]G6[1595143022%7488934]=673950+-673904 G6[92922219%1366502]=z[l[-655479-(-655481)]]G6[757818+-757734]=G6[-757960-(-758043)](G6[-559761+559846],G6[-197527-(-197613)])G6[194640073%892844]=G6[543327+-543245][G6[706751416%3661924]]G6[92482-92400]=100868-100807 I={[P]=M,[n]=w,[T]=Y;[x]=A;[J]=d,[r]=K,[p]=t,[o]=E,[L]=mT;[QT]=IT;[zT]=iT,[CT]=lT;[WT]=eT;[cT]=XT,[sT]=jT;[OT]=FT,[VT]=UT,[gT]=qT;[GT]=HT,[kT]=fT;[hT]=ZT;[DT]=BT;[RT]=bT;[uT]=aT,[vT]=NT;[ST]=yT;[PT]=MT;[wT]=YT;[TT]=nT;[xT]=AT,[JT]=KT,[rT]=dT,[pT]=oT,[tT]=ET,[LT]=m6,[Q6]=I6,[C6]=i6,[l6]=e6,[c6]=W6,[z6]=X6,[s6]=j6,[O6]=F6,[V6]=U6;[g6]=q6,[G6[65621809%3645656]]=G6[-736459-(-736461)];[G6[-849405+849408]]=G6[507940+-507936];[G6[767713-767708]]=G6[1327297323%15256291],[G6[-1006845-(-1006852)]]=G6[35753668%3575366],[G6[-7689-(-7698)]]=G6[599337308%2387798];[G6[1199757017%8448993]]=G6[3083293192%14014969];[G6[300934731%1406237]]=G6[-626165-(-626179)];[G6[771562+-771547]]=G6[526559+-526543];[G6[773999-773982]]=G6[-231182+231200],[G6[22082068%223051]]=G6[-104929+104949];[G6[258319+-258298]]=G6[-393362+393384];[G6[2276649779%9646821]]=G6[926333+-926309];[G6[814122-814097]]=G6[654636+-654610];[G6[584490+-584463]]=G6[-794267+794295],[G6[1046686-1046657]]=G6[1282861334%8439877],[G6[-986382+986413]]=G6[-286116-(-286148)],[G6[-290391-(-290424)]]=G6[-97729-(-97763)],[G6[740866+-740831]]=G6[-903356-(-903392)];[G6[998562+-998525]]=G6[1912200755%14377449];[G6[26000811%1857198]]=G6[2285387374%10729518];[G6[-415993+416034]]=G6[985844-985802];[G6[106867+-106824]]=G6[-969380+969424];[G6[-692486+692531]]=G6[2257472126%9815096];[G6[-565632-(-565679)]]=G6[11031426%134529],[G6[-263421-(-263470)]]=G6[877741+-877691],[G6[635951+-635900]]=G6[-1030577+1030629];[G6[1543610453%6431710]]=G6[633702-633648],[G6[1926624811%8095062]]=G6[1009860268%4334164];[G6[317349-317292]]=G6[656666+-656608],[G6[2475878441%15769926]]=G6[406410763%2245363],[G6[10929005%105086]]=G6[415901582%10397538];[G6[434476-434413]]=G6[43546-43482],[G6[-964643+964708]]=G6[-984341-(-984407)],[G6[-919208-(-919275)]]=G6[602485757%16283397],[G6[-208100-(-208169)]]=G6[48643+-48573],[G6[255355055%1182199]]=G6[707058542%9958570];[G6[314276-314203]]=G6[1002450980%16168563];[G6[1296647835%16208097]]=G6[691444-691368],[G6[-511731-(-511808)]]=G6[-487417+487495],[G6[516212-516133]]=G6[667128330%2668513];[G6[265520-265439]]=G6[820759-820677]}n=Q(676431+-714234)M=m[n]x,A,P=Q(-426679+389018),-213163+14453315869429,I w=z[l[-440610+440611]]T=z[l[1415324234%7488488]]Y=T(x,A)n=w[Y]I=M[n]n=-155401-(-155402)w=#a T,M=w,I w=942055417%4131822 Y=w w=759356-759356 x,I=Y<w,139079756%11453678 w=n-Y elseif 1630958425%11964747>I then G6[-152707-(-154310)],G6[502607+-500998]=6999824-(-670227)>=128716262%9586478,284536+-324834 X=G6[294359940%3234707]G6[270871-269267]={X}G6[188344-186738]=z[l[-250738-(-250743)]]G6[-860403-(-862010)]=z[l[155375912%1785930]]G6[915584+-913976]=G6[704087187%16001945](G6[-239189+240798])I=2676332-(-739141)G6[731445+-729840]=G6[2247999694%15292504][G6[-295679+297287]]X,w=G6[3841536405%16006395],G6[962948+-961344]else I=141216+8759973 end else if 3850177234%19930349>I then G6[360741-359629]=z[l[313288-313286]]G6[-480399-(-481513)]=-415757-(-375492)G6[-937640-(-938753)]=G6[-424117+425229](G6[186795529%948195])G6[2649321130%12208848],G6[670249-669127]=FT,-946765-(-946771)G6[278326008%2262804]=z[l[-332235+332240]]IT,G6[-222985+224097],x=G6[-840096+841210],4952296234%20318566,G6[12707072%1815137]X,G6[182257+-181132],G6[-440665-(-441783)]=G6[285039+-283927],851278-851277,-156609+116164 G6[515630801%5055193]=G6[400123601%8165765][x]G6[457424292%2722757]=z[l[216059+-216057]]jT=G6[-267855+268970]G6[437341+-436224]=G6[208815754%6141607](G6[-482383+483501])x=G6[7175875%1195793]G6[-833097+834213]=jT[x]kT=G6[-688949-(-690065)]G6[206099540%2124726]=kT(y,IT)jT,G6[686584-685460]=G6[318760482%4139732],nil G6[254620+-253500]=z[l[36327204%1135225]]G6[-510108+511229]=O[G6[-937807-(-938929)]]G6[362122767%7544201]=G6[469352+-468232][G6[-271494-(-272615)]]kT,I=G6[648996-647877],1104946813%15021341 G6[-403028+404148]=kT()x,G6[165912+-164789]=G6[-54957-(-56077)],-813290+813546 G6[1086364382%15300891]=jT+x sT=G6[746313-745192]G6[625536+-624414]=sT+o mT,sT,jT=G6[246150+-245028],G6[68632-67509],G6[984964-983839]G6[1269820486%7054552]=mT%sT IT,UT=G6[935474624%9354735],G6[488694350%12860348]G6[2351736584%13286641]=UT o=G6[2820940855%15847976]G6[1047071+-1045943]=o+jT kT=G6[357698336%16258964]G6[-1045847-(-1046976)]=L[kT]sT=G6[454757+-453628]G6[491732+-490602]=lT..sT mT=G6[804560895%9465409]G6[36333-35202]=mT lT=G6[262005-260874]elseif 639810+2998802>I then G6[262474-261472],I=nil,8743321-(-627152)FT,G6[245440293%8765689],G6[-200184-(-201184)]=G6[1042139324%7497398],7423119071%29748959,nil X,t=G6[607537+-606536],G6[18995+-17995]elseif I<788768794%8352072 then G6[3741062212%16125261]=-765009+6562169 G6[619341-617682]=X<G6[-149747-(-151407)]I=G6[-767001-(-768660)]and 1007007+13196777 or 4763291303%30829405 else o,I=G6[2467759379%13267521],G6[515840-515366]G6[498144+-497670],G6[-815049+815524]=o,I I=o and 601496-(-134877)or 1912717339%14942262 end end else if I<3570429-(-302367)then if-504634+4336510>I then G6[-873336-(-874543)]=2255526792%19085734 G6[-148609+149815]=X<G6[372156-370949]I=G6[754764+-753558]and 42777+9590930 or 257922+13824047 elseif 4578714-714408>I then I=6282407723%27865430 else I=1004187+13163871 end else if 648805+3256179>I then v=-858303+858304 W=a==v I=W and 16288174-859999 or 2725914684%17741214 elseif 3315594-(-625035)>I then I,G6[508464537%5241887]=G6[58971472%331292],180704-221027 G6[82816571%473229]=z[l[997592-997590]]G6[-455594-(-457098)],G6[587949075%10887918]=632275724%16212198,-754148-(-754149)G6[253307-251810]=G6[1583169803%9712689](G6[-334772+336270])G6[-132082+133587],w=15398003452982-(-585676),G6[202094+-200599]G6[242033-240537],OT,G6[1687858356%9325176],G6[33989-32464],G6[-169326+170845]=w,G6[-172838+174335],276396+-316830,I,-594250+594251 G6[-721153-(-722651)]=z[l[1056750770%7338547]]sT=G6[422605+-421109]G6[225233-223734]=G6[-122924+124422](G6[-976478+977978])G6[651448+-649947]=z[l[-904262-(-904266)]]G6[-837337+838835]=-880362+32786032224909 P,G6[98692077%12336321]=G6[93450217%10383191],40309777%1550376 G6[461108-459606]=O[G6[229700-228197]]G6[-921130+922630]=G6[-176865+178366][G6[-781057+782559]]d,M,G6[625737+-624214]=G6[-53731+55230],G6[315175-313670],I G6[997591-996089]=z[l[-622078-(-622082)]]G6[2757149688%16709989]=O[G6[221467168%1757664]]G6[361343-359829]=-35700+35702 G6[-996320-(-997821)]=G6[-223823-(-225325)][G6[824959563%4660780]]jT,G6[332433124%14453548],x,G6[941613544%15693534]=G6[2616179224%11525012],-591074-(-591076),G6[968296+-966795],nil G6[-166287+167789]=x(d,cT)v,I,G6[285826-284316]=G6[100815+-99313],470239776%17024556,570012-570010 G6[432594+-431091]=jT[v]jT,kT=G6[871065159%15837521],G6[-520856+522359]G6[875836-874329]=z[l[924564-924560]]G6[-835341+836849]=O[G6[-744872+746381]]G6[706688153%9680639]=G6[352409-350902][G6[-70229+71737]]G6[-110280-(-111788)]=z[l[1793398600%7410738]]G6[603675+-602166]=O[G6[-657519+659029]]v=G6[-944313-(-945819)]G6[-363667+365174]=G6[-912887-(-914395)][G6[742377099%13497738]]G6[780977-779464],d=-96160-(-96161),G6[183795-182288]G6[958696778%12290965]=d(E,M)cT=G6[-198330-(-199838)]G6[302999-301490]=v[cT]x=G6[66787045%16696384]G6[-514064-(-515575)]=z[l[301846444%2874728]]G6[150069911%6524713]=O[G6[197233563%3944641]]G6[332874+-331364]=G6[102641+-101130][G6[-420099-(-421611)]]E=G6[867359-865849]G6[3226510392%13556760]=z[l[43067121%1485073]]G6[1048672-1047159]=O[G6[88221022%3393058]]G6[797133407%6533868]=G6[649550+-648038][G6[548566-547053]]M=G6[2143666441%11587378]G6[-193796+195308]=M(eT,P)G6[1994990101%8906199],G6[121874878%1997924],a=894458501%7186870,X,G6[-947887-(-949399)]G6[667411247%3193348]=E[a]G6[114834+-113308],G6[878774+-877261]=2441646-26707,X M=G6[2580353389%15928098]G6[858446-856929]=z[l[1206459325%5177937]]cT=G6[460446-458931]G6[877266872%4024153]=O[G6[-631639-(-633158)]]G6[611771-610255]=G6[152010329%4222467][G6[758076990%12032944]]G6[255246750%3867352]=z[l[41965-41961]]G6[-522867+524386]=O[G6[921989-920469]]eT=G6[659583202%4745192]G6[247532+-246015]=G6[172026+-170508][G6[-788691-(-790210)]]VT,G6[-654375-(-655893)],CT=G6[2013711215%14081886],32749958526537-342711,G6[-965499+967015]b=G6[-590478+591996]G6[-558763+560282]=VT(OT,b)zT=G6[261169+-259650]G6[488788+-487268]=CT[zT]qT=G6[-129365+130885]G6[-64587-(-66108)]=GT[qT]P=G6[-80520+82041]G6[-953193-(-954717)],G6[-996049-(-997572)]=P and G6[-618875+620401],P a,G6[248693932%1167570]=G6[-871231-(-872754)],G6[1343841724%6719201]or G6[327271461%11688212]X=G6[222359-220837]else G6[-1026120+1027252],I=406364+8864196,3992365971%24441577 X=G6[542193388%4235877]end end end end else if-400858+3535863>I then if I>3557742285%19424807 then if I>897550149%15160422 then if I<414942194%13285275 then I,o,E=830971716%19516669,nil,nil elseif 3348975-233502>I then G6[645127+-643450],G6[1510396973%14807797],G6[46628+-44948],G6[603699+-602013],G6[254868933%12743362],G6[328432260%2132666],G6[1729141302%9053087],G6[580836-579158]=nil,nil,nil,{},nil,nil,nil,nil G6[555372+-553691]=z[l[1772529223%9529727]]FT,G6[13389487%13387804],sT,G6[32535451%1414512]=G6[-1008790+1010470],nil,G6[1467665909%15288169],nil G6[-362331-(-364013)]=G6[786920-785239](t)UT,G6[-336565+338260],GT,w,y,G6[1998664076%9517440]=G6[453873+-452195],nil,G6[707721-706046],G6[183849654%1242216],G6[153862+-152183],nil v,G6[638827-637135],t,G6[688083537%12287176]=G6[460781+-459105],nil,G6[721446+-719764],nil G6[-329906-(-331594)]=z[l[501352280%7265975]]A,jT,WT,G6[-663473-(-665157)],u=G6[165039+-163343],G6[-8658+10339],G6[85523-83830],nil,G6[934634+-932942]G6[2991021770%15659791]=z[l[24334+-24332]]J,G6[122885221%4237363],mT,G6[19275+-17584],I=G6[55922+-54245],nil,G6[474205-472522],-216634+176229,-755949+14943317 G6[-558222+559912]=G6[-236772-(-238461)](G6[554792497%9403234])lT=G6[-524632+526327]G6[47179356%396451]=G6[-136578+138266][G6[-659700-(-661390)]]kT,G6[-643222+644911],G6[968754+-967063],X,x,G6[1470721820%7781588]=G6[-833086+834770],nil,nil,G6[-160297-(-161984)],G6[213108-211414],nil o,G6[1205232075%14179181],r,IT=G6[12219+-10531],nil,G6[912911715%7869914],G6[301148913%10755258]L=G6[315808+-314118]else W=505929+9323849 I=W>X I=I and 1033719+-917048 or 1096753123%11126182 end else if 3181154-168949>I then O=s()P=s()X,a=i[-343517-(-343518)],i[-929227-(-929234)]j=s()S=s()z[j]=i[-171735+171737]b=s()A=i[111345969%601870]T=s()z[O]=i[878940-878937]y=s()F=s()WT={}w=s()x=s()z[F]=i[1232464963%4871403]M=s()u=s()v=s()Y=s()d=s()t=966458+-966458 z[b]=i[-483447+483452]z[u]=i[598183-598177]z[v]=i[-963487-(-963495)]N=s()z[N]=i[366204351%2317749]z[S]=i[2010882826%13964464]z[y]=i[349922891%3888032]n=s()z[P]=i[388365184%2734966]z[M]=i[691580+-691567]lT=2245208-(-505718)J=s()z[n]=i[-937880+937894]p=h(2085655661%16130788,{T;l[2809415337%15436348],y,J,u;d;O,M,Y,v;S})z[w]=i[349305667%4596127]L={}QT=k(990119+3104687,{x,n})I=k(5780801-(-255404),{x;n})iT=h(3072884192%12339621,{x,n})W=k(8868815-813142,{P,J})z[T]=i[46824428%508961]z[Y]=i[1037580-1037563]o=G(1069640827%12550505,{x,n})E,A={},I r=k(72888+3404302,{P,b,F;l[-594199-(-594200)],N;j})K=k(3742293169%16053910,{P,J})z[x]=i[760331+-760313]mT=D(433163+15258497,{w;P})z[J]=i[-395572-(-395592)]IT=q(4392485049%28989850,{x;n})z[d]=i[805374-805353]z[T]=W z[x]=r zT=G(9380505-(-89967),{x;n})z[N]=K z[n]=p z[w]=t z[v]=o z[P]=E z[J]=L z[y]=mT z[d]=QT I=m[Q(-770435+732932)]z[Y]=IT z[M]=zT z[S]=iT CT=A(lT,WT)WT=z[O]eT={WT(a)}lT={CT(C(eT))}W={C(lT)}elseif 740942+2311350>I then G6[9712308%167431]=-136466+209067 G6[-266682-(-267991)]=G6[418348330%3218054]>X I=G6[589757-588448]and 12108399-(-635410)or 15282240-(-690840)else I=621642+12468344>=1294917161%26709548 z[l[2147300093%11421809]]=I W,I={},m[Q(845506-883259)]end end else if I<898720+2044306 then if 3771219-914332>I then X=s()z[X]=i[234752083%2301491]j=s()z[j]=i[-333153-(-333155)]I=z[l[755003772%12377111]]O=z[j]W=I(O)O=s()z[O]=W I=Z(7953577-808257,{l[346200122%5495240];X;j;O})F=I W,I={F},m[Q(-991322+953766)]elseif I<2371985-(-509849)then I=-636859+14822443 elseif 880906479%7634755>I then I=10566184-660796 XT={y(iT)}cT=F(K,C(XT))else I=5307172086%23533021 end else if-447186+3425261>I then ZT=-986091+10209239 hT=X<ZT I=hT and-100945+2587836 or 14862018-(-663261)elseif I<2066141-(-930820)then G6[413381-412067]=709586298%2848708 G6[-341066-(-342379)]=G6[-661433+662747]>X I=G6[315426-314113]and 1112736674%16844355 or-995848+5485553 else G6[808803+-807584]=1981684-(-843723)G6[2957031598%15728885]=G6[10127095%843823]>X I=G6[111386793%636489]and 144278-(-104140)or 474346-(-881173)end end end else if I<-726736+3973603 then if I<4003342-791483 then if 90734822%6255537>I then G6[-637359+637399]=10782054-645571 G6[245113-245074]=G6[-743669+743709]>X I=G6[687525904%10577321]and 1183916358%8576916 or 11578522-(-66394)elseif-832787+4013649>I then I,G6[-1024846+1026645]=3532131408%17042531,o elseif 618357+2582845>I then G6[-119354-(-120705)]=13672595-(-554873)~=-392461+8283202 G6[351029-349677]=z[l[143087076%1153928]]X,I,G6[144370+-143016]=G6[736447-735096],148221+15223911,691200+-691199 G6[3611942013%15841845]=O[G6[713041+-711687]]G6[620445+-619091]=X G6[268093512%3351152][G6[-267937+269290]]=G6[402836-401482]G6[2052248781%8143839]=z[l[558985-558980]]G6[-417467+418823]=-1021012+980608 G6[-669795-(-671149)]=z[l[343400752%1373603]]G6[-360719-(-362074)]=G6[135344738%554686](G6[779661780%14438156])G6[592544168%6172321]=G6[409304-407951][G6[264952-263597]]G6[-245833-(-247186)],X={},G6[446946+-445594]w=G6[-495003-(-496356)]else v=-143060+14721186<=9498268-314468 z[j]=v I=4461332591%23198183 end else if 3083506-(-139880)>I then I=O and-928786+16043319 or 971140764%23911264 elseif 130507396%5090783>I then I=z[l[-847784-(-847785)]]W=z[l[1129039872%7012670]]O,j=nil,nil I[X]=j I=-168652+8320127 W[X]=O else v,N,j=-156009+115585,328940+-369262,{}I=z[l[-939796+939802]]u=98503-138857 F=z[l[-196504-(-196508)]]b=F(u)F=z[l[570530231%4104534]]u=z[l[-879426-(-879430)]]a=u(v)u=z[l[2155355780%9622124]]v=u(N)u=f(12274521-814033,{})O={[b]=F;[a]=X;[v]=u}W={I(j,O)}W,I={C(W)},m[Q(-428602+390927)]end end else if I<4062143-773904 then if 35542577%8069638>I then G6[-263479+263696]=-140142+11256399 G6[206437+-206221]=G6[483677423%2795822]>X I=G6[-296343+296559]and 258199561%27343792 or-864918+14089815 elseif 2911109-(-372493)>I then G6[-718357+719194]=z[l[-951420+951422]]G6[-89429-(-90265)],G6[392193929%4357701]=X,-337362+297077 G6[987823+-986985]=G6[2828359015%14808158](G6[-868476-(-869315)])G6[525633-524792]=I G6[-510172+511011]=z[l[465597934%16055101]]cT,M,G6[62574552%2720596]=G6[3131291036%15656451],G6[348822+-347984],575421469%10707711 G6[570411-569574]=G6[1319425463%14341572][M]E=G6[2035837899%10028754]G6[403431-402592]=E d,G6[1051975812%9309513]=G6[3607073839%14428292],I G6[456010827%6333472],I,G6[1310703808%15791602]=1949547331%13579153,692571331%25116040,E and G6[512192+-511348]G6[258263-257423]=G6[1321732797%8108785]or G6[734686443%4897904]X=G6[485117976%2146536]else iT,QT,lT=-979879-(-1045415),-911206-(-911206),-417219-(-482755)zT=p/iT I=739027067%7673043 IT=S(zT)CT=p%lT t,lT=QT,13404+-13148 iT=CT/lT zT=S(iT)CT=722034+-721778 iT=p%CT lT={y(IT,zT,iT)}zT,IT=nil,nil CT=F(r,C(lT))CT=65664438%643769 p,iT=CT,nil end else if 2090812456%13381537>I then G6[1192040933%12681267],G6[1517577180%12752734]=478797+-519155,245847+-286224 G6[583643667%4595605]=z[l[245907124%10691614]]G6[-246705-(-248538)]=G6[-890671-(-892503)](G6[277409-275575])G6[161836+-160000]=-578784-(-538326)G6[43328852%14442340]=z[l[520813+-520811]]G6[683104318%9900036]=G6[-501335+503167](G6[-807587+809422])G6[920611-918779]=z[l[609073726%6215038]]lT=G6[-614173-(-616006)]G6[105834383%597924]=G6[788869332%7888675](G6[2278006178%14417749])G6[877144556%6265305]=3826671473%18799486 G6[1225895505%8572683]=z[l[895147-895142]]w,G6[-82364+84203],G6[1377453212%7326869]=G6[767998+-766163],-677941+677945,{}G6[460014682%9200257]=G6[1218121156%13842265][w]X=G6[-184243-(-186075)]G6[643463070%9603899]=z[l[1033428439%15898899]]G6[71962+-70124]=O[G6[967007-965168]]G6[1014893831%5151736],G6[3606017099%14778751]=-202556+6614257,I G6[1001208-999372]=G6[81293140%9032367][G6[1723947474%8795641]]y=G6[-43720-(-45556)]G6[-639513-(-641350)]=z[l[1578724570%11276604]]G6[584908+-583061],L=816799-857091,G6[-879187+881021]G6[2973905811%11848223]=G6[-129120-(-130957)](G6[-542093+543932],G6[51280750%8546485])G6[-139658+141497]=z[l[269012-269007]]IT=G6[205339-203501]G6[454469+-452632]=G6[-984426-(-986265)][L]G6[413009545%2503077]=z[l[1158349416%13956017]]G6[-870066+871921]=561241+10221350 G6[226913+-225074]=G6[-832536-(-834376)][lT]o=G6[-271510+273349]G6[529111+-527270]={o(IT)}G6[2381847680%10826572]={C(G6[2012545226%7892327])}lT=G6[973880890%12985054]G6[763657533%6879781]=z[l[3503722637%14909458]]G6[-467760+469603]={G6[-92652+94494](lT)}G6[325675-323834],r,G6[2044010959%9687247]={C(G6[594753-592910])},G6[353548+-351711],-264754+264756 WT,o,G6[136419511%5246833]=G6[823183681%4332536],G6[364570+-362728],779089+-779084 G6[592520597%2332751]=WT[o]A=G6[481644+-479801]G6[-843181-(-845025)]=r(A)G6[280742-278897]=z[l[1021902-1021900]]G6[357186344%1475969]=G6[76640121%491271](G6[-541813-(-543660)])L,r=G6[324960464%1547422],G6[1012493646%10124918]G6[-426883-(-428728)]=y(L,r)u=G6[-354509-(-356354)]G6[94102939%707527]={u()}G6[944033-942186]={C(G6[-216448+218296])}y=G6[551211-549364]G6[110791-108942]=z[l[-778416+778423]]G6[-912170-(-914020)]={G6[53148+-51299](y)}G6[896462+-894614]=X(C(G6[-104645+106495]))w=G6[547837-545989]G6[1387185319%5755948]=z[l[-263814+263818]]G6[210696+-208847]=w y=G6[-341877-(-343726)]G6[3948119352%15792470]=O[G6[2299539948%11217259]]G6[76737+-74887]=G6[3648943238%16511047][G6[312659+-310807]]G6[1600497887%12406946],u=I,G6[-818892+820742]G6[-919564+921418],I=u and G6[762010-760154],350425+8885330 G6[-147477+149329],G6[-338184-(-340035)]=G6[940134+-938280]or G6[889394701%8634882],u w,X=G6[64535925%285549],G6[146107+-144255]elseif-69578+3386689>I then G6[408106936%3778756]=467981+2643246 G6[281140+-279853]=G6[2066279432%8071399]>X I=G6[694708+-693421]and-105480+13633317 or 1899134737%24515888 else I=w I,P=n and 3963623518%22337174 or 10321273-(-525536),n end end end end end else if I<2122624-(-294482)then if I>1778688-(-324962)then if I<2008256705%9930204 then if I<528541+1730265 then if 724473140%6069939>I then G6[523822+-523635],G6[770323+-770129]=905432+-905431,13846+-54307 G6[-270840-(-271025)]=z[l[186157054%1241047]]G6[-675879+676077]=715851-715850 G6[-994411+994597]=O[G6[-227919-(-228106)]]G6[-276110-(-276297)]=-113103-(-72740)G6[524474512%9201304]=G6[1577282864%7405083][G6[40943166%209964]]G6[230351-230156]=-541048-(-500621)G6[2131498590%11521613]=z[l[-657639+657641]]G6[386959-386773]=G6[500246282%2263557](G6[133043-132856])L,G6[618529705%14057489],o=G6[-816360-(-816544)],335895226%2525528,G6[2719402546%14312644]G6[989870+-989683]=z[l[-736309-(-736313)]]G6[-83335-(-83523)]=O[G6[-612177-(-612366)]]G6[-36496-(-36681)]=G6[863210-863023][G6[-26022-(-26210)]]A,G6[119393062%682245],G6[1346276900%12128619]=G6[161513-161328],3828369932052-555038,4337341448%24837432 lT=G6[227511+-227324]G6[-951585-(-951774)]=A(o,lT)G6[522415+-522227],X,WT=516469+35146531413625,G6[307388-307197],G6[1048014+-1047825]FT=G6[-945684-(-945872)]G6[1474203112%6494286]=L[WT]r=G6[464548+-464358]G6[864656-864464]=z[l[384820802%2466800]]G6[840913-840720]=G6[98089386%3382386](G6[345948824%11531621])G6[-69711+69903]=z[l[1719250700%9193854]]G6[802324-802130]=G6[109479162%2432866](G6[-145668-(-145863)])t,WT,G6[133215+-133016]=G6[2982862996%16664038],G6[-972310-(-972503)],771129374%14829411 G6[390377-390182]=z[l[-881703+881708]]G6[556993608%3315437]=G6[1679798931%6665868][WT]A=G6[-339651-(-339843)]G6[495068915%10533377]=z[l[88416832%398274]]G6[7467-7270]=O[G6[978437+-978239]]G6[1927160259%10037292]=G6[774304-774108][G6[425932+-425735]]o=G6[121468479%964034]G6[595880097%8512570]=z[l[387136889%1647391]]I=-496077+9266013 G6[-500558-(-500756)]=O[G6[3533603371%14601666]]G6[493388784%11213377]=G6[606672179%4814857][G6[1672128695%6769751]]lT=G6[753961731%5936705]G6[874346-874149]=lT(t,FT)IT=G6[-476009-(-476206)]G6[386398977%7290543]=o[IT]WT=G6[1918926486%15475212]G6[468785+-468586]=A[WT]L=G6[1607284983%15163064]G6[-409842+410042]=r..L u=G6[314853760%4497908]G6[-348829-(-349030)]=u y=G6[-840525-(-840726)]elseif 1267312-(-931341)>I then G6[2596483544%13047647]=A+r r,G6[140662731%5410036]=G6[1400068538%13862047],I G6[694748+-692955]=L>=r G6[174339+-172547],u=not WT,G6[20627-18834]o=G6[753227242%10043006]I,G6[113915319%7594235]=o and 4805854344%19814151 or 16188770-770636,o elseif 2789783202%15838379>I then G6[103988386%12998344]=-379413+5836357 G6[174220-172587]=X<G6[-272598+274232]I=G6[-1012695+1014328]and-364070+1867459 or 1352128154%5623787 else G6[-1017876+1019626]=-988176+7003943 G6[-541070-(-542819)]=X<G6[1653965158%11485857]I=G6[-616155+617904]and 759535+8193398 or 263274+6431880 end else if 2608176-307580>I then z[j]=A I=J J=z[j]I=J and-424372+15348598 or-224864+1198819 elseif I<-364283+2688621 then G6[1299710624%8841557]=1804703-334287 X,I=G6[833852617%3825004],412643529%11649579 else iT,IT=2084954901%14280513,925830250%7067406 zT=iT-t QT=IT^zT mT=E*QT L=p+mT QT=248022+-248021 mT=t+QT p,IT,t=L,120573-120569,mT QT=t==IT I=QT and 340127044%5027469 or 3122316139%13447850 end end else if I<3828183755%16561868 then if 929388+1452263>I then I=6114124-700205 elseif 2564609-178823>I then sT,I=2182480860%8592444,14995490-(-713843)XT=sT else G6[68896125%1565813],I=M,3186783430%20744317 end else if 470997+1929092>I then X,I=G6[1084971811%5424854],G6[498742+-497730]G6[-785693-(-786706)],G6[401104+-400090],G6[771315-770303]=X,I,295601155%12608904 I,mT=X and 344367+16420119 or 6144996-620116,G6[971955-970943]elseif I<311215+2097705 then G6[999492420%4736926]=I G6[-294126-(-295160)],G6[-530441+531473],G6[-96001+97031],G6[3708167823%16703454]=15035468-(-624722),I,x,9040359-745588 G6[953249514%4475345]=z[l[1405445317%7940369]]G6[-56330+57359][u]=G6[2472031525%14982003]G6[340291+-339262]=v G6[222795359%9283097]=z[l[943774980%3686621]]I=1776428909%16639592 G6[-149203+150233]=G6[42763283%7127042][u]v,X=G6[866682310%14444688],G6[-886550+887579]G6[622514+-621481]=v and G6[322560+-321525]G6[2615336801%14060945]=G6[688769-687736]or G6[1011783-1010749]X=G6[209753694%870343]else I=13321842-639181 end end end else if I>-101540+2106106 then if 1133622-(-888674)>I then if I<1981580-(-28107)then G6[823575-822540],G6[2356624689%15402769],G6[1443954845%14585392]=-1072881-(-1032602),221960+10292019163056,257644+-257643 G6[623333275%15982878]=z[l[-174838-(-174840)]]G6[711679+-710641]=877596-877594 G6[793671+-792637]=G6[480606-479573](G6[-509438-(-510473)])mT=G6[1166144684%11106130]G6[204356151%14596794]=z[l[2544842107%14377639]]sT=G6[-744451-(-745483)]G6[33549418%1863799]=O[G6[156578505%6807716]]G6[487396517%5297777]=G6[601117+-600082][G6[955773940%5138564]]G6[-101951+102994],J,G6[2353638125%14991319]=14211462-431818,G6[945072+-944039],I G6[141750056%7087451]=z[l[-175209-(-175213)]]G6[966493+-965451]=9226220-316969 G6[806695097%13444901]=O[G6[789432+-788394]]G6[-608728-(-609763)]=G6[-960676-(-961712)][G6[1024906-1023869]]GT=G6[-1040609-(-1041644)]G6[105541886%2245550]=GT(mT,sT)UT=G6[4228+-3192]G6[26700-25663]=J[UT]FT=G6[301043282%8601207]G6[986360+-985322]=y==FT G6[1020529+-1019489],t=I,G6[59412159%261723]G6[1170359513%8605577]=t and G6[-109944+110987]G6[-902327+903366]=G6[-978031+979072]or G6[-92825+93867]X,I=G6[-802913-(-803952)],11992753-(-639404)elseif I<1137576-(-877635)then I,j={},293594493%10123948 X=I O=z[l[-188432+188441]]F=O O=328992-328991 b,I=O,10576140-(-304642)O=-470900+470900 u=b<O O=j-b else I=-487140+10820819 end else if I<244398667%13464307 then G6[800276+-798469],G6[752542+-750740],G6[-569878+571683]=-603014+603269,{},-22989+22991 X,o=G6[88633-86831],G6[-272254+274061]G6[959453391%4321854]=z[l[724247-724243]]G6[1589082484%13242339]=O[G6[-31881+33686]]G6[-629196-(-631001)]=X G6[429287+-427484][G6[974681-972877]]=G6[-783304+785109]G6[66698+-64892]=-868166-(-868169)G6[-425356+427160]=z[l[753459-753455]]G6[-806984+808789]=O[G6[-704093-(-705899)]]G6[-11293-(-13106)]=41117168%13705721 G6[-313630-(-315433)]=G6[-273266+275070][G6[91309213%5706713]]G6[797336-795532],w,G6[49399495%16465893]=35184372575032-486200,G6[-829156-(-830959)],972649+-1012967 G6[801518-799713],A=w,G6[631075-629271]G6[1772769790%8522923]=u%A w,L,G6[916602-914792]=G6[647460-645654],G6[538152+-536347],800299-800295 G6[960342+-958534]=z[l[3930847204%16378530]]G6[478000-476191]=O[G6[-430451-(-432261)]]G6[-248552-(-250362)]=w G6[-792135-(-793943)][G6[-569218-(-571027)]]=G6[223330-221520]G6[1133281361%6261213]=u%o WT,G6[1505020929%12541826]=G6[1484937366%7654307],1035249+-1035247 o=G6[-223307+225116]G6[931752+-929942]=WT+o A=G6[-251616-(-253426)]G6[930552+-928741]=z[l[871799-871795]]G6[381378+-379566]=O[G6[2880666228%15571159]]G6[3224863733%13549840],G6[773387-771570]=A,-1025526+985208 G6[2020265981%10467690][G6[1004332-1002520]]=G6[343311-341498]G6[2181296%9314]=470003+-470003 G6[-950265+952076]=#y WT=G6[2612659027%14199224]G6[598638222%13013835],G6[1445077555%12676103]=WT,138938182%20675581 t=G6[595200-593388]G6[138072+-136258]=z[l[763166%8772]]G6[7386+-5571]=G6[518093-516279](G6[-529765-(-531581)])lT=G6[-980739+982554]G6[-400452+402266]=z[l[2351069142%10834420]]G6[-297212+299028]=G6[1041172+-1039358](G6[1005451-1003634])I,o=-959010+10194765,G6[1025166+-1023350]G6[-834787-(-836601)],G6[100405+-98587]=o,-108271-(-108272)r[u]=G6[-20591+22405]G6[486814-484997],G6[95396-93582],X=51083129%12770782,640945-640741,G6[986505544%4162463]o,IT,FT=G6[546666+-544852],G6[489404-487586],G6[53572301%2435022]G6[1219386781%5593509]=FT J,FT=G6[-901999+903818],G6[694179-692359]G6[484587+-482766]=FT>J G6[865943950%12196368]=IT-J GT,FT=G6[-201523-(-203344)],G6[356370416%1990886]elseif I<2192767-125323 then G6[-65867-(-67084)]=2039392820%19273948 G6[1819139887%12047276]=z[l[483541-483537]]G6[386356-385143]=-736434-(-736435)G6[761023+-759811]=O[G6[234682+-233469]]G6[19939396%9969093]=G6[-139120+140331][G6[823033-821821]]I,G6[67631+-66415],G6[667604251%12838520]=7792669-64304,792014-792012,372062+5512655002793 A,G6[-407037-(-408251)]=G6[456176+-454965],843047+-883373 G6[-891004+892216]=z[l[258797570%2021856]]G6[-590390-(-591603)]=G6[876187+-874975](G6[-356446+357660])G6[-820758+821972]=z[l[136271294%13627129]]L,w=G6[172571+-171358],G6[-675937+677147]G6[-1013766+1014981]=O[G6[560545+-559329]]G6[-103442-(-104654)]=G6[896189702%8617197][G6[333811-332596]]u=G6[1562220048%13703674]G6[-844154-(-845368)]=u(L,A)r=G6[-644959-(-646173)]G6[-471015+472230]=w[r]X=G6[1131541746%13006213]G6[195765-194549]=X y,X=G6[-720816-(-722032)],G6[683187-681970]else G6[-188999+189916]=-1009086+16265541 G6[187078+-186162]=X<G6[-974827+975744]I=G6[816276+-815360]and 14734+4748603 or 1211144-367867 end end else if I>-959236+2924394 then if 699947305%13422551>I then G6[2127762610%16119399]=7662496-(-204402)G6[968862717%9315969]=X<G6[302905-300963]I=G6[2825271717%11211388]and-164091+8864683 or 3830605604%28279009 elseif I<1581136537%7895721 then G6[382439+-381020]=-636188+2331859 G6[54742-53324]=X<G6[114600544%4583965]I=G6[909542+-908124]and-1029979+6003422 or 1428980210%23939930 else I=900856+3431975 end else if I<-418839+2307897 then I=1806232314%28935058 elseif I<1681232-(-224696)then G6[-910092-(-911799)]=5666942-859327 G6[2164082999%8553681]=G6[-962182+963889]>X I=G6[15580-13874]and 662268+11681110 or 2269015394%11116405 elseif 2339678579%16462951>I then G6[796007982%4574749]=5803718-184019 G6[562758+-561103]=G6[-138168+139824]>X I=G6[203633699%4848382]and-825280+6525035 or 1445297067%12379722 else I=15224831-1039247 end end end end else if I>2561618111%16947136 then if I>4033851462%19014700 then if 802488+2000948>I then if 268182566%4914958>I then G6[-46940+48360]=z[l[337236-337234]]G6[55611-54172],G6[-248213+249632],G6[-602971+604393]=2673699266%12140241,-663089+2365063~=4824493-(-513864),-101741+61476 G6[591542-590121]=G6[284815311%5373847](G6[1374399918%14316651])X=G6[772840+-771421]G6[326769-325347]=X G6[464330-462910]=z[l[311248234%1700810]]G6[254562999%5303366],A={},G6[448214+-446793]G6[467258386%1876534][u]=G6[425080-423658]G6[74956231%1469702],G6[-137320+138750],G6[551557+-550125]=494172+-534549,1025005486%6068666,821794-(-42371)G6[441415258%3559789]=z[l[492907-492902]]G6[248949700%2370936]=G6[836480142%11617760][A]L,G6[713572-712148]=G6[-357456+358876],744236+-784575 G6[375698+-374276]=z[l[795115-795113]]G6[504246548%4033961]=G6[518808+-517386](G6[633566+-632142])A=G6[819414927%4502272]G6[1135956450%14563526]=z[l[-728313+728316]]G6[-907749-(-909173)]=G6[656960-655538]()G6[962824+-961402]=L[A]WT,r=G6[1941580184%16179823],G6[-261464-(-262886)]G6[7700473%549932]=z[l[666120+-666117]]G6[-265762+267188]=G6[-298641+300066]()L=G6[-565658+567084]G6[552265-550838]=z[l[489892+-489890]]G6[589681+-588256]=X G6[382484-381056]=G6[-31089+32516](G6[1784247581%8073512])G6[39614772%408385]=z[l[629389+-629385]]o,J,G6[41499+-40070]=G6[-377416+378841],G6[-65572+67000],r G6[964502+-963075][L]=G6[-792911+794340]G6[410928657%9556447]=I G6[904679+-903252]=z[l[770042-770033]]G6[885743749%3690593]=G6[1608992357%9871110](G6[480952130%16031690],G6[24814823%652984])G6[1953175622%15879465]=z[l[-330374-(-330377)]]r,G6[-981049+982482]=G6[413732281%1814609],{WT}G6[-841696-(-843127)],G6[-428422+429860]=r,I G6[869836-868406]=G6[-369804+371231]()G6[162294+-160867]=z[l[-394706+394710]]A=G6[1560254830%7801267]G6[43975247%222090][A]=G6[425371-423940]I=2835855438%30658912 G6[-488981-(-490408)]=z[l[1890153512%8832493]]G6[59236383%7404369]=G6[1857285779%7255017](G6[178929+-177497],G6[-969247+970680])G6[3312073715%15333668]=16563350-943523<4396036-462764 G6[921795+-920363]=z[l[-185646-(-185650)]]GT,r=G6[161796783%6741473],G6[945749-944322]G6[-972075-(-973508)]=r G6[755892-754460][WT]=G6[1285445911%9247802]G6[386546-385113]=z[l[-969737-(-969742)]]G6[1851630358%13922022]=G6[883823960%7185549][J]FT,G6[470954284%3737721]=G6[760927552%12682102],-745173+8827318 G6[-784550-(-785983)]=FT(GT)J=G6[250565825%1210456]G6[367805724%5254347]=J r,G6[671913+-670476]=G6[118155249%1817751],J and G6[-851849+853288]G6[1394909602%7622449]=G6[1366613742%10432155]or G6[-337176+338614]X=G6[-767105+768540]elseif I<-368834+3162648 then X=z[l[753271303%5419218]]W=#X X=1404470895%16523187 I=W==X I=I and 3148772432%23758086 or 2210151536%11469617 else y=z[j]P=9558084-522604<=-222816+2711581 S=y==P I=S and 3741213690%19125407 or 528170462%10146489 end else if 3542463-733206>I then G6[-626888-(-627092)],G6[170435771%831393],G6[134250-134048]=I,I,-531142+9874503~=5921549-1032143 X,G6[169155297%1879501],G6[255728+-255522]=G6[-233398-(-233600)],953386+9667803,3885892477%15224079 G6[271236565%9041212]=X and G6[902259-902052]G6[1086352971%10755968]=G6[562257-562052]or G6[-84787+84993]X,I=G6[109989009%1774013],2202542630%11135902 elseif I<223986574%3949305 then G6[876983+-875830]=1628612162%6553627 G6[872938-871786]=X<G6[494398-493245]I=G6[104826792%5241282]and 265015700%6423345 or 13488562-(-521255)else G6[742821+-742334],G6[92107962%635224],G6[1609101293%11021237]=229667-269947,848190-848189,-352461+352463 G6[-102781-(-103261)]=z[l[247946872%2119204]]G6[30986-30242]=756768-756766 G6[1319440097%10308122]=O[G6[738726-738244]]G6[1526799516%13754945]=716232+-756579 G6[612373079%3402070]=G6[437301+-436821][G6[500487237%8629082]]G6[-635039+635521],G6[596169+-595511],G6[-71795-(-72352)],G6[407832-407347]=14982-55269,49173+-89504,-415159+415161,471842498%4368912 G6[-160769+161249]=z[l[-367786-(-367788)]]a,G6[1593122898%8340955],G6[-749393-(-750017)]=G6[-543529+544008],-160226-(-160227),-877059+877060 G6[965216+-964735]=G6[472731+-472251](G6[141083186%11756892])G6[908904929%5284328],G6[815572+-815092],qT=481946338%3886664,25984867122837-986961,G6[448513-448032]G6[-349738+350221]=z[l[-194876+194880]]G6[-577670+578154]=O[G6[284734-284249]]G6[2409731963%16734246]=-357441+317081 G6[17781190%808214]=G6[555244951%13542548][G6[547362054%2657095]]G6[269564-269079]=z[l[2657102336%10801229]]eT,G6[-96045-(-96528)]=G6[16364858%16364376],M X,G6[3926870659%16710085]=G6[-810567+811050],177626043%16147822 G6[776050150%4000256]=G6[-337304-(-337789)](G6[-54659-(-55146)])G6[-680149-(-680644)],G6[-541103-(-541607)],OT,G6[687337161%14319514],G6[359936359%12854848],G6[915031204%4919520]=344442-344440,3237203670%16773076,G6[1064416806%6047820],12456980593925-108125,57441-97706,22517252516899-(-294098)b,CT,G6[-795008-(-795495)],G6[844462-843747],G6[231397305%1081293]=G6[46653-46164],G6[1090931916%6379716],-975743+5839697800734,176165929%9786996,-574692+534238 gT=G6[866081+-865594]G6[672652+-672167]=eT(qT,CT)P,VT,G6[354394815%5062774]=G6[678566213%12566032],G6[1952852199%14907265],-807029-(-807031)G6[203906933%1836995]=a[P]M=G6[346891+-346403]G6[14479-13988]=z[l[2862496399%13696155]]G6[-270629-(-271135)]=-869999+15484802327193 G6[-306552+307044]=O[G6[-182110+182603]]G6[-485021-(-485511)]=G6[28344471%1417199][G6[868586+-868094]]HT,eT,G6[422805920%3155263],G6[508471257%10818525]=G6[-742985+743491],G6[345459890%6281080],15785206-(-815561)<362694+8583800,93152+-93150 G6[347535140%16549269]=z[l[-479354+479356]]G6[-1043597+1044090]=-677667+637368 G6[602518194%5285243]=G6[473983+-473492](G6[127777389%3993028])CT,G6[1009065-1008516],G6[-432033+432593],G6[-378937+379435]=G6[721247+-720755],2666229673%16257498,-1004071+963806,-373932+373933 G6[645025622%4849813]=z[l[153869+-153865]]G6[847370843%4483441]=O[G6[-305346+305841]]G6[-50074-(-50565)]=G6[1313933029%15642054][G6[1218786370%15828388]]G6[-611315-(-611814)],G6[-890848+891380],G6[909086-908516],P,G6[-1024788-(-1025288)]=-590628+590630,595213051%3968087,-928383+928384,G6[65783067%357514],61032+-101313 G6[-363781+364274]=P(CT,VT)G6[328641+-327966],qT=2510824513%14945384,G6[-702735+703228]G6[-702751+703245]=eT[qT]G6[740233732%12986548]=z[l[730272+-730268]]G6[-780567-(-781144)]=-205183+164761 G6[1685958581%14789106]=O[G6[775207+-774709]]G6[31130581%15564977],a=703934-703932,G6[-523472-(-523966)]G6[270316-269821]=G6[200234-199738][G6[1310080401%11697142]]G6[2272523528%10669121],CT=I,G6[820340+-819845]G6[-473370+473867]=z[l[-750944-(-750948)]]G6[-920701-(-921410)],G6[850380890%10123575],G6[924390525%6898433]=-970683-(-970684),82461-82459,-651480-(-651481)G6[194733694%6281716]=O[G6[3663430450%16427937]]G6[-217682-(-218197)],G6[26045815%5209059]=419691-459956,-958869-(-958871)G6[329470573%1323173]=G6[-861357+861854][G6[567311986%8864242]]G6[-808382-(-808891)],VT,G6[3512841405%15612626]=-96986-(-56590),G6[454415+-453919],-981697+941299 G6[3829476704%16022913]=VT(OT,b)zT=G6[888621+-888124]G6[69095766%523449]=z[l[1221850601%6825981]]G6[238255199%9530188]=G6[688758763%4750057](G6[-632992-(-633492)])G6[28918243%507325],QT,G6[-381933+382542]=-722019-(-681583),G6[409742257%6717078],1011396+-1011395 G6[-957823-(-958321)]=CT[zT]qT,G6[-861076-(-861587)]=G6[-815387+815885],-900618+900619 G6[511935-511434]=z[l[351764-351760]]G6[483093034%4128996]=O[G6[-700006+700509]]G6[-710554+711054]=G6[1585473441%11744244][G6[2133556832%14319170]]G6[194953-194451]=z[l[2564389858%16760718]]G6[-19469+19972]=O[G6[257930330%3349738]]G6[465429-464866],VT,G6[1423407%8039],G6[899757+-899214]=551960+-551959,G6[-1011456-(-1011956)],-610056+569644,790907+-790906 G6[-503478+503979]=G6[684334965%12911971][G6[-1036075-(-1036578)]]G6[1434166828%9019914]=z[l[-445231+445233]]zT=G6[-373090-(-373591)]G6[316042967%1727008]=G6[-500715-(-501217)](G6[40595-40091])G6[164953-164418],b,G6[309727-309225]=3656392852%19196662<=378995815%20822994,G6[64734487%16183496],642141+24201970458536 n=G6[-767273-(-767775)]G6[759121+-758617]=zT(b,n)OT,G6[-121400+122054]=G6[-20371+20875],835225+-835224 G6[-34474+34979]=VT[OT]CT,G6[-910170-(-910841)]=G6[-639083-(-639588)],-605522-(-565253)G6[-790467+790974]=z[l[-219080-(-219082)]]G6[-557715-(-558223)]=G6[-645748-(-646255)](G6[1837965419%14247790])G6[1105667661%7470724]=z[l[322297+-322293]]G6[-910997+911507]=O[G6[-67357+67868]]G6[-915037-(-915544)]=G6[289009+-288500][G6[314204614%1707631]]n,zT,G6[-132376-(-132885)]=G6[-146351-(-146859)],G6[93645617%720347],33652734380220-(-521338)G6[294258-293747]=z[l[650064-650060]]G6[990338-989826]=O[G6[152939126%8996389]]G6[731567917%8506597],G6[910340+-909822]=-441677-(-441679),1518543076%6198135 G6[891591+-891081]=G6[-777756+778267][G6[88346492%4908110]]OT,G6[1891839003%12782691]=G6[-320304+320814],864382-864380 G6[427719965%9298249]=OT(n,gT)p,b=G6[360746641%5818486],G6[-371390-(-371901)]G6[1017432900%4274926]=zT[b]G6[502557-502044]=z[l[-633888-(-633890)]]VT=G6[-868549-(-869061)]G6[-659299-(-659813)]=G6[-529663+530176](G6[2184972655%13917020])b,G6[726581-726054]=G6[818632+-818118],-824579-(-824581)G6[711342+-710827]=z[l[-591359+591364]]G6[-230205+230731]=3389341697%16294912 G6[987236-986723]=G6[788778015%4507300][b]OT,G6[-518359-(-518988)]=G6[1974770399%11032234],94640+-134948 G6[752829-752313]=z[l[-931226-(-931230)]]G6[503460089%3269218]=O[G6[185757323%1587665]]G6[262258312%1024444],G6[2465140649%16112027]=-891868-(-891869),-598395+558067 G6[-403095-(-403610)]=G6[583527300%2559328][G6[751293332%3399515]]G6[-649441-(-649957)]=z[l[540784739%3055281]]G6[653546+-653024]=690960-731403 G6[1479481064%13826921]=G6[105447286%5549830](G6[714375-713857])XT,n,G6[-562530+563084]=G6[231831-231314],G6[-357578+358093],806242-806241 G6[225701-225183]=z[l[-156719-(-156723)]]G6[2525947941%10658006]=O[G6[2480597464%14765458]]G6[-899730+900246]=G6[234299046%7321829][G6[936381-935862]]gT=G6[163525+-163009]G6[-288226+288744]=gT(XT,HT)N=G6[-971491+972009]G6[-1025167-(-1025686)]=n[N]G6[883846+-883326]=z[l[2244531377%9975695]]G6[2590960841%16193502]=G6[669042+-668522](G6[430292478%3211134])G6[-719325+719908],G6[281047-280527],G6[2790352584%14236490],G6[910284+-909704],b,G6[-434759+435399],G6[-780298+780832],XT,G6[153678-153127]=23126829429958-(-472395),512034+30964894066737,10491+-10489,-286021+286022,G6[1565494599%11344160],-239472+239473,-319892+319894,G6[383035613%11607124],655100903%2718261 G6[111219882%1059232]=OT[b]zT,HT=G6[320817+-320295],G6[2006615158%9420726]G6[-787823+788347]=z[l[35146-35142]]G6[-786736+787261]=O[G6[377993+-377467]]G6[172636+-172113]=G6[423457+-422933][G6[329506+-328981]]n=G6[257917555%14328724]G6[2299123351%16077782]=z[l[685664+-685660]]G6[-526353-(-526879)]=O[G6[-674895-(-675422)]]G6[661617-661017]=624307-624305 G6[-854715-(-855239)]=G6[2183243717%8947718][G6[411120871%5204055]]gT=G6[-548601-(-549125)]G6[-456244+456769]=gT(XT,HT)N=G6[-259185+259710]G6[-971977+972503]=n[N]G6[-446535-(-447063)]=z[l[165075+-165071]]G6[511189160%13815909]=G6[209151-208623][t]b,n=G6[788187-787661],G6[-936075+936602]G6[-662672+663200]=zT(b,L,A,r,n)G6[2736390830%13961175]=z[l[-430245+430249]]OT=G6[822218-821690]G6[573215-572684]=O[G6[-510413-(-510945)]]G6[903932+-903346],G6[576454-575883]=805926+-846333,608079434%4438536 G6[-369510+370039]=G6[219450+-218920][G6[392576675%2133566]]G6[419223144%5516087],G6[793885712%5924515],b=327979+-368254,1417965057%5538926,G6[460617-460088]G6[1024895+-1024365]=z[l[674753-674751]]G6[-268766+269297]=G6[2928295610%16268306](G6[-838833-(-839365)])G6[-377866-(-378398)]=z[l[-291329-(-291333)]]G6[-749129+749662]=O[G6[-90856+91390]]G6[171299-170609],G6[579207+-578640]=-550472+550473,-776661-(-736244)G6[-901950+902480]=G6[-133413-(-133945)][G6[61590769%504838]]G6[169510-168978]=854612+29174918949565 XT,N,n,G6[778455-777866],G6[293434+-292842]=G6[-134631+135163],G6[452340-451809],G6[1543093510%10569130],144001842%628829,998565+7073359<1875129133%16880300 G6[-38236+38769]=n(N,XT)gT,G6[-944807-(-945464)]=G6[-890388+890921],463027-503292 G6[-296971-(-297505)]=b[gT]b,zT=G6[649069-648534],G6[224636946%3403582]G6[188468+-187932]={[qT]=CT;[VT]=OT,[zT]=b}P=G6[351422+-350886]G6[187524989%9869708]=z[l[137196152%1988350]]G6[-272864+273402]=G6[743463+-742926](G6[2308277444%13989557])G6[380051789%7756148],b=901932+8056100424571,G6[-317830+318368]gT,G6[276353+-275814]=G6[898621-898084],-821621+12327203708897 G6[1256731885%10217328]=z[l[1494480251%11767561]]S=G6[-443023+443562]G6[-961925-(-962467)]=O[G6[185802-185259]]G6[55320291%6146639]=G6[831047491%3693542][G6[-480654+481196]]VT=G6[-195632+196172]G6[28395634%251284]=z[l[1984953743%13145389]]G6[-890728-(-891427)]=839585-879850 G6[-245013+245556]=O[G6[17498653%330153]]G6[637446548%3684659]=G6[884465-883923][G6[670166039%7364456]]zT,G6[-48730+49447],G6[-296688+297231]=G6[-740310-(-740851)],-204718-(-204720),667807+11622703817861 n,G6[926094222%11576171],G6[570652545%10375489]=G6[1186075281%5342679],-380187+20710933852871,-420288-(-420290)G6[-401400+401944]=zT(b,n)Y,OT=G6[534037036%9051466],G6[126191+-125647]G6[896258822%11064917]=VT[OT]G6[602981904%3465410]=-838002-(-838004)G6[664924-664377]=z[l[96181771%628639]]CT=G6[467430+-466885]G6[-475918+476466]=O[G6[-114247+114796]]G6[-418760-(-419306)]=G6[459469+-458922][G6[-622152+622700]]G6[168391-167842],zT=-901024-(-860681),G6[735763-735217]G6[-521268-(-521815)]=z[l[196087+-196085]]G6[298353-297805]=G6[98187+-97640](G6[749631-749082])n=G6[-686257-(-686805)]G6[-230198-(-230747)]=z[l[-204359-(-204363)]]G6[-706042+706648],G6[-320448-(-321078)]=599549062%10900892,33434033096005-(-14219)G6[-206529+207079]=O[G6[468984-468433]]G6[2050603787%9537689]=419323-459590 G6[-243178+243725]=G6[311543-310994][G6[258559-258009]]G6[1821449497%7464954],G6[673535-672813],G6[-512533+513229],OT,G6[615883+-615153]=508616+7955419122608,-737240+15728596524148,942091-942090,G6[-672818-(-673365)],919686-919684 G6[593636+-593087]=OT(n,gT)b=G6[-487265-(-487814)]G6[-17032+17582]=zT[b]G6[57929247%351083]=z[l[2939233913%12948167]]VT=G6[-464291+464841]G6[-21853-(-22406)]=O[G6[29070+-28516]]G6[1103672087%8361148]=G6[-481289-(-481841)][G6[647070-646517]]OT,G6[615703-615151]=G6[289883579%3083862],905978+31432746542643 G6[435001+-434448]=z[l[644253782%3463730]]N=G6[742299752%3711496]G6[-459964+460518]=G6[2641571121%11099036](G6[-350062-(-350617)])G6[3604212181%14893436],HT=79645+-79643,G6[142106+-141552]G6[-402588+403143]=z[l[3361991116%14491341]]G6[3630411424%15784395]=-275998+275999 G6[820534+-819978]=O[G6[-264719-(-265276)]]G6[1713470553%7788500]=G6[1128799979%14852624][G6[134913526%7495165]]G6[1064385621%10538466]=z[l[1762077478%7221629]]G6[255516+-254882],G6[-577261-(-577818)]=-1013895-(-1013896),652766+-693087 G6[-228888-(-229444)]=G6[219624-219069](G6[856175-855618])b,gT=G6[-387337-(-387890)],G6[-986902-(-987458)]G6[85769995%1072118]=b(gT,N)G6[160694084%9452558],n=672360+-672359,G6[-236249-(-236804)]G6[663023-662466]=OT[n]G6[-298343+298901]=z[l[-634207+634209]]zT=G6[-832242+832799]G6[31946662%198423]=G6[32501576%16250509](G6[298196-297636])G6[759291+-758731]=z[l[1811862475%7487035]]n=G6[1888301809%12588675]G6[879474478%13530368]=G6[-833142-(-833702)][n]G6[340837+-340276]=z[l[-320410-(-320414)]]G6[-182488+183050]=O[G6[1341211589%10993533]]b=G6[-377143-(-377701)]G6[494501+-493941]=G6[-67878-(-68439)][G6[2789545230%12343118]]G6[336315+-335753]=z[l[1543791944%9959948]]gT=G6[839126+-838566]G6[787252-786689]=O[G6[991979+-991415]]G6[82956+-82395]=G6[-647941-(-648503)][G6[-449327-(-449890)]]N,G6[854537+-853973]=G6[775797+-775236],24160050127318-570852 G6[2299835442%10267120]=N(HT,S)XT,G6[-513952+514563]=G6[318203183%3150521],1564+-1562 G6[-722448-(-723011)]=gT[XT]G6[-938782-(-939378)],G6[-454793-(-455465)]=68166+-108480,639867-680293 G6[110375360%1298527]=z[l[-434196+434198]]S,n=G6[339668342%11712682],G6[-154223-(-154786)]G6[2862912774%13764001]=G6[-628605-(-629170)](G6[17929+-17362])HT,G6[875364+-874746]=G6[843605-843039],426669+-426668 G6[142986+-142421]=b[n]G6[260497-259929]=z[l[913707+-913703]]OT=G6[1345775510%8682419]G6[162872+-162303]=O[G6[-868211+868781]]G6[397104-396537]=G6[263459648%13172954][G6[-522185+522754]]G6[850320-849751]=z[l[-6452+6456]]gT=G6[746610+-746043]G6[107340555%795111]=O[G6[763901+-763330]]G6[-929506+930074]=G6[-245127+245696][G6[34907315%6981349]]N=G6[1042998-1042430]G6[384339956%10387551]=N(HT,S)G6[-750501-(-751156)],XT=1076867084%6859026,G6[-938539+939108]G6[32318596%375791]=gT[XT]G6[-9524-(-10096)]=z[l[-30251+30255]]G6[950711253%5281726]=O[G6[556299-555725]]n=G6[643805277%9330503]G6[-1027238-(-1027809)]=G6[827453042%12730038][G6[-638526+639099]]G6[305717-305144]=z[l[-246701-(-246705)]]XT=G6[-344410-(-344981)]G6[-1026155-(-1026729)]=O[G6[736858334%3665959]]G6[380983+-380411]=G6[490725-490152][G6[-1036086+1036660]]HT=G6[893700+-893128]G6[165801+-165228]=HT(QT,p)S=G6[130728990%6880443]G6[2340142306%9791388]=XT[S]N=G6[642523852%8682747]G6[-298924-(-299499)]=z[l[-88026+88028]]G6[-704675+705251]=G6[520923103%5315536](G6[63431-62854])G6[3623080442%15549699]=GT[N]G6[-324585-(-325262)],p,gT=917741-917739,G6[638535+-637959],G6[219572+-218997]G6[-375655-(-376233)]=z[l[7905402%7905398]]G6[1045690-1045048],G6[-974810-(-975415)]=253985+-294371,-186368+186369 G6[2383966083%12416487]=O[G6[537614+-537034]]G6[2586763252%14781501]=G6[-959702+960280][G6[2133201555%9000848]]G6[727286+-726642],HT,G6[258450-257870]=-443451+443453,G6[252848513%15802996],962711-1003017 G6[35168-34590]=z[l[10377474%324296]]G6[265942+-265363]=G6[-849516-(-850094)](G6[-777728+778308])K=G6[263857-263278]G6[900876+-900296]=z[l[282540+-282536]]G6[-1002524+1003105]=O[G6[896218134%6055524]]G6[1931735908%16233070]=G6[372143+-371563][G6[543536-542955]]S=G6[319201+-318623]G6[978042623%4679627]=S(p,Y)QT=G6[370060-369480]G6[346455+-345874]=HT[QT]HT,XT=G6[1160723853%16581761],G6[-247506-(-248087)]G6[454894344%4098142]=GT[XT]N=G6[211857-211275]G6[653175260%6597724]=z[l[100557122%3351904]]G6[916785573%4284042]=G6[948425-947841](G6[-325519-(-326105)])G6[202901-202317]=OT(n,FT,gT,N)XT,b=G6[858513-857928],G6[810844695%10530443]G6[990657-990070]=z[l[737938+-737934]]G6[54138619%1151873]=O[G6[-325630+326219]]G6[-458769-(-459525)],G6[666076505%3433381]=1073315787%6266822,32509296023385-(-828361)G6[1151028403%6430323]=G6[949419-948832][G6[524664180%4231158]]G6[964098830%8844938]=z[l[1256464684%13225944]]G6[-291319-(-291908)]=O[G6[799486926%4275328]]p,n=G6[524979+-524349],G6[2117736406%12384420]G6[-128365-(-128952)]=G6[559060+-558472][G6[162620189%16261960]]gT=G6[-18164+18751]G6[-143091+143679]=gT(XT,HT)N=G6[-332209-(-332797)]G6[6698349%669776]=n[N]G6[382447-381857],XT,n=30211986425915-(-929465),G6[-98408+98999],G6[66490892%6649030]gT,OT=G6[-101812+102402],G6[-1030870-(-1031459)]G6[418357+-417763]=z[l[1381468664%14096619]]G6[854288-853693]=G6[567568-566974](G6[544935-544339])S=G6[1085950668%4396559]G6[430846-430250]=z[l[-489777-(-489781)]]G6[195821+-195228]={[CT]=VT;[zT]=b;[OT]=n}G6[980188-979591]=O[G6[615078572%3705289]]G6[655919+-655169],qT,G6[1920708022%13338246],G6[685598174%11620296]=501788341%13561847,G6[692280143%7691995],97422+-137872,1233309404%5270553 G6[871241224%5155270]=G6[-969619-(-970215)][G6[-467748-(-468345)]]G6[-498051-(-498647)]=z[l[164414747%1034055]]G6[660003+-659406]=G6[217961+-217365](G6[612508+-611910])G6[159092-158494]=z[l[753147+-753143]]G6[-634475+635224]=1041240061%9916572 G6[-691167-(-691766)]=O[G6[-592802-(-593402)]]zT=G6[351363+-350769]G6[-359313-(-359909)]=G6[-8761-(-9359)][G6[-68891-(-69490)]]OT,n=G6[-522486+523082],G6[388055847%5174070]G6[950602+-950004]=OT(n,gT)G6[-706736-(-707335)]=15465639416284-(-346693)N,b=G6[1406495189%7901655],G6[244063402%1099382]G6[1176946125%6227225]=zT[b]G6[430603+-430002]=z[l[578123-578121]]VT=G6[848036+-847436]G6[-837715-(-838317)]=G6[635111389%16284892](G6[379221003%3416400])G6[-881380-(-881983)]=z[l[636026054%11564110]]gT=G6[698696-698094]G6[589542-588938]=O[G6[1506329205%15063286]]G6[97712-97111]=G6[946314+-945711][G6[585407+-584803]]G6[1154834221%7856011]=z[l[-937019-(-937023)]]OT=G6[378459620%13050311]G6[570249665%2837060]=O[G6[161065+-160459]]G6[1020121-1019518]=G6[-416800-(-417404)][G6[-421862+422467]]b=G6[-421458+422061]G6[-506367-(-506971)]=b(gT,N)G6[3346813293%15566570],n=720665+-720664,G6[-31134+31738]G6[978307550%4772229]=OT[n]zT,G6[447421733%1920262]=G6[-639019-(-639624)],-1004672+964291 G6[708591905%6005011]=z[l[348289-348285]]G6[-173787+174395]=O[G6[314747+-314138]]G6[-214583+215189]=G6[2546594833%14387538][G6[-184002+184610]]b,G6[235334630%1392509]=G6[610603485%3099507],-21008+-19285 G6[-786945-(-787552)]=z[l[648096698%5539288]]G6[1655553020%15329189]=G6[53739463%13434714](G6[164693386%4016897])G6[2712210633%16537866]=z[l[-468815-(-468819)]]N,G6[740021+-739402]=G6[1835124748%12153140],706323+-706321 G6[897370+-896760]=O[G6[1133292353%9213754]]G6[629113-628373],G6[88406-87739]=326812+-326810,929927-929926 G6[879981475%5365737]=G6[495175+-494566][G6[-666149+666759]]G6[3694455304%14718943],G6[1032710730%8980088],n=9719142453802-(-1032067),14018744420272-486961,G6[868685607%12235000]G6[74802627%12467003]=n(N,XT)QT,G6[-647461-(-648214)],gT=G6[45919750%3826595],I,G6[769051398%4718103]G6[441146-440534]=b[gT]T,G6[1006912+-1006208],G6[6207+-5545],G6[767252057%11119585]=G6[-519813+520424],290633-330903,1711243413%15143747,-913650-(-873266)G6[126613+-126000]=z[l[967844+-967842]]OT=G6[2058221196%9528799]G6[-891510+892124]=G6[337739053%11257948](G6[986941-986326])G6[-729521-(-730136)]=z[l[-633894+633899]]gT,G6[2161868091%8511289]=G6[-25889-(-26503)],-637810+637812 G6[-1030825+1031438]=G6[-563330-(-563945)][gT]G6[790536+-789920]=z[l[296898+-296894]]G6[757632-757015]=O[G6[816759+-816141]]n=G6[886609+-885996]G6[-630572+631187]=G6[1026178+-1025562][G6[842676-842059]]N=G6[658451-657836]G6[116867300%12985187]=z[l[2649358964%11518952]]G6[2526730140%15991959]=O[G6[290392-289773]]G6[-899602-(-900218)]=G6[-996694+997311][G6[297630-297012]]XT=G6[619798-619182]G6[171940-171323]=XT(S,QT)HT=G6[695768+-695151]G6[772424547%13091931]=N[HT]gT=G6[-231527+232145]G6[-231413-(-232032)]=z[l[548598+-548596]]G6[-360204+360824]=G6[-741883-(-742502)](G6[-884490-(-885111)])G6[-651808+652427]=n[gT]S,b=G6[840179+-839559],G6[294270+-293651]G6[488914+-488292]=z[l[-425325+425329]]G6[798680351%12101208]=O[G6[38115-37491]]G6[-12955+13576]=G6[804947072%3326225][G6[-801195+801818]]G6[-554570+555193]=-1025103+21800114260982 G6[19592989%148427]=z[l[104989-104985]]G6[1265400476%5001580],G6[269551+-268929],Y,N=1027165+-1067442,-1044854+28667062691227,G6[-55264-(-55887)],G6[-757742-(-758363)]G6[-955107-(-955733)]=O[G6[317690+-317063]]QT=G6[145048573%16116439]G6[6423+-5799]=G6[2250308146%9741591][G6[568233-567607]]XT=G6[1283168092%7208806]G6[152469+-151844]=XT(S,QT)HT=G6[-31196-(-31821)]G6[985418-984792]=N[HT]gT=G6[279491-278865]G6[-443621-(-444248)]=z[l[-17294-(-17296)]]G6[-211662-(-212290)]=G6[-25994+26621](G6[17829-17200])HT=G6[1458363058%11574305]G6[170044767%8097340]=b(gT,J)G6[859925+-859296]=428661+24073798754645 S,n=G6[810058+-809429],G6[117632-117005]G6[-224225-(-224857)]=z[l[669431-669427]]G6[162677-162044]=O[G6[-79835-(-80469)]]G6[1532912531%15329119]=G6[877535306%8278629][G6[-518212-(-518845)]]gT=G6[338764336%9678963]G6[1470406433%7352029]=z[l[-286490+286494]]G6[-51833-(-52467)]=O[G6[-902088-(-902723)]]G6[866313142%16345519]=12206492-(-691904)<=668322007%24425308 G6[56312+-55680]=G6[467241357%3313764][G6[965315+-964681]]N=G6[-1027871-(-1028503)]G6[-702278+702911]=N(HT,S)XT=G6[285115309%3702788]G6[-511042-(-511676)]=gT[XT]G6[-1034534-(-1035172)]=z[l[1932558572%15840644]]gT,b=G6[583395-582760],G6[-73413+74047]G6[770833+-770197]={[VT]=zT;[OT]=n;[b]=gT}G6[-869516-(-870155)]=O[G6[-529311-(-529951)]]CT=G6[2169048004%9075512]G6[380130+-379493]=G6[2655342116%13758246][G6[-543903+544542]]G6[-576514+577152]=-129317+7593665791733 HT,G6[1017160015%6691838],G6[-533778-(-534517)]=G6[-190909-(-191547)],13356+16976130779829,225310681%1251726 XT=G6[11752812%1305797]G6[513063-512423]=z[l[-312387-(-312389)]]G6[2263207841%15088048]=G6[-407997-(-408637)](G6[-863354-(-863996)])G6[739838-739174],gT,OT=30302-70658,G6[2591593957%15067403],G6[-966389+967026]G6[1039043+-1038401]=z[l[915874780%5653548]]G6[403335877%13010814]=O[G6[1359719396%6665288]]G6[-540999+541639]=G6[-559235-(-559877)][G6[240298-239655]]b,G6[-450868+451510]=G6[2346431558%9237917],32051978647974-(-245927)N,G6[591302+-590641]=G6[-484558-(-485200)],564059299%8546353 G6[-884094-(-884737)]=b(gT,N)n=G6[370704895%2487948]G6[828355548%15929902]=OT[n]G6[-978864-(-979510)]=z[l[10912941%222713]]zT=G6[-977791-(-978435)]G6[600990+-600343]=O[G6[757077480%10972128]]G6[-50255-(-50900)]=G6[816632116%15122805][G6[678497219%8698674]]G6[1859655806%8452978]=z[l[-654848-(-654850)]]b,G6[-814716+815364]=G6[-354558+355203],293098+-333394 G6[-636153+636800]=G6[148019066%2691244](G6[332672724%2749356])N=G6[1622137050%9376511]G6[-278111-(-278759)]=z[l[-258382+258386]]G6[65268-64619]=O[G6[830780040%6541570]]G6[642479+-641833]=G6[1026445-1025797][G6[-331508+332157]]n=G6[2927544720%16085407]G6[867181-866533]=n(N,XT)gT=G6[247422-246774]G6[-189140+189789]=b[gT]OT=G6[137257+-136608]G6[-881259+881909]=z[l[-1037284+1037286]]G6[663738615%5721879]=G6[-225440+226090](G6[866430-865778])XT=G6[-39128+39779]G6[-534900+535552]=z[l[2412317428%13628912]]G6[507579+-506926]=O[G6[619317834%4621770]]G6[694921-694271]=G6[-206891+207543][G6[-169065+169718]]n=G6[-90457+91107]G6[-508006+508659]=z[l[717950776%7252028]]G6[671659+-671005]=O[G6[745350876%15211229]]G6[1790367224%11331434]=G6[12572-11919][G6[504029+-503375]]gT=G6[1048864957%9281985]G6[106160+-105507]=gT(XT,HT)N=G6[478197653%3825576]G6[851824-851170]=n[N]G6[-412861+413516]=z[l[-957782+957784]]G6[777717458%5515722]=G6[-224670-(-225325)](G6[281591+-280934])N,b=G6[1028936+-1028280],G6[541938-541284]G6[-394388+395043]=z[l[-744962-(-744964)]]G6[-341965-(-342622)]=G6[616815+-616160](G6[321248-320590])QT=G6[2139642815%13628294]G6[-507376-(-508034)]=z[l[-142914-(-142919)]]G6[2813726449%15046662]=G6[-587947-(-588605)][N]gT,G6[635279+-634546]=G6[623563+-622908],630613338%5580649 G6[88584-87925]=z[l[673113-673109]]G6[889905651%10228793]=O[G6[-881190-(-881851)]]G6[-488515+489173]=G6[-278767+279426][G6[854741+-854081]]G6[-298783-(-299443)]=z[l[1039847-1039843]]XT=G6[387196434%3024967]G6[92968409%4042076]=O[G6[-682070+682732]]G6[325330409%13013190]=G6[-586993-(-587653)][G6[1614520581%12419384]]HT=G6[818672-818013]G6[130657463%939977]=HT(QT,p)S=G6[258432-257772]G6[246895129%1046163]=XT[S]N=G6[164698441%10979852]G6[239526626%2753172]=z[l[-869158+869160]]G6[556838263%3480235]=G6[788910-788248](G6[222058630%3314298])G6[-571611+572273]=gT[N]n=G6[266369+-265707]G6[-579593-(-580258)]=z[l[980885+-980881]]G6[161813018%12447104]=O[G6[-213486-(-214153)]]G6[-808512-(-809176)]=G6[2103012185%13143822][G6[-440351-(-441017)]]QT,XT,G6[2326740287%11027202]=G6[-205461+206124],G6[-646696-(-647360)],-472420+32374135320647 G6[152745094%1542873]=z[l[387810-387806]]G6[7540213%7539545]=O[G6[-364384+365053]]G6[1003206746%6600040]=G6[885714091%3884708][G6[49749-49081]]HT,p=G6[-934447+935113],G6[377091+-376426]G6[-236348-(-237015)]=HT(QT,p)S=G6[340472+-339805]G6[589655-588987]=XT[S]G6[616046239%6417141],G6[744640+-743961]=-129847+129849,841803+30999618363416 G6[303113997%7216984]=z[l[100039+-100037]]N=G6[1664433974%9403578]G6[937444-936774]=G6[385034+-384365](G6[-733617+734288])S=G6[-771780-(-772450)]G6[527180-526511]=z[l[2229189062%10615186]]G6[1279016%426115]=G6[-283449+284118](G6[-441640-(-442312)])G6[829901+-829232]=n(N,WT,o,o)G6[-728475-(-729148)]=z[l[-562267-(-562271)]]p,gT=G6[192611-191940],G6[-620718-(-621387)]G6[343837055%2339023]=O[G6[863529+-862854]]G6[-848698+849370]=G6[663529-662856][G6[14306+-13632]]G6[-978773+979446]=5195324565874-(-335873)G6[2018225819%13277797]=z[l[-6953-(-6957)]]G6[236696512%4551843]=O[G6[-11534+12211]]G6[607344397%2798819]=G6[1287911475%9540080][G6[265904240%2581588]]QT,N,XT=G6[-39820-(-40493)],G6[-754066-(-754738)],G6[84214+-83540]G6[507748083%8323728]=XT(S,QT)HT=G6[-449838+450513]G6[-211907-(-212583)]=N[HT]n,XT,G6[-366033+366710]=G6[-237339-(-238015)],G6[-105518-(-106197)],-735707+22556018975458 HT,N=G6[716193-715516],G6[-348323+349001]G6[180363+-179683]={[zT]=OT;[b]=gT,[n]=N}VT=G6[-531739+532419]G6[561793+-561111]=z[l[44376217%349419]]G6[-14095+14778]=O[G6[-787158-(-787842)]]G6[683266089%6100584]=G6[4062826410%15870413][G6[-546082+546765]]b=G6[878471-877790]G6[991644+-990961]=z[l[1299290527%8604573]]G6[871314530%6136013]=O[G6[816351+-815666]]G6[111558+-110876]=G6[3242150971%15587261][G6[-733076+733760]]G6[-933420-(-934103)]=z[l[832534900%4926242]]n,G6[744761-744076]=G6[51883248%894527],353494-393780 G6[930076+-929392]=G6[985860907%5357936](G6[1018130-1017445])N=G6[254879563%4319981]G6[-954059-(-954742)]=n(N,XT)gT=G6[214955+-214272]G6[166047+-165362]=z[l[239351312%2175921]]G6[1013844137%11653373]=G6[-376423+377108](G6[-259477+260164])G6[335150+-334465]=b[gT]OT=G6[-103463-(-104148)]G6[-126713-(-127401)]=z[l[63135-63131]]G6[-866425+867114]=O[G6[696812-696122]]XT=G6[280462708%9047162]G6[127105995%3530703]=G6[359337-358649][G6[227781-227092]]G6[-903835+904524]=z[l[510367810%13086354]]G6[156951491%1986719]=O[G6[-539764+540455]]G6[750657+-749969]=G6[-657055+657744][G6[1228445106%12796296]]n,gT=G6[-567727-(-568414)],G6[409125+-408437]G6[1876195245%16174091]=gT(XT,HT)N=G6[564071800%12001513]G6[964546964%7906117]=z[l[338840+-338838]]G6[924281035%6041048]=G6[-741728-(-742418)](G6[343601879%6028091])G6[1392839529%12436061],HT=-601209-(-601211),G6[798869-798178]G6[-450085-(-450777)]=n[N]G6[-992594-(-993284)]=15198009105290-(-688155)S,b=G6[684854+-684164],G6[286079004%2103517]G6[1991893624%7999570]=z[l[-880641-(-880645)]]G6[392410415%13080324]=O[G6[-756416-(-757112)]]G6[-609038+609731]=G6[810490+-809796][G6[1958302007%15299229]]gT=G6[1999427791%8296378]G6[-429733+430428]=z[l[-855598+855602]]G6[-20450+21146]=O[G6[-216772-(-217469)]]G6[-598927-(-599621)]=G6[67089-66394][G6[175535+-174839]]N=G6[1784038198%12927808]G6[2486031249%11456362]=N(HT,S)XT=G6[-667580-(-668275)]G6[-17355-(-18051)]=gT[XT]G6[383749793%1899748]=z[l[682510-682508]]n=G6[4140617912%16174286]G6[718845550%15627062]=G6[20333+-19636](G6[589927145%15943958])XT=G6[-28924+29622]G6[531993691%3075104]=z[l[123527-123522]]G6[61001095%6777822]=G6[-790175+790874][XT]N=G6[-876945-(-877642)]G6[-311407+312107]=z[l[-951917+951921]]G6[-546354+547055]=O[G6[-965766+966468]]G6[645873036%6523963]=G6[899687340%9275120][G6[-769119+769820]]HT=G6[2957996475%15406228]G6[575625-574924]=z[l[300311+-300307]]G6[-94392-(-95094)]=O[G6[785800-785097]]G6[1382552572%9095736]=G6[187131671%959646][G6[-81900-(-82602)]]S=G6[-423883+424583]G6[1325283954%8231573]=S(p,Y)G6[-637667+638392]=321738-362053 G6[-45040+45742]=z[l[404787+-404785]]QT=G6[1044079-1043378]G6[1415095215%6803339]=G6[629882+-629180](G6[922638178%7264862])G6[-370096+370800]=HT[QT]XT,G6[1554622334%8269264]=G6[-97928-(-98632)],922366+9888898023166 Y,p=G6[3042232902%12217800],G6[397610-396907]G6[784407-783702]=N[XT]gT=G6[280134860%1880095]G6[210122611%12360112]=z[l[-305025+305029]]G6[628832+-628124]=O[G6[413562+-412853]]G6[1362612757%5607457]=G6[-406750+407457][G6[-372122+372830]]G6[616415195%16659851]=z[l[-516114-(-516118)]]HT=G6[161148862%13429013]G6[2141083904%14766091]=O[G6[-956637+957347]]G6[288353231%2645436]=G6[-849999+850707][G6[1204322533%5575564]]S=G6[-184728-(-185435)]G6[669797+-669089]=S(p,Y)QT,G6[904275590%4709765]=G6[-167977+168685],27654989267623-(-1011622)G6[1763512533%13160536]=HT[QT]p,XT=G6[722385960%8498650],G6[1685323273%13591311]G6[-582405-(-583116)]=gT(XT,UT)G6[1411897590%13979177]=z[l[247548294%11252195]]N=G6[365224713%14047077]G6[-264903+265617]=O[G6[1114738695%5867042]]G6[382215969%2001127]=G6[-918966-(-919679)][G6[1783838331%7526741]]G6[155371+-154658]=z[l[321220+-321218]]G6[1803345027%14903672]=1048033+-1088471 G6[1733898%29376]=G6[216409277%1045452](G6[1342907665%8952713])QT,XT,G6[2389021141%13421463]=G6[-8195+8909],G6[-805690+806402],588950401%7361880 G6[-864109+864824]=z[l[969477-969473]]G6[-202938-(-203654)]=O[G6[961544553%16578342]]I=1441869326%10172851 G6[814588625%14291016]=G6[-1016950-(-1017665)][G6[-42437-(-43153)]]HT=G6[-782490-(-783203)]G6[-931766-(-932481)]=HT(QT,p)G6[257406-256690]=z[l[-640061+640063]]S=G6[420000+-419285]G6[132646182%8843031]=G6[998336+-997620](G6[269447676%5732914])HT=G6[3300107791%15789986]G6[-1018149+1018865]=XT[S]gT,G6[1160578717%5717133],G6[-548367-(-549122)]=G6[1938622876%10311820],1166941869%4943663>=-922003+13487165,4660415-(-804116)XT=G6[896940+-896222]G6[837429+-836710]={[OT]=b;[n]=N,[gT]=XT}zT,N=G6[760690-759971],G6[-965710+966431]G6[-355061+355781]={P;qT;CT;VT,zT}G6[-282183+282906]=z[l[-872836-(-872838)]]n=G6[393857+-393135]G6[-134007-(-134731)]=G6[176742303%1497810](G6[871251+-870526])G6[537067105%15796070]=z[l[-966539-(-966543)]]zT,eT=G6[1171636447%6402381],G6[-40500-(-41220)]G6[758636-757910]=O[G6[588451-587724]]G6[-723392-(-724115)]=G6[87491735%460479][G6[11627-10901]]G6[85235-84510]=z[l[1845831080%12556674]]qT,G6[1010929-1010202]=G6[2547411547%12996994],-870474+830210 G6[-713746-(-714472)]=G6[1195994825%8542815](G6[-651162+651889])G6[311998-311270]=z[l[-1001765+1001769]]b,G6[302573386%2030689]=G6[-1009606+1010332],-925311+10817713156652 OT=G6[255413421%2606252]G6[1371545259%13446515]=O[G6[928693-927963]]G6[91692999%6549448]=G6[2369378592%10918792][G6[2637691161%10384608]]CT=G6[-76642+77369]G6[697936-697208]=CT(zT,OT)VT=G6[902087-901359]G6[510113-509384]=qT[VT]G6[1180179395%6782636]=z[l[523364-523360]]P=G6[-653817-(-654546)]G6[282176-281444]=O[G6[-459557-(-460290)]]G6[120123198%5222716]=G6[2876331%102700][G6[2224105732%8896420]]G6[134729-133998]=663044+6598234041852 G6[-201216-(-201949)]=z[l[1162584488%11287228]]S,VT=G6[3066743243%14197882],G6[-35770-(-36500)]G6[-746976+747710]=O[G6[-578191-(-578926)]]G6[999779-999047]=G6[1616156608%7182915][G6[855023-854289]]zT=G6[-352813+353545]G6[574211209%13353732]=zT(b,n)G6[-163557-(-164291)]=z[l[1799934782%8571118]]OT=G6[25807954%832491]G6[609415397%14172434]=G6[206073-205339](G6[545184-544448])G6[2587129863%10474207]=VT[OT]G6[137300237%610220]=z[l[355882+-355878]]gT,CT=G6[-881840-(-882575)],G6[168718766%4017096]G6[212832641%9253561]=O[G6[380081+-379342]]G6[1191926358%16107103]=G6[239244-238507][G6[-259276+260014]]OT=G6[-685830-(-686566)]G6[36245-35507]=z[l[-655447+655451]]G6[-697513-(-698252)]=O[G6[794926+-794186]]G6[231223137%9248896]=G6[-314190-(-314928)][G6[143768584%737271]]b=G6[1145290817%14316126]G6[-781514+782252]=b(gT,N)n=G6[13628263%230975]G6[2353+-1614]=OT[n]zT=G6[-5993-(-6732)]G6[952516-951775]=z[l[973076+-973072]]G6[1735568527%16529217]=O[G6[309508778%1213757]]G6[851989188%4759712]=G6[1944253833%8877868][G6[683834+-683092]]G6[1930146850%14622319]=z[l[484495246%3146073]]gT=G6[-704184+704924]G6[901627+-900884]=O[G6[1392077576%7404664]]G6[467310+-466569]=G6[492089-491347][G6[-106846+107589]]N,G6[1491820103%12431828]=G6[2061237411%16230210],X G6[3092458707%16715989]=N(HT,S)G6[999166+-998422],XT,HT=X,G6[130193074%2284076],G6[583296+-582553]G6[728420-727675]=gT[XT]N=G6[-674899+675643]G6[825746+-824999]=z[l[461018384%4349230]]G6[117999987%592961]=O[G6[-967839+968588]]G6[1153050844%9771611]=G6[662739+-661992][G6[-87022+87770]]p,n=G6[1006109-1005363],G6[2602668337%15492069]G6[-78285-(-79033)]=z[l[73220034%14644006]]G6[430204-429455]=O[G6[57943614%2759184]]G6[181732+-180985]=G6[12091-11343][G6[96960+-96211]]Y=G6[1782253425%8175471]G6[-1047581+1048329]=Y(K,T)iT=G6[1285672556%10044311]G6[523190619%2696855]=p[iT]QT=G6[365323107%2876554]G6[-228086+228836]=GT[QT]S=G6[586797+-586047]G6[-109343-(-110097)]=S and G6[1386979686%9836730]G6[738002+-737250],G6[917343-916592]=G6[143873930%4231564]or G6[-1023789-(-1024544)],S XT,X=G6[795634+-794883],G6[2620500708%12020642]end end else if 610072486%5784751>I then if I<3264878-642901 then G6[873077+-871115]=7468483-180492 G6[-582090+584048]=z[l[960404-960402]]G6[-178755-(-180720)],G6[-1010858-(-1012819)],G6[307229+-305269]=-542959-(-542960),-111413-(-71106),616582+-656959 G6[397864619%6120964]=G6[239631278%1331274](G6[603462-601502])G6[-326047-(-328005)]=z[l[1002093+-1002091]]G6[307035-305060]=I G6[423923+-421963]=G6[3024557523%16348949](G6[404621682%4546289])G6[368903-366937],o=577203-577201,G6[784852+-782892]G6[-101493-(-103451)]=z[l[858256+-858245]]G6[-728269+730233]=O[G6[581954694%10209697]]w=G6[-568341+570300]G6[2031440935%11949641]=O[G6[4071602331%16618777]]G6[415231+-413268]={G6[667277553%6606689];G6[462358-460393]}G6[1625219114%13657287]=G6[-296571+298529](G6[964629+-962667],G6[928424145%16007279])L=G6[241840+-239879]G6[1441135642%10293812]=z[l[-722610-(-722615)]]G6[3234299708%16011375]=G6[-3800+5762][w]X=G6[1683311834%12562014]G6[913095-911132]={X(L)}G6[2853233350%14557303],G6[464835-462870]={C(G6[-341322+343285])},-243691-(-243693)G6[-358375-(-360338)]=6762922527028-(-951065)lT,A=G6[1256389688%6791285],G6[772620+-770658]G6[-203506-(-205470)]=A[G6[713593+-711628]]G6[-849188-(-851166)],G6[-592749+594715]=-942096+16766737,-1047828-(-1047829)G6[2612537825%11875163]=A[G6[1126579531%8345019]]w,r=G6[922551-920586],G6[2875823039%12781427]G6[21767690%89941]=z[l[-980855+980859]]G6[1036608926%10577622],G6[-296534+298500]=-859186+859187,w G6[871296085%4129356]=O[G6[968335-966365]]L=G6[245490910%8465136]G6[-412009-(-413976)]=G6[-699023-(-700991)][G6[-619216+621185]]w,G6[1184758731%6369660],G6[1901429706%11184869]=G6[616845+-614878],-725736+725738,L and G6[1458090122%13626992]G6[56343111%971399]=z[l[-207650+207654]]G6[816948-814971]=I G6[-763378-(-765348)]=O[G6[864096+-862125]]G6[304330-302362]=G6[2696655481%16051509][G6[544118-542148]]I,A=846395305%18341049,G6[641647-639679]G6[916463849%6192310]=A(o,lT)WT,G6[-119358+121329]=G6[-355348+357317],L G6[3103437060%12667082]=w[WT]X=G6[-703054-(-705024)]G6[855051-853078],G6[-245314-(-247286)],WT=X,X,G6[1444357226%9318421]A,G6[1370499597%6257980],o=G6[-994001-(-995973)],12353968-(-534384),G6[-686468-(-688441)]G6[490205362%8308532]=G6[823033638%5049274]or G6[610900+-608923]X=G6[-633166-(-635140)]elseif 3235935311%15849482>I then eT,I=-897791+897792,zT z[j]=IT WT=z[o]lT=WT+eT CT=E[lT]iT=n+CT CT=936339-936083 zT=iT%CT n=zT lT=z[t]CT=w+lT lT,I=849116+-848860,2362828318%27345643 iT=CT%lT w=iT elseif 1705180297%8345727>I then I=1971432308%20813761 else I,G6[749635160%5242194]=16086767-851233,193791+10730393 X=G6[3718649643%15824035]end else if 366372+2326028>I then I=-701833+2704676 elseif I<-1046708+3749326 then I=361669+7621025 z[l[637737+-637732]]=W X=nil else I=132508197%9670149 end end end else if I>815361488%7892157 then if I<2465167-(-76368)then if I<800011+1700736 then bT,hT,RT=3990807-575835,151807+1742529<784486+6810244,I IT=hT BT,DT=IT and bT,I I,RT=48395+14821996,12853102-(-462251)ZT=BT or RT X=ZT elseif I<3242674-726252 then G6[288230+-286948]=842043+-842042 G6[431952144%5683564]=z[l[1564651636%10716792]]I=2647050816%11871973 G6[781039731%5206923]=O[G6[1846443928%9927111]]G6[679412+-678133]=G6[163394804%864516][G6[-604461-(-605742)]]u,G6[780515-779235]=G6[645389534%7592803],nil L=G6[-91933+93213]G6[915871-914590]=#u G6[1056448810%12143075],y=932940+-932939,G6[2766830115%11977614]G6[223536686%1910559]=z[l[636517124%15912928]]G6[128205+-126921]=O[G6[-38336-(-39621)]]G6[491761123%7339699]=193546-233999 G6[21605498%10802108]=G6[1323057011%6125258][G6[245155544%4714505]]r=G6[991175130%4164596]G6[-913656-(-914939)]=r[y]u=G6[3427096915%13818934]G6[411109494%5958090]={u}G6[2137919144%14643273]=z[l[-463599-(-463603)]]w,G6[749935-748647]=G6[227148+-225864],879377-879376 G6[921469-920182]=O[G6[340361-339073]]G6[637868+-636583]=G6[577676-576390][G6[501242-499955]]G6[216867+-215581],r=L,G6[92477-91192]r[y]=G6[-394236+395522]G6[133330059%7407154]=z[l[830055+-830050]]G6[593053513%10404425]=z[l[744508526%10060926]]G6[2421050108%11156907]=G6[226310-225022](G6[192611590%7704412])G6[-925261-(-926547)]=G6[144527262%875915][G6[90594-89305]]X=G6[-806344-(-807630)]else G6[397581-396178]=z[l[703931232%2849924]]G6[514170+-512764],G6[-443493+444894],G6[472627+-471222]=500429+-500427,-11741+25237642075077,-960577-(-960578)WT=G6[1514139969%10230666]G6[-380497+381901]=O[G6[-876991-(-878396)]]G6[795075-793673]=G6[295969-294566][G6[1467513144%15447492]]G6[-211859-(-213263)]=z[l[733317-733313]]G6[366350+-364945]=O[G6[-722509+723915]]I=1250722957%13114788 G6[697730-696327]=G6[613811+-612407][G6[521188+-519783]]w,G6[-463630+465036]=G6[1186380522%14829739],-406044-(-365691)G6[-175732+177136]=z[l[1234460845%16031959]]r=G6[479929823%15997614]G6[851912-850507]=G6[-793908+795312](G6[208302+-206896])G6[183489-182081],A=205720182%5498260,G6[1943462968%9668963]G6[-506007-(-507411)]=r(A,WT)L=G6[316905306%1331529]G6[876741-875335]=w[L]X=G6[1967453336%13568634]G6[2141617751%8998388]=X u,X=G6[-578921+580328],G6[643535+-642127]end else if 3634028545%16969407>I then I=8151006-869551 elseif I<720347621%5607474 then G6[-242529-(-242747)],G6[743787-743568]=nil,15047279-(-581001)IT,X,I=G6[-656267-(-656485)],G6[105551060%6208873],723683142%16855201 else I=4364079200%17571372 end end else if I<27725+2400177 then if 2073659602%14794571>I then G6[-748646+750281]=485413+4981651 G6[660738+-659104]=X<G6[-450306+451941]I=G6[-12704-(-14338)]and 735864+10799236 or 1268155676%6532670 elseif I<-518760+2940670 then G6[-330047+330890]=525624+-565986 G6[-1003991+1004832]=z[l[1000797-1000795]]G6[512818-511976]=G6[2386871807%13796942](G6[1726+-883])E,G6[-551124+552014]=G6[416973-416131],I G6[-368261-(-369104)]=z[l[82856+-82853]]G6[243580-242709],G6[679742860%6730119]=431561884424%11356982587,{}mT=G6[950911+-950070]G6[109726+-108882]=G6[-535690-(-536533)]()G6[319329-318484]=z[l[545104122%16032474]]G6[286471-285628],sT=nil,G6[150382584%779180]CT,G6[600249+-599401],G6[322683967%1581780]=G6[-200651-(-201494)],{sT;o;A;WT},15750041-(-478173)G6[232450380%4557834]=G6[-596574-(-597419)](G6[253890391%1476102],G6[116949+-116101])G6[251328+-250480]=z[l[1936755745%8384224]]kT,G6[649964+-649117],G6[-576485+577336],G6[-1035337+1036216],G6[-496834-(-497679)]=G6[590307-589461],nil,-698275-(-657851),-21659+-18671,nil UT,r=G6[604496+-603651],G6[-181249-(-182096)]G6[-535832-(-536681)]=G6[272844-271996](WT)G6[-729151+730001],WT=mT,G6[519957+-519108]G6[831895386%8076646]=z[l[-952963-(-952967)]]G6[660302-659448]={}G6[-531812+532660][sT]=G6[458788+-457938]G6[320413+-319565]=z[l[666440+-666438]]G6[402437+-401587]=G6[-716523-(-717371)](G6[1944+-1093])G6[52581+-51733]=z[l[1710135891%7500596]]G6[80533-79682]=G6[667215-666367]()G6[-731405+732253]=z[l[-413725+413729]]M,mT,G6[-730389-(-731241)]=G6[-548330+549184],G6[945675-944824],kT G6[878671+-877823][mT]=G6[259583882%15269590]eT=G6[252246145%1627389]G6[962907947%4097477]=z[l[479265-479262]]G6[1469993753%12782547],G6[1412192730%6789384]={},-411414-(-371036)G6[-460866+461719]=G6[-704072-(-704924)]()jT,kT,G6[102228278%7301959]=G6[-251483-(-252336)],G6[-246310-(-247158)],nil G6[578638-577782],GT=kT,G6[-780071+780923]G6[-562612-(-563467)]=z[l[-401558+401562]]G6[-1032734+1033589][jT]=G6[-68330-(-69186)]G6[908401+-907545]=z[l[-1003869-(-1003874)]]G6[386334+-385479]=G6[585127+-584271][E]kT,G6[442537384%15259880]=G6[-591989+592844],{jT,sT,FT;o,A;mT}G6[275493+-274637]=z[l[-933461+933463]]G6[-828942-(-829799)]=G6[982730+-981874](G6[164284378%1283465])G6[98819134%866827]=-899989+10325246045 G6[-995511+996370]=z[l[858693-858689]]G6[1624947399%7628857]=G6[1465201134%6814885][jT]UT,P,qT=G6[-563126+563982],G6[-372315+373173],G6[-346565+347422]G6[623946-623087]={[eT]=P,[qT]=CT}a=G6[-162568+163427]G6[-195269+196129]=kT(M,a)E=G6[-92508+93368]G6[-495504+496365]=z[l[-50998-(-51002)]]G6[-630086-(-630949)],G6[12190525%4063221]=15277333-757768,E G6[-404602-(-405463)][L]=G6[-1032368+1033230]G6[493974-493113]=z[l[-249383-(-249389)]]G6[850596+-849714]=1313575727%12584998 G6[-335851+336713]=G6[-207797+208658](G6[505219460%12954323],G6[212598438%3729782])G6[-508360+509221]=z[l[82444033%858792]]kT=G6[-37031-(-37893)]G6[891873-891010]=G6[780463-779602](mT)mT,G6[487147+-486286],WT,G6[68578+-67710]=G6[2579130713%15631090],nil,G6[754397-753526],kT J=G6[328235-327374]G6[125484471%1818603]=z[l[559886-559885]]G6[2449934044%13387613]=G6[536280-535416](FT)FT=G6[1644341185%10277127]G6[2421864828%15524769]=z[l[617557-617556]]G6[-489330-(-490196)]=G6[2847384150%14166086](jT)jT,G6[531020364%8045750],G6[57987178%11597257]=G6[833221+-832355],-646082+10324994049,13019390%2020471 G6[110750-109883]=z[l[-147713+147717]]J,G6[-92694+93574]=G6[-262200-(-263064)],971912-1012203 G6[689333-688466][u]=G6[-698427-(-699295)]G6[-974873-(-975740)]=10662349805-(-192718)G6[-339765+340634]=z[l[535481827%9394418]]GT=G6[-852963+853830]G6[-480370+481240]=G6[721715-720846](A)G6[2055448152%13009160]=z[l[-452909-(-452910)]]G6[-694662+695535]=G6[-840682-(-841554)](sT)G6[-477387-(-478256)],G6[202242652%8426741],G6[621085-620213]=-378710+10809217063,-283620+99214917856419,-961464+9873433798 mT=G6[612866+-611998]G6[-500357+501231]=z[l[720905-720904]]FT,sT,A=G6[990843300%14788693],G6[-442109-(-442982)],G6[1253092934%5594161]A=G6[86850098%487917]G6[542169-541294]=G6[124050-123176](o)G6[-939143+940017],o=861140+1.2127160493876e+14,G6[-801935+802810]o=G6[298788+-297914]G6[875692110%8845366]={A,WT,o;FT,J,GT;UT;mT}G6[1517045677%15802550]=z[l[1033041-1033039]]G6[-707626-(-708504)]=G6[39899482%13299535](G6[-258476-(-259355)])G6[3160184626%12691501]=z[l[136480983%617561]]G6[994629+-993750]=G6[-981976+982853](G6[556040-555160])G6[935085+-934208]=z[l[890665+-890662]]G6[2964445041%13661033]=G6[-948548-(-949425)]()G6[-632285-(-633162)]=z[l[84471+-84467]]A,J,r=G6[993918430%5231145],G6[421578682%6799642],G6[657894+-657018]G6[2977257476%12669177],sT,G6[-362043-(-362926)]=r,G6[-547718+548597],{A}G6[-653673+654550][A]=G6[344764763%4996578]G6[-430267+431144]=z[l[50073-50064]]G6[-911258-(-912139)]=G6[212914557%3041624](G6[542424-541542],G6[13363-12480])r=G6[179068709%4367508]G6[22854+-21972]=z[l[459830-459825]]G6[723022-722145]=G6[392732-391850][J]FT=G6[754938-754061]G6[683685163%2745720]=z[l[1512837135%8951699]]G6[92383+-91501]=G6[-120989+121872][L]GT=G6[577108-576226]G6[99331828%1552046]=z[l[2403764500%16692809]]G6[841534507%7791978]=G6[530262+-529378][u]UT,G6[-663700+664584]=G6[-259395+260278],22126427842034-(-770637)kT=G6[-356510+357394]G6[2858997321%16431014]=UT(sT,kT)mT,G6[739802748%11559404]=G6[758592-757707],I I=-707902+6412585 G6[360725782%7515102]=GT[mT]G6[896313-895421],J=-192011+10109201,G6[-973104-(-973990)]G6[1036356+-1035469]=FT[J]o=G6[247263-246376]G6[104281548%1738011]=r(o)WT=G6[-630422+631310]G6[232047-231156]=WT and G6[-141494+142387]G6[247476871%9518307]=G6[587322234%9322561]or G6[-518379-(-519271)]X=G6[329675689%3296748]elseif 3404725-980835>I then I=G6[-52253+52610]G6[-722186-(-722543)],G6[3511534331%16107954],X=-807558+7538370,I,G6[109681-109325]x,G6[884981990%7629152],I=G6[378442957%15137704],X,X and 1358484969%26901004 or 13102+9453471 else G6[430996125%8979050]=UT==mT d=G6[611586-609861]G6[46350602%3089925],G6[110217+-108491]=d,14514859-(-1030504)x,X,I=G6[-96698-(-98425)],G6[-911316+913042],-956250+16158529 end else if I<609365204%9337382 then G6[-603923+604078]=7516188-(-761738)G6[-544455-(-544609)]=X<G6[772572-772417]I=G6[-833825-(-833979)]and 906811+2695943 or 20608947%8069581 elseif 517496+1927854>I then G6[-148521+148886],G6[784820-784457],G6[-740804+741163]=-627570+627572,1234724107%6142906,169645+10002684705668 G6[-420592+420953]=z[l[-866125-(-866129)]]G6[401938750%1989794]=O[G6[2108211078%10811337]]VT=G6[1009503+-1009144]G6[459004+-458644]=G6[-919802+920163][G6[-560692+561054]]G6[-486035+486396]=z[l[-310437-(-310439)]]G6[-844339+844702]=-403209+362827 G6[182187+-181825]=G6[1988838215%11110826](G6[-631408+631771])CT,eT=G6[504737-504375],G6[2112235386%14176074]G6[667377-667014]=z[l[791101-791097]]G6[1008068+-1007704]=O[G6[420261+-419896]]G6[748668+-748307]=G6[-733229+733592][G6[574429-574065]]P,G6[125437441%2668874]=G6[-402769-(-403130)],-63710+14228399 G6[-96010+96374]=P(CT,VT)qT,X,I=G6[-25155+25519],G6[-154991-(-155354)],7502012-892995 G6[-646789-(-647154)]=eT[qT]a=G6[259207021%1012526]G6[537592+-537226]=a E=G6[1228549299%6236289]else G6[-331410+332829]=1891317-(-150008)G6[773270+-771852]=X<G6[1023461-1022042]I=G6[-848315-(-849733)]and 2767103-785271 or 1459806926%7147336 end end end end end end else if 871598+-1738>I then if 1135493-613387>I then if I>304898045%10880153 then if I<-203066-(-615454)then if 333232670%3871233>I then if I<-26415-(-287662)then G6[-96283+98197],G6[421259-419347]=55544+-95909,139320-179632 G6[394008-392098]=z[l[598118-598116]]I=3262672635%28249532 G6[-14310+16221]=G6[209032-207122](G6[-72675-(-74587)])G6[235884316%6552289]=z[l[701242+-701237]]E=G6[456487526%5370419]G6[-543821-(-545731)]=G6[2776369711%16236069][E]v=G6[1612517234%10969492]G6[-145104+147019]=v G6[-230576-(-232488)]=z[l[-1000767+1000769]]G6[-480557+482470]=G6[466881962%9337601](G6[893024022%6922652])E,G6[269863363%5291401]=G6[-220262-(-222175)],936415+8839371 G6[-733632+735546]=z[l[236488-236483]]G6[2507053734%11938342][E]=G6[153078865%11775150]X=G6[193980268%2939066]elseif-755287-(-1033948)>I then I=485821+10866121 elseif I<-780083+1078024 then G6[534013+-532128],G6[454149+-452270]=I,X G6[-109600+111481]=z[l[239061159%991955]]G6[134122+-132239]=I I=806502+11432452 G6[323015044%3047294]=G6[-142853+144734][u]G6[-183839-(-185725)],v,d,G6[210820-208935]=4829942-918856,G6[-541761+543640],G6[666099+-664219],2239392170%24437877 G6[603011089%4748104],G6[-1038973-(-1040857)]=d,d and G6[-803743+805629]G6[-569057+570939]=G6[-758685+760569]or G6[-78415+80300]X,x=G6[-631930+633812],G6[88093+-86212]else G6[514303+-514260]=I G6[979540+-979501]=z[l[323387+-323385]]G6[1935853817%15611724]=570381-610811 G6[-356092-(-356132)]=G6[5309543%57712](G6[-431595+431636])IT=G6[-367239+367279]G6[33654473%4206804]=z[l[-943832+943837]]G6[1995191145%11084395]=I G6[235530+-235491]=G6[-255378-(-255419)][IT]G6[173444+-173398],lT=2237249656%12244016,G6[-129220-(-129259)]G6[848772-848731]=lT()IT,G6[620101+-620056]=G6[506214437%14061511],4693580763%25869471 G6[-570881-(-570925)]=IT and G6[1718357665%16059417]G6[-979982+980024],I=G6[-270088-(-270132)]or G6[843105349%5140886],-249504+8668904 X=G6[-19664-(-19706)]end else if 640068-325129>I then G6[1185989864%12484084]=8104966-1014269 G6[488468323%5746664]=X<G6[-260113-(-261997)]I=G6[-707534+709417]and 726296097%4252179 or-177452+14224542 elseif I<481670-148677 then X=s()j=s()z[X]=i[1003654-1003653]z[j]=i[29426442%189848]I=z[l[855541+-855540]]O=z[j]W=I(O)O=s()z[O]=W I=G(2384587499%25256205,{l[3642644028%15305227],X;j;O})F=I I,W=m[Q(-904617+866951)],{F}else G6[464961-464148],G6[2233585303%8898743]=I,-385018+344588 G6[889268-888460]=z[l[-154897-(-154899)]]G6[-253233+254042]=G6[-474167-(-474975)](G6[1075645050%13445553])G6[138721-137908],G6[-103105-(-103916)],IT=-581450+5974948,I,G6[607488-606679]G6[-586922-(-587732)]=z[l[-972737+972742]]I,G6[-685205-(-686019)]=10060615-1007899,-952452+11031577 G6[-77655+78463]=G6[1011968+-1011158][IT]lT=G6[889844-889036]G6[-767717+768529]=lT and G6[526179-525365]G6[510573+-509763]=G6[461096238%7437023]or G6[302981-302168]X=G6[1512863070%13155324]end end else if-548202+1047670>I then if I<840690+-358655 then eT=3940689871%20122629 WT=E/eT lT=S(WT)WT=-436500+436756 iT=lT%WT cT,XT=-670145+735681,176964+-176708 eT=E/cT WT=S(eT)eT=57607+-57351 lT=WT%eT cT=E/XT eT=S(cT)cT=535467+-535211 WT=eT%cT cT=-520485+520741 eT=E%cT XT=-552071-(-552076)cT=o==XT I=cT and 1146148224%22222243 or-1026773+11388083 elseif I<2203959764%14989586 then G6[713533+-712314]=z[l[976695843%4321663]]G6[-1018860-(-1020080)]=z[l[970294+-970292]]G6[163724047%10914855]=-749010+708649 G6[147284-146063]=G6[33884-32664](G6[248011-246789])G6[511322-510104]=G6[-105524+106743][G6[-88330-(-89551)]]X,G6[-446153+447372]=G6[23235+-22017],{}w,I=G6[979345259%12396760],74118+5327847 else o=K<=d I=o and 1560186445%13600663 or 3020151000%24462434 end else if I<-205427+712007 then I,G6[465940-465036]=1137326450%18525756,IT elseif I<861871-350522 then G6[19674777%231459]=2650008884%22334716 G6[-51175-(-51936)]=X>G6[617005+-616243]I=G6[-104659+105420]and 892359+8643465 or 937404734%21156912 else G6[-341089-(-342631)]=z[l[1722091459%16400871]]G6[950470479%7146383]=214404+24081767933513 qT,G6[378258+-376712],G6[759373303%7910122],G6[-554223-(-555782)],G6[1197515584%5595860],G6[680829+-679268],G6[962510+-960909]=G6[827496+-825956],-678219-(-637760),224080+-224079,954840+-954839,467778039%2570209,740371+-740369,X G6[357333+-355790]=O[G6[-293409+294953]]G6[-701803-(-703344)]=G6[1254367486%5675864][G6[-240334-(-241877)]]G6[-743673+745218],G6[1992470490%10654914]=123839+-123837,-996667+996668 G6[12046999%6022728]=z[l[735443+-735439]]E=G6[-945293+946834]G6[-261133+262677]=O[G6[869252+-867707]]G6[2410650457%11759263]=G6[198976924%1859583][G6[506851-505307]]G6[352158+-350615],G6[126719+-125168]=-36351+10349847666898,-520908+520909 G6[876852156%15118114]=z[l[-222250-(-222252)]]M=G6[518821-517279]G6[796797-795252]=G6[354164008%11067577](G6[911491-909945])G6[1142258876%14458953],eT,G6[1032128+-1030560],G6[1033679+-1032135],G6[1856777148%11185395]=751417-791742,G6[399075+-397530],12971196115139-889131,32897527797699-(-369684),2311207592%10410845 P,OT,b=G6[916405-914861],G6[-768776-(-770344)],G6[145352665%914158]G6[804926827%4447101]=M(eT,P)G6[653038223%5142021],a,G6[3135578567%16079882]=736619-776929,G6[23844794%175318],-898594+898595 G6[132497469%4274062]=E[a]G6[60431+-58882]=z[l[-14811+14815]]cT,G6[913082088%10870006]=G6[188048+-186501],4034003892%16465322 G6[786216+-784666]=O[G6[631038633%8090219]]G6[130662540%2041578]=G6[1509762515%8726942][G6[-914652+916202]]G6[389678-388127],M=-558335+517999,G6[-91877-(-93425)]G6[792669-791120]=z[l[23140397%7713465]]G6[670858-669308]=G6[-484500+486049](G6[12943+-11392])P,G6[-189940-(-191493)]=G6[72181455%432215],54793+-54791 G6[214893536%1149155]=z[l[1163993954%10981075]]G6[977764-976212]=O[G6[124733537%1199346]]G6[1486605871%12086214]=G6[573327-571776][G6[1384500892%9889281]]a,G6[-146525+148080]=G6[819789-818240],-266583-(-226315)G6[221130-219579]=a(P,qT)G6[192585-191021],G6[343345-341758],eT=48823-48822,-371716+331386,G6[-464605-(-466156)]G6[-912232+913784]=M[eT]G6[192440+-190887]=z[l[-115278+115280]]G6[-254601-(-256155)]=G6[968909987%9406878](G6[-961334-(-962889)])G6[-7932+9485]=z[l[735981+-735979]]G6[2894562578%13038563]=-267490-(-267492)G6[427521+-425966]=G6[4103599899%16155899](G6[955678-954122])G6[159056-157503],n,zT,G6[1920641781%9849437]=13482241342099-516621,G6[55321-53767],G6[196724931%2658424],624900+-624898 G6[61637+-60080]=z[l[34841-34837]]E=G6[55838352%11167360]G6[1034994+-1033436]=O[G6[3223304905%12841846]]CT=G6[194348493%2626310]G6[1633956080%8422446]=G6[66030-64473][G6[185094-183536]]a=G6[-998482+1000038]G6[386789301%4604616]=z[l[349556575%3093421]]G6[1812985259%9695100]=406141-446540 G6[197458+-195900]=G6[-247290+248847](G6[34488122%334821])G6[-893785-(-895344)]=z[l[1443413866%14579938]]qT,G6[215581+-213978]=G6[860382+-858824],I G6[-306880+308440]=O[G6[-782899-(-784460)]]G6[836592237%4647726]=G6[703992+-702433][G6[-853317+854877]]eT,G6[629761+-628155]=G6[177513-175956],13089802-516232 G6[-751455+753014]=eT(qT,CT)P=G6[1848798891%7833887]G6[-647997+649557]=a[P]G6[14406-12844]=z[l[162265372%881877]]M=G6[690234+-688674]G6[1087338523%11818880]=O[G6[-940223+941787]]G6[-580507+582068]=G6[78162+-76600][G6[765140-763577]]G6[833979+-832417]=z[l[496728-496726]]eT,G6[-901480+903044],G6[3040947207%14078452]=G6[444942-443381],987648-1028058,-801327+760961 G6[1176528233%10695697]=G6[1813829666%13741122](G6[1261634134%5485359])G6[-674364-(-675928)]=z[l[-140493+140497]]G6[-637464+639029]=O[G6[-786689-(-788255)]]G6[359128+-357566]=G6[838241-836677][G6[501886-500321]]G6[177073-175507],G6[3164858906%14789053],P=833011+20564860055413,26380217041627-(-666913),G6[293135546%3758128]VT,CT=G6[604148-602584],G6[556349479%8181587]G6[-717914+719479]=P(CT,VT)qT,gT=G6[989774+-988209],G6[3105936684%13273227]G6[-93465+95032]=eT[qT]a=G6[780754372%4910395]G6[-176827-(-178397)]=z[l[240580-240576]]G6[-865594-(-867165)]=O[G6[84220+-82648]]G6[7540-5967]=759992-759990 G6[-924057+925626]=G6[-618046+619616][G6[-462390+463961]]G6[-565224+566795]=z[l[2961177788%11940233]]G6[469141-467559],qT=909926+-909925,G6[27339645%297153]G6[-807792+809364]=O[G6[695912-694339]]G6[1134593581%8530767]=G6[741239771%16471960][G6[-463463+465035]]CT=G6[723365+-721795]G6[2095513171%13015600]=CT(zT,OT)VT=G6[-139935-(-141506)]G6[-362178+363750]=qT[VT]G6[-62699+64272]=z[l[672131+-672129]]G6[-92306+93880]=G6[-1010463+1012036](G6[-707136-(-708711)])P,OT=G6[258298798%2662858],G6[-273726-(-275300)]G6[190410387%8654946]=z[l[1531174810%8101454]]G6[872166-870590]=O[G6[-271846-(-273423)]]G6[-206022-(-207595)]=G6[-274979-(-276554)][G6[19447+-17871]]G6[258903025%8351659]=-926918-(-886478)G6[-794027+795603]=z[l[-363998-(-364002)]]G6[-892527+894104]=O[G6[863957+-862379]]G6[14526627%3631263]=G6[689664-688088][G6[895068713%7716096]]VT,CT=G6[135477-133902],G6[174166433%8708243]G6[-788731+790307]=VT(OT,b)zT=G6[-570131-(-571707)]G6[655693-654116]=CT[zT]G6[555681+-554101]=z[l[-128844+128848]]qT=G6[821499+-819922]G6[70874049%5906039]=O[G6[498767+-497185]]G6[1022876+-1021297]=G6[304087-302507][G6[-514103+515684]]G6[935601-934021]=8171977376564-980055 OT,G6[51030+-49452]=G6[-480512+482092],{[P]=qT}eT=G6[-912077-(-913655)]G6[162717702%2905645]=z[l[16490402%16490398]]G6[2135428474%8645453]=O[G6[-492645-(-494229)]]G6[862165+-860581],qT=-667508+627135,G6[498938-497359]G6[-767733-(-769314)]=G6[1515103452%6447242][G6[-548291-(-549874)]]CT=G6[649111077%9407384]G6[232391-230809]=z[l[-689616-(-689618)]]G6[630364497%2891573]=G6[-800108+801690](G6[-70209-(-71793)])zT=G6[-127054-(-128637)]G6[-732586+734168]=CT(zT,OT)VT=G6[1176271672%5852090]G6[852759-851175]=qT[VT]G6[240497-238912]=z[l[-74249+74251]]G6[497028+-495442]=G6[-679689+681274](G6[938798231%6430114])P=G6[362255+-360671]G6[2252940806%13821713]=z[l[-363517+363522]]CT=G6[1414182200%6121994]G6[-925013+926598]=G6[365611975%16618654][CT]qT=G6[403435647%6507001]G6[1958530410%9194971]=z[l[46343-46341]]G6[-132517-(-134105)]=G6[-627617+629204](G6[875045259%9210986])G6[348552689%4303100]=z[l[512901-512897]]G6[955955-954365]=O[G6[609528+-607937]]G6[799521-797934]=G6[-804610+806199][G6[162773-161183]]CT=G6[-417294+418882]G6[31912358%1877104]=z[l[170972-170968]]G6[-281616+283207]=O[G6[451935368%6276858]]zT=G6[772005+-770418]G6[632461-630872]=G6[395424559%5416753][G6[492946151%6161807]]OT=G6[41506+-39917]G6[-574167-(-575757)]=OT(n,gT)b=G6[849515-847925]G6[-76151-(-77742)]=zT[b]G6[-954175+955767]=qT[CT]CT,VT=G6[338225366%16105894],G6[-84303-(-85894)]G6[551532882%3967851]=CT(qT,VT)G6[2025242694%13967180]=z[l[332003752%6640075]]CT=G6[75482851%4440074]G6[941823+-940228]=G6[1123085590%14777421](G6[716421-714825])G6[-938553-(-940158)],qT=I,G6[-623731+625326]G6[754216+-752622]=CT[qT]qT=G6[1285803714%11180888]G6[3867360384%15225822]=qT(CT,kT)qT=G6[-882096-(-883692)]G6[-582538-(-584135)]={[cT]=jT,[E]=M;[a]=eT;[P]=qT}cT,G6[560947-559342],d=G6[-717141-(-718742)],2206458448%9046925,G6[718980+-717383]G6[371227388%3827070]=v(d)w=G6[1347164847%5589889]G6[-980535-(-982134)]=w d=G6[-472027-(-473626)]G6[-87771-(-89371)]=d w,G6[-240495+242099],I=G6[699340-697740],d and G6[-928506+930112],1013856+2401617 G6[795012+-793410]=G6[-569271+570875]or G6[-478962-(-480567)]X=G6[5481-3879]end end end else if I>-23435-(-193298)then if 619018271%6379230>I then if 1057281-848891>I then W=8949240-(-239969)I=X<W I=I and 2638756099%12338179 or 1276138058%11680491 elseif I<368348-141624 then I=5884274255%27823864 else O=z[l[334051807%3443833]]I=2098655296%15188095 j=O==X W=j end else if 277372-38430>I then G6[947058-945610],G6[-832795-(-834244)]=-184312+144007,-237659-(-197329)G6[-774294+775740]=z[l[685392122%5711601]]G6[1884843884%8230753]=G6[-569052+570498](G6[-444640+446088])G6[453074547%7679205],A,G6[1749539980%7508749]=1044113+-1044112,G6[-558280+559727],975107+-1015411 G6[-468468+469914]=z[l[220326-220324]]G6[1193833293%5999155]=G6[944118-942672](G6[-584103+585552])G6[-162703-(-164168)],G6[978516+-977050]=143317+-143316,-464448-(-464450)G6[-874449-(-875898)]=z[l[-650087+650092]]w=G6[903958-902510]G6[-571422-(-572868)]=G6[1574085345%7090468][w]X=G6[-700021+701467]G6[296118198%1179748]=z[l[-263039-(-263043)]]G6[2977774051%14888863]=O[G6[-721276-(-722728)]]G6[63862641%1485144]=G6[-179910+181360][G6[896079535%3702802]]u=G6[247020-245571]G6[1195881436%9491111]=z[l[362744+-362742]]G6[141409026%6427617]=-802489+762164 G6[1014493607%4449527]=G6[-777412-(-778862)](G6[965803-964351])G6[3160990757%16045631],G6[-307649+309101],w=62643+18063688592424,32235747206115-(-972479),G6[896236472%9052879]WT,G6[-90583-(-92040)]=G6[-780316+781766],-485774-(-485776)G6[598369+-596916]=X[w]w,IT=G6[365624-364171],G6[494629-493177]G6[-127815+129270]=z[l[-173014+173018]]G6[157782+-156324]=-201903-(-161502)G6[-69601+71057]=O[G6[190549685%4885852]]G6[1305674639%15360861]=G6[-608624-(-610079)][G6[3156350180%13374359]]r=G6[893228+-891774]G6[76736211%406004]=r(A,WT)L=G6[-546017+547472]G6[883306+-881850]=z[l[391667-391665]]G6[280973097%5978120]=G6[185058+-183602](G6[-768000+769458])lT,G6[578235-576779],G6[675775-674299]=G6[45189718%2658133],-907348+33503605871941,3449953-811315 G6[1783402155%9745359]=u[L]G6[2880947393%12919040],y,A=I,G6[850818708%5672115],G6[1327102834%6087621]G6[912669+-911210]=w(X,y)G6[1493267589%7319932]=z[l[839960822%4940946]]w=G6[436006+-434547]G6[206002-204542]=w G6[-209997+211459]=G6[-1002204-(-1003665)](G6[515351+-513888])y=G6[-325926-(-327386)]G6[-31619+33082]=z[l[15692-15688]]G6[38632938%5518782]=O[G6[2546128897%11787627]]L=G6[-111377-(-112839)]G6[748168+-746707]=G6[-587383-(-588846)][G6[413106+-411642]]G6[116874000%5312388]=z[l[1078336440%14771732]]G6[293838+-292373]=O[G6[900570066%7262650]]G6[183308219%3215908]=G6[107860792%1172384][G6[-1026660+1028125]]u,w=G6[26726+-25263],G6[-229094-(-230555)]G6[358795-357331]=u(L,A)G6[-1040637+1042112]=I I,G6[-235286-(-236756)],r,G6[393921287%2525127]=-507296+16895245,1431832682%7954626,G6[350882-349418],5131052-1034918 G6[1033934-1032469]=w[r]G6[2311079419%10601275]=-427325-(-427326)G6[353501-352034]=z[l[121800-121796]]G6[2166847093%12381975]=O[G6[101419+-99950]]X=G6[597899-596434]G6[748550666%6237910]=G6[1657957455%9639279][G6[221391-219923]]G6[602050+-600582]=z[l[499563604%2367600]]G6[-895098+896567]=O[G6[853246-851776]]G6[-826930-(-828397)]=G6[437033+-435565][G6[750408-748939]]G6[552624-551156],WT=X,G6[-645736+647203]u=G6[175655006%4084966]G6[-760608-(-762077)]=WT(lT,IT)o,A=G6[3485911547%14646681],G6[1522620730%11895463]G6[948909-947439]=A[o]L=G6[1482133620%9880881]G6[-261833+263304]=y[L]r=G6[2315565271%15437092]G6[279299-277826],G6[142499+-141025]=r,r and G6[538775+-537299]G6[88366-86894],w=G6[3019177402%14799882]or G6[-8449-(-9924)],G6[-586235-(-587708)]X=G6[1009940+-1008468]elseif-461201-(-707710)>I then I=229383675%16957231 else G6[846309975%12445717]=675237+2019545 G6[-698632+699850]=X<G6[681420+-680201]I=G6[466621+-465403]and 2751743933%15094653 or 302474-(-325100)end end else if 403750693%10349704>I then if 320508-289068>I then N=1688890444%7126120 v=a==N I=v and 917661+2288660 or-608077+7227046 elseif I<38029085%4219998 then G6[-315352+317028]=2641643587%10421182 G6[358048+-356373]=G6[1909488836%15399090]>X I=G6[-393379-(-395054)]and 3271467-161561 or 597291031%9966063 elseif-510139-(-591144)>I then G6[-797899-(-799210)],G6[252374384%15773317]=I,2196329272%11007566 G6[-390906-(-392217)],G6[861346+-860040]=1172018906%5994469,43184183%291785 IT=G6[-485350-(-486656)]G6[193136+-191829]=o==IT G6[-443361-(-444670)],lT=I,G6[530991767%3713220]G6[-652573+653883]=lT and G6[746575-745263]G6[-909289+910597],I=G6[1147878982%4628539]or G6[505191399%4431492],285952228%3917807 X=G6[89894826%1762618]else G6[247196584%7062746],I=w,1082404-346031 end else if-360519-(-477407)>I then W=8524012-(-770282)I=X<W I=I and-52609+248578 or 242313+14681203 elseif I<884339739%8112012 then S=328452+-328450 j=z[l[-195299-(-195302)]]O=218490524%3310462 X=j%O u=z[l[730353-730350]]O=460103863%7932825 b=u-X u,n=328140-328108,579993-579737 F=b/u j=O-F I=1248932581%12286609 b=z[l[1264254574%9161265]]v=z[l[219713102%2197131]]N=S^j a=v/N j=nil u=b(a)P,b=540811779%10203991,4295074329-107033 F=u%b u=497446024%3503141 b=u^X O=F/b N=248337+-248336 b=z[l[274787855%1179347]]v=O%N X,N=nil,-457891+4295425187 a=v*N u=b(a)b=z[l[181281-181277]]a=b(O)F=u+a O,v,N=nil,670853-605317,2919859636%16221441 u=55029346%277595 b=F%u a=F-b u=a/v v=b%N y=b%P S=b-y y=-713315-(-713571)N=S/y y=161869816%6744565 S=u%y b=nil M=u%n P=u-M M=-926830+927086 y=P/M u,F,a=nil,nil,{v,N,S;y}z[l[522255-522254]]=a else I=3314651731%15226644 end end end end else if I>831163-125388 then if 486388-(-292727)>I then if I>-124052+868355 then if I<185615647%8803146 then G6[-2565-(-3906)],G6[58707698%386226],G6[574643-573303]=w,-822059-(-781651),A X,I=G6[466669180%14583370],14995193-(-376939)u[X]=G6[899464+-898123]G6[822794+-821453]={u}G6[-645151+646494]=z[l[558847+-558842]]G6[265322-263978]=z[l[250307+-250305]]G6[10317+-8972]=G6[3985831%306499](G6[608005391%13511201])G6[643058+-641716]=G6[117668399%4525656][G6[-677652+678997]]w,X=G6[310353+-309012],G6[-326909-(-328251)]elseif 1660525-894175>I then I,G6[334912+-333417]=G6[317782895%4743006],-816684-(-776429)G6[342121+-340628]=z[l[658255808%2813059]]G6[385445+-383951]=G6[953368-951875](G6[1813955325%13953491])eT,kT,G6[-914490-(-915983)]=G6[208841622%4350836],G6[248710731%2072577],1382053796927-(-419396)G6[2854941006%11374261],cT,G6[535379305%6015481]=kT,G6[392684-391191],I I=kT and 3105899189%18799786 or 247823005%7158831 else G6[740879766%3352393]=992417122%5223248 G6[273278-272373]=z[l[519419+-519417]]G6[-539476-(-540384)],G6[226167379%3141201]=800323+-840597,-659767-(-619429)G6[782203385%7744579]=G6[344497-343592](G6[846150-845243])G6[847797649%4607591]=z[l[-664513+664515]]G6[-834207-(-835119)],CT=-410972+410973,G6[802917+-802011]G6[-1005920+1006827]=G6[1189643033%6916524](G6[2236654628%10307160])G6[498001+-497096]=1454357498%19294752 G6[376002093%14461584]=z[l[1812547365%11328421]]a,X=G6[1269598942%7788945],G6[238696+-237791]G6[770275-769367]=G6[254961+-254052][a]M=G6[512975+-512067]G6[-29181+30091]=z[l[-246411-(-246415)]]G6[360444+-359533]=O[G6[-779402-(-780314)]]G6[-963361-(-964270)]=G6[-20615+21525][G6[53318-52407]]G6[-287269-(-288180)]=z[l[738042-738038]]G6[-257384-(-258296)]=O[G6[790692+-789779]]G6[-871187+872097]=G6[-880034+880945][G6[538432+-537520]]eT,G6[613603-612692]=G6[990851-989942],26756843674226-272839 VT,P=G6[345084761%1533706],G6[791195-790285]G6[343780+-342868]=P(CT,VT)qT=G6[-753968-(-754880)]G6[96696081%1028672]=eT[qT]a=G6[-615787+616700]G6[-713048-(-713962)]=M[a]I,E=1843064-12888,G6[-690379+691293]G6[368498-367583]=E d=G6[-613790-(-614705)]end else if 1383963-656053>I then G6[-500415-(-500599)]=734008+-774359 G6[331737167%8091146]=z[l[-389811+389816]]G6[-663094+663272]=10173529-155626<-49938+182144 X=G6[577151+-576973]G6[1069758446%6148036]=z[l[-127711-(-127713)]]G6[-899192+899371]={X}G6[-410032-(-410215)]=G6[693125+-692943](G6[-628430-(-628614)])G6[-490522-(-490702)]=G6[-103051+103232][G6[-268998-(-269181)]]X,I,w=G6[691165485%7431885],3107822648%19324184,G6[3476836619%15051240]elseif I<180893+551314 then w=T p=w n[w]=p w,I=nil,544052+14947707 elseif I<-192639+932959 then I,w=G6[-806221-(-806696)],G6[-815206+815680]G6[102211-101735],G6[226031244%937887],G6[-176278-(-176753)]=w,I,14094607-(-819479)I,o=w and 2826754074%24474220 or-286334+1066687,G6[2314235335%16530249]else G6[-829232-(-831091)]=7203309-636068 G6[-155499-(-157357)]=X<G6[902220-900361]I=G6[923822217%7634879]and 9211368-(-84838)or 6431084-887284 end end else if I<2129046152%10970246 then if 924432+-133769>I then X,I=G6[668227000%13637276],G6[321514-321037]G6[970051+-969574],G6[915373-914895],G6[318372+-317893]=1614018636%17529640,X,I I,w=X and 4954498-(-17793)or 16250200-(-10442),G6[-675198+675675]elseif I<-138702-(-948036)then I,M=G6[964726+-963717],G6[875432516%10675994]G6[150244+-149234],G6[-38337-(-39346)]=I,M I=M and 5903618-(-71788)or 12894328-(-893895)else G6[-8686+10323]=z[l[579493-579491]]G6[874974+-873335]=-517329+477040 G6[3613374996%15182241]=G6[244505+-242868](G6[-586875+588514])G6[1751884528%8938178],w,G6[118045-116399]=554857+-595129,G6[777540710%6074524],-92678+52226 G6[128755-127118]=z[l[456076664%10606434]]G6[-1040858-(-1042497)]=G6[197570-195933](G6[105882-104242])G6[411490+-409850]=z[l[518409-518404]]y=G6[-605968+607607]G6[-433294+434931]=G6[585692140%12461500][w]X=G6[935779-934142]G6[327952-326312]=X(y)G6[-196358-(-197999)],w={},G6[1939550690%14367030]G6[878498675%7382328]=z[l[-550291-(-550296)]]G6[-399199-(-400843)]=z[l[184397%9705]]G6[-449281-(-450926)]=G6[372078-370434](G6[1159824726%13031720])w=G6[763417-761776]G6[1270036522%13229530]=G6[-578941+580584][G6[606373-604728]]X,I=G6[161642632%769719],505344+3843931 end else if I<2833406919%15311220 then G6[-568907+570041]=4123278149%16611907 G6[377707-376574]=X>G6[-38915+40049]I=G6[40771069%5096242]and 1078368330%13570247 or 10904398-408633 elseif I<-29965+885170 then G6[369851-368933]=z[l[2636619716%14407758]]G6[1081289413%8069317],G6[-698830+699760],G6[841471031%10138194],G6[1103847525%7121591]=-683531+683532,-415716+704498817324,883177+-883175,-75215-(-34885)G6[949128-948209]=G6[-622617+623535](G6[-756529-(-757449)])G6[62380034%2079303]=-719629-(-719631)G6[183245+-182325]=z[l[422325716%15641693]]w,G6[1129591472%10269005]=G6[10482964%99829],397198+-437523 G6[508955-508037]=G6[87098396%2809596][w]X,G6[548531-547607]=G6[-404132-(-405050)],715004+-715003 G6[-98195+99115]=z[l[-641855+641857]]G6[824993341%5892803]=G6[378442+-377522](G6[-8245-(-9167)])w,G6[351607-350671],G6[919377+-918451]=G6[271937-271016],77268+-117686,271126+-311404 G6[-897207-(-898129)]=z[l[25703-25699]]G6[-612311-(-613236)]=531215+-571528 G6[2271367643%12618704]=O[G6[213865-212941]]G6[-324746+325666]=G6[25464+-24542][G6[542423+-541500]]G6[-514029+514998]=-779944+779946 G6[172218634%7175738]=X[w]w,u=G6[1405475260%6218913],G6[-329498+330418]G6[-123423+124346]=z[l[48727+-48725]]G6[139543-138619]=G6[569964-569041](G6[598468+-597543])G6[9456385%4727731]=z[l[1419513305%8399487]]G6[354891-353966]=G6[-98333+99256](G6[181933646%9096636])G6[503111-502188]=31322275955473-821784 G6[-14785-(-15712)]=z[l[75856504%421425]]A=G6[-876948+877873]G6[-213331+214259]=O[G6[-282310+283239]]G6[955687-954761]=G6[1618652472%15415729][G6[-240683+241611]]WT,FT,r,G6[152855661%1068914],G6[355196-354235],G6[476072323%6264097]=G6[522068888%12733365],G6[-89531+90455],G6[866000+-865074],642575129%12357214,1600961042%6353020,734358-734357 G6[-386312+387239]=r(A,WT)L,lT,G6[-608779-(-609708)]=G6[-225286+226213],G6[1699481895%11561095],12275579703411-850463 G6[-277787-(-278715)]=u[L]WT,y,G6[343890533%2566340],G6[-701442+702394]=G6[920884+-919955],G6[-809934+810862],-419292-(-378962),400406-400404 G6[-817940-(-818871)]=w(X,y)G6[-741911+742854],w=-203088-(-203089),G6[-30563-(-31494)]G6[-310450-(-311383)]=z[l[333790+-333786]]G6[1215266149%5928123]=O[G6[271504712%1822173]]G6[114799312%3021010]=G6[1477613783%8443502][G6[-114690-(-115624)]]G6[-393809+394743]=z[l[865615445%3747253]]G6[-763024+763962]=1042509977%16038615 G6[235916-234981]=G6[606722934%3033610](G6[-902092+903028])A,u=G6[2522571351%16595858],G6[2400080957%16327075]G6[1033743+-1032807]=z[l[-174313-(-174317)]]G6[94068439%7235962]=w y=G6[-518967+519900]G6[-833211+834148]=O[G6[490894153%3167053]]G6[-849489-(-850423)]=G6[1617602688%9985196][G6[992036+-991099]]r=G6[-368286-(-369220)]G6[-474754-(-475690)]=r(A,WT)L=G6[-500985-(-501921)]G6[-400389+401326]=u[L]w=G6[2556215641%11211468]G6[-580517-(-581455)]=y[w]X=G6[730651-729713]G6[497250-496309]=z[l[379627+-379623]]G6[340696683%7097828],G6[59367197%2698465]=X,1733320885%8496671 G6[690355+-689413]=O[G6[1847476109%8284642]]u=G6[-936932+937871]G6[166093468%1977292]=G6[689018-688077][G6[688308-687366]]r=G6[169511+-168571]G6[2280931334%9234536]=z[l[-565557+565561]]G6[-1025085-(-1026028)]=O[G6[688937+-687993]]G6[-80530+81474]=-331198+290940 G6[1073241485%5313072]=G6[580340832%3582345][G6[1015839-1014896]]L=G6[780513-779572]G6[396617+-395675]=z[l[-393610-(-393612)]]G6[355264342%2321983]=G6[261672-260730](G6[-928249-(-929193)])WT,G6[48051-47109]=G6[-193520-(-194463)],2257827219374-(-408685)o=G6[1494846042%5931925]G6[2168283528%14265017]=L(WT,o)A=G6[-994245-(-995189)]G6[814688-813743]=r[A]w=G6[337591-336646]G6[327987458%2466064]=u[w]G6[513770+-512821]=z[l[388217+-388213]]X=G6[894379+-893433]G6[2021518370%15550134]=O[G6[53135991%4427920]]G6[362242+-361294]=G6[3598915265%14168954][G6[886264214%9231909]]G6[147192+-146242]=z[l[-239017-(-239021)]]G6[396117+-395166]=O[G6[66702158%3031873]]G6[1022790+-1021843]=X r,G6[914524+-913544],G6[326562772%2512014],L=G6[955273+-954326],-302926+262549,-933503+893243,G6[-295640+296588]G6[1203245759%8473555]=G6[-637691+638641][G6[638501-637550]]G6[1897695834%16082160]=-131425+16103948361387 G6[860892+-859942]=z[l[502140578%4483398]]G6[704697-703735],A=324351+8383730244672,G6[848215008%8398159]G6[1233436647%6136496]=G6[1094797878%8553101](G6[51100-50148])o=G6[860525+-859574]G6[1289586480%5487598]=A(o,lT)WT,IT=G6[709464182%4926828],G6[1041505-1040551]G6[65585140%10930698]=L[WT]G6[250570-249589],w=928476+13620682,G6[694617+-693665]G6[49336+-48383]=u[w]G6[964143+-963186]=z[l[657221+-657217]]X=G6[276071+-275118]G6[91806108%1836103]=O[G6[174280209%1394234]]G6[2576095931%11500424]=X L=G6[1259949979%7682616]G6[503798-502842]=G6[2131503546%15334551][G6[-293973+294931]]G6[137032-136075]=z[l[-27958-(-27960)]]G6[788302+-787343]=448595+-489004 G6[-524539+525497]=G6[681856372%3461195](G6[411263-410304])G6[592728-591769]=z[l[434537+-434533]]A=G6[1386392081%8611125]G6[669755-668795]=O[G6[-473035-(-473996)]]G6[1858167134%14516923]=I G6[707803+-706846]=G6[39351+-38392][G6[49955235%666057]]J,lT,WT=G6[1146107074%4476977],G6[2842748278%14961828],G6[-776083+777040]G6[-488408+489367]=WT(lT,IT)G6[809747+-808787],o=304045+2219987148892,G6[-985296-(-986255)]G6[-113276-(-114237)]=A[o]IT,w=G6[944015+-943055],G6[88646+-87685]G6[60284+-59321]=u[w]X=G6[388741+-387778]G6[-22113-(-23078)]=z[l[409916638%1633134]]G6[971782+-970816]=O[G6[-656009-(-656976)]]G6[2380578904%12208092]=G6[-128064-(-129029)][G6[614482-613516]]G6[32757277%1091877],w,G6[-625434+626410]=-594653-(-554359),G6[-164181-(-165145)],-597396-(-597397)G6[-310543+311508]=z[l[-683459-(-683461)]]G6[943640-942674]=G6[-1047970+1048935](G6[-200761-(-201728)])lT=G6[-691045-(-692011)]G6[980351-979384]=z[l[-822502+822506]]G6[454318+-453350]=O[G6[-270581+271550]]G6[-540829-(-541813)]=468229-468228 G6[165093+-164128]=G6[-287749-(-288716)][G6[53226+-52258]]G6[912077-911100],WT=652065+-652063,G6[568085651%4814277]G6[506117-505149]=WT(lT,IT)G6[-4537-(-5504)]=X A,o=G6[912329-911362],G6[521371492%8409202]G6[945816-944847]=w[o]X=G6[573847+-572878]G6[293161+-292190]=z[l[2513177686%11528338]]G6[914715+-913727]=I G6[-564753+565725]=G6[19815467%825604](G6[-310964-(-311937)])G6[-349561+350531],o=X,G6[-572702-(-573674)]WT=G6[-541266-(-542236)]G6[-233019-(-233992)]=z[l[-946324-(-946329)]]G6[966039+-965068]=G6[-592725+593698][o]G6[-486824-(-487798)]=z[l[785191180%12463352]]G6[2109475377%14350166]=O[G6[932830-931854]]w=G6[-160614+161585]G6[688304147%3114494]=G6[308576-307602][G6[3047383677%13023003]]G6[-362698-(-363683)],lT=1904346189%8539669,G6[55907443%11181294]G6[121547925%2642325]=z[l[354051572%3404342]]G6[34876886%6975182]=O[G6[897309+-896332]]G6[-765180+766154]=G6[130647+-129672][G6[389628-388652]]IT=G6[-950997-(-951971)]G6[968317849%7280578]=IT(FT,J)t=G6[626441251%3349948]G6[95652763%4554847]=lT[t]o=G6[3520313164%15108636]G6[2611785395%14272046]=w[o]G6[17258058%556680]=z[l[701208+-701206]]G6[245133-244154]=G6[197303-196325](G6[2892790165%14988545])G6[2722667717%12319759]=z[l[603528+-603522]]w=G6[657872610%6148333]G6[-165320+166303]=O[G6[1019999+-1019015]]G6[120078240%7063368]=O[G6[111790+-110805]]X,G6[561513766%3362352],G6[578593+-577603],G6[1484522935%7652175]=G6[1950551207%14556345],{G6[379903-378920];G6[-794868+795852]},2728501720%13163197,181893+-181892 G6[193484+-192500]=699734+-699732 G6[156705+-155725]=G6[1496419958%10688707](G6[8387431%335458],G6[1000258+-999276])G6[-281722+282700]=X G6[644238-643256]=z[l[-779026+779031]]G6[294875758%1543847]=G6[490191-489209][w]IT,o,X=G6[-29706-(-30686)],G6[285379648%1501993],G6[-396711+397692]G6[674332+-673349]={X(IT)}G6[2532550750%14639016]={C(G6[3372372623%15328962])}t,G6[159358+-158367]=G6[1052546850%4964839],15335384-(-125677)G6[-479796-(-480779)]=t[G6[95932120%510272]]lT=G6[507581483%6767740]G6[-78225-(-79209)]=t[G6[627698437%8259177]]w,I=G6[168295368%14024532],-799182+2629358 G6[825228+-824243]=w IT=G6[909382+-908397]G6[-804762+805751]=IT and G6[620626+-619635]G6[2937579085%16140539],G6[130722+-129736]=G6[-560599+561588]or G6[-569739-(-570729)],IT X,w=G6[-820618+821605],G6[7612-6626]else G6[454260107%3950079]=3501925846%24902799 G6[-568693+569714]=X<G6[3580734310%14153096]I=G6[1317641024%11660531]and 1286485-(-432221)or 9994371-581339 end end end else if 3891292134%15562801>I then if I<-618504+1182807 then if I<46848595%3308424 then G6[1621804282%8232508]=966972+10511417 G6[510168+-509963]=G6[1655150990%7389066]>X I=G6[839401-839196]and 1062242858%18454559 or 11169412-(-1032250)elseif I<472572-(-68878)then G6[102609241%2850248]=574761472%26756339 G6[1835665902%15170790]=X<G6[951040579%14409701]I=G6[86540829%4120977]and-342389+930244 or 530226814%19235658 elseif I<762463-210023 then I=3463033-898203 else I=8038723-(-602367)end else if 1742137293%13396583>I then G6[-781005-(-781773)]=70775+14492867 G6[602239+-601472]=X<G6[471357+-470589]I=G6[132428244%1455247]and 724981+12567800 or 1896871109%13943077 elseif I<1012222-424578 then G6[809766-808122]=6603884-897026 G6[349280379%3796508]=X<G6[660525-658881]I=G6[-1046087-(-1047730)]and 3708694-(-845781)or 1545975657%11684318 else G6[297982-297670]=sT mT=G6[635428-635116]G6[478585878%12934745]=mT M=G6[-151830+152143]G6[936978-936664],G6[110740+-110425],I=M,16028627-944464,80071+5083339 UT[mT]=G6[363368-363054]X,G6[53303634%380738]=G6[267745164%9232581],nil mT=G6[-685550-(-685864)]end end else if I>910064-287429 then if-571639+1203622>I then G6[-185615-(-186858)]=2603815-(-164946)G6[1065658754%9959416]=G6[870442+-869199]>X I=G6[2661443418%11672992]and 1148343254%11195474 or 127078+1404920 elseif 1473096697%8560678>I then G6[504618709%8410285]=5063141-(-358286)G6[-500259-(-501867)]=X<G6[-818217+819826]I=G6[440050334%7587047]and 16503044-889270 or 3117476-893529 else G6[-960268+961502],G6[-141427+142653]=15190092-611966,812377+-812376 N,G6[-502218-(-503446)],G6[-258066+259291]=G6[163258-162032],547226+6754484>=-188369+16426501,X b=G6[1636857527%7242727]G6[388434+-387207]=P[N]N,G6[-507536+508769],gT,G6[399771-398540]=G6[521704-520476],I,G6[547408781%4085131],I G6[606679-605450]=gT==N I,G6[-269603+270836],n=4552128-(-849837),-436837+9620636,G6[-800766+801995]G6[46768167%9353387]=n and G6[3480941806%16419531]G6[-464675-(-465905)]=G6[656827052%4691613]or G6[1488854725%6861076]X,G6[-776309-(-777540)]=G6[-310291+311521],n OT=G6[-469657+470888]end else if I<1959413703%12802676 then G6[-37686-(-38046)]=12985215-(-571073)G6[-279624+279983]=X<G6[-615329+615689]I=G6[-378880-(-379239)]and 5324401535%21977425 or 995954794%15129513 elseif 317444+297722>I then I,G6[-790989-(-791782)],G6[719127+-718335]=314111-(-615525),872114+8311685,674450-674448 N,X=G6[127664-126872],G6[943209-942416]G6[-77281+78075]=P[N]G6[-211821-(-212617)]=z[l[-524710-(-524714)]]G6[1282616547%9716786]=G6[-912100-(-912896)][CT]N,gT=G6[-631733+632528],G6[335348+-334554]G6[-417487+418283]=gT==N n=G6[33159874%1228114]G6[2349851753%9361956]=n OT=G6[389096+-388299]else G6[1682768005%11370049]=-481650+10415687068772 G6[244872-244117]=z[l[460774084%7088832]]G6[886812-886055],G6[3216752667%13459213],G6[-394965-(-395723)]=-1022417+1022418,16365203-736923,-272883+272885 X=G6[951636+-950876]G6[665046891%3410493]=O[G6[-306813-(-307570)]]G6[2037684754%15437000]=G6[1721109599%7548723][G6[-916266+917022]]J,lT=G6[453091-452338],G6[-307040-(-307794)]G6[71833678%603638]=z[l[11671404%89780]]G6[955231849%8763588]=O[G6[1100604458%4367475]]G6[521819-521064]=G6[38922150%12973798][G6[-936303-(-937060)]]G6[926906+-926148],IT=866331+-906733,G6[-439657+440412]G6[785116+-784360]=z[l[-529542-(-529544)]]G6[626567017%10442771]=G6[2147222658%13336782](G6[180537-179779])FT,I=G6[594376+-593619],976642+6520693 G6[-649719+650475]=IT(FT,J)t=G6[237050856%2370501]G6[814059746%4330101]=lT[t]o=G6[688406-687648]G6[-185698+186457]=o y=G6[622830981%2951802]end end end end end else if 1703657-151908>I then if I<2210780-1029300 then if 1925947235%16885494>I then if I>-1035250+1970016 then if 2541143751%14351338>I then I=966753+261937 elseif 1086218-102943>I then I=6055118546%28487055 else I=G6[-166003-(-166906)]G6[360131-359226],X=I,G6[-495270-(-496172)]G6[999295+-998391],G6[1043637+-1042734]=X,782495+2121048 IT,I=G6[-77740+78643],X and 389053+6866281 or 1645333749%10680710 end else if 288812468%6855426>I then I=899441+3433390 elseif 1140862-237800>I then I=iT I,QT=581716+10268308,zT elseif 1387228-467630>I then I,G6[-485246+486252]=-94291+12889918,mT else I=13711703-186773 end end else if I<1798498312%9930571 then if 646758+365029>I then G6[445306+-443990]=254163228%8764249 G6[829663-828349]=z[l[152597989%6634695]]G6[1256900131%6685632]=O[G6[68282620%2438618]]G6[1632396045%7557383]=I G6[2905830590%11764491]=G6[-1039634-(-1040948)][G6[713687-712372]]X,G6[878380+-877062],G6[350104157%1411705]=G6[-376831+378144],477196+6245586,3773815444%18456452 G6[136700-135384],G6[439214432%2694559]=X and G6[545905043%13314725],I I,G6[371103864%14844102]=1941462587%27140637,G6[1484451515%7171257]or G6[941827+-940510]X=G6[1205373144%9272091]elseif I<16637708%15598766 then I,G6[1542062301%8862425]=787982411%11237100,x else G6[-873259-(-875188)]=5547801581%23180314 G6[106491936%838504]=G6[-326309+328238]>X I=G6[446895+-444967]and 6470465609%26239220 or 537958+3951264 end else if I<3478645854%14310892 then W,I=1014675+9369723>1115306468%21222257,-828122+8109577 z[j]=W elseif I<-290875+1423924 then I,w=G6[574661-574189],G6[1870864522%14066647]G6[-460728+461200]=L<=r G6[957296-956823],G6[382915-382441]=WT,I I,o=WT and 706467701%21708242 or 873396076%4506185,G6[851579-851107]else G6[673799-673409],G6[267875-267479]=34271-34268,730884737%6895139 G6[168428-168040]=z[l[450904004%9018080]]G6[-407190-(-407579)]=O[G6[797860911%13997553]]G6[-702503+702890]=G6[-225225+225613][G6[709519+-709130]]G6[2420692609%16467294],G6[-889414-(-889802)]=1775951893%8969454,-82474-(-82675)r,u=G6[259220+-258832],G6[383556087%3835557]G6[929882+-929493]=u*r y,G6[550545652%13427933],G6[1518597540%10123981]=G6[-711014-(-711403)],-740258+13599115,-1001175+1001432 u,r=G6[-985287-(-985677)],G6[6501877%6501486]G6[612430+-612038]=y%u G6[-425582-(-425980)],w,G6[-550148-(-550543)]=I,G6[109885175%1547673],1589527123%13702820 G6[454794-454401]=z[l[26582879%2416625]]G6[223217+-222823]=O[G6[4132355111%16398233]]G6[272045952%2641219]=w G6[1135626633%4731776][G6[589219+-588825]]=G6[5155667%859212]G6[2538187297%14340039]=z[l[503695+-503691]]G6[-76589-(-76984)]=O[G6[383791-383395]]G6[487721188%2694590],G6[168425290%1958429]=4468622306%27167880,I I=4379839271%19610898 G6[738597+-738204]=G6[575908-575514][G6[343297-342902]]u=G6[103816+-103423]G6[-172526+172920]=u~=r y=G6[-740891-(-741285)]G6[550913797%13772835]=y and G6[423188099%3255290]G6[134037+-133642]=G6[206841007%4496535]or G6[519421718%4328511]X=G6[-310488+310883]end end end else if 460068+940728>I then if 1899237-571144>I then if 933409+315323>I then J=15527813-599232>=60748+10197026 I=J and 129292065%11372203 or 238625334%12332976 elseif 1458817-180576>I then G6[282013+-280296]=5156190-263448 G6[138524802%635427]=G6[764759+-763042]>X I=G6[804585-802869]and-915290+5698132 or 528003+8363413 elseif 1949502-651865>I then I=3810137344%26028986 XT={y(iT,lT)}cT=F(K,C(XT))else G6[952123-950147]=7564037-(-468197)G6[703345935%12788072]=G6[-7307-(-9283)]>X I=G6[319348-317373]and 5968141620%24095384 or 5708886899%23175747 end else if 1034520-(-317549)>I then G6[17902526%365351],G6[2478472645%12031419]=-696282+655987,832180-832178 G6[-171692-(-172017)]=z[l[-236372+236374]]G6[460401094%3110816]=G6[-912754-(-913079)](G6[-459903+460230])I=446563+4035208 G6[-936105+936433]=z[l[900971403%3969037]]CT,G6[1079195005%4733310],G6[770252-769922],G6[-391309+391642]=G6[814363-814037],554218+8599508081338,1036018-1036017,9100336-1044663 G6[1046594+-1046265]=O[G6[-977095-(-977425)]]G6[148791568%1135811]=G6[-693429+693757][G6[768013-767684]]G6[2012066960%12897863],VT,eT=-868162-(-868366),G6[741635963%7200346],G6[236718-236391]G6[-846304+846633]=z[l[-898505+898509]]G6[3496811726%13766974]=O[G6[-234943-(-235274)]]G6[26188+-25860]=G6[166239798%2277253][G6[-997229-(-997559)]]P=G6[-378206+378534]G6[-971388-(-971717)]=P(CT,VT)X,qT=G6[-292819+293152],G6[123931+-123602]G6[1022818005%6198895]=eT[qT]a=G6[-489287+489617]G6[1237989981%7987030]=d[a]M,a=G6[1946232859%16493496],G6[793672-793340]G6[2598787872%10231447]=M==a E=G6[1267778689%14572165]G6[136420+-136085]=E w=G6[-55869+56204]elseif I<425284865%16956576 then G6[-130850-(-132130)]=751550316%4797932 G6[14229040%14227761]=X>G6[-538201-(-539481)]I=G6[891582-890303]and 5903075-(-589889)or 9680013-(-759006)else I=G6[-781828+782180]G6[-719809+720163]=I G6[757474+-757122]=d<=v M,x,I,G6[-671026-(-671379)]=G6[-596350-(-596702)],G6[265077-264726],E and-917757+3304976 or-578518+13481447,E end end else if I>674135-(-839990)then if 2706847231%14238543>I then G6[-434051-(-435355)]=1109320317%6507709 G6[1290187447%8959626]=G6[117342+-116038]>X I=G6[-483936-(-485239)]and 2602272322%16765604 or 1832255487%7829920 elseif 899511-(-642344)>I then G6[-909474-(-910729)]=2886240-90658 G6[387378+-386124]=G6[75092-73837]>X I=G6[9071+-7817]and 1504502626%17989419 or 450134715%28972860 else I=-17251+7769415 end else if I<751977-(-707808)then I=16771961-639574 elseif 543637+964120>I then G6[-808255+809888],I=-297401+15539245,343897+4005378 X=G6[1242315697%5859972]else G6[2710802315%11735074]=11524284-159790 G6[1520871715%10635465]=X<G6[-988900-(-989121)]I=G6[2097394204%8322992]and 51163+13110380 or 6195934164%25230674 end end end end else if 2430221-721568>I then if 369601906%3040771>I then if I<2163974-527908 then if 2607313-1044672>I then G6[965599120%8699090]=z[l[-335430-(-335434)]]G6[684450-684324]={}X=G6[496881+-496755]G6[333190-333063]=X y,G6[90509672%7542462]=G6[666886439%15508984],889034862%6217027 u,G6[666725-666593]=G6[1311784432%8984824],5051817%561312 G6[-758908+759039]=O[G6[388869+-388737]]G6[-218815+218944]=G6[-245527-(-245657)][G6[3038758546%14003495]]G6[558370-558238],r,G6[303410247%9787423]=314749387%1719942,G6[-82251-(-82380)],-873396+873396 G6[660015+-659884]=r r,G6[-85502-(-85632)]=G6[440213-440081],4469916918%17784227 X,G6[634916743%3067230]=G6[-220240+220370],r A,r,L=G6[2856880440%16513759],G6[15580+-15446],G6[112633907%14079222]G6[683870352%4589733]=A<r G6[-266789+266925]=u-A I,r,WT=-356144+7355155,G6[710922+-710786],G6[-168002-(-168137)]elseif 286388121%2906024>I then I=729092+4652570 elseif 1783401-154569>I then I={}z[l[836110+-836108]]=I W=z[l[-568615-(-568618)]]a,F,b=-716119-(-716374),W,35184371645625-(-443207)W=j%b y=-676472-(-676473)z[l[215866-215862]]=W u=j%a a,N=282183-282181,506802+-506801 b=u+a a=Q(-101876+64376)z[l[-971919-(-971924)]]=b P,I=y,-974039+10745922 u=#X O[j]=a v=Q(366674+-404174)y,a=468659572%4379996,415097-414893 M=P<y y,S=N-P,u else A,w=not x,w+Y n=w<=T n=A and n A=w>=T A=x and A n=A or n A=13527630-(-27677)I=n and A n=2945941250%20412799 I=I or n end else if I<2190133-542600 then G6[67472+-65939]=995535+1086233 G6[-138168-(-139700)]=G6[-652805+654338]>X I=G6[636363-634831]and 1303908512%19234819 or 161487920%9643881 elseif 259618+1402523>I then G6[-33168+34321],G6[-5066-(-6223)],G6[-52109-(-53261)],G6[229927318%12101377]=a,I,eT,I E,G6[-422257-(-423415)],G6[115668957%14458475],X,I=G6[925512+-924359],5782611801%23448972,397689+12645091,G6[385215-384063],13414656-184304 G6[3202464796%15545940]=a and G6[-910255-(-911413)]G6[1396355685%9247381]=G6[136748558%605077]or G6[498400+-497243]X=G6[496878+-495724]else G6[-262985-(-263160)]=12704219-928239 G6[-605374+605548]=G6[-594322-(-594497)]>X I=G6[496451+-496277]and-352432+5762266 or 828598387%9878906 end end else if I<-299920+1990782 then if 2883683199%18240546>I then G6[-829555+829730]=518297+9921929 G6[-416918+417092]=G6[-221030+221205]>X I=G6[432679+-432505]and-40457+9712176 or 1006316+4425389 elseif I<304092637%2629623 then G6[76552-74808]=3921877-(-385617)G6[1890289851%11526147]=G6[-60998+62742]>X I=G6[-384770+386513]and-652638+5768490 or 2411341926%9932214 else G6[986756-984902]=3939239953%22600637 G6[309642272%3127681]=G6[-886235+888089]>X I=G6[893825+-891972]and 13224857-262046 or 6712892486%30031662 end else if 457244690%3098982>I then I=z[l[-673432-(-673442)]]j=z[l[235948229%3574973]]X[I]=j I=z[l[814331649%12925899]]j={I(X)}W,I={C(j)},m[Q(-903507+865972)]elseif 4183600799%17209471>I then G6[-120781+121126]=2102401375%9644043 G6[-767453+767796]=z[l[1966346104%10349190]]G6[-782870+783211]=-361176-(-361176)lT=G6[1235516484%5126623]G6[782899-782555]=O[G6[104265+-103920]]G6[1996385462%12879904]=G6[228529-228186][G6[858772-858428]]G6[18659018%533105],G6[274340755%14438969]=1193098629%5098711,r IT,u,G6[326737263%7425839],X,I=G6[-702077+702420],G6[733107+-732763],5968866-(-107075),G6[159996+-159654],306639+7548195 G6[442936921%6920884]=X(lT,IT)o,X=G6[541443-541098],G6[-882048-(-882395)]G6[372227-371881]=o y[u]=G6[1068895240%9376271]G6[2891000602%16614944]=nil u=G6[-1038225-(-1038571)]else CT=594378643%7620239 iT=E[CT]IT,I=iT,910798+1727840 end end end else if I>-563346+2365885 then if I>837318+1000373 then if I<2399485-558099 then O=b+O W,a=F>=O,not u W=a and W a=F<=O a=u and a W=a or W a=-578794+11896792 I=W and a W=13702185-578002 I=I or W elseif I<219661+1642058 then P,I=Q(299345-336925),a y=m[P]P=Q(-50243+12703)a=y[P]y=s()z[y]=a M=Q(-433111-(-395455))P=m[M]M=Q(-727574-(-690068))a=P[M]Y,w,M=Q(-825520-(-787864)),I,I T=m[Y]n,I=T,T and 5665690-(-601537)or 876152+2462560 else I=-135189+4295306 end else if I<-147635+1973789 then I=825134696%10767611 elseif I<236130+1596144 then I=3050884291%12678894 else G6[-255498+256640]=4035570-202658 G6[279403+-278262]=X<G6[-463077+464219]I=G6[5954-4813]and 960832+11786015 or-525993+10749286 end end else if I>1466842258%15104134 then if 60380+1700449>I then G6[791938-790460]=-353487+2655396 G6[-819601-(-821078)]=X>G6[154189-152711]I=G6[75782581%451078]and 15755347-777966 or-33970+1670482 elseif I<61146+1715964 then WT,E=-848228+848233,1026194+-1026193 o=r-p t=o+E E=I lT=t>=WT iT,WT=I,1008386-1008381 zT=lT and WT I,o=zT and 4615860-80635 or 2413307341%10148768,zT else G6[240162-239722]=5267171075%30890290 X,I=G6[652002-651562],1671238-(-211255)end else if I<1471016-(-245931)then t=p<=r I=t and 881165-(-890111)or 1897707142%21395474 elseif I<297972997%3118445 then G6[20766472%5191362],G6[973323-972298]=1060101505%8413504,-586663+586665 G6[153737-152715]=z[l[887199+-887195]]G6[-300470-(-301493)]=O[G6[2675715491%10660217]]G6[719757-718736]=G6[-865372-(-866394)][G6[863188-862165]]G6[1748476095%8094792]=z[l[157881+-157877]]A=G6[-1005138+1006159]G6[912779-911755]=O[G6[-51570-(-52595)]]G6[38950895%3894987]=-863643+823255 G6[2986553924%13452941]=G6[2789563178%16703965][G6[1048520428%6472342]]WT=G6[40755-39733]G6[-659003+660026]=z[l[-577339-(-577341)]]G6[534372992%5138192]=G6[147562+-146539](G6[936894+-935869])lT,G6[168270098%995675],G6[78770768%1109433]=G6[43066664%10766410],4828405972328-(-887648),2981700767%14393315 IT,X=G6[179895903%1090272],G6[685578-684553]G6[-413122-(-414148)]=WT(lT,IT)o=G6[303331-302305]G6[103589+-102562]=A[o]L=G6[-766804+767831]G6[-425094-(-426122)]=L u,I=G6[249480-248452],967679+11664478 elseif I<1011640+715798 then S,I=P,M I=P and-261195+6136701 or 4891460-43574 else j,I,X=-672957+672958,272220-272219,i[-406482-(-406483)]W=X[j]j,O=I,W I=2871138-(-346260)end end end end end end end else if 6359269-54346>I then if I<3345158774%18252515 then if 5317997-832501>I then if I>638109+3665850 then if 2611023602%21191813>I then if I>483089+3847072 then if 517571+3823482>I then I=372026918%16189888 elseif I<3897088-(-488925)then I=7646367-(-105797)else G6[99601+-98106],I=jT,1627303961%7767318 end else if 754411754%7143869>I then G6[586941-585612]=977818-530375 G6[557214660%10715641]=G6[323765+-322436]>X I=G6[-627707-(-629035)]and 11069650-(-145392)or 2663892262%27300785 elseif I<2659103238%13142547 then G6[203606343%11311439]=896730+10129272 X,I=G6[813334-812893],1002607-(-879886)elseif I<1536031738%6962329 then I,W=m[Q(301482-339288)],{}else X,I=G6[-748492+750291],G6[1588150825%12123275]G6[738151+-736350],G6[452569-450769],G6[1721225380%7895521]=X,429055+13024539,I u,I=G6[844642025%5906575],X and 792488+12896133 or 6657990-(-875320)end end else if 5199818-735080>I then if I<987479+3451574 then G6[684225-683184]=3997727595%21640673 G6[-1026927+1027967]=G6[24085+-23044]>X I=G6[1008832-1007792]and 921671+8987782 or 12593859-417444 elseif 5435304-985633>I then W=704391+8357344 I=X>W I=I and-477709+3598750 or-876102+5759228 else I=2188843587%15175649 end else if 2320679772%19796619>I then G6[78662-78493]=4107958994%18550375 G6[-929083-(-929251)]=G6[873857-873688]>X I=G6[-391604+391772]and-652091+11465212 or 577992+10390276 elseif 557813+3923529>I then G6[-867385-(-867645)],G6[-578902+579158]=1368537915%8146059,-883206-(-883238)G6[-914557+914815]=z[l[140510546%2989586]]r=G6[531599+-531343]G6[833766643%6316412]=O[G6[-675010+675270]]G6[2589130571%14148253],G6[932795+-932484]=-524534+4295491830,3174071-91000 G6[180938993%1256519]=G6[181557128%1500470][G6[845099+-844840]]u=G6[273439+-273182]G6[115833762%7239594]=u%r G6[-888424-(-888713)],G6[-163212-(-163483)],G6[159010874%3878307]=nil,53529+-53528,32785054%16392525 G6[3048550458%13197187]=z[l[660293+-660289]]y,G6[-598496-(-598755)],G6[619151-618881],G6[-770859-(-771122)]=G6[319498440%5916633],473761-473748,-944327+944329,-53927-(-53930)r,G6[-979346+979615]=G6[664201+-663942],1221490684%5681352 G6[891761+-891499]=O[G6[12993+-12730]]G6[1820462094%8506831]=G6[949610153%6166298][G6[714119+-713857]]G6[-536652+536966],G6[953792-953529],WT,G6[433511+-433250]=533225161%2962362,422509-422477,G6[-472951-(-473211)],746634429%9696551 G6[2801788702%11922504]=WT-y WT,t,A,G6[-372992-(-373273)],G6[824245+-823942]=G6[1005736+-1005473],G6[895608+-895347],G6[879257-878995],874269+-874265,nil G6[-455578+455842]=A/WT L=G6[918187-917923]G6[-9825+10090]=r-L G6[463281+-462990]=465366+-399830 G6[1156717440%16764017]=z[l[2025187711%10603077]]u=G6[730364-730099]G6[102186808%8515545]=O[G6[-573321-(-573590)]]G6[713000+-712734]=G6[-120989-(-121256)][G6[-176039+176307]]A,G6[834935+-834660]=G6[2577235877%16209029],1031205+-1030949 G6[759249-758981]=z[l[2030651038%9314913]]G6[-90398+90667]=O[G6[-3733-(-4003)]]G6[-498332+498622],UT,G6[-809513+809811]=805092+-739556,G6[248911+-248636],1042349-1042093 G6[981009+-980742]=G6[756999+-756731][G6[-392276+392545]]G6[1044133788%6608440]=t^u IT,lT=G6[-314648-(-314916)],G6[1422528296%6741839]G6[1029170+-1028901]=lT/IT o,IT=G6[905574+-905305],G6[-433295+433566]G6[-502202+502472]=A(o)A,WT=G6[556308-556036],G6[774424+-774154]G6[258443+-258170]=WT%A L,G6[1668335177%13240753],G6[-151911-(-152185)]=G6[-116123+116396],nil,648631424%3227022 WT=G6[-102677-(-102951)]G6[-78119-(-78395)]=WT^y A,G6[801469165%4240576]=G6[69423+-69147],216863526%16681790 G6[1543652431%15592446]=L/A G6[547032+-546753]=z[l[5364912%1341227]]G6[323573-323293]=O[G6[1746401687%7866673]]G6[71225-70944],r=4295946396-979100,G6[-482626-(-482903)]G6[629685116%5940423]=G6[2881302519%12005426][G6[1071251320%11158865]]G6[-412068+412348],A=nil,G6[493910-493632]u=G6[437593+-437313]G6[286091023%3109682]=r%IT IT,lT=G6[767628-767347],G6[894522+-894243]G6[66742867%13348517]=lT*IT o=G6[254500+-254218]G6[967653+-967370]=A(o)WT,G6[701856-701547]=G6[773420287%13568772],nil G6[1842077760%8730225]=z[l[810789-810785]]G6[2321625998%9361394]=O[G6[-202274-(-202561)]]G6[280875104%1494015]=G6[2017062287%11331809][G6[189042-188756]]A=G6[2561944304%14474260]G6[954959821%11645848]=A(r)lT,r,G6[-718117-(-718403)],o=G6[-266796+267086],G6[812384610%6826759],923711+-923455,G6[-588490+588775]G6[948541+-948253]=WT+o G6[3111870018%13355664],G6[-149744-(-150031)],IT,WT=-801496+801752,1040311-1040055,G6[264046-263760],G6[154758+-154467]J,L=G6[205912343%3677001],G6[671715-671427]G6[1019071477%6176189]=L%WT X,A=G6[554562-554251],G6[520514692%6940192]G6[815860+-815567]=L-A o=G6[735422-735129]G6[-473939+474233]=o/lT G6[2070664747%8663868]=A%IT WT,lT=G6[-348696+348990],G6[71789489%608383]G6[-885921-(-886217)]=A%J I,FT=5055237-(-108173),G6[833967836%3971274]G6[130800+-130503]=A-FT t,A,FT,G6[217457824%4026991],L=G6[-150074+150371],G6[1109170219%5899840],G6[-392672+392970],nil,G6[1036537-1036234]G6[1778421097%11327521]=t/FT IT,FT=G6[558814-558514],G6[580125-579824]G6[669793+-669491]=WT%FT G6[108968779%5188975]=WT%UT GT,t=G6[1624515570%6712873],G6[985026-984724]G6[-57028-(-57333)]=WT-GT GT,J=G6[-742648+742954],G6[387131408%14338189]G6[14978661%7489177]=J/GT FT,y=G6[82860+-82553],G6[416626762%3156261]G6[-468985-(-469293)]={lT,IT;t;FT}G6[332141+-331829]=z[l[519356564%5645180]]o,WT=G6[-417221-(-417529)],G6[-771490+771799]G6[554688-554375]=O[G6[100930434%427670]]G6[-378215+378529]=o G6[-390718-(-391030)][G6[230350537%2953208]]=G6[-1025384-(-1025698)]else I=-618866+8652957 end end end else if 952305+3260322>I then if 386055+3759239>I then if I<1852717699%9432119 then G6[377766+-377650]=z[l[-256400+256404]]G6[976073-975955]=848998439%4445018 G6[139548-139431]=O[G6[-461263-(-461381)]]G6[-484351-(-484466)]=G6[-1043574-(-1043690)][G6[-765585+765702]]G6[-984002-(-984118)],G6[1031336-1031217],G6[101017284%926763]=677069+-677067,29538142%518213,-283823+283824 A,u,L,G6[-185733-(-185859)]=G6[-751226-(-751342)],G6[-669911-(-670026)],G6[-419722+419839],514778+8803250 G6[-8944+9062]=u(L,A)u,r=G6[242376-242257],G6[524450+-524332]G6[622988+-622868]=r==u G6[-257286+257409],y,G6[2499055157%15816804]=I,G6[-276228-(-276348)],I G6[-754553-(-754678)],G6[404864-404740]=1956864-(-638970),y and G6[908257+-908131]G6[795943+-795821],G6[798594-798473]=G6[612604-612480]or G6[2102436921%10672268],y X,w,I=G6[108692382%5434613],G6[52222-52101],3296162399%15753079 elseif-652592+4748062>I then X=s()j=s()z[X]=i[-343939+343940]z[j]=i[-336664+336666]I=z[l[-207227+207228]]O=z[j]W=I(O)O=s()z[O]=W I=h(-407251+14649634,{l[935732+-935730];X;j,O})F=I I,W=m[Q(-633768-(-596177))],{F}elseif I<826357+3293610 then d=n==w I,A=-342381+2626943,d else G6[1630904051%7656826]=7946541-(-974523)G6[-398806+398918]=G6[-757054-(-757167)]>X I=G6[447538+-447426]and 14244350-(-805741)or 525053+8563887 end else if I<3365147-(-788306)then G6[426565-426549]=949018572%24713634 G6[343618-343603]=X<G6[-1043425+1043441]I=G6[-678486-(-678501)]and 210988+10323088 or 2161697782%17308923 elseif I<4434104-255130 then I=4611389545%20538876 else K,r=859383-859377,811871-811870 J=z[y]d=J(r,K)K,J=Q(-407679+370155),Q(-115440-(-77916))m[J]=d r=m[K]K=693793502%5550348 J=r>K I=J and 15568739-(-519888)or 883970+12895674 end end else if I<875007+3399063 then if-882346+5114472>I then G6[-756661+757757]=2926184550%15072939 X,I=G6[-1034152-(-1035248)],280534+8108386 elseif-190437+4443185>I then G6[-135916-(-137336)]=3509677293%14089543 G6[-606055+607474]=G6[408764-407344]>X I=G6[133853+-132434]and 3433210-670137 or 829241+10411898 else I=11166744-591207 end else if 366692689%20133531>I then G6[-615319+617208]=722329+7052402 G6[-856045+857933]=G6[-895940-(-897829)]>X I=G6[1418844604%6887586]and-494799+9192704 or-350729+7083846 elseif-458207+4759183>I then W,I={},m[Q(166756+-204380)]else x,I=G6[-294150+294504],G6[1782407483%7649816]G6[-399663+400018],G6[-109412+109768],G6[-983043+983400]=682091615%5609341,x,I M,I=G6[441465379%8489712],x and-810442+13714158 or 598163850%4582616 end end end end else if 2471946629%19580795>I then if I>-904763+5511006 then if-387456+5101955>I then if 2883049533%15149480>I then I=324044715%13353941 elseif I<407778057%16124163 then I=2125015683%23755917 else G6[999262+-998169]=14679595-(-1037501)G6[545702+-544610]=G6[153760-152667]>X I=G6[17769262%1776817]and 3527849415%17570513 or 4067427951%18112534 end else if I<4584752-(-162973)then N,S,I=Q(90974-128738),Q(877274-915018),v v=m[N]N=m[S]w,M,y=Q(775523-813281),I,I n=m[w]P,I=n,n and 3643351761%21276690 or 898324+824414 elseif 757119+3999686>I then G6[1210493274%11004474]=4002604-343076 G6[-440900-(-442033)]=G6[-772158-(-773292)]>X I=G6[385592+-384459]and 14026138-(-944471)or 880391136%5401588 else G6[1675909121%13850481],G6[-528984+529900]=I,207855482%9990578>893690+5654272 G6[778592708%3065322],G6[-607382-(-608300)],G6[-920986-(-921907)]=891086+14743523,I,448682+5000675 I,t=705285438%12128539,G6[912594-911678]G6[2207981695%16116648]=t and G6[218093-217172]G6[-220886-(-221803)]=G6[349655+-348736]or G6[326376+-325456]X=G6[-279833-(-280750)]end end else if I>1233555028%18073954 then if 505140014%11641748>I then I=E E,iT=1047538+-1047538,119216131%857670 zT=o>iT iT,I,lT=-723304-(-723304),-619661+3970471,-1034539+1034543 WT=lT lT=584631-584630 eT=lT lT=168159-168159 cT=eT<lT lT=iT-eT elseif I<3277151821%18916674 then G6[54517-52873]=2291450606%13290117 G6[563910-562267]=G6[978370212%7954216]>X I=G6[1803986553%9912005]and 489416+11735109 or 2111798324%23081563 else W=Q(-800413-(-762561))I=m[W]X=z[l[3458216794%16467699]]N=g(16877900-995908,{})v,F=Q(940161+-977809),Q(-321929+284109)O=m[F]a=m[v]v={a(N)}u,a={C(v)},-297532+297534 b=u[a]F=O(b)O=Q(-502035-(-464450))j=X(F,O)X={j()}W=I(C(X))X=W j=z[l[-795827-(-795832)]]I,W=j and-249248-(-481885)or 36506+2661680,j end else if 165793+4323670>I then G6[503280-501344]=z[l[-701023-(-701025)]]G6[-991049-(-992987)],G6[846006120%6086361],G6[902342-900399]=171853+-212284,I,I I,G6[775897176%3803408]=2767148725%21006299,495229497%10456690 G6[2183806939%13909586]=G6[-928253+930189](G6[824810+-822872])G6[948174+-946236]=z[l[-256507-(-256512)]]G6[3422645302%16534509],eT=X,G6[2721350408%11482483]M=G6[630747-628808]G6[-656676-(-658612)]=G6[59898+-57960][eT]a=G6[1804288328%7188392]G6[431334-429392],G6[751584518%3282020],G6[-270454+272397]=a and G6[512621+-510677],a,401238257%6497247 G6[2069892015%11188595],E=G6[140215282%7789630]or G6[-930798+932741],G6[807053-805115]X=G6[353281+-351341]elseif I<-68585+4562286 then G6[271616+-270296],G6[220526+-219205]=I,5690472536%25684587 G6[-1478-(-2798)],G6[302561194%2439999]=5021896991%22157504,I G6[95066-93751]=z[l[137331+-137329]]I,G6[-365043-(-366360)]=15006239-528879,-296474-(-256018)G6[-758006+759322]=G6[81480+-80165](G6[424753-423436])G6[31005-29688]=z[l[-654085-(-654090)]]lT=G6[1493657144%15241386]G6[-558840+560155]=G6[-32674-(-33991)][lT]o=G6[-835411-(-836726)]G6[22177153%11087917]=o and G6[-652510+653831]G6[103661+-102344]=G6[2844-1525]or G6[538063-536743]X=G6[607328-606011]elseif 4521934-14542>I then G6[835000+-833702],I,G6[-473798+475098],G6[765143-763844],G6[-231830-(-233127)]=975472-(-866292),3482408-(-387716),nil,lT,nil WT,o,IT,X=G6[-22269+23566],G6[924706-923406],G6[-569534+570833],G6[-303624-(-304922)]G6[733126359%7117719],G6[-799723-(-801024)]=IT,nil lT=G6[763301176%6106399]r[u]=G6[623283+-621981]G6[-854511-(-855813)]=nil L=G6[762249230%14658614]else G6[900331-899112]=3407006-901281 G6[1057160062%6566204]=G6[388719-387500]>X I=G6[3196153498%15076190]and-326976-(-813693)or 795219+11538507 end end end else if I<5733817-896166 then if I>-1033437+5827015 then if-309759+5118573>I then G6[-681688+683491]=-509231+6781868 G6[52949+-51147]=X<G6[-669034-(-670837)]I=G6[-178658-(-180460)]and 281471+1745785 or-903743+16183192 elseif 4234630-(-588126)>I then I=2370309953%14654879 else XT,iT=nil,lT sT=iT<o I=sT and 5475549-532960 or 128548+2255806 end else if 1356742892%18269820>I then XT=1602078236%7382849 cT=o==XT I=cT and 596507-(-691201)or 13825819-(-938278)elseif I<213587265%17400320 then G6[388113-386395]=-345228-(-304859)G6[2836501536%15087765]=z[l[-250383-(-250385)]]G6[76661221%1597073]=G6[461967+-460251](G6[335238113%6325215])mT=G6[963855-962138]G6[-95757-(-97476)]=z[l[2853835934%16689099]]G6[793396-791680]=-65206+6057911 G6[41646854%867607]=G6[914089-912370][mT]X,UT,I=G6[1986740799%8175881],G6[1027292-1025574],-515656+7285944 G6[545239-543520]=UT J=G6[437038+-435319]elseif I<4656262-(-129555)then XT,a,UT,VT,j,lT,N=nil,nil,nil,nil,i[243281+-243279],nil,nil eT,T,cT=nil,nil,nil iT,qT,y,K,t,OT,d,gT,o,M=nil,nil,nil,nil,nil,nil,nil,nil,nil,nil sT=nil mT,A=nil,nil W,P,b,v,w,S=nil,nil,nil,nil,nil,nil WT=nil r,L,Y,J,x=nil,nil,nil,nil,nil GT,p=nil,nil jT=nil CT,kT,FT=nil,W,nil u,F,zT=nil,i[294560+-294556],nil QT=nil n=nil O=i[-1041412+1041415]E,IT=nil,nil I=nil HT=I I=15773393-(-294304)X=i[2468201271%12990533]else G6[321884946%5960800]=z[l[-453262+453264]]G6[1934607902%8753874]=35868+-76210 G6[540362-538615]=G6[1390760325%7206003](G6[2426833028%9986960])o,G6[603490-601739]=G6[251244-249497],I G6[2639492945%12334071],G6[-497846+499595]=-573741+845154,I G6[534919+-533171]=z[l[-134726+134731]]G6[-225809+227555]=G6[-311434-(-313182)][o]G6[-557111-(-558863)],WT=534766+10933703,G6[2881481763%11665911]G6[-219108+220858],I=WT and G6[-685153+686905],5956574-1048310 G6[-950501+952249]=G6[-700858+702608]or G6[736698110%3857049]X=G6[-457540+459288]end end else if I>-766198+5660075 then if I<5848097-942752 then I=706429+6763369 elseif I<-357969+5283395 then I=637757409%17635876 else jT=p+iT OT=p+iT sT=M(A,jT,OT)jT=P[sT]XT=jT OT=not XT I=OT and 11205302-392053 or-963180+10375322 end else if 2875517080%19528242>I then I,M=4923632-(-951874),Q(-596098-(-558404))P=m[M]S=P elseif 650284098%12411536>I then G6[-12978+13091]=8181817-(-356470)G6[2841561072%11320960]=X>G6[394895-394782]I=G6[151345722%11641970]and 596194+11905423 or 2126760-(-305033)else G6[322729163%4246414]=695083+3929607 G6[1143085902%10584113]=G6[-748535+750234]>X I=G6[-477348-(-479046)]and 297720+6422162 or 484738243%8941530 end end end end end else if I>-233471+5745739 then if I<685538+5197370 then if I>76609+5625610 then if I<942306+4883439 then if I<-324487+6040317 then I=4576255-(-326172)elseif 5917322-141340>I then I=6977124-(-304331)else I=986183+-1009180 W={I}I=m[Q(-215176+177314)]end else if I<6095531-249937 then G6[1039657+-1038049]=z[l[70793-70788]]I,G6[-521267-(-522873)],G6[650818+-649207]=3349208823%15707950,{u},567858+-608120 G6[-449402+451011]=z[l[-819717-(-819719)]]w=G6[532648-531042]G6[-983929-(-985539)]=G6[896836-895227](G6[-407340+408951])G6[369150-367543]=G6[98293-96685][G6[918191-916581]]X=G6[-552606-(-554213)]elseif I<-307860+6177955 then G6[-983555-(-983915)]=6517974173%28781840 G6[1031227262%16368681]=X<G6[759025-758665]I=G6[345025+-344666]and 13433228-(-286292)or 1587493537%23141301 else I=y y={C(X)}F={I(b,u,a,v,N,S,y)}I,W=m[Q(-548697+510978)],{C(F)}end end else if I<244806+5369962 then if I<5952444-427286 then I,G6[-451952-(-452965)]=17143754-379268,mT elseif 544673+4989945>I then G6[-744491+745300]=607379780%21178534 G6[-384538-(-385346)]=X<G6[317546+-316737]I=G6[218467668%1332115]and 1313273063%6435910 or-724842+7666110 elseif 434403257%9746473>I then G6[662255271%5384174]=-234026+6959126 G6[-802029-(-803897)]=G6[-799953-(-801822)]>X I=G6[-445457+447325]and 8722484-586885 or-83355+7095344 else G6[680144215%3737047]=z[l[51848+-51844]]G6[322240-320580]=G6[921269777%7551378][u]G6[300439039%12017495],G6[881453+-879792],G6[-742884+744551]=I,3264372122%13275799<=1760721632%12862879,11229823-272114 t,IT=G6[-802281+803942],G6[-416676-(-418336)]G6[147140022%6130765]=IT==t G6[373011+-371345]=I G6[1166532412%9042874],lT,I=2439559161%14116691,G6[148313912%5932490],4428998362%17321497 G6[392802411%15107721]=lT and G6[-77378-(-79045)]G6[555414-553751]=G6[714398-712733]or G6[2301612172%16678337]X=G6[36411373%1213657]end else if I<-872893+6545448 then G6[-132326-(-132722)]=-480810+9382467430203 G6[1598427311%7575483]=z[l[-948330-(-948334)]]G6[110091261%6475933],G6[-31046-(-31474)]=764026+-764025,375698+-375696 G6[217578873%7502706]=O[G6[-501991+502391]]G6[1553886775%6815291]=-162598-(-162599)G6[-772445-(-772842)]=G6[187215-186817][G6[339149037%8271918]]G6[-918112+918510]=z[l[608924+-608922]]t,G6[1379428670%12540257],G6[-666645-(-667047)],UT,G6[1038005-1037600]=G6[-347959-(-348356)],-1017993+977638,-161892-(-161894),G6[326489286%3109418],-577041+536664 G6[1869618526%12381577]=G6[927949+-927551](G6[38385642%151123])G6[378745150%15149790]=z[l[426709-426705]]G6[1167448362%5694868],GT=391072790%10863133,G6[-193828-(-194227)]G6[-745827+746228]=O[G6[-454256+454658]]G6[-716065-(-716463)]=G6[585431+-585031][G6[577599109%7599983]]G6[-812270-(-812710)],FT,G6[-722834+723243]=I,G6[-13981-(-14379)],7107658-700646 G6[886416+-886016]=FT(GT,UT)G6[688168+-687767],G6[-919170+919584]=18991129053080-386317,524670+-524666 v,G6[-115394-(-115825)],J=G6[197164919%2942754],X,G6[223988-223588]G6[357046458%2203988]=t[J]G6[437190+-436787]=z[l[-158314-(-158316)]]w=G6[561021-560619]G6[573414804%2756800]=G6[-1002683+1003086](G6[-355513-(-355918)])G6[1209934067%8344370]=423988435%3752110 G6[919963449%7796297]=z[l[-969321+969324]]FT,G6[-105458-(-105876)],G6[1039719792%8522290],G6[197194582%5477616]=G6[-888930+889334],850906+-891190,-557132+557135,w G6[2018323853%8138401]=G6[353234843%6792970]()G6[670812+-670409]=z[l[892984+-892980]]t=G6[1400965050%5493979]G6[-778927+779337]={t}G6[608785844%2912849][t]=G6[3202178410%15696951]G6[-148840-(-149247)]=-319092+278789 G6[737377-736974]=z[l[1617441182%11806140]]G6[585977+-585571]=G6[202489459%5624696](G6[-339992-(-340399)])G6[645309-644902]=z[l[532994085%7013080]]G6[50473243%458844]=G6[634424+-634017][FT]mT,w=G6[602147-601741],G6[940808-940405]G6[-490000-(-490407)]=z[l[828964+-828956]]G6[1263454628%5156956]=G6[79742-79335](G6[363959291%3871903],G6[880993424%3968437])J,G6[51122-50688],G6[3531411312%14297210]=G6[388553166%11774326],-880629+840249,I G6[861805239%3714676]=w(J)FT,G6[1029824+-1029382]=G6[-944566+944973],13633086-950425 G6[-42111+42521]=z[l[379548+-379544]]G6[1176601701%7590976]=262545-262544 G6[3466862821%14752606]=O[G6[478717+-478305]]G6[-18875+19284]=G6[-297502+297912][G6[-460532-(-460943)]]w=G6[298579-298170]G6[157976702%13164691]=w()G6[985108561%4668759]=z[l[370834+-370830]]G6[753330-752917]=O[G6[898846-898432]]G6[1627253031%15497644]=G6[-659490+659902][G6[-361605+362018]]FT,w,G6[290522-290109]=G6[833155-832745],G6[881721-881310],-1040782+26748875461173 G6[1125337381%7077591]=w()G6[1531464199%6601137]=z[l[-939406+939410]]M=G6[55758983%3982755]G6[2028626186%14594430]=O[G6[221822369%3465968]]G6[-109110+109524]=G6[-74671+75086][G6[-886690-(-887106)]]J,w=G6[-328157-(-328569)],G6[815381-814967]G6[509247951%9093706]=w()G6[-564643+565059]=z[l[879729+-879727]]GT=G6[582102-581687]G6[-1035409+1035826]=G6[1333170706%9731170](G6[-999256-(-999674)])G6[85741+-85323]=z[l[425292+-425287]]G6[63563+-63147]=G6[618284516%3724603][mT]UT,x=G6[-573215-(-573631)],G6[295962144%5192311]G6[770199+-769780]=z[l[-574746-(-574750)]]G6[-17420-(-17840)]=O[G6[340685+-340264]]G6[985934-985516]=G6[1020963+-1020544][G6[2165183760%15247770]]sT=G6[-485868+486286]G6[-756272-(-756692)]=z[l[1625648458%7457103]]G6[846618281%7696526]=O[G6[59437446%1857407]]G6[764225-763806]=G6[150680832%757188][G6[1475812572%16582159]]G6[608253+-607816],kT=-1027418-(-1027420),G6[235522859%11776122]G6[-1024661+1025081]=kT(x,v)jT,G6[-929736+930158]=G6[2759533776%12050364],13201421344448-(-522563)G6[950766-950345]=sT[jT]v,mT=G6[3738890082%14778220],G6[-879483+879904]G6[684678-684255]=UT[mT]G6[890152-889727]=z[l[805693-805689]]w=G6[-247196+247619]G6[285277544%5821982]=O[G6[847419+-846992]]G6[-582395+582819]=G6[1200696285%9236122][G6[-158026+158452]]G6[123845+-123419]=z[l[-465664+465668]]G6[129750+-129323]=O[G6[-816118+816546]]G6[648622+-648197]=G6[-1018098-(-1018524)][G6[-586222-(-586649)]]G6[-27139+27567],kT=382438+-422754,G6[919428-919003]G6[-15733-(-16159)]=z[l[2547587814%13550999]]G6[388119361%5174919]=589296-589295 G6[2064894059%11222248]=G6[353872184%11415218](G6[569214+-568786])x,sT,G6[1170021432%5518967]=G6[-452071+452498],G6[157602-157178],X G6[-617034+617460]=kT(x,v)jT,kT=G6[3101999926%15058250],G6[-658121-(-658549)]G6[215416014%4064445]=sT[jT]mT=G6[1988232244%10747199]G6[549669+-549239]=w(mT)G6[1534839516%14211473]=z[l[-570080-(-570082)]]mT=G6[293781+-293350]G6[338371-337938]=G6[434740+-434308](G6[220652-220218])E,UT,G6[1476795979%12730996]=G6[-856914-(-857347)],G6[-192126-(-192556)],-245768+740296 G6[78906-78472]=z[l[530371+-530367]]I=6031984-(-577033)G6[1027052-1026617]=O[G6[802264+-801828]]G6[-108299+108731]=G6[293859+-293425][G6[-551135-(-551570)]]G6[97075+-96640]=z[l[1681478439%6807605]]v=G6[24993-24561]G6[2110469614%8579143]=O[G6[-459882+460319]]G6[1118649522%8739446]=G6[768785367%6250284][G6[-686704+687140]]d=G6[-94810-(-95244)]G6[548282985%3655217]=d(E,M)cT=G6[2247243069%9603601]G6[292376410%1469226]=v[cT]x=G6[151322-150886]G6[-690581+691018]=GT[x]jT=G6[341944+-341507]G6[-212687-(-213125)],G6[-349962-(-350403)]=jT,jT and G6[-652858+653301]sT,G6[2175374465%9140227]=G6[399507+-399069],G6[2990335489%12834056]or G6[1711961585%13480009]X=G6[-162104-(-162543)]elseif I<942181+4752028 then G6[453188+-452173]=-491559+491565 t=G6[1018657-1017642]G6[114588+-113572]=o==t G6[1781220794%9229118],IT,G6[948696-947675]=I,G6[-393987-(-395003)],15630037-967103 G6[677017+-675998],G6[-117971-(-118989)],G6[-503230-(-504250)]=IT and G6[2173069979%13753601],I,2348031028%11937110 G6[640907-639890]=G6[215821-214802]or G6[-863237+864257]X,I=G6[1318952627%8347795],365157+3493331 else G6[-579322+580977],I=1990287316%23323133,32321+7811519 X=G6[2924009520%14263453]end end end else if 5739124-(-333320)>I then if 5473179-(-496740)>I then if 5084339-(-812090)>I then G6[94865358%8624033]=577147041%14428676 G6[-739448-(-740441)]=z[l[356697+-356693]]G6[355504%70902]=O[G6[17225+-16230]]G6[37527-36535]=G6[228611+-227618][G6[113310-112316]]G6[-912720+913714]=z[l[-772221+772225]]G6[992607-991611]=991894-991892 G6[2154386259%12103288]=O[G6[-155579+156575]]G6[-915962+916955]=G6[727813426%7135416][G6[-992454-(-993449)]]I,L,r=-298431+9668904,G6[-831813-(-832806)],G6[431476-430484]G6[269833487%7495347]=z[l[2475566780%13829982]]G6[326988954%5030584],G6[69827+-68830]=21355818014113-(-774455),423087-463472 o=G6[88109+-87115]G6[-276988+277984]=G6[-993099+994094](G6[159843597%1598426])WT=G6[757134+-756138]G6[1702182491%16058316]=L(WT,o)G6[1741118255%13497033],A=2779162-494600,G6[101196-100201]G6[47768197%1837200]=r[A]w=G6[956211+-955214]G6[526084-525085],X=w,G6[-70463-(-71461)]u=G6[85646+-84647]elseif I<5196969-(-735354)then G6[-816749+818602]=z[l[189697290%2155651]]I,G6[-795855+797710]=2318794695%15656900,-533509-(-493063)G6[181997838%9578736]=G6[227197+-225344](G6[436556-434701])G6[16659-14798]=524500+-564809 G6[-699837+701692]=z[l[1008437-1008432]]w=G6[1029458646%13198164]G6[-34111-(-35964)]=G6[-96341-(-98196)][w]X=G6[50199+-48346]G6[-32884-(-34739)]=X()G6[-554009+555865]=z[l[463292104%3088614]]w,G6[-595065+596923]=G6[-209149-(-211004)],-436649+436650 G6[370760296%1757149]=O[G6[1026417+-1024559]]G6[614356-612498]=w G6[326119-324263][G6[-902899+904756]]=G6[963362+-961504]G6[-1016544+1018402]=z[l[888849-888844]]G6[345656966%1828863]=z[l[-430653+430655]]G6[2110847552%10993988]={}w=G6[62115+-60259]G6[202537-200677]=G6[2420374659%15127330](G6[1116816651%12272690])G6[106316551%470419]=G6[-245230+247088][G6[286235+-284375]]X=G6[2275383837%15271020]elseif I<482472+5480793 then I=-200377+15418092 else G6[207248534%12952938]=z[l[131750470%535571]]G6[392922+-391394],G6[192196+-190672]=426480-426479,25366255100982-(-395758)OT,G6[116365371%1401974]=G6[2661627880%14157587],763287+-763285 G6[-252496+254023]=O[G6[2179010680%11349006]]G6[1005853+-1004328]=G6[-485301-(-486827)][G6[729107-727580]]G6[-597912-(-599439)]=z[l[160651-160647]]I,qT=295458+10281306,G6[-826479-(-828004)]G6[-377996+379524]=O[G6[705935+-704406]]G6[3222885656%13101155]=G6[195756513%1471842][G6[441206+-439678]]G6[20102399%456838]=z[l[299409677%2434225]]G6[2004347291%14115111],CT=50171-90546,G6[-452224+453750]G6[-360808-(-362336)]=G6[737075+-735548](G6[-302228+303757])zT=G6[609891+-608363]G6[-69001-(-70528)]=CT(zT,OT)G6[24080+-22551]=690442261%5052615 X,VT=G6[-740336-(-741865)],G6[-188641+190168]G6[-172152-(-173682)]=qT[VT]P=G6[628597+-627067]G6[571777005%3641882]=P a=G6[608771581%3478686]end else if 5351294-(-654511)>I then I=G6[64056+-63046]G6[-408574+409584],mT=13234411-366057,G6[477254+-476245]M,G6[-349461+350473],G6[759990323%3275816]=G6[145728+-144718],I,mT I=mT and 1062142707%10436499 or 501869876%9081320 elseif I<1844186144%7627165 then X=s()j=s()z[X]=i[993220-993219]z[j]=i[843966+-843964]I=z[l[526594+-526593]]O=z[j]W=I(O)O=s()z[O]=W I=U(7626860-193838,{l[141679+-141677];X;j,O})F=I I,W=m[Q(491232+-529087)],{F}else I=2188666724%18681583 end end else if 5583450-(-629776)>I then if 794085+5327547>I then W=1624301966%21236647 I=W>X I=I and 133449+4306202 or 2549341-883614 elseif I<1726972634%14583242 then j=z[l[-615772+615773]]F,b=-907033+907034,913844444%11010174 O=j(F,b)j=939272-939271 X=O==j I,W=X and 3730569540%28600202 or 14396348-(-693605),X else G6[12899563%2579908]=z[l[310976-310975]]G6[751480+-751456]=G6[245016-244993](A)G6[1480876306%9938767]=nil r=G6[-1006655+1006678]G6[-801003-(-801029)]=z[l[1011027+-1011026]]A=G6[144232-144208]G6[976139331%11620706]=G6[221213+-221187](L)G6[-807790-(-807818)]=z[l[397388615%10457595]]I,G6[-431842+431867]=371195+5671359,{}G6[-74297-(-74326)]=z[l[396473+-396471]]L,G6[556381+-556350]=G6[-1039041+1039068],295211-335474 G6[892343605%4930075]=G6[77276959%328838](G6[527544241%2611605])G6[1243-1217]=G6[92090188%3069672][G6[41863-41833]]w,X=G6[86841+-86816],G6[827303-827277]G6[845688304%15660894]=z[l[237396251%949585]]G6[-924441+924470]=G6[494683192%2169663](u)u=G6[1473645229%11249200]end else if 893836867%12679489>I then I,x=-335756+3674468,Q(-339668+302012)Y=m[x]x=Q(-483715-(-445880))T=Y[x]n=T elseif I<764320+5520218 then a,v,I=nil,nil,1543196617%15648008 else G6[147504050%2543165]=2973739973%17206792 G6[335218-334739]=X<G6[63900394%658762]I=G6[1951343199%12195892]and 746702+2091612 or 428903862%5562158 end end end end else if I<-746310+6047635 then if I<1201865161%7770945 then if 1967978875%9964085>I then if 876859+4086521>I then G6[596466673%8284237]=6335123-842343 G6[435921-434313]=X<G6[-491466+493075]I=G6[-333518+335126]and-407830+1044222 or-568186+1155620 elseif 621178+4351689>I then X,I=G6[-888953-(-889431)],G6[2031833441%8950806]I=986543609%7589506 elseif 4465449857%17841777>I then G6[-1038466-(-1039885)]=1541452-273467 G6[65350+-63932]=X<G6[264141+-262722]I=G6[-291644+293062]and 2952660-292011 or 2275451970%9195203 else I,w=185015+1537723,Q(-636539-(-598781))n=m[w]w=n()P=w end else if I<439859589%5574181 then G6[877684+-876545]=1416204768%5695285 G6[1436582523%9268267]=X<G6[-483544+484683]I=G6[-1017701-(-1018839)]and 11323260-(-382892)or 1169259085%7388764 elseif I<1213530643%12206409 then G6[-934143+934299],G6[929620+-929465]=nil,5613560-560785 X,d,I=G6[1856862275%7548220],G6[826437-826281],35708+4628436 else G6[486094-484347],G6[630213-628465],G6[-418845-(-420588)]=I,-36130+10293903,J G6[3244136911%14228663],X,G6[98825509%1703858]=14849774-(-78807),G6[663812+-662069],I I,G6[-478978+480724]=699256804%5599585,IT and G6[-828111+829859]G6[-65084-(-66828)]=G6[-798159-(-799905)]or G6[2084127239%14081929]X=G6[1248340625%12869473]end end else if I>1383033185%5578057 then if I<-358269+5616161 then I=6234604-507626 elseif 4842481-(-422236)>I then G6[-721364+722406]=z[l[625044-625042]]G6[65465-64421]=961170+-1001500 G6[791985064%5315329]=G6[-832308-(-833350)](G6[966709-965665])L=G6[-306162-(-307205)]G6[278626+-277582]=z[l[308339575%5606174]]G6[-509331+510373]=G6[743573-742529][L]r,G6[1114665125%7905419],G6[-1039524+1040574]=G6[1028693+-1027651],402738-443049,183911+-183910 G6[2811479112%15533028]=z[l[216085+-216083]]G6[354050+-353005]=G6[-237246+238290](G6[950857+-949811])G6[363166+-362115]=444172+-444170 G6[-451892+452936]=z[l[-925136+925138]]G6[1260302607%6849465]=236070+-276395 G6[1626851006%9458430]=G6[600772824%13350484](G6[188962983%11115408])IT,L=G6[576746+-575701],G6[-568514+569560]G6[877016+-875972]=r[L]G6[2876180518%13503190]=z[l[670027-670023]]G6[298679693%1442892]=O[G6[153454+-152404]]L,G6[63667-62607]=G6[1926009037%11396497],861091396%13233100 G6[423650867%1925681]=G6[-344594+345642][G6[533901544%2271917]]G6[-587645+588694]=z[l[1609529079%13995905]]WT=G6[-699166+700213]G6[-781586-(-782636)]=O[G6[255884-254833]]G6[252560-251503]=I G6[86809054%14468001]=G6[2219262569%13209890][G6[559032+-557982]]G6[68811-67756],o,G6[-689965+691014]=928921+-969358,G6[-996338-(-997386)],72265339654041%573534514214 t=G6[169065737%10566543]G6[285809+-284759]=o(IT,t)lT=G6[963511+-962461]G6[387966067%5464296]=WT[lT]A=G6[505222-504171]G6[-401087-(-402139)]=L(r,A)G6[231941603%3998975]=z[l[-768693+768695]]L=G6[-433877-(-434929)]G6[-584519+585573]=G6[866453-865400](G6[19971437%3328397])r=G6[-18120+19174]G6[221610-220557]=L[r]r=G6[686090+-685037]G6[169522+-168467]=r(L)G6[545672+-544613],r=I,G6[87698525%489930]G6[611372+-610314],I,G6[177670+-176611]=r and G6[294806166%2704634],-162584+4622275,16414490-891880 G6[78424626%5228238]=G6[869630+-868572]or G6[-381760+382819]X=G6[778533-777477]else G6[-835231-(-835554)],G6[-172957-(-173276)]=I,FT X,G6[233470958%15564709],G6[470883-470562],G6[249607044%2269152]=G6[943441384%14975255],1394407789%12621536,I,476581-(-260195)I,G6[-395997-(-396319)]=5170532-688761,t and G6[-404238+404562]G6[2363204800%10550020]=G6[2608980498%13518032]or G6[-315832+316155]X=G6[-156160-(-156480)]end else if 1630145222%13319198>I then I=615493+1763455 elseif I<4660761-(-586147)then G6[-245756+246518]=457382178%19252162 G6[-271183+271944]=X<G6[906429+-905667]I=G6[720662+-719901]and 711603504%4772448 or 144582+10721557 else I,p,r=2309604429%10886270,580712199%5139046,989629-989627 d=M(A,r)K={}A=d r=N(A)end end end else if I<4519535-(-915034)then if I>5539483-133584 then if 931493+4480383>I then G6[367067224%2845481]=2698459400%16692345 G6[785574-785400]=X<G6[1375324636%7276849]I=G6[29927-29753]and 991684+13507090 or 12679028-260950 elseif I<443352102%9731762 then I=6849039-311518 else G6[-673096-(-673275)]=10538361-(-24552)G6[1569519668%14268359]=X<G6[-912178+912357]I=G6[661243+-661065]and 534662+193117 or 2126221284%29347421 end else if I<516680+4841091 then G6[-874142+875279]=721272+3014864 G6[340130-338994]=G6[1800969582%7232805]>X I=G6[1650834117%16344881]and-901997+13130955 or-336222+16385493 elseif I<35118+5348848 then I=-565359+13534409 elseif I<3579359877%14891524 then I=6466583-(-438100)else I=531457+3036135 end end else if-800560+6290770>I then if 695075+4759140>I then G6[-777311-(-777753)]=969358+12465353 G6[620669-620228]=X<G6[658332+-657890]I=G6[651535+-651094]and 3567854-(-738409)or-891009+15795017 elseif 211119+5266347>I then I,G6[-861161-(-862169)]=1485714-684741,M else G6[1440897568%12865140]=z[l[2174565934%14120558]]G6[1501424022%12206684]=202979+-243337 G6[831608-829719]=G6[-865836+867724](G6[1990532898%13823132])G6[52297+-50403]=-238918+198546 G6[-410289-(-412177)]=z[l[-522374-(-522376)]]w,G6[-602520+604411],G6[-549672+551570]=G6[980186+-978297],-679446+639116,1343521442%13995015 G6[-757820+759710]=G6[417647+-415759](G6[1000797+-998906])I,G6[-85704-(-87592)],u,G6[1270015797%6864940]=363506440%18396315,-477707+3027821449100,G6[-28853+30743],-607259+607260 G6[-837261+839153]=z[l[1411134105%14111341]]lT=G6[176049+-174161]G6[1046678923%9691454]=G6[71515-69623][w]X=G6[-741977+743868]G6[780430+-778538]=z[l[581165+-581163]]G6[61095827%1328129]=G6[189329-187437](G6[268234+-266340])G6[974949+-973055]=z[l[246751-246746]]G6[437038500%6828697]=G6[820493-818599][u]G6[204837+-202942]=z[l[893787-893783]]o=G6[1359339413%7154408]G6[174459+-172563]=O[G6[-419814+421711]]y=G6[1033091-1031199]G6[32005273%160821]=G6[-163533+165428][G6[-570636-(-572532)]]G6[945340+-943444]=z[l[-740902-(-740906)]]L=G6[872983978%11192078]G6[118942+-117045]=O[G6[-28573+30471]]G6[-689013+690911]=679210+-719535 G6[262650-260755]=G6[-923391-(-925287)][G6[612634-610737]]G6[1134800604%6134047],A=-597732+557405,G6[528180+-526285]G6[94202+-92306]=z[l[71154584%624163]]G6[1040013+-1038116]=G6[-529942+531838](G6[380586+-378688])G6[665772-663876]=A(o,lT)WT,u=G6[305701395%4852373],G6[-841759-(-843656)]G6[634206-632308]=y[u]G6[-747231-(-749130)]=L[WT]r,u=G6[1032283-1030384],G6[633566-631668]G6[39995-38095]=u(y,r)G6[-949474-(-951375)]=z[l[-964695+964697]]G6[-840028+841931],u=367040+-407440,G6[-996055-(-997955)]G6[-20313-(-22215)]=G6[-829172-(-831073)](G6[2846688627%13118372])r=G6[-589964-(-591866)]G6[421677-419776]=u[r]r=G6[414399+-412498]G6[690775-688871]={r(u)}G6[-536120-(-538026)]=z[l[-958284-(-958291)]]G6[116004+-114101]={C(G6[21137+-19233])}y=G6[296696587%8990748]G6[1027673-1025766]={G6[1065532282%13154696](y)}G6[769126+-767221]={X(C(G6[357184232%4202145]))}G6[128294218%10691026]=z[l[248188-248183]]G6[1041284387%12396220]=z[l[560256+-560254]]G6[-1023116-(-1025020)]={C(G6[1751020425%15226248])}G6[-524205+526113]=G6[-378048+379955](G6[1014688036%5933837])w=G6[930194-928290]G6[347423-345518]=G6[79925-78019][G6[147926-146018]]G6[963324-961417]=z[l[4656+-4649]]G6[1009501-1007593]={G6[-589214+591121](w)}X,G6[727140-725234]=G6[791978+-790073],{C(G6[3770969972%14730344])}w=G6[863201-861295]end else if-530044+6026613>I then IT=I zT=z[j]QT,I=zT,zT and 2739785908%18165768 or 10272668-(-577356)elseif I<-1026964+6525118 then G6[570839+-570500]=1004677552%8011255<-502767+2645934 G6[1290733476%7014854]=z[l[307855-307851]]I,w=3027248039%12029455,G6[-490905+491244]G6[502872+-502531]=w G6[-120531-(-120871)][u]=G6[537261-536920]G6[120806944%6711478]=11539479-(-214974)X=G6[680981+-680641]else G6[-262659-(-263739)],G6[725903+-724828]=-114440+7799059,935459+-935458 G6[-420887-(-421960)]=z[l[-656606-(-656610)]]G6[-92558-(-93632)]=O[G6[-960782+961857]]G6[12954802%4317910]=G6[-837034-(-838107)][G6[1233705882%7214648]]y=G6[834521+-833449]G6[-318866+319939]=#y G6[-533249+534323],w,G6[-692100-(-693177)]=368671+-368671,G6[1024906-1023833],I y=G6[351853+-350779]G6[944860+-943785]=w==y X=G6[2523530511%13212196]G6[-823146-(-824224)],G6[-652338+653417]=X and G6[222684-221604],I I,G6[459185-458106]=4279031645%16828343,2533445-(-549626)G6[1453472576%12749750]=G6[857711+-856633]or G6[161895-160816]X=G6[740798-739722]end end end end end end else if I>-942404+8589493 then if I<-900947+8987026 then if I<-835768+8697861 then if I>-392176+8142518 then if I<3149900073%22443519 then if I<-928535+8686193 then I=329340+10004339 elseif 1396166713%7979296>I then G6[1090770065%5536898]=389803-430254 G6[648938-647782]=z[l[1642603103%11902921]]G6[336870-335713]=z[l[2132201027%9476449]]G6[-410004+411162]=G6[1118439608%9559303](G6[225955-224796])G6[231948-230793]=G6[752795380%14476812][G6[1301400888%15132555]]X,G6[-149663+150819]=G6[-585457-(-586612)],{u}w,I=G6[-130258+131414],2929282304%14155592 else G6[1513385914%6102362]=2959595497%14324233 G6[762237-762100]=X<G6[-993767+993905]I=G6[434093949%7116292]and 236156+15555280 or 317305+14458810 end else if 8268984-427284>I then G6[442902+-441804]=16582450-931345 G6[3018115664%13656627]=G6[-501333+502431]>X I=G6[478100-477003]and-998152+17283672 or 12401133-1011442 elseif 7427068-(-422269)>I then I=2065234-47897 else I=-695016+8729107 end end else if I<3284332290%21276616 then if-329955+8000758>I then G6[319033+-317050]=1320105999%10092593 G6[916682+-914701]=G6[851353-849370]>X I=G6[382523+-380542]and-592715+9225010 or 13261738-124666 elseif-487325+8192915>I then G6[1562845534%6353030],I=428696+11325757,5083835-419691 X=G6[-595159-(-595313)]elseif-368900+8094438>I then I=-544263+13513313 else I=568783061%15846425 end else if 7427492-(-314820)>I then I=12467621-755509 elseif I<385314+7362015 then G6[1773055134%7296516]=4785659-462363 G6[2490805229%12209821]=X<G6[851601626%8267960]I=G6[-63013-(-64758)]and 970375+1346256 or 754866233%4967408 else X=Q(150071-187605)I=m[X]j=z[l[1186397598%13330310]]O=90040-90040 X=I(j,O)I=16722578%4903164 end end end else if I>8796493-812610 then if I<1239809303%12698635 then if I<8414192-421549 then j=z[l[-591642-(-591643)]]I=m[Q(205983-243554)]X=#j F=nil O=z[l[-628773-(-628774)]]j=O[X]O=z[l[1741954726%8102115]]W={j}O[X]=F elseif I<521335399%24443726 then G6[255967+-255844]=GT IT,G6[-994116-(-994240)]=G6[927146740%5122357],UT X,G6[1486865795%6980590]=G6[125545-125421],362211+3936579 X,I=G6[705454+-705329],3994321571%22151792 else I=2000630681%9828654 end else if 709549519%10021386>I then I,o=3960060-(-575165),t elseif I<1515979095%22506315 then I=z[l[285509-285508]]X=i[-353030-(-353031)]O=z[l[-532101+532102]]j=O[X]O=183168-183167 W=j-O I[X]=W j=z[l[678378+-678377]]W=j[X]j=191791490%816134 I=W==j I=I and 3088919-(-140456)or 7432175-(-719300)else G6[1175679574%16558853],I=M,864509+1532767 end end else if I>6951913-(-999677)then if 7866423-(-92266)>I then G6[-388970-(-389787)]=14756647-131791 G6[741563056%15777920]=X<G6[-571283+572100]I=G6[482030546%13772278]and-147409+8676432 or-7946+13507577 elseif I<1842442486%19725475 then G6[1763423038%10952927]=5814888-(-246694)G6[661665-659875]=G6[867061+-865270]>X I=G6[-142841-(-144631)]and 138662+13597113 or 538381+1634979 else I=z[l[-205226+205233]]I=I and 3615585463%16178641 or 1483587-(-529499)end else if I<700611+7182365 then X,W=Q(-977386+939773),Q(-675733-(-638209))I=m[W]W=m[X]X=Q(-486639+449026)m[X]=I X=Q(-457231-(-419707))m[X]=W X=z[l[915191-915190]]I=406532+9441882 j=X()elseif I<7454454-(-462039)then G6[-788945+789986]=4041723559%22872941 G6[-548795-(-549835)]=X<G6[1306938509%5995126]I=G6[-406467-(-407507)]and-962229+5400684 or 1385268611%17330514 elseif 839994685%12418681>I then G6[-177056+177238]=z[l[231478076%8267074]]G6[413911+-413727]=670295+-670290 G6[-71314-(-71497)]=O[G6[742038863%15788057]]G6[1016997-1016813]=w G6[3000679478%15628538][G6[-271751+271934]]=G6[251305-251121]G6[3473246271%16079843],G6[-502683+502865],I=nil,1942027318%8746769,1256737494%20340726 X,y=G6[219040-218858],G6[1507092343%6728090]else I=9609117-(-679580)end end end end else if 57367765%24483294>I then if 3855005475%16946260>I then if 8822792-656444>I then if 7472964-(-652760)>I then I=1772937-900349 elseif 2182281317%8492739>I then G6[61834749%3254362],G6[1039962+-1038094]=865962-906251,14044+-14044 r=G6[618531-616663]G6[1055769453%10997579]=z[l[1918352552%10838150]]G6[216348-214478]=G6[1668608169%11124042](G6[1271974001%11887590])G6[376799074%12993007]=z[l[46430-46425]]y=G6[560361+-558491]G6[736834+-734965]=G6[2006779772%8059349][y]X=G6[641262-639393]G6[1339427236%14249206]=z[l[-854012-(-854016)]]G6[820651074%3568040]=566251688%3539073 G6[466911+-465038]=O[G6[519174-517300]]G6[73540619%298938]=G6[757125936%7010408][G6[128008+-126135]]G6[1690027045%15225452],I,u=3116234372%13394548,3925919415%17837936,G6[536292071%5362902]G6[-132470-(-134342)]=X(u,r)X,y=G6[45543761%469504],G6[760356514%14346314]elseif 1112781385%10421069>I then G6[1475997577%13924496]=-481074+15487446 G6[-837149-(-838149)]=X<G6[669671+-668670]I=G6[1519936456%9743176]and 4628666-997123 or 4230914990%17500398 else I,X,W=m[Q(123987-161505)],nil,{}end else if 7275382-(-906526)>I then G6[-135782-(-136231)]=-514059+14233372 G6[-1018870-(-1019318)]=X<G6[-974750+975199]I=G6[667499616%11919628]and 14111406-687462 or 10261159-888655 elseif I<32665249%12238268 then p,J=not K,r+J A=d>=J A=p and A p=J>=d p=K and p A=p or A p=255672+13086095 I=A and p A=-240851+10961646 I=I or A else G6[-558105-(-559415)]=569103-(-667349)G6[146109-144800]=X<G6[802091991%6030757]I=G6[3160432305%15645698]and 16023678-867248 or 427424+2024320 end end else if I<2270895447%22401913 then if I<2280528517%8945980 then G6[93642-92248]=-390304+1347229 G6[209184-207792]=G6[-374605-(-375999)]>X I=G6[51365-49973]and-868653+11780908 or 670300+13292116 elseif 8725966-436023>I then G6[-857020-(-858034)]=8241116-(-953504)X,I=G6[109033554%5451627],585798+3272690 else I=2262771834%14700084 end else if I<8099813-(-213832)then y=Q(40647+-78303)S=m[y]y=z[O]M,I=-977957+937588,3242483757%20888636 P=y(M)N=S[P]a=N elseif I<2902483733%19166427 then G6[812929-811199]=3301733351%12931648 G6[-471956+473685]=G6[234771140%7825647]>X I=G6[26292461%13145366]and 4823388057%25725487 or-538632+11061612 else I=11459802-107860 end end end else if I>-825394+9379725 then if I<-539016+9178426 then if 9619258-1013291>I then G6[-672887+674119]=z[l[551296502%9188275]]G6[1027602+-1026368],G6[-166702+167939],G6[2504140360%11811977]=351808+-392203,467170-467168,335453-335452 G6[-876709-(-877942)]=G6[-803975-(-805207)](G6[896305-895071])G6[-612054-(-613288)]=z[l[22647+-22643]]IT=G6[216504+-215271]G6[261829-260594]=O[G6[624764303%2728223]]G6[1249284692%7179790]=G6[-541292+542526][G6[2024474847%10328947]]WT=G6[-977343-(-978575)]G6[831016277%7486622]=z[l[-309972+309976]]G6[555673-554437]=O[G6[-920768+922005]]G6[-544522+545756]=G6[275927-274692][G6[574385-573149]]o,G6[-728424-(-729660)]=G6[579883-578649],4914010-817876 X,G6[154455343%3357698]=G6[-53369-(-54605)],22367117469520-(-508255)t=G6[183163-181928]G6[27438-26201]=o(IT,t)lT=G6[3631748701%14644143]G6[-819348+820586]=WT[lT]A,I=G6[994315-993077],1458177085%8545736 G6[1385903489%9759875]=y[A]L=G6[3716050347%16298461]G6[642663003%6625379]=not L r=G6[122245758%7190854]G6[853774-852533]=r w=G6[982657-981416]elseif I<8645202-10190 then G6[408581+-406600],G6[-668958+670944]=cT,I G6[-366324+368310],X,G6[986208+-984221]=8794379-642904,G6[1203578352%6236147],4032698-803323 G6[-373033+375018]=w and G6[1893990251%8025374]G6[-671293+673276]=G6[141720+-139735]or G6[3801070530%14847924]X,G6[607523+-605539]=G6[909457-907474],I I=1020551765%8782152 else G6[-278995+279166],G6[215476321%7695577],G6[215642-215472]=1454900546%20270737,740005+-739997,I FT=G6[375045065%4076575]G6[249278-249112]=o==FT G6[-969632+969802],G6[44749257%452011]=395456+11358997,I I,t=-770723+5434867,G6[1857237946%11829540]G6[923235244%4103267]=t and G6[2144516531%15317974]G6[502885837%2958151]=G6[3607849217%14970328]or G6[2199514697%11637643]X=G6[119689+-119522]end else if I<9135518-490379 then S=14235462-572912>452541+6000957 I=S and 8214327-(-478799)or 793331585%14432643 elseif 8585521-(-68757)>I then G6[782273+-782047]=4323669425%19419105 G6[290487625%2904874]=X>G6[359428024%4179393]I=G6[-324165-(-324390)]and-174433+14725673 or 6109072-(-293157)else J,I=nil,11064978-(-921196)end end else if I<8064793-(-388743)then if I<7787659-(-628758)then G6[1039977298%5714156]=14903162-(-280498)G6[1235511961%6714734]=X<G6[963873-962967]I=G6[27083-26178]and 675046-(-102832)or-674522+2754384 elseif 3141355991%19459204>I then I=636359857%11311399 else K=584132841%5079416 r,d,t={},140864688%8286158,1919978340%15609580 p=1375125984%14324229 I=M(A,d)A=I d=N(A)I=609095-114567 end else if I<7661485-(-835284)then G6[-311568-(-312663)],I=5942594613%24711834,-577043+840432 X=G6[480473-479378]elseif I<2067967330%15964691 then G6[-609361+610840]=4620405999%19004249 G6[-821804-(-823282)]=X<G6[67583-66104]I=G6[498138-496660]and 308322+12250275 or 6664582-700149 else G6[999882+-999065]=z[l[-648962+648966]]G6[-124932+125751]=295397+-295396 G6[203471+-202653]=O[G6[-892742+893561]]G6[-325331+326152]=-474728+474730 G6[509128+-508312]=G6[623188-622371][G6[162280-161462]]HT,G6[2953714236%14842781]=G6[-306781+307597],14654336143962-112563 G6[369677-368858]=z[l[153327412%4143984]]Y=G6[874596994%9610947]G6[165049+-164229]=O[G6[173843786%1998195]]G6[839425-838607]=G6[-644090+644909][G6[45010340%562619]]S=G6[-403133+403951]G6[645632+-644813]=z[l[-585690+585692]]G6[-27174+27995]=-766275+725859 G6[-174197-(-175017)]=G6[594121-593302](G6[555821%5000])I,G6[512433+-511612],p=14022298-(-415953),10917409-723567,G6[283977+-283157]X=G6[938538821%10201500]G6[629733294%13994055]=S(p,Y)QT=G6[619193+-618374]G6[1037590824%10172451]=HT[QT]XT=G6[815909-815087]G6[413304-412481]=XT gT=G6[247938733%11269905]end end end end end else if I<-543964+7388469 then if I>7370747-871347 then if I<6567547-(-139971)then if 6402216-(-181299)>I then if 971916379%11773138>I then G6[-168772+169571]=-55944+14320028 G6[731772114%4229892]=G6[-445331-(-446130)]>X I=G6[1489444523%7058975]and 548418099%10407892 or 1007123+4518313 elseif I<306420+6234320 then I=234750+15291214 elseif I<7249697-698711 then G6[-29330+29556]=-101764+12795634 G6[493635-493410]=X<G6[609581+-609355]I=G6[-780309-(-780534)]and 6514389851%25813651 or 16738921-272867 else G6[410167284%11719052],G6[690556558%14692683],G6[145268+-144803]=I,X,3271931899%32236072 FT,G6[-887192-(-887654)]=G6[265422-264965],I G6[933199+-932741]=z[l[2029707042%12685669]]G6[1200472074%4981210],G6[-712769+713229]=11467288-(-893275),-473209+432760 G6[77415159%7037700]=G6[71933594%2997214](G6[-286340-(-286800)])GT=G6[1007552459%5824000]G6[-847673-(-848133)]=z[l[1183473541%10566728]]G6[-330096+330554]=G6[392481250%5031805][GT]J=G6[517481+-517023]G6[252746+-252286],I,G6[-864652-(-865115)]=J,5607607-(-354491),J and G6[24223493%195347]t,G6[732116-731655]=G6[-578362+578822],G6[798538359%8495084]or G6[184055-183591]X=G6[341122011%13644862]end else if 1605104821%8073186>I then I=12976449-717731 elseif I<575230+6081831 then S=139469543%3576142 N=a==S I=N and 3276311383%25904077 or 1098741907%29272903 else G6[721575+-719789]=-31684+6074710 G6[-381891+383676]=X<G6[-114856-(-116642)]I=G6[228451101%3217596]and 3231026491%24968739 or 3567310452%19449981 end end else if I>5813025-(-970249)then if 6521718-(-276041)>I then I=-6786+11638608 elseif I<-938931+7743641 then X,W,I=nil,{},m[Q(914918-952598)]else G6[-668817-(-670725)]=534644629%11216555 G6[-442084+443991]=G6[-741672-(-743580)]>X I=G6[1393659829%5552422]and-9160+12487848 or 906713+7930705 end else if 6628102-(-98397)>I then G6[528582+-526883]=z[l[-689774+689778]]G6[3493113796%16713455],G6[-119501-(-121204)]=-517897-(-517898),-339901+339903 G6[-711263-(-712963)]=O[G6[667049+-665348]]G6[3689620818%15373413]=G6[308564+-306865][G6[-568077+569777]]G6[-202312-(-204013)]=z[l[2924610124%16247834]]L,I=G6[158936850%4182504],-699430+7469718 G6[504939+-503237]=O[G6[-70357-(-72060)]]G6[-570207-(-571907)]=G6[1395863872%11536051][G6[383621770%2459103]]G6[-598694+600393],A,G6[-1014392+1016095]=-780904+7679232948319,G6[1949271020%14125140],-666603-(-626188)lT=G6[2350772478%10541573]G6[-1032932-(-1034633)]=z[l[2719416804%12474389]]G6[1688161112%10169635]=G6[2053388701%10266935](G6[890491-888788])o,G6[43186-41483]=G6[-661343+663045],-785931+16414211 G6[782642+-780941]=A(o,lT)WT=G6[-604499-(-606200)]G6[675150380%7850566]=L[WT]r,X=G6[-464795-(-466499)],G6[-526006-(-527709)]G6[-710908+712613]=r y=G6[140331-138626]elseif 310532+6441170>I then G6[1408067042%14080651]=7021128-(-975806)G6[-426013-(-427954)]=X<G6[284645+-282703]I=G6[-497480+499421]and 985392278%5230983 or 235092+1072474 else I=-1025583+2988425 end end end else if 6128438-(-277521)>I then if I<12246+6370869 then if 361207+5975799>I then G6[706921699%3448393]=562929+3195770 G6[1501221633%6004882]=X<G6[79303030%4173784]I=G6[278828610%3132893]and 4195472-(-554801)or 2268696250%21354960 elseif 1921002290%9718975>I then G6[308098+-308065],G6[1910635021%9411995]=795755+-836199,3735565345%16676631 G6[-1021232+1021263]=z[l[380921556%13135226]]G6[-823644+823676]=G6[116910-116879](G6[616157+-616124])G6[-234555+234589]=z[l[-682847+682851]]G6[-595688+595719],v=1454044-(-878002),G6[102728428%1116613]X=G6[54045+-54014]G6[17471717%970649]=O[G6[920558+-920522]]G6[131205387%551283]=G6[479731266%14991601][G6[-864423-(-864458)]]G6[1427595517%8251997]=z[l[1917729289%7520507]]G6[53313128%8885515]=1630635438%9942899 G6[274738-274701]=O[G6[10511078%218980]]I,kT,G6[-394129-(-394163)]=1078876094%9248565,G6[29156+-29123],23493441985067-733040 d=G6[1003410+-1003376]G6[866887979%16670922]=G6[-954771-(-954807)][G6[188823+-188786]]jT=G6[-1005579+1005614]G6[879758537%16599217]=jT(v,d)x=G6[-757444+757480]G6[395021051%1812023]=kT[x]sT=G6[1731435979%10430337]G6[513511-513473]=sT w=G6[-993020+993058]elseif I<6580753-204664 then G6[-807561+807929]=z[l[-994059-(-994063)]]G6[1138293811%5269877],G6[-128073-(-128443)]=187717+-187715,592327148%5750749 G6[-612125+612494]=O[G6[837921-837551]]G6[-140515+140882]=G6[-62042+62410][G6[321858-321489]]G6[-179534+179905]=2800390204%15644638 G6[864944+-864575]=z[l[953254552%5574588]]G6[-805886-(-806256)]=O[G6[126680-126309]]G6[-786085+786466],G6[901449714%14777858]=-1024474+984045,-277946-(-277947)G6[-606226-(-606594)]=G6[-778281-(-778650)][G6[-296541-(-296911)]]G6[996465-996096]=z[l[-500484-(-500486)]]w,G6[-291223-(-291594)],r=G6[307100-306733],137055-177445,G6[33896+-33528]G6[994567182%5587454]=G6[-489015+489384](G6[940697+-940326])I,A,G6[-369534-(-369903)]=7532425-923408,G6[372663320%2192135],12401025478783-(-157199)WT=G6[822263265%5270916]G6[-287067-(-287438)]=r(A,WT)L=G6[1072386533%5765517]G6[1162413684%7647456]=w[L]G6[240712-240338]=z[l[1069638008%15065324]]X=G6[-997293+997665]G6[873813735%4161016]=O[G6[-337374+337750]]G6[-589926+590302]=-831946+791525 G6[696013-695640]=G6[1030514+-1030140][G6[-402833-(-403208)]]G6[-314630+315004]=z[l[670672-670670]]G6[-293459-(-293834)]=G6[61321670%1277527](G6[562534436%4536565])WT,G6[773843834%9921070],G6[-431214-(-431599)],G6[495190+-494807]=G6[172280+-171905],-557202+28419280614467,-472975-(-472977),265571-265570 o=G6[-520433+520807]G6[-589049-(-589426)]=z[l[634371+-634367]]r=G6[-32654+33027]G6[479481+-479103]=O[G6[28045+-27666]]G6[226852351%1680385]=G6[2149338321%12717976][G6[875842+-875464]]L=G6[75166-74790]G6[118619+-118242]=L(WT,o)A=G6[131259+-130882]G6[153212059%2157911]=r[A]w=G6[2248633994%15835448]G6[1151430945%8051962]=w u[X]=G6[2197997155%13911372]G6[-818471-(-818850)]=z[l[-165582-(-165584)]]G6[1211898911%6279267]=G6[585869+-585490](G6[62271507%669582])A=G6[1688317302%8001502]G6[233600-233219]=z[l[-134874+134878]]G6[82535737%5502357]=O[G6[477944123%5310486]]G6[2258900891%12834662]=G6[1348111245%12482508][G6[191608+-191226]]G6[1412720877%8026821],w=32335369745639-326166,G6[-797585+797964]WT=G6[46579-46198]G6[-582134-(-582517)]=z[l[2735193092%10684348]]G6[-718404-(-718788)]=O[G6[-483750+484135]]G6[-655353+655735]=G6[428059469%4703946][G6[12392907%105919]]G6[-458936-(-459321)],r=253884+9276850~=695495512%5334135,G6[713202582%7132022]G6[-20447+20830]=r(A,WT)L=G6[-1033022+1033405]G6[775832+-775448]=w[L]X,w=G6[1062945018%9934062],G6[764595378%5063543]G6[1105275034%11394584]=w u[X]=G6[-645186+645572]G6[-387368+387754]=1402029342%8823065 X=G6[1895818486%9977990]else I=5251799-127902<88026+12283623 I=I and 1380871328%10550410 or 92753+151847 end else if 221492+6173266>I then G6[3029737846%14427323]=10614368-544103 G6[606427-606412]=X<G6[-652118+652134]I=G6[-712773+712788]and 1845197109%11877744 or 2120343-(-1028626)elseif 7110651-707084>I then G6[202110872%1981476]=-622260+12837824 G6[-747629-(-747948)]=X>G6[1989306240%12433162]I=G6[729947-729628]and 172528+9679003 or 11933271-(-32239)else G6[675323+-674081]=z[l[-950853-(-950855)]]G6[55643+-54399]=815197+-855636 G6[747527-746284]=G6[825365-824123](G6[21505199%390981])G6[-346635-(-347877)],X,I=169767494%9431527,G6[298657912%2428103],2382970483%14211067 r=G6[1979095744%9749234]G6[527677-526433]=z[l[404281491%2591548]]G6[1849055065%9386060]=G6[851745-850501]()u,G6[-313576-(-314820)],G6[-1039294+1040541]=G6[-523469+524714],j,X G6[151591074%2135068]=z[l[493099+-493095]]G6[-435231+436477][u]=G6[-642620+643867]y,G6[515649+-514402],G6[-578624+579874]=G6[-987252-(-988496)],r,759746+13165542 L,G6[1941194754%10724826]=G6[-1032826-(-1034073)],1745648910%13745267 r,G6[-77314+78560]=G6[263950+-262702],131369+-131369 w,X,G6[-647897-(-649146)],G6[775778-774527]=G6[890857+-889611],G6[3320008424%16038682],r,697346+-697346 r,A=G6[248797-247546],G6[779929-778680]G6[1734431404%16677213]=A<r G6[455956677%2780216]=w-A WT,r=G6[394487+-393235],G6[3002743310%15558249]end end else if I>4118+6475389 then if 680931949%8992558>I then G6[584588604%2319796],G6[-627464+627475],I=eT,a,-997585+8736072 E,G6[602641+-602628],X=G6[-131408-(-131419)],1934314996%8357359,G6[1593335236%10148632]X=G6[325259+-325246]elseif 673004559%7015884>I then G6[-566769+568049]=3999475-909214 G6[264885-263606]=X<G6[-164825-(-166105)]I=G6[-39104+40383]and 240994161%8223433 or-970688+4266198 else a,N,F,v,b=nil,nil,nil,nil,nil I=R(777063+2225834,{O})u=nil u,S,v,a=Q(11777-49439),nil,I,Q(972618+-1010319)S,y=Q(-817448-(-779613)),nil b=m[u]P=nil u=m[a]M=nil N=m[S]a,I=N,N and 94669667%5994966 or 854447+7455250 end else if I<7263325-838247 then S=-920240+920241 N=v[S]y=891104+-891102 S=v[y]I=N<S I=I and 14015631-774318 or 4172389632%22160168 elseif 6090538-(-366924)>I then I=11141620-(-490202)else W=z[j]v=Q(206299+-244100)I=W~=v I=I and-945843+3541677 or 1300881092%9228153 end end end end else if 7558921-286990>I then if I<700902+6377752 then if 773927+6221162>I then if I<917936+5973829 then I=586651408%11031105 elseif 6083247-(-839728)>I then I=-290086-(-433843)elseif I<352777+6613440 then G6[-70849+71661]=814152+13668747 G6[40768-39957]=G6[1033257-1032445]>X I=G6[164174041%6080490]and-795811+10244086 or 2470659709%20802907 else G6[157196212%8273394]=80839+3922771 G6[488293603%5954779]=X<G6[1214619273%6495281]I=G6[-899971-(-901696)]and 2053085827%11520572 or-681339+14827536 end else if 644610+6357050>I then I=1028589+7872600 elseif 481795981%13964348>I then G6[-852500+853823],G6[-218422+219740]=903737+-903736,28294454088781-(-57130)L,G6[-655526-(-656847)]=G6[530759+-529441],-129085-(-88783)G6[834114095%14894871]=z[l[-913547-(-913549)]]G6[367524-366200]=615538+-615536 G6[3463376187%15530829]=G6[949242+-947923](G6[602376-601055])r=G6[600774-599454]G6[-374715+376036]=z[l[1772948524%8442612]]G6[594722992%9592285]=O[G6[-704161-(-705484)]]G6[388296+-386977]=G6[-432883+434204][G6[-795890+797212]]G6[74229098%1546412]=z[l[-424662-(-424666)]]w=G6[625055547%11793476]G6[14809635%3702078]=O[G6[-841414-(-842738)]]G6[384655-383334]=G6[-605137-(-606459)][G6[294614+-293291]]y=G6[-649861+651182]G6[108275+-106953]=y(r,L)u,G6[571403+-570073]=G6[-672867-(-674189)],I G6[517060015%5442723],G6[-50052-(-51379)]=763330184%7079433,570628-610902 G6[-275440+276763]=w[u]X=G6[799968-798645]G6[606216-604891]=z[l[-802248-(-802250)]]G6[3799632366%16377720]=G6[738095-736770](G6[372971-371644])G6[1134321997%11012822],w,G6[104104454%1010710]=-986200+4437511,G6[135329016%3007282],X G6[-783719-(-785046)]=z[l[-465913+465918]]G6[888349+-887021]=I I=2604055367%17379805 G6[-337294+338619]=G6[68995196%9856267][w]X,y=G6[-972998-(-974323)],G6[-400313+401637]G6[69985829%699845]=X and G6[1363041863%10817782]G6[903313-901986]=G6[-564731-(-566060)]or G6[-671370-(-672700)]X=G6[-871542+872869]else G6[3075813858%12254231],G6[1222358%610242]=-750648-(-710187),X r=G6[979885326%12403588]G6[2942254947%16437168]=z[l[1288499530%6474872]]G6[1008854-1006978]=G6[340294179%1933479](G6[1862199214%13022359])A=G6[-358450-(-360326)]G6[-15869+17746]=z[l[520379-520374]]G6[190196705%13585345]=G6[1954464781%10622081][A]G6[1841738928%9542679],G6[54827-52945],L=I,1613300725%11090671,G6[-881059+882934]G6[2696581%19814],G6[-768308+770188],G6[960176+-958295],G6[-538070+539949]=L,L and G6[-481823-(-483705)],-507438+11914330,I I,u,G6[468788-466910]=2383152511%10445522,G6[284514977%9483770],G6[164647439%1167699]or G6[330240-328359]X=G6[1481923754%10816948]end end else if 1825384349%16528978>I then if I<6448615-(-711870)then O,b,j,X=i[122986-122983],i[1423325511%7451966],i[-755606+755608],i[217811-217810]I=z[l[989008922%16213261]]u=z[l[1297093338%6936328]]v=z[l[1126065427%6398099]]F=i[167354+-167350]N=z[l[1009502-1009498]]a={X,j;O,F;b}W={I(u,a,v,N)}I,W=m[Q(-467168+429318)],{C(W)}elseif I<1105778746%7373141 then I=578661+2107953 else G6[329076-327535]=2929136-808923 G6[2089151110%15475182]=G6[-630599-(-632140)]>X I=G6[-899116-(-900656)]and-894281+1408228 or 5023775198%25074437 end else if 72041+7159483>I then G6[-714627+715428],G6[285828-285028]=490566-531007,-214989-(-174612)G6[267227+-266429]=z[l[-386489-(-386491)]]G6[1590021439%7644330]=G6[-977662+978460](G6[-995915-(-996715)])t=G6[-353105+353904]G6[336640582%3236921]=z[l[265519575%3199031]]G6[-786922+787722]=G6[863193+-862395](G6[947532201%6316876])G6[409821021%8719579]=I G6[-608031-(-608832)]=z[l[-604896+604901]]G6[2819190814%11012461]=G6[141023886%4029231][t]G6[4295705%29620],G6[40625757%394417],GT=536688+-536687,270098-270096,G6[598133-597333]G6[1071638383%6739859]=z[l[-894358-(-894363)]]G6[148048582%3895994]=I G6[-452792+453593]=G6[-755946+756748][GT]G6[-958502-(-959312)],IT,J=2738457310%14390308,G6[2462614552%15586163],G6[-673931-(-674732)]G6[122579-121776]={IT(J)}G6[219686097%1515071]={C(G6[42107960%4678573])}GT,G6[550728931%14884544]=G6[465220282%15007080],X G6[2583968124%12363480]=GT[G6[40995081%1205714]]t=G6[-1044081-(-1044885)]G6[646112+-645307]=GT[G6[384427-383621]]G6[239524513%2753146],I=4764694-566862,2775443711%20192635 G6[-626415+627224]=t and G6[270208+-269397]G6[-697399-(-698206)],J,G6[371339+-370533]=G6[-704439-(-705248)]or G6[171711360%1144737],G6[1518017869%6298826],t IT,FT,X=G6[603349-602543],G6[567792-566987],G6[-11617+12424]elseif 1865678902%16593036>I then X,I=G6[2096527455%10327717],G6[16485+-15580]I=3622185146%15006143 else W=13057241-91675 I=X<W I=I and-1002577+7104911 or 16568043-(-142762)end end end else if I<8182538-687144 then if I<931620284%15664227 then if I<8132234-844644 then a,I=nil,2670710709%14993650 elseif I<7983520-677978 then G6[-54675+54997]=347355043%25759186 G6[456566-456245]=G6[394797-394475]>X I=G6[-152147+152468]and-347648+9963037 or-325240+1673860 elseif 6680255-(-692804)>I then I=917553+14931829 else I,G6[-125645-(-126544)]=1523217311%15604899,UT end else if I<656239155%7632797 then X={c(706781-706780,C(i))}O={C(X)}I=z[l[521739-521738]]j=z[l[2850343037%13015265]]F=z[l[145725-145722]]b=z[l[-770672+770676]]W={I(j,O,F,b)}W,I={C(W)},m[Q(-252992-(-215144))]elseif I<933196+6548429 then I=14374131-(-564643)else G6[1022809+-1021746]=-962523-(-922074)G6[-223197+224258]=z[l[-112068+112070]]G6[20770+-19701]=-732190-(-732191)G6[31626468%310053]=G6[105933-104872](G6[1869563514%12547399])G6[2471347211%13007085]=z[l[-560804-(-560806)]]G6[522365-521301]=825907+-866296 G6[633383+-632320]=G6[353208-352147](G6[560248+-559184])jT,G6[2379685445%14164788]=G6[-463321+464384],-982662+27139737235427 x,GT=G6[-862607-(-863668)],G6[-928079-(-929141)]G6[3007924760%16259047]=z[l[727914+-727909]]G6[26802210%13400573]=G6[570541-569476][GT]J,G6[602947-601882]=G6[1091087588%4508622],1851169899%17680859 G6[438656-437589]=z[l[819004324%3412518]]G6[74021078%1947895]=O[G6[54536+-53467]]X=G6[-146167-(-147232)]G6[652267+-651201]=G6[23089+-22022][G6[-534242+535310]]I=4678090-45567 G6[250081+-249013]=z[l[1225613556%5260144]]G6[103387496%408642],mT=1025137+-1025135,G6[1913004538%9377468]G6[303345+-302276]=O[G6[437746-436676]]G6[62554896%370141]=G6[1566419493%10953975][G6[279207389%13960316]]sT=G6[620837-619770]G6[960042+-958974]=sT(jT,x)kT=G6[271670-270602]G6[857159+-856090]=mT[kT]UT=G6[62287-61218]G6[82113+-81043]=J(UT)GT=G6[1379915195%9786625]G6[2485177947%9861813]=GT t=G6[-634772+635843]end end else if I<2533744473%10145470 then if 1875814377%14047481>I then I=5754443669%24845134 elseif I<891916+6619620 then G6[-451669-(-453143)]={u}G6[-272783+274259]=z[l[675647856%3774569]]I,G6[2678340065%13877402],w=16564309-176360,-288132+247775,G6[3101241985%13085403]G6[-561088-(-562565)]=z[l[769179917%5962635]]G6[-1012792+1014270]=G6[955149+-953672](G6[-500106+501585])G6[148089+-146614]=G6[-696111+697587][G6[259956+-258478]]X=G6[-99785-(-101260)]else G6[-697541-(-697901)]=13789015-(-413930)G6[485411905%5919653]=G6[841669-841309]>X I=G6[1854872455%12044624]and-61748-(-657662)or 556973+4685750 end else if I<-995915+8524213 then G6[-502256-(-502412)]=-245288+8408409 G6[124318-124163]=G6[269687-269531]>X I=G6[760220-760065]and 2241518252%10962950 or-44545+9884996 elseif 2490003035%10746389>I then G6[387945-386144],I=u,-962872+14651493 else G6[119192+-117717]=428283539%5015829 G6[-737242-(-738716)]=G6[631877042%4481387]>X I=G6[-436524+437998]and 377064+7124409 or 2845993198%23225689 end end end end end end end end end end I=#e return C(W)end,function(m,Q)local C=O(Q)local i=function(i,l,e)return I(m,{i;l,e},Q,C)end return i end,function(m,Q)local C=O(Q)local i=function(i)return I(m,{i},Q,C)end return i end,function(m,Q)local C=O(Q)local i=function(i,l,e,c,W,z,X,s,j,O)return I(m,{i,l,e;c,W,z;X;s,j,O},Q,C)end return i end,{},function(m,Q)local C=O(Q)local i=function(i,l,e,c,W)return I(m,{i,l;e;c,W},Q,C)end return i end,function()j=j+269899015%1752591 X[j]=-695596-(-695597)return j end,function(m,Q)local C=O(Q)local i=function(i,l)return I(m,{i,l},Q,C)end return i end,function(m,Q)local C=O(Q)local i=function(...)return I(m,{...},Q,C)end return i end,771440-771440,function(m)for Q=222187+-222186,#m,83446-83445 do X[m[Q]]=X[m[Q]]+(-493125-(-493126))end if i then local I=i(true)local C=e(I)C[Q(412408-450077)],C[Q(876626+-914280)],C[Q(-183499-(-145877))]=m,F,function()return-3418023-(-884836)end return I else return l({},{[Q(-1069208-(-1031554))]=F,[Q(-1076043-(-1038374))]=m,[Q(-272584+234962)]=function()return-2686208-(-153021)end})end end,function(m,Q)local C=O(Q)local i=function(i,l,e,c,W,z)return I(m,{i;l,e;c,W,z},Q,C)end return i end,{},function(m,Q)local C=O(Q)local i=function()return I(m,{},Q,C)end return i end,function(m)X[m]=X[m]-(856749-856748)if X[m]==905360+-905360 then X[m],z[m]=nil,nil end end,function(m,Q)local C=O(Q)local i=function(i,l,e,c,W,z,X,s)return I(m,{i;l,e;c,W;z,X,s},Q,C)end return i end,function(m,Q)local C=O(Q)local i=function(i,l,e,c,W,z,X)return I(m,{i,l;e,c;W;z;X},Q,C)end return i end,function(m)local Q,I=2510888193%9808157,m[-469493+469494]while I do X[I],Q=X[I]-(904414-904413),Q+2401738054%10867593 if X[I]==-730657-(-730657)then X[I],z[I]=nil,nil end I=m[Q]end end,function(m,Q)local C=O(Q)local i=function(i,l,e,c)return I(m,{i;l;e,c},Q,C)end return i end return(U(-678901+10953973,{}))(C(W))end)(getfenv and getfenv()or _ENV,unpack or table[Q(937263-975098)],getmetatable,setmetatable,{...},newproxy,select)end)(...)]=]
function DFunctions.RunDraconicUpstream()
local U = DConfiguration.Visual.DraconicUpstream
if U.Running then return false, "already running" end
local src, origin
local ok, fetched = pcall(function() return game:HttpGet(U.Url) end)
if ok and type(fetched) == "string" and #fetched >= 1024 then
src, origin = fetched, "network"
elseif type(DraconicEmbedded) == "string" and #DraconicEmbedded >= 1024 then
src, origin = DraconicEmbedded, "embedded"
else
return false, "fetch failed and the embedded copy is missing"
end
local chunk, compileErr = loadstring(src)
if not chunk then return false, tostring(compileErr) end
U.Running = true
local marker = Instance.new("Folder")
marker.Name = "DraconicUpstream"
marker:SetAttribute("Loaded", true)
marker:SetAttribute("Bytes", #src)
marker:SetAttribute("Source", origin)
marker:SetAttribute("EmbeddedReady", type(DraconicEmbedded) == "string" and #DraconicEmbedded >= 1024)
marker:SetAttribute("EmbeddedBytes", type(DraconicEmbedded) == "string" and #DraconicEmbedded or 0)
task.spawn(function()
local ran, err = pcall(chunk)
if not ran then
U.Running = false
marker:SetAttribute("Failed", true)
Fluent:Notify({ Title = "Draconic upstream failed", Content = tostring(err) })
end
end)
return true, tostring(#src) .. " bytes"
end
Tabs.Visual:AddSection("Draconic Upstream")
Tabs.Visual:AddToggle("DraconicUpstreamRun", {
Title = "Run Draconic's own script",
Default = DConfiguration.Visual.DraconicUpstream.Running,
Callback = function(State)
if not State then return end
local ok, detail = DFunctions.RunDraconicUpstream()
Fluent:Notify({ Title = ok and "Draconic upstream running" or "Draconic upstream", Content = tostring(detail) })
end
})
Tabs.Visual:AddParagraph({
Title = "Runs the author's Overhaul.lua as shipped, no porting. It opens its own menu, so turn this on instead of the local features, not alongside them.",
Content = ""
})
Tabs.Visual:AddSection("Cosmetics Changer")
Tabs.Visual:AddInput("CurrentCosmetic", {
Title = "Current Cosmetic",
Default = "",
Placeholder = "Cosmetic name",
Numeric = false,
Finished = false,
Callback = function(Value)
DConfiguration.Visual.OriginalCosmetics.Cosmetics1 = Value
end
})
Tabs.Visual:AddInput("NewCosmetic", {
Title = "New Cosmetic",
Default = "",
Placeholder = "Cosmetic name",
Numeric = false,
Finished = false,
Callback = function(Value)
DConfiguration.Visual.ModifyCosmetics.Cosmetics1 = Value
end
})
Tabs.Visual:AddButton({
Title = "Swap Cosmetics",
Description = "Swap current cosmetic with new cosmetic",
Callback = function()
local cur = DConfiguration.Visual.OriginalCosmetics.Cosmetics1
local neu = DConfiguration.Visual.ModifyCosmetics.Cosmetics1
if cur and neu and cur ~= "" and neu ~= "" then
DFunctions.ChangeCosmetics(cur, neu)
end
end
})
Tabs.Visual:AddButton({
Title = "Reset Cosmetics",
Description = "Restore all cosmetic swaps",
Callback = function()
DFunctions.RestoreCosmetics()
end
})
Tabs.Visual:AddSection("Emote Changer")
for i = 1, 12 do
DConfiguration.Visual.CurrentEmotes[i] = DConfiguration.Visual.CurrentEmotes[i] or ""
Tabs.Visual:AddInput("CurrentEmote_" .. i, {
Title = "Current Emote " .. i,
Default = "",
Placeholder = "Emote name or ID",
Numeric = false,
Finished = false,
Callback = function(Value)
DConfiguration.Visual.CurrentEmotes[i] = Value
DConfiguration.Visual.OriginalEmotes["Emote" .. i] = Value
end
})
end
Tabs.Visual:AddParagraph({ Title = " ", Content = "" })
for i = 1, 12 do
DConfiguration.Visual.SelectEmotes[i] = DConfiguration.Visual.SelectEmotes[i] or ""
Tabs.Visual:AddInput("SelectEmote_" .. i, {
Title = "Select Emote " .. i,
Default = "",
Placeholder = "Emote name or ID",
Numeric = false,
Finished = false,
Callback = function(Value)
DConfiguration.Visual.SelectEmotes[i] = Value
DConfiguration.Visual.ModifyEmotes["Emote" .. i] = Value
end
})
end
Tabs.Visual:AddButton({
Title = "Apply Emote Mappings",
Description = "Build mapping and start emote watcher",
Callback = function()
DFunctions.BuildEmoteMapping()
DFunctions.StartEmoteWatcher()
end
})
Tabs.Visual:AddButton({
Title = "Reset Emote Mappings",
Description = "Stop watcher and clear mappings",
Callback = function()
DFunctions.ResetEmoteChanges()
end
})
Tabs.Info:AddParagraph({
Title = "Elderwyrm Hub X / Overhaul Script",
Content = "Created by Vraigos"
})
Tabs.Info:AddParagraph({
Title = "Adjustments / Movement Modification",
Content = "Created by Vraigos and Aerave"
})
Tabs.Info:AddParagraph({
Title = "Adjustments / ESP / Legacy Script",
Content = "Created by Aerave"
})
Tabs.Info:AddButton({
Title = "Join Discord",
Description = "Tap to copy link",
Callback = function()
if setclipboard then
setclipboard("https://discord.gg/zvhjwgVVbR")
end
end
})
Tabs.Info:AddParagraph({
Title = "UI: Fluent",
Content = "Created by dawidscripts"
})
Tabs.Settings:AddParagraph({
Title = "Configuration",
Content = " "
})
Tabs.Settings:AddButton({
Title = "Clear Settings Cache",
Description = "Wipes the saved config folder so the next launch starts clean",
Callback = function()
if writefile and isfolder and isfolder("Reicht/Evade") then
for _, name in ipairs(listfiles("Reicht/Evade")) do
pcall(delfile, name)
end
end
end
})
Window:SelectTab(RealTabs.Main)
local ExtensionLoaded = false
Tabs.Extension:AddButton({
Title = "Load Extension",
Description = "Not all the scripts here are ours. Some are recommendations from this tab.",
Callback = function()
Window:Dialog({
Title = "WARNING",
Content = "Extension loading is currently unavailable.",
Buttons = {
{
Title = "OK",
Callback = function() end
},
},
})
end
})
local tadaSound = Instance.new("Sound")
tadaSound.SoundId = "rbxassetid://131653558869295"
tadaSound.Parent = game:GetService("SoundService")
tadaSound.Volume = 6
tadaSound:Play()
tadaSound.Ended:Connect(function() tadaSound:Destroy() end)
print("[Elderwyrm Hub X] Loaded.")
end
Safe(function() return Library:LoadAutoloadConfig() end)
local ok, err = xpcall(Run, debug.traceback)
if not ok then
Alert("Draconic menu error: " .. tostring(err))
end
