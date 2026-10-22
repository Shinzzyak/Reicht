if not game:IsLoaded() then
game.Loaded:Wait()
end
local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local RunService = game:GetService("RunService")
local Workspace = game:GetService("Workspace")
local UserInputService = game:GetService("UserInputService")
local HttpService = game:GetService("HttpService")
local Lighting = game:GetService("Lighting")
local TeleportService = game:GetService("TeleportService")
local StarterGui = game:GetService("StarterGui")
local VirtualInputManager = game:GetService("VirtualInputManager")
local VirtualUser = game:GetService("VirtualUser")
local LocalPlayer = Players.LocalPlayer
if game.GameId ~= 7633926880 then
LocalPlayer:Kick("Reicht: this script is for BloxStrike only")
return
end
local function RuntimePrint()
local ok, renv = pcall(getrenv)
return ok and type(renv) == "table" and type(renv.print) == "function" and renv.print or print
end
local ReichtBanner = {
Print = RuntimePrint(),
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
"   BLOXSTRIKE  //  by Reicht  //  ",
"   executor: " .. executor .. "   //   player: " .. game:GetService("Players").LocalPlayer.Name,
rule,
}, "\n"))
end
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
local environment = getgenv and getgenv() or _G
if environment.BloxStrikeUnload then pcall(environment.BloxStrikeUnload) end
if not LPH_OBFUSCATED then
local function Passthrough(fn) return fn end
LPH_JIT, LPH_JIT_MAX, LPH_NO_VIRTUALIZE = Passthrough, Passthrough, Passthrough
end
local vector2New = Vector2.new
local cframeLookAt = CFrame.lookAt
local osClock = os.clock
local Library, T
local Reicht = setmetatable({}, {
__newindex = function(self, key, value)
rawset(self, key, type(value) == "function" and LPH_JIT(value) or value)
end,
})
Reicht.Config = {
UiSource = "https://raw.githubusercontent.com/Shinzzyak/Reicht/refs/heads/main/ui.lua",
Discord = "https://",
UpdateLog = {
{ "2026-10-10", "Silent Aim and Ragebot hit again after the game update\nFixed the game crashing when you shoot\nFixed ESP Team Check and health\nAim and ESP now include bots\nSkin pictures, turning skins off restores the stock look\nAuto Rebuy works from round 1, No Flash/No Smoke/FOV restore when off" },
{ "2026-10-03", "Classic Reicht UI is back\nBetter executor support\nImproved Combat & Movement" },
},
SaveFolder = "BloxStrike",
StatusInterval = 1,
AimRenderPriority = Enum.RenderPriority.Camera.Value + 1,
RefireGap = 0.12,
TriggerRay = 2000,
SilentFocusTime = 1,
SeeThrough = { "Characters", "Debris", "ThirdPersonWeaponStash" },
EspCacheMax = 256,
SoundSelfRange = 6,
GhostSnap = 45,
LeadExtra = 0.02,
LeadMaxSpeed = 60,
SpreadMethods = { "getTrueSpread", "getSpreadForConfig", "getMovementSpreadForConfig", "getBaseSpreadForConfig", "getBaseSpread" },
SoundMaxMarks = 24,
SoundColor = Color3.fromRGB(255, 196, 64),
RedeemGap = 1.1,
RebuyGap = 0.25,
AlertTries = 20,
AlertGap = 0.5,
RequireTimeout = 5,
MaxFails = 5,
FailWindow = 10,
CombatToggles = { "Aimbot", "Triggerbot", "Ragebot", "AimbotShowFov", "SilentShowFov" },
ModuleFeatures = {
Net = { "AutoRebuy" },
Character = { "BunnyHop" },
Skins = { "SkinChanger" },
},
Codes = {
"1MGROUPMEMBERS", "MYFAULTYALL", "RIANOMINATED2026", "LORE", "DUST_II", "MICHAELSRETURN",
"FREEDOM", "HAPPYBDAYYUUTO", "GAMEBROKE318", "OHNEPIXEL", "NEBULA", "REACTORDELAY", "BUTTERFLYCASE", "TRADEUPS",
},
BoneParts = {
Head = { "Head" },
Torso = { "UpperTorso", "Torso", "HumanoidRootPart" },
},
BuyStates = { ["Buy Period"] = true, ["Warmup"] = true },
StickySlack = 1.5,
HopGap = 0.05,
HookSettle = 1,
SkinFile = "BloxStrike/skins.json",
SkinWears = { "Factory New", "Minimal Wear", "Field-Tested", "Well-Worn", "Battle-Scarred" },
SkinKinds = { Melee = "Knives", Glove = "Gloves", Grenade = "Grenades", C4 = "Gear", ["Zeus x27"] = "Gear" },
SkinOrder = { "Pistol", "SMG", "Rifle", "Sniper", "Heavy", "Shotgun", "Machine Gun", "Knives", "Gloves", "Grenades", "Gear" },
SkinRanks = { Forbidden = 9, Special = 8, Red = 7, Pink = 6, Purple = 5, Blue = 4, LightBlue = 3, Gray = 2, White = 1 },
SkinMainRows = 5,
SkinArms = { ["Left Arm"] = true, ["Right Arm"] = true },
GloveKey = "@Glove",
FovColors = {
Aimbot = Color3.fromRGB(232, 160, 76),
Silent = Color3.fromRGB(110, 170, 255),
},
EspFocusColor = Color3.fromRGB(255, 214, 64),
FovLayer = 50,
}
Reicht.State = {
Alive = true,
Connections = {},
Halted = {},
Notices = {},
AimTarget = nil,
AimPart = nil,
RageTarget = nil,
RagePart = nil,
SilentTarget = nil,
Firing = false,
PressedAt = 0,
LastShot = 0,
Shots = 0,
Redirected = 0,
Bought = {},
LightSaved = nil,
FovSaved = nil,
ViewSaved = nil,
Hooks = {},
TriggerWarned = false,
HopAt = 0,
HopCrouched = false,
SpaceHeld = false,
FovBound = false,
FovBase = 0,
}
Reicht.Options = {
Aimbot = false,
AimbotSmooth = 1,
AimbotBone = "Head",
AimbotPriority = "Crosshair",
AimbotFov = 150,
AimbotShowFov = false,
AimbotVisible = true,
AimbotSticky = true,
AimbotMaxDistance = 1500,
SilentAim = false,
SilentHitChance = 100,
SilentHeadChance = 100,
SilentPriority = "Crosshair",
SilentFov = 220,
SilentShowFov = false,
SilentVisible = true,
SilentMaxDistance = 2000,
SilentPredict = false,
Triggerbot = false,
TriggerDelay = 0,
TriggerHitChance = 100,
Ragebot = false,
RageVisible = true,
RageMaxDistance = 2000,
NoRecoil = false,
NoSpread = false,
Fullbright = false,
NoFlash = false,
NoSmoke = false,
SoundEsp = false,
SoundEspLife = 3,
EspMemory = 5,
CameraFov = false,
CameraFovValue = 100,
InfiniteJump = false,
BunnyHop = false,
BunnyCrouch = true,
SkinChanger = false,
AutoRebuy = false,
AntiAfk = false,
}
Reicht.Caps = setmetatable({}, {
__index = function(_, name)
return Library ~= nil and Library.Compat.Caps[name] == true
end,
})
Reicht.Util = {}
function Reicht.Util.HttpGet(url)
local ok, body = pcall(game.HttpGet, game, url)
if ok and type(body) == "string" then return body end
local req = request or http_request or (syn and syn.request)
if not req then error("no http") end
local sent, response = pcall(req, { Url = url, Method = "GET" })
if not sent then error(response) end
local status = type(response) == "table" and tonumber(response.StatusCode)
if status ~= 200 or type(response.Body) ~= "string" then error("http status " .. tostring(status)) end
return response.Body
end
function Reicht.Util.Alert(text, detail)
warn("[BloxStrike] menu:", detail or text)
task.spawn(function()
for _ = 1, Reicht.Config.AlertTries do
if pcall(StarterGui.SetCore, StarterGui, "SendNotification", { Title = "Reicht", Text = text, Duration = 10 }) then return end
task.wait(Reicht.Config.AlertGap)
end
end)
end
function Reicht.Util.LoadLibrary(url)
local got, source = pcall(Reicht.Util.HttpGet, url)
local whole = got and type(source) == "string" and source:sub(-64):find("return Library%s*$") ~= nil
if not whole then
Reicht.Util.Alert("Could not download the menu. Check your connection and run it again.", got and "truncated or not the menu" or source)
return nil
end
local chunk, err = loadstring(source)
if type(chunk) ~= "function" then
Reicht.Util.Alert("The menu failed to load on this executor: " .. tostring(err))
return nil
end
local ran, loaded = pcall(chunk)
if ran and type(loaded) == "table" then return loaded end
Reicht.Util.Alert("The menu failed to load on this executor: " .. tostring(loaded))
return nil
end
function Reicht.Util.Try(label, fn, ...)
local ok, err = pcall(fn, ...)
if not ok then warn("[BloxStrike] " .. label .. ":", err) end
return ok
end
function Reicht.Util.Copy(text)
local fn = setclipboard or toclipboard
if not fn then return false end
return pcall(fn, text)
end
function Reicht.Util.Hook(key, fn, replacement)
if type(fn) ~= "function" or Reicht.State.Hooks[key] or not Reicht.Caps.HookFunction then return nil end
local ok, original = pcall(hookfunction, fn, replacement)
if not ok or type(original) ~= "function" then
warn("[BloxStrike] hook " .. key .. ":", ok and "executor returned no original" or original)
return nil
end
Reicht.State.Hooks[key] = { Fn = fn, Original = original }
return original
end
function Reicht.Util.UnhookAll()
for key, hook in pairs(Reicht.State.Hooks) do
local ok, err = pcall(Library.Compat.Unhook, hook.Fn, function() hookfunction(hook.Fn, hook.Original) end)
if not ok then warn("[BloxStrike] unhook " .. key .. ":", err) end
end
table.clear(Reicht.State.Hooks)
end
function Reicht.Util.Decode(raw)
if type(raw) ~= "string" then return nil end
local ok, decoded = pcall(HttpService.JSONDecode, HttpService, raw)
return ok and decoded or nil
end
function Reicht:Connect(signal, handler)
local conn = signal:Connect(handler)
table.insert(self.State.Connections, conn)
return conn
end
Reicht.GameLib = { Missing = {} }
function Reicht.GameLib.Find(parent, name, class, home)
local found = parent and parent:FindFirstChild(name)
if found and found:IsA(class) then return found end
for _, desc in ipairs(ReplicatedStorage:GetDescendants()) do
if desc.Name == name and desc:IsA(class) and desc.Parent and desc.Parent.Name == home then return desc end
end
Reicht.GameLib.Missing[name] = "Absent"
warn("[BloxStrike] " .. home .. "." .. name .. " not found, features that need it are blocked")
return nil
end
function Reicht.GameLib.Require(inst)
if not (inst and inst:IsA("ModuleScript")) then return nil end
local ok, mod = pcall(require, inst)
if ok then return mod end
local done, okAgain, again = false, false, nil
task.spawn(function()
pcall(setthreadidentity, 2)
local read, identity = pcall(getthreadidentity)
if read and identity == 2 then okAgain, again = pcall(require, inst) end
done = true
end)
local deadline = osClock() + Reicht.Config.RequireTimeout
while not done and osClock() < deadline do task.wait() end
if okAgain then return again end
warn("[BloxStrike] require " .. inst.Name .. ":", mod)
return nil
end
do
local database = ReplicatedStorage:FindFirstChild("Database")
local security = database and database:FindFirstChild("Security")
local custom = database and database:FindFirstChild("Custom")
local controllers = ReplicatedStorage:FindFirstChild("Controllers")
local find = Reicht.GameLib.Find
Reicht.GameLib.Net = Reicht.GameLib.Require(find(security, "Remotes", "ModuleScript", "Security"))
Reicht.GameLib.Character = Reicht.GameLib.Require(find(controllers, "CharacterController", "ModuleScript", "Controllers"))
Reicht.GameLib.Camera = Reicht.GameLib.Require(find(controllers, "CameraController", "ModuleScript", "Controllers"))
Reicht.GameLib.WeaponFolder = find(custom, "Weapons", "Folder", "Custom")
Reicht.GameLib.Rarities = Reicht.GameLib.Require(find(custom, "Rarities", "ModuleScript", "GameStats"))
local vfx = ReplicatedStorage:FindFirstChild("Components") and ReplicatedStorage.Components:FindFirstChild("VFXLibary", true)
Reicht.GameLib.Smoke = Reicht.GameLib.Require(find(vfx, "CreateVoxelSmoke", "ModuleScript", "VFXLibary"))
Reicht.GameLib.Flash = Reicht.GameLib.Require(find(vfx, "FlashEffect", "ModuleScript", "VFXLibary"))
end
Reicht.Weapons = {}
do
local folder = Reicht.GameLib.WeaponFolder
for _, module in ipairs(folder and folder:GetChildren() or {}) do
local data = module:IsA("ModuleScript") and Reicht.GameLib.Require(module)
if type(data) == "table" and data.FireRate then Reicht.Weapons[module.Name] = data end
end
end
Reicht.Player = {}
function Reicht.Player.Character()
local chars = Workspace:FindFirstChild("Characters")
return (chars and chars:FindFirstChild(LocalPlayer.Name)) or LocalPlayer.Character
end
function Reicht.Player.Alive()
local char = Reicht.Player.Character()
return char ~= nil and char.Parent ~= nil and tostring(LocalPlayer:GetAttribute("Dead")) ~= "true"
end
function Reicht.Player.Humanoid()
local char = Reicht.Player.Character()
return char and char:FindFirstChildOfClass("Humanoid")
end
function Reicht.Player.Body()
local controller = Reicht.GameLib.Character
if not controller then return nil end
local ok, body = pcall(controller.getCurrentCharacter)
return ok and body or nil
end
function Reicht.Player.Equipped()
return Reicht.Util.Decode(LocalPlayer:GetAttribute("CurrentEquipped"))
end
Reicht.Target = { Motion = setmetatable({}, { __mode = "k" }) }
local losParams = RaycastParams.new()
losParams.FilterType = Enum.RaycastFilterType.Exclude
local losFilter = table.create(3)
local wallParams = RaycastParams.new()
wallParams.FilterType = Enum.RaycastFilterType.Exclude
function Reicht.Target.Candidates()
local list = {}
local chars = Workspace:FindFirstChild("Characters")
if not chars then return list end
for _, model in ipairs(chars:GetChildren()) do
if model.Name ~= LocalPlayer.Name and model:IsA("Model") then list[#list + 1] = model end
end
return list
end
function Reicht.Target.Owner(model)
return Players:FindFirstChild(model.Name)
end
function Reicht.Target.TeamOf(model)
local owner = model and Reicht.Target.Owner(model)
local team = owner and owner:GetAttribute("Team")
if team then return team end
local look = model and model:GetAttribute("CharacterName")
if not look then return nil end
if look == Workspace:GetAttribute("CTCharacter") then return "Counter-Terrorists" end
if look == Workspace:GetAttribute("TCharacter") then return "Terrorists" end
return nil
end
function Reicht.Target.MyTeam()
return LocalPlayer:GetAttribute("Team") or Reicht.Target.TeamOf(Reicht.Player.Character())
end
function Reicht.Target.IsEnemy(model)
if tostring(model:GetAttribute("Dead")) == "true" then return false end
if not Reicht.Target.Owner(model) and model:GetAttribute("Health") == nil then return false end
if Reicht.Target.FreeForAll() then return true end
local mine = Reicht.Target.MyTeam()
if mine == nil then return false end
return Reicht.Target.TeamOf(model) ~= mine
end
function Reicht.Target.Track()
local motion, now = Reicht.Target.Motion, osClock()
for _, model in ipairs(Reicht.Target.Candidates()) do
local head = model:FindFirstChild("Head")
if not head then continue end
local last = motion[head]
if last and now > last.Time then
local step = (head.Position - last.Pos) / (now - last.Time)
last.Vel = last.Vel and last.Vel:Lerp(step, 0.5) or step
last.Pos, last.Time = head.Position, now
else
motion[head] = { Pos = head.Position, Time = now, Vel = Vector3.zero }
end
end
end
function Reicht.Target.Lead(part)
if not Reicht.Options.SilentPredict then return part.Position end
local track = Reicht.Target.Motion[part] or Reicht.Target.Motion[part.Parent and part.Parent:FindFirstChild("Head")]
local vel = track and track.Vel or Vector3.zero
if vel.Magnitude > Reicht.Config.LeadMaxSpeed then return part.Position end
local ok, ping = pcall(LocalPlayer.GetNetworkPing, LocalPlayer)
return part.Position + vel * ((ok and ping or 0.05) + Reicht.Config.LeadExtra)
end
function Reicht.Target.FreeForAll()
return tostring(Workspace:GetAttribute("Gamemode")):find("Deathmatch") ~= nil
end
function Reicht.Target.Part(model, bone)
for _, name in ipairs(Reicht.Config.BoneParts[bone] or Reicht.Config.BoneParts.Head) do
local part = model:FindFirstChild(name)
if part and part:IsA("BasePart") then return part end
end
return model:FindFirstChild("HumanoidRootPart")
end
function Reicht.Target.Visible(from, model, point)
local skip = { Workspace.CurrentCamera, model }
for _, name in ipairs(Reicht.Config.SeeThrough) do
local folder = Workspace:FindFirstChild(name)
if folder then skip[#skip + 1] = folder end
end
wallParams.FilterDescendantsInstances = skip
return Workspace:Raycast(from, point - from, wallParams) == nil
end
function Reicht.Target.Pick(cfg)
local cam = Workspace.CurrentCamera
local origin = cam.CFrame.Position
local center = cam.ViewportSize / 2
local best, bestPart, bestScore
for _, model in ipairs(Reicht.Target.Candidates()) do
if not Reicht.Target.IsEnemy(model) then continue end
local part = Reicht.Target.Part(model, cfg.Bone)
if not part then continue end
local dist = (part.Position - origin).Magnitude
if dist > cfg.MaxDistance then continue end
local screen, onScreen = cam:WorldToViewportPoint(part.Position)
local screenDist = (vector2New(screen.X, screen.Y) - center).Magnitude
if cfg.Fov and (not onScreen or screenDist > cfg.Fov) then continue end
if cfg.Visible and not Reicht.Target.Visible(origin, model, part.Position) then continue end
local score = dist
if cfg.Priority == "Crosshair" then
score = onScreen and screenDist or 1e6 + dist
elseif cfg.Priority == "Health" then
score = (tonumber(model:GetAttribute("Health")) or 100) * 1e4 + dist
end
if not bestScore or score < bestScore then best, bestPart, bestScore = model, part, score end
end
return best, bestPart
end
function Reicht.Target.StillValid(model, part, cfg)
if not (model and part and part.Parent and Reicht.Target.IsEnemy(model)) then return false end
local cam = Workspace.CurrentCamera
local origin = cam.CFrame.Position
if (part.Position - origin).Magnitude > cfg.MaxDistance then return false end
if cfg.Visible and not Reicht.Target.Visible(origin, model, part.Position) then return false end
if not cfg.Fov then return true end
local screen, onScreen = cam:WorldToViewportPoint(part.Position)
local center = cam.ViewportSize / 2
return onScreen and (vector2New(screen.X, screen.Y) - center).Magnitude <= cfg.Fov * Reicht.Config.StickySlack
end
function Reicht.Target.UnderCrosshair()
local cam = Workspace.CurrentCamera
losFilter[1], losFilter[2], losFilter[3] = Reicht.Player.Character(), cam, nil
losParams.FilterDescendantsInstances = losFilter
local hit = Workspace:Raycast(cam.CFrame.Position, cam.CFrame.LookVector * Reicht.Config.TriggerRay, losParams)
if not hit then return nil end
local chars = Workspace:FindFirstChild("Characters")
local model = hit.Instance
while model and model.Parent ~= chars do model = model.Parent end
if model and model:IsA("Model") and Reicht.Target.IsEnemy(model) then return model end
return nil
end
local function roll(percent)
return percent >= 100 or math.random() * 100 < percent
end
Reicht.Aimbot = {}
function Reicht.Aimbot.Config()
local o = Reicht.Options
return { Bone = o.AimbotBone, Fov = o.AimbotFov, Visible = o.AimbotVisible, MaxDistance = o.AimbotMaxDistance, Priority = o.AimbotPriority }
end
function Reicht.Aimbot.Step()
local state, o = Reicht.State, Reicht.Options
if not o.Aimbot then state.AimTarget, state.AimPart = nil, nil return end
local cfg = Reicht.Aimbot.Config()
if o.AimbotSticky and Reicht.Target.StillValid(state.AimTarget, state.AimPart, cfg) then return end
state.AimTarget, state.AimPart = Reicht.Target.Pick(cfg)
end
function Reicht.Aimbot.Lock(dt)
local o, state = Reicht.Options, Reicht.State
local part, smooth = nil, 1
if o.Ragebot and state.RagePart and state.RagePart.Parent then
part = state.RagePart
elseif o.Aimbot and state.AimPart and state.AimPart.Parent then
part, smooth = state.AimPart, math.max(o.AimbotSmooth, 1)
end
if not part then return end
local cam = Workspace.CurrentCamera
local origin = cam.CFrame.Position
local want = (part.Position - origin).Unit
local alpha = 1 - (1 - 1 / smooth) ^ ((dt or 1 / 60) * 60)
local look = smooth <= 1 and want or cam.CFrame.LookVector:Lerp(want, alpha).Unit
cam.CFrame = cframeLookAt(origin, origin + look)
end
Reicht.Silent = {}
function Reicht.Silent.Config(bone, forced)
local o = Reicht.Options
if forced then return { Bone = bone, Visible = o.RageVisible, MaxDistance = o.RageMaxDistance, Priority = "Distance" } end
return { Bone = bone, Fov = o.SilentFov, Visible = o.SilentVisible, MaxDistance = o.SilentMaxDistance, Priority = o.SilentPriority }
end
function Reicht.Silent.Aim()
local o, state = Reicht.Options, Reicht.State
state.SilentTarget = nil
if not (o.SilentAim or o.Ragebot) then return nil end
local forced = o.Ragebot
if not forced and not roll(o.SilentHitChance) then return nil end
local bone = (forced or roll(o.SilentHeadChance)) and "Head" or "Torso"
local target, part = Reicht.Target.Pick(Reicht.Silent.Config(bone, forced))
state.SilentTarget = target
return part
end
function Reicht.Silent.InstallHook()
local gun = Reicht.Guns.FindClass()
if gun then
local original
original = Reicht.Util.Hook("Shoot", gun.shoot, function(...)
local state = Reicht.State
state.LastShot = osClock()
state.Shots += 1
return original(...)
end)
end
local bullet = Reicht.Guns.FindBullet()
if bullet and type(bullet.create) == "function" then
local create
create = Reicht.Util.Hook("Bullet", bullet.create, function(...)
Reicht.Silent.Flick()
return create(...)
end)
end
Reicht.Guns.HookSpread()
local net = Reicht.GameLib.Net
local packet = net and net.Inventory and net.Inventory.ShootWeapon
if not packet then return end
local send
send = Reicht.Util.Hook("Send", packet.Send, function(...)
Reicht.Silent.RestoreView()
return send(...)
end)
end
function Reicht.Silent.Flick()
local ok, part = pcall(Reicht.Silent.Aim)
local cam, state = Workspace.CurrentCamera, Reicht.State
if not (ok and part and cam) then return end
state.ViewSaved = state.ViewSaved or cam.CFrame
cam.CFrame = cframeLookAt(cam.CFrame.Position, Reicht.Target.Lead(part))
state.Redirected += 1
end
function Reicht.Silent.RestoreView()
local state, cam = Reicht.State, Workspace.CurrentCamera
if not state.ViewSaved then return end
if cam then cam.CFrame = state.ViewSaved end
state.ViewSaved = nil
end
Reicht.Trigger = {}
function Reicht.Trigger.Press(down)
if down and Library.Window and Library.Window.Visible then return end
Reicht.State.Firing = down
if down then Reicht.State.PressedAt = osClock() end
local center = Workspace.CurrentCamera.ViewportSize / 2
pcall(VirtualInputManager.SendMouseButtonEvent, VirtualInputManager, center.X, center.Y, 0, down, game, 0)
end
function Reicht.Trigger.Fire(want)
local state, now = Reicht.State, osClock()
if not want then
if state.Firing then Reicht.Trigger.Press(false) end
return
end
if not state.Firing then
Reicht.Trigger.Press(true)
return
end
local gap = Reicht.Config.RefireGap
if now - state.PressedAt > gap and now - state.LastShot > gap then Reicht.Trigger.Press(false) end
end
function Reicht.Trigger.Wanted()
local o, state = Reicht.Options, Reicht.State
if not o.Triggerbot then return false end
local model = Reicht.Target.UnderCrosshair()
if model ~= state.TriggerModel then
state.TriggerModel = model
state.TriggerSeen = model and osClock() or nil
state.TriggerRoll = model ~= nil and roll(o.TriggerHitChance)
end
if not model or not state.TriggerRoll then return false end
return osClock() - state.TriggerSeen >= o.TriggerDelay / 1000
end
Reicht.Rage = {}
function Reicht.Rage.Step()
local state = Reicht.State
if not Reicht.Options.Ragebot then state.RageTarget, state.RagePart = nil, nil return false end
state.RageTarget, state.RagePart = Reicht.Target.Pick(Reicht.Silent.Config("Head", true))
return state.RageTarget ~= nil
end
Reicht.Combat = { Circles = {} }
function Reicht.Combat.Screen()
local screen = Reicht.Combat.Gui
if screen and screen.Parent then return screen end
screen = Instance.new("ScreenGui")
screen.Name = "MarioHubFov"
screen.IgnoreGuiInset = true
screen.ResetOnSpawn = false
screen.DisplayOrder = Reicht.Config.FovLayer
local function Mount(parent) screen.Parent = parent end
local okHui, hui = pcall(gethui)
local mounted = okHui and hui ~= nil and pcall(Mount, hui)
if not mounted then mounted = pcall(Mount, game:GetService("CoreGui")) end
if not mounted then Mount(LocalPlayer:FindFirstChildOfClass("PlayerGui")) end
Reicht.Combat.Gui = screen
return screen
end
function Reicht.Combat.NewCircle(color)
if Reicht.Caps.Drawing then
local circle = Drawing.new("Circle")
circle.Thickness, circle.NumSides, circle.Filled, circle.Color = 1.5, 64, false, color
return { Drawing = circle }
end
local frame = Instance.new("Frame")
frame.AnchorPoint = vector2New(0.5, 0.5)
frame.BackgroundTransparency = 1
local round = Instance.new("UICorner")
round.CornerRadius = UDim.new(1, 0)
round.Parent = frame
local edge = Instance.new("UIStroke")
edge.Thickness, edge.Color = 1.5, color
edge.Parent = frame
frame.Parent = Reicht.Combat.Screen()
return { Frame = frame }
end
function Reicht.Combat.Circle(key, show, radius)
local circle = Reicht.Combat.Circles[key]
if not circle then
if not show then return end
circle = Reicht.Combat.NewCircle(Reicht.Config.FovColors[key])
Reicht.Combat.Circles[key] = circle
end
local center = Workspace.CurrentCamera.ViewportSize / 2
local drawing, frame = circle.Drawing, circle.Frame
if drawing then
drawing.Visible, drawing.Position, drawing.Radius = show, center, radius
return
end
frame.Visible = show
frame.Position = UDim2.fromOffset(center.X, center.Y)
frame.Size = UDim2.fromOffset(radius * 2, radius * 2)
end
function Reicht.Combat.Step()
local o, state = Reicht.Options, Reicht.State
Reicht.Combat.Circle("Aimbot", o.AimbotShowFov, o.AimbotFov)
Reicht.Combat.Circle("Silent", o.SilentShowFov, o.SilentFov)
if not Reicht.Player.Alive() then
state.AimTarget, state.AimPart, state.RageTarget, state.RagePart, state.SilentTarget = nil, nil, nil, nil, nil
Reicht.Trigger.Fire(false)
return
end
if o.SilentAim or o.Ragebot then Reicht.Target.Track() end
Reicht.Aimbot.Step()
local rage = Reicht.Rage.Step()
Reicht.Trigger.Fire(rage or Reicht.Trigger.Wanted())
end
function Reicht.Combat.Rest()
local state = Reicht.State
state.AimTarget, state.AimPart, state.RageTarget, state.RagePart, state.SilentTarget = nil, nil, nil, nil, nil
Reicht.Trigger.Fire(false)
for key in pairs(Reicht.Combat.Circles) do
Reicht.Combat.Circle(key, false, 0)
end
end
function Reicht.Combat.Start()
RunService:BindToRenderStep("ReichtView", Enum.RenderPriority.First.Value, Reicht.Silent.RestoreView)
RunService:BindToRenderStep("ReichtAim", Reicht.Config.AimRenderPriority, Reicht.Aimbot.Lock)
Reicht:Connect(RunService.Heartbeat, function()
local ok, err = pcall(Reicht.Combat.Step)
if ok then
Reicht.Faults.Clear("Combat")
else
Reicht.Faults.Report("Combat", err, Reicht.Config.CombatToggles, Reicht.Combat.Rest)
end
end)
end
function Reicht.Combat.Unload()
Reicht.Trigger.Fire(false)
pcall(RunService.UnbindFromRenderStep, RunService, "ReichtAim")
pcall(RunService.UnbindFromRenderStep, RunService, "ReichtView")
for key, circle in pairs(Reicht.Combat.Circles) do
Reicht.Combat.Circles[key] = nil
if circle.Frame then
circle.Frame:Destroy()
else
pcall(function() circle.Drawing:Remove() end)
end
end
if Reicht.Combat.Gui then
Reicht.Combat.Gui:Destroy()
Reicht.Combat.Gui = nil
end
end
Reicht.Guns = { Signature = nil, Warned = false }
function Reicht.Guns.HookKick()
local cam = Reicht.GameLib.Camera
if not cam then return end
local kick, aim, rotation
kick = Reicht.Util.Hook("Kick", cam.weaponKick, function(...)
if Reicht.Options.NoRecoil then return end
return kick(...)
end)
aim = Reicht.Util.Hook("Recoil", cam.setWeaponRecoil, function(...)
if Reicht.Options.NoRecoil then return end
return aim(...)
end)
rotation = Reicht.Util.Hook("KickRotation", cam.getWeaponKickRotation, function(...)
if Reicht.Options.NoRecoil then return Vector3.zero end
return rotation(...)
end)
end
function Reicht.Guns.Scoped()
if LocalPlayer:GetAttribute("IsSniperScoped") == true then return true end
local cam = Reicht.GameLib.Camera
local getter = cam and cam.getTargetFOV
if type(getter) ~= "function" then return false end
local ok, target = pcall(getter)
if not ok or type(target) ~= "number" then return false end
local state = Reicht.State
if target > state.FovBase then state.FovBase = target end
return target < state.FovBase
end
function Reicht.Guns.StepFov()
local camera, state = Workspace.CurrentCamera, Reicht.State
if not camera then return end
if not Reicht.Options.CameraFov then
if state.FovSaved then camera.FieldOfView, state.FovSaved = state.FovSaved, nil end
state.FovBase = 0
return
end
if Reicht.Guns.Scoped() then return end
state.FovSaved = state.FovSaved or camera.FieldOfView
camera.FieldOfView = Reicht.Options.CameraFovValue
end
function Reicht.Guns.BindFov()
local state = Reicht.State
if state.FovBound then return end
state.FovBound = true
RunService:BindToRenderStep("ReichtFov", Enum.RenderPriority.Camera.Value + 3, Reicht.Guns.StepFov)
end
function Reicht.Guns.UnbindFov()
local state, camera = Reicht.State, Workspace.CurrentCamera
if state.FovSaved and camera then camera.FieldOfView, state.FovSaved = state.FovSaved, nil end
state.FovBound = false
pcall(RunService.UnbindFromRenderStep, RunService, "ReichtFov")
end
function Reicht.Guns.FindClass()
if not Reicht.Caps.Gc or not Reicht.Caps.HookFunction then return nil end
for _, entry in ipairs(getgc(true)) do
if type(entry) == "table" and rawget(entry, "getSpread") and rawget(entry, "shoot") and rawget(entry, "setupRecoil") then return entry end
end
return nil
end
function Reicht.Guns.FindBullet()
if not Reicht.Caps.Gc or not Reicht.Caps.HookFunction then return nil end
for _, entry in ipairs(getgc(true)) do
if type(entry) == "table" and rawget(entry, "getTrueSpread") and rawget(entry, "getSpreadForConfig") then return entry end
end
return nil
end
function Reicht.Guns.HookSpread()
local bullet = Reicht.Guns.FindBullet()
if not bullet then return end
for _, method in ipairs(Reicht.Config.SpreadMethods) do
if type(bullet[method]) ~= "function" then continue end
local original
original = Reicht.Util.Hook("Spread:" .. method, bullet[method], function(...)
local value = original(...)
if type(value) == "number" and (Reicht.Options.NoSpread or Reicht.State.ViewSaved) then return 0 end
return value
end)
end
end
Reicht.Esp = { Count = 0, Decoded = {}, CacheSize = 0, Ghosts = {}, Folder = nil }
function Reicht.Esp.Attr(owner, key)
local raw = owner:GetAttribute(key)
if type(raw) ~= "string" then return nil end
local esp = Reicht.Esp
if esp.Decoded[raw] == nil then
esp.CacheSize += 1
if esp.CacheSize > Reicht.Config.EspCacheMax then table.clear(esp.Decoded) esp.CacheSize = 1 end
esp.Decoded[raw] = Reicht.Util.Decode(raw) or false
end
return esp.Decoded[raw] or nil
end
function Reicht.Esp.Flags(owner)
if not owner then return "" end
local flags = {}
local armor = Reicht.Esp.Attr(owner, "Armor")
local bomb = Reicht.Esp.Attr(owner, "Slot5")
if bomb and bomb.Weapon == "C4" then flags[#flags + 1] = "C4" end
if owner:GetAttribute("HasDefuseKit") == true then table.insert(flags, "Kit") end
if armor and type(armor.Type) == "string" and armor.Type:find("Helmet") then flags[#flags + 1] = "Helmet" end
if owner:GetAttribute("IsSniperScoped") == true then flags[#flags + 1] = "Scoped" end
return #flags > 0 and " " .. table.concat(flags, " ") or ""
end
function Reicht.Esp.Focus()
local state = Reicht.State
local silent = osClock() - state.LastShot < Reicht.Config.SilentFocusTime and state.SilentTarget or nil
return state.AimTarget or silent or state.RageTarget
end
function Reicht.Esp.Ghost(name)
local esp = Reicht.Esp
local ghost = esp.Ghosts[name]
if ghost and ghost.Model.Parent then return ghost end
if not (esp.Folder and esp.Folder.Parent) then
esp.Folder = Instance.new("Folder")
esp.Folder.Name = "ReichtGhosts"
esp.Folder.Parent = Workspace.CurrentCamera
end
local model = Instance.new("Model")
model.Name = name
local root = Instance.new("Part")
root.Name, root.Size, root.Transparency = "HumanoidRootPart", Vector3.new(2, 2, 1), 1
root.Anchored, root.CanCollide, root.CanQuery, root.CanTouch = true, false, false, false
root.Parent = model
model.PrimaryPart = root
model.Parent = esp.Folder
ghost = { Model = model, Root = root, Seen = 0, Heard = 0 }
esp.Ghosts[name] = ghost
return ghost
end
function Reicht.Esp.Row(ghost, model, owner, mine, focus)
local equipped = owner and Reicht.Esp.Attr(owner, "CurrentEquipped")
local label = owner and owner.DisplayName or ghost.Model.Name
if equipped and equipped.Name then label = label .. " [" .. equipped.Name .. "]" end
local live = model and model:FindFirstChild("HumanoidRootPart")
if not live then label = label .. " ?" end
return {
Model = ghost.Model,
Root = live or ghost.Root,
Adornee = model or false,
Name = label .. Reicht.Esp.Flags(owner),
Health = tonumber(owner and owner:GetAttribute("Health")) or tonumber(model and model:GetAttribute("Health")) or 100,
MaxHealth = tonumber(model and model:GetAttribute("MaxHealth")) or 100,
Friendly = ghost.Friendly,
Color = model ~= nil and model == focus and Reicht.Config.EspFocusColor or nil,
}
end
function Reicht.Esp.Targets()
local esp, now = Reicht.Esp, osClock()
local list = {}
local mine = Reicht.Target.MyTeam()
local ffa = Reicht.Target.FreeForAll()
local focus = Reicht.Esp.Focus()
pcall(Reicht.Sound.Install)
local live = {}
for _, model in ipairs(Reicht.Target.Candidates()) do
if Reicht.Esp.IsDead(model, Reicht.Target.Owner(model)) then
Reicht.Esp.Forget(model.Name)
continue
end
local hrp = model:FindFirstChild("HumanoidRootPart")
if not hrp then continue end
local ghost = esp.Ghost(model.Name)
ghost.Root.CFrame, ghost.Seen = hrp.CFrame, now
ghost.Friendly = not ffa and mine ~= nil and Reicht.Target.TeamOf(model) == mine
live[model.Name] = true
list[#list + 1] = esp.Row(ghost, model, Reicht.Target.Owner(model), mine, focus)
end
local memory = Reicht.Options.EspMemory
for name, ghost in pairs(esp.Ghosts) do
if live[name] then continue end
local owner = Players:FindFirstChild(name)
if owner and Reicht.Esp.IsDead(nil, owner) then
Reicht.Esp.Forget(name)
continue
end
local gone = not ghost.Model.Parent or (not owner and now - ghost.Seen > memory)
if gone or now - math.max(ghost.Seen, ghost.Heard) > memory then
if gone and not owner then
ghost.Model:Destroy()
esp.Ghosts[name] = nil
end
continue
end
list[#list + 1] = esp.Row(ghost, nil, owner, mine, focus)
end
esp.Count = #list
return list
end
function Reicht.Esp.IsDead(model, owner)
if model and (tostring(model:GetAttribute("Dead")) == "true" or (tonumber(model:GetAttribute("Health")) or 1) <= 0) then return true end
if owner and (owner:GetAttribute("Dead") == true or (tonumber(owner:GetAttribute("Health")) or 1) <= 0) then return true end
return false
end
function Reicht.Esp.Forget(name)
local ghost = Reicht.Esp.Ghosts[name]
if ghost then ghost.Seen, ghost.Heard = 0, 0 end
end
function Reicht.Esp.Hear(pos, weapon)
local esp, now = Reicht.Esp, osClock()
local best, bestDist = nil, Reicht.Config.GhostSnap
for name, ghost in pairs(esp.Ghosts) do
if ghost.Friendly or now - ghost.Seen < 0.3 then continue end
local owner = Players:FindFirstChild(name)
local equipped = owner and Reicht.Esp.Attr(owner, "CurrentEquipped")
if weapon and equipped and equipped.Name and equipped.Name ~= weapon then continue end
local dist = (ghost.Root.Position - pos).Magnitude
if dist < bestDist then best, bestDist = ghost, dist end
end
if not best then return end
best.Root.CFrame = CFrame.new(pos + Vector3.new(0, 2.5, 0))
best.Heard = now
end
Reicht.Sound = { Marks = {}, Entry = nil, Original = nil, Folder = nil }
function Reicht.Sound.Install()
local sound = Reicht.Sound
if sound.Entry then return true end
local net = Reicht.GameLib.Net
local packet = net and net.Sound and net.Sound.ReplicateSound
if not (packet and Reicht.Caps.Upvalues) then return false end
local ok, listeners = pcall(function() return getupvalues(packet.Listen)[1] end)
if not ok or type(listeners) ~= "table" then return false end
for _, entry in ipairs(listeners) do
if type(entry) == "table" and type(entry.callback) == "function" then
sound.Entry, sound.Original = entry, entry.callback
entry.callback = function(info, ...)
Reicht.Util.Try("sound esp", Reicht.Sound.Heard, info)
return sound.Original(info, ...)
end
return true
end
end
return false
end
function Reicht.Sound.Uninstall()
local sound = Reicht.Sound
if sound.Entry then sound.Entry.callback = sound.Original end
sound.Entry, sound.Original = nil, nil
for _, mark in ipairs(sound.Marks) do mark.Gui:Destroy() end
table.clear(sound.Marks)
end
function Reicht.Sound.Friendly(pos)
local range = Reicht.Config.SoundSelfRange
local me = Reicht.Player.Character()
if me and (me:GetPivot().Position - pos).Magnitude < range then return true end
if Reicht.Target.FreeForAll() then return false end
for _, model in ipairs(Reicht.Target.Candidates()) do
if not Reicht.Target.IsEnemy(model) and (model:GetPivot().Position - pos).Magnitude < range then return true end
end
return false
end
function Reicht.Sound.Heard(info)
if type(info) ~= "table" or typeof(info.Position) ~= "Vector3" then return end
local floor = info.Class == "FloorSounds"
if not floor and info.Name ~= "Shoot" then return end
if Reicht.Sound.Friendly(info.Position) then return end
Reicht.Esp.Hear(info.Position, not floor and tostring(info.Class) or nil)
if Reicht.Options.SoundEsp then Reicht.Sound.Mark(info.Position, floor and "Steps" or tostring(info.Class)) end
end
function Reicht.Sound.Mark(pos, label)
local sound = Reicht.Sound
if not (sound.Folder and sound.Folder.Parent) then
sound.Folder = Instance.new("Folder")
sound.Folder.Name = "ReichtSounds"
sound.Folder.Parent = Workspace.Terrain
end
if #sound.Marks >= Reicht.Config.SoundMaxMarks then
table.remove(sound.Marks, 1).Gui:Destroy()
end
local holder = Instance.new("Attachment")
holder.WorldPosition = pos
local gui = Instance.new("BillboardGui")
gui.AlwaysOnTop, gui.Size, gui.LightInfluence = true, UDim2.fromOffset(120, 34), 0
local text = Instance.new("TextLabel")
text.BackgroundTransparency, text.Size, text.Font, text.TextSize = 1, UDim2.fromScale(1, 1), Enum.Font.GothamBold, 13
text.TextColor3, text.TextStrokeTransparency = Reicht.Config.SoundColor, 0.3
text.Parent = gui
gui.Parent = holder
holder.Parent = Workspace.Terrain
gui.Adornee = holder
sound.Marks[#sound.Marks + 1] = { Gui = holder, Text = text, Label = label, Born = osClock() }
end
function Reicht.Sound.Step()
local sound, life = Reicht.Sound, Reicht.Options.SoundEspLife
local cam = Workspace.CurrentCamera
for index = #sound.Marks, 1, -1 do
local mark = sound.Marks[index]
local age = osClock() - mark.Born
if age > life or not Reicht.Options.SoundEsp then
mark.Gui:Destroy()
table.remove(sound.Marks, index)
else
local dist = cam and math.floor((mark.Gui.WorldPosition - cam.CFrame.Position).Magnitude) or 0
mark.Text.Text = ("%s\n%dm"):format(mark.Label, dist)
mark.Text.TextTransparency = age / life * 0.8
end
end
end
Reicht.World = {}
function Reicht.World.Step()
local opts, state = Reicht.Options, Reicht.State
if opts.Fullbright then
state.LightSaved = state.LightSaved or { Lighting.Brightness, Lighting.ClockTime, Lighting.FogEnd, Lighting.GlobalShadows, Lighting.Ambient }
Lighting.Brightness, Lighting.ClockTime, Lighting.FogEnd, Lighting.GlobalShadows = 2, 14, 1e6, false
Lighting.Ambient = Color3.fromRGB(178, 178, 178)
elseif state.LightSaved then
Lighting.Brightness, Lighting.ClockTime, Lighting.FogEnd, Lighting.GlobalShadows, Lighting.Ambient = table.unpack(state.LightSaved)
state.LightSaved = nil
end
end
function Reicht.World.HookEffects()
local smoke, flash = Reicht.GameLib.Smoke, Reicht.GameLib.Flash
if smoke and type(smoke.Create) == "function" then
local create
create = Reicht.Util.Hook("Smoke", smoke.Create, function(...)
if Reicht.Options.NoSmoke then return nil end
return create(...)
end)
end
if flash and type(flash.Flash) == "function" then
local blind
blind = Reicht.Util.Hook("Flash", flash.Flash, function(...)
if Reicht.Options.NoFlash then return nil end
return blind(...)
end)
end
if Reicht.Options.NoSmoke and smoke then pcall(smoke.DestroyAll) end
if Reicht.Options.NoFlash and flash then pcall(flash.CancelFlash) end
end
function Reicht.World.OnIdled()
if not Reicht.Options.AntiAfk then return end
pcall(function()
VirtualUser:CaptureController()
VirtualUser:ClickButton2(vector2New())
end)
end
function Reicht.World.OnJump()
if not Reicht.Options.InfiniteJump or Reicht.Player.Body() then return end
local hum = Reicht.Player.Humanoid()
if hum then hum:ChangeState(Enum.HumanoidStateType.Jumping) end
end
function Reicht.World.SetCrouch(down)
local state = Reicht.State
if state.HopCrouched == down then return end
state.HopCrouched = down
local controller = Reicht.GameLib.Character
if not controller then return end
if not down and UserInputService:IsKeyDown(Enum.KeyCode.LeftControl) then return end
controller.crouch(down)
end
function Reicht.World.OnSpace(input, down, processed)
if input.KeyCode ~= Enum.KeyCode.Space then return end
if down and UserInputService:GetFocusedTextBox() then return end
Reicht.State.SpaceHeld = down
end
function Reicht.World.Hop()
local opts, state = Reicht.Options, Reicht.State
local body = opts.BunnyHop and state.SpaceHeld and Reicht.Player.Alive() and Reicht.Player.Body()
if not body or UserInputService:GetFocusedTextBox() then
Reicht.World.SetCrouch(false)
return
end
local controller = Reicht.GameLib.Character
local grounded = body.OnGround == true
Reicht.World.SetCrouch(opts.BunnyCrouch and not grounded)
controller.jump(false)
if not grounded or osClock() - state.HopAt < Reicht.Config.HopGap then return end
state.HopAt = osClock()
controller.jump()
end
function Reicht.World.HopStep()
local ok, err = pcall(Reicht.World.Hop)
if ok then
Reicht.Faults.Clear("Bunny Hop")
else
Reicht.Faults.Report("Bunny Hop", err, { "BunnyHop" }, Reicht.World.Hop)
end
end
function Reicht.World.Rejoin()
pcall(TeleportService.TeleportToPlaceInstance, TeleportService, game.PlaceId, game.JobId, LocalPlayer)
end
function Reicht.World.ServerHop()
pcall(TeleportService.Teleport, TeleportService, game.PlaceId, LocalPlayer)
end
Reicht.Skins = { Map = {}, Applied = setmetatable({}, { __mode = "k" }), Catalog = nil, Rarity = {}, Images = {}, Colors = {}, Originals = setmetatable({}, { __mode = "k" }) }
function Reicht.Skins.Folder()
local assets = ReplicatedStorage:FindFirstChild("Assets")
return assets and assets:FindFirstChild("Skins")
end
function Reicht.Skins.CategoryOf(name, kind)
local mapped = Reicht.Config.SkinKinds[kind]
if mapped then return mapped end
if kind ~= "Weapon" then return nil end
local gun = Reicht.Weapons[name]
return gun and gun.Type or "Other"
end
function Reicht.Skins.Build()
local skins = Reicht.Skins
local folder = skins.Folder()
local listing = Reicht.Util.Decode(ReplicatedStorage:GetAttribute("AvaiableSkins")) or {}
local ranks = Reicht.Config.SkinRanks
local catalog = {}
for name, entries in pairs(listing) do
if type(entries) ~= "table" or not (folder and folder:FindFirstChild(name)) then continue end
local _, first = next(entries)
local category = skins.CategoryOf(name, type(first) == "table" and first.type)
if not category then continue end
catalog[category] = catalog[category] or {}
table.insert(catalog[category], name)
skins.Rarity[name], skins.Images[name], skins.Colors[name] = {}, {}, {}
for skin, entry in pairs(entries) do
if type(entry) ~= "table" then continue end
skins.Rarity[name][skin] = ranks[entry.rarity] or 0
local look = type(entry.wearImages) == "table" and entry.wearImages[1]
skins.Images[name][skin] = look and look.assetId
local rarity = Reicht.GameLib.Rarities and Reicht.GameLib.Rarities[entry.rarity]
skins.Colors[name][skin] = type(rarity) == "table" and rarity.Color or nil
end
end
for _, names in pairs(catalog) do table.sort(names) end
skins.Catalog = catalog
end
function Reicht.Skins.Categories()
if not Reicht.Skins.Catalog then Reicht.Skins.Build() end
local list, seen = {}, {}
for _, category in ipairs(Reicht.Config.SkinOrder) do
if Reicht.Skins.Catalog[category] then list[#list + 1] = category seen[category] = true end
end
for category in pairs(Reicht.Skins.Catalog) do
if not seen[category] then list[#list + 1] = category end
end
if #list == 0 then list[1] = "-" end
return list
end
function Reicht.Skins.Items(category)
if not Reicht.Skins.Catalog then Reicht.Skins.Build() end
local names = Reicht.Skins.Catalog[category or ""]
return (names and #names > 0) and names or { "-" }
end
function Reicht.Skins.List(weapon)
local folder = Reicht.Skins.Folder()
local holder = folder and folder:FindFirstChild(weapon or "")
if not holder then return { "-" } end
local ranks = Reicht.Skins.Rarity[weapon] or {}
local names = {}
for _, child in ipairs(holder:GetChildren()) do names[#names + 1] = child.Name end
table.sort(names, function(a, b)
local ra, rb = ranks[a] or 0, ranks[b] or 0
if ra ~= rb then return ra > rb end
return a < b
end)
return #names > 0 and names or { "-" }
end
function Reicht.Skins.Source(weapon, skin, view)
local folder = Reicht.Skins.Folder()
local paint = folder and folder:FindFirstChild(weapon) and folder[weapon]:FindFirstChild(skin)
local side = paint and paint:FindFirstChild(view)
if not side then return nil end
for _, wear in ipairs(Reicht.Config.SkinWears) do
if side:FindFirstChild(wear) then return side[wear] end
end
return side:FindFirstChildOfClass("Folder")
end
function Reicht.Skins.Paint(model, weapon, skin, view)
local source = Reicht.Skins.Source(weapon, skin, view)
if not source then return false end
local whole = source:FindFirstChild("SurfaceAppearance")
local arms = Reicht.Config.SkinArms
for _, part in ipairs(model:GetDescendants()) do
if not part:IsA("BasePart") then continue end
local old = part:FindFirstChildOfClass("SurfaceAppearance")
local look = source:FindFirstChild(part.Name)
if not look and whole and old and not arms[part.Name] then look = whole end
if not look then continue end
local originals = Reicht.Skins.Originals
if originals[part] == nil then originals[part] = old and old:Clone() or false end
if old then old:Destroy() end
look:Clone().Parent = part
end
return true
end
function Reicht.Skins.Reset(model)
local originals = Reicht.Skins.Originals
for _, part in ipairs(model:GetDescendants()) do
local saved = part:IsA("BasePart") and originals[part]
if saved == nil then continue end
local current = part:FindFirstChildOfClass("SurfaceAppearance")
if current then current:Destroy() end
if saved then saved:Clone().Parent = part end
originals[part] = nil
end
end
function Reicht.Skins.WeaponOf(model)
local folder = Reicht.Skins.Folder()
if folder and folder:FindFirstChild(model.Name) then return model.Name end
local equipped = Reicht.Player.Equipped()
return equipped and (equipped.Weapon or equipped.Name)
end
function Reicht.Skins.Models()
local list = {}
for _, child in ipairs(Workspace.CurrentCamera:GetChildren()) do
if child:IsA("Model") then list[#list + 1] = { child, "Camera" } end
end
local char = Reicht.Player.Character()
local folder = Reicht.Skins.Folder()
if char and folder then
for _, child in ipairs(char:GetChildren()) do
if child:IsA("Model") and folder:FindFirstChild(child.Name) then list[#list + 1] = { child, "Character" } end
end
end
return list
end
function Reicht.Skins.Step()
local skins = Reicht.Skins
local on = Reicht.Options.SkinChanger
local glove = on and skins.Map[Reicht.Config.GloveKey]
local gloveSkin = glove and skins.Map[glove]
for _, entry in ipairs(skins.Models()) do
local model, view = entry[1], entry[2]
local weapon = skins.WeaponOf(model)
local skin = on and weapon and skins.Map[weapon] or nil
local key = (skin or gloveSkin) and (tostring(weapon) .. "|" .. tostring(skin) .. "|" .. tostring(gloveSkin)) or nil
if skins.Applied[model] == key then continue end
if skins.Applied[model] then skins.Reset(model) end
if skin then skins.Paint(model, weapon, skin, view) end
if gloveSkin and view == "Camera" then skins.Paint(model, glove, gloveSkin, view) end
skins.Applied[model] = key
end
end
function Reicht.Skins.Set(weapon, skin, quiet)
if not weapon or weapon == "-" or not skin or skin == "-" then return false end
local map, gloveKey = Reicht.Skins.Map, Reicht.Config.GloveKey
local isGlove = Reicht.Skins.Catalog and table.find(Reicht.Skins.Catalog.Gloves or {}, weapon)
if skin == "Default" then
if map[weapon] == nil then return false end
map[weapon] = nil
if map[gloveKey] == weapon then map[gloveKey] = nil end
else
if map[weapon] == skin then return false end
map[weapon] = skin
if isGlove then map[gloveKey] = weapon end
end
if not quiet then Reicht.Skins.Save() end
return true
end
function Reicht.Skins.SetAll(pick)
local count = 0
for _, category in ipairs(Reicht.Skins.Categories()) do
if category == "Gloves" then continue end
for _, weapon in ipairs(Reicht.Skins.Items(category)) do
Reicht.Skins.Set(weapon, pick(Reicht.Skins.List(weapon)), true)
count += 1
end
end
Reicht.Skins.Save()
return count
end
function Reicht.Skins.Save()
if type(writefile) ~= "function" then return end
local ok, err = pcall(function()
if type(isfolder) == "function" and not isfolder(Reicht.Config.SaveFolder) then makefolder(Reicht.Config.SaveFolder) end
writefile(Reicht.Config.SkinFile, HttpService:JSONEncode(Reicht.Skins.Map))
end)
if not ok then warn("[BloxStrike] skins save:", err) end
end
function Reicht.Skins.Load()
if type(readfile) ~= "function" or type(isfile) ~= "function" then return end
local ok, raw = pcall(function() return isfile(Reicht.Config.SkinFile) and readfile(Reicht.Config.SkinFile) end)
local map = ok and Reicht.Util.Decode(raw)
if type(map) == "table" then Reicht.Skins.Map = map end
end
Reicht.Economy = {}
function Reicht.Economy.RedeemAll()
local net = Reicht.GameLib.Net
local packet = net and net.Dashboard and net.Dashboard.RedeemCode
if not packet or Reicht.State.Redeeming then return 0 end
Reicht.State.Redeeming = true
local sent = 0
for _, code in ipairs(Reicht.Config.Codes) do
if pcall(packet.Send, code) then sent += 1 end
task.wait(Reicht.Config.RedeemGap)
end
Reicht.State.Redeeming = false
return sent
end
function Reicht.Economy.HookBuys()
local net = Reicht.GameLib.Net
local packet = net and net.Inventory and net.Inventory.BuyMenuPurchase
if not packet then return end
local original
original = Reicht.Util.Hook("Buy", packet.Send, function(payload, ...)
if type(payload) == "table" and payload.Name and not Reicht.State.Replaying then
local list = Reicht.State.Bought
for index, entry in ipairs(list) do
if entry.Name == payload.Name then table.remove(list, index) break end
end
list[#list + 1] = { Equipment = payload.Equipment, Path = payload.Path, Name = payload.Name }
end
return original(payload, ...)
end)
end
function Reicht.Economy.Rebuy()
local net = Reicht.GameLib.Net
local packet = net and net.Inventory and net.Inventory.BuyMenuPurchase
if not packet or #Reicht.State.Bought == 0 or Reicht.State.Replaying then return 0 end
Reicht.State.Replaying = true
local sent = 0
for _, entry in ipairs(Reicht.State.Bought) do
if pcall(packet.Send, { Equipment = entry.Equipment, Path = entry.Path, Name = entry.Name }) then sent += 1 end
task.wait(Reicht.Config.RebuyGap)
end
Reicht.State.Replaying = false
return sent
end
function Reicht.Economy.Step()
local state = Reicht.State
local phase = Workspace:GetAttribute("GameState")
local entered = Reicht.Config.BuyStates[phase] and phase ~= state.LastPhase
state.LastPhase = phase
if not entered then state.RebuyPending = state.RebuyPending and Reicht.Config.BuyStates[phase] return end
state.RebuyPending = true
end
function Reicht.Economy.Tick()
local state = Reicht.State
Reicht.Economy.Step()
if not (Reicht.Options.AutoRebuy and state.RebuyPending and Reicht.Player.Alive()) then return end
state.RebuyPending = false
task.spawn(Reicht.Economy.Rebuy)
end
function Reicht.Economy.BoughtText()
local names = {}
for _, entry in ipairs(Reicht.State.Bought) do names[#names + 1] = entry.Name end
return #names > 0 and table.concat(names, ", ") or "-"
end
Reicht.Spectators = {}
function Reicht.Spectators.Text()
local count = tonumber(LocalPlayer:GetAttribute("Spectators")) or 0
if count == 0 then return "None" end
local names = {}
for _, player in ipairs(Players:GetPlayers()) do
if player ~= LocalPlayer and tostring(player:GetAttribute("IsSpectating")) == "true" and tostring(player:GetAttribute("Dead")) == "true" then
names[#names + 1] = player.DisplayName
end
end
return count .. " watching" .. (#names > 0 and (" (dead: " .. table.concat(names, ", ") .. ")") or "")
end
Reicht.Faults = { Streaks = {} }
function Reicht.Faults.Clear(name)
Reicht.Faults.Streaks[name] = nil
end
function Reicht.Faults.AnyOn(toggles)
for _, key in ipairs(toggles) do
if Reicht.Options[key] then return true end
end
return false
end
function Reicht.Faults.Halt(name, err, toggles, restore)
warn("[BloxStrike] " .. name .. " stopped:", err)
for _, key in ipairs(toggles) do
Reicht.Options[key] = false
end
if restore then Reicht.Util.Try(name .. " restore", restore) end
local halted = Reicht.State.Halted
halted[#halted + 1] = { name, tostring(err):match("^[^\n]*"), toggles }
end
function Reicht.Faults.Report(name, err, toggles, restore)
local now, streaks = osClock(), Reicht.Faults.Streaks
local streak = streaks[name]
if not streak or (streak.Halted and Reicht.Faults.AnyOn(toggles)) then
streak = { Count = 0, First = now, Warned = false, Halted = false }
streaks[name] = streak
end
streak.Count += 1
if streak.Warned then return streak.Halted end
if streak.Count < Reicht.Config.MaxFails or now - streak.First < Reicht.Config.FailWindow then return false end
streak.Warned = true
if #toggles == 0 then
warn("[BloxStrike] " .. name .. " keeps failing:", err)
return false
end
streak.Halted = true
Reicht.Faults.Halt(name, err, toggles, restore)
return true
end
Reicht.Scheduler = { Jobs = {} }
function Reicht.Scheduler.Every(name, interval, fn, toggles, restore)
Reicht.Scheduler.Jobs[name] = { Interval = interval, Fn = fn, Next = 0, Toggles = toggles, Restore = restore }
end
function Reicht.Scheduler.Resume(name, job)
if not Reicht.Faults.AnyOn(job.Toggles) then return false end
job.Halted = false
Reicht.Faults.Clear(name)
return true
end
function Reicht.Scheduler.Boot()
Reicht:Connect(RunService.Heartbeat, function()
local now = osClock()
for name, job in pairs(Reicht.Scheduler.Jobs) do
if now < job.Next then continue end
job.Next = now + job.Interval
if job.Halted and not Reicht.Scheduler.Resume(name, job) then continue end
local ok, err = pcall(job.Fn)
if ok then
Reicht.Faults.Clear(name)
else
job.Halted = Reicht.Faults.Report(name, err, job.Toggles, job.Restore)
end
end
end)
end
Reicht.UI = { Labels = {} }
function Reicht.UI.Detach(fn)
return function(...)
local packed = table.pack(...)
task.defer(function()
local ok, err = pcall(fn, table.unpack(packed, 1, packed.n))
if not ok then warn("[BloxStrike] ui:", err) end
end)
end
end
function Reicht.UI.Bind(widget, key)
local function Apply(value) Reicht.Options[key] = value end
Apply(widget.Value)
widget:OnChanged(Apply)
end
function Reicht.UI.AddKeyMode(group, toggleIdx, keyIdx, default)
group:AddDropdown(toggleIdx .. "Mode", { Text = T("Key mode", "โหมดปุ่ม"), Values = { "Hold", "Toggle", "Always" }, Default = default, Callback = function(mode)
local picker = Library.Options[keyIdx]
if picker then picker:SetValue({ picker.Value, mode }) end
end })
end
function Reicht.UI.NamedToggle(group, idx, info)
local toggle = group:AddToggle(idx, info)
toggle.Info = toggle.Info or info
return toggle
end
function Reicht.UI.BuildMain(window)
window:AddTabSection(T("Main", "หลัก"))
local tab = window:AddTab(T("Main", "หลัก"), "mushroom", T("Status and links", "สถานะและลิงก์"))
local status = tab:AddLeftGroupbox(T("Status", "สถานะ"), "star")
Reicht.UI.Labels.Match = status:AddParagraph({ Title = T("Match", "แมตช์"), Content = "-" })
Reicht.UI.Labels.Combat = status:AddParagraph({ Title = T("Combat", "การต่อสู้"), Content = "-" })
Reicht.UI.Labels.Spectators = status:AddParagraph({ Title = T("Spectators", "คนดูเรา"), Content = "-" })
Reicht.UI.Labels.Esp = status:AddParagraph({ Title = T("ESP", "ESP"), Content = "-" })
local discord = tab:AddRightGroupbox(T("Discord", "ดิสคอร์ด"), "link")
discord:AddLabel(Reicht.Config.Discord)
discord:AddButton({ Text = T("Copy Discord Link", "คัดลอกลิงก์ดิสคอร์ด"), Func = Reicht.UI.Detach(function()
if Reicht.Util.Copy(Reicht.Config.Discord) then
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
local priorities = { "Crosshair", "Distance", "Health" }
function Reicht.UI.BuildAimbot(window)
window:AddTabSection(T("Combat", "การต่อสู้"))
local tab = window:AddTab(T("Aimbot", "เล็งอัตโนมัติ"), "crosshair", T("Locks your camera onto enemies", "ล็อคกล้องไปที่ศัตรู"))
local main = tab:AddLeftGroupbox(T("Aimbot", "เล็งอัตโนมัติ"), "crosshair")
main:AddToggle("Aimbot", { Text = T("Aimbot", "เล็งอัตโนมัติ"), Description = T("Locks your view onto the enemy in the FOV", "ล็อคกล้องไปที่ศัตรูในวง FOV") })
:AddKeyPicker("AimbotKey", { Default = "E", Mode = "Toggle" })
Reicht.UI.AddKeyMode(main, "Aimbot", "AimbotKey", "Toggle")
main:AddSlider("AimbotSmooth", { Text = T("Smoothness", "ความนุ่ม"), Description = T("1 = instant snap", "1 = หันทันที"), Min = 1, Max = 20, Default = 1, Rounding = 0 })
main:AddCheckbox("AimbotSticky", { Text = T("Sticky target", "ล็อคเป้าเดิม"), Description = T("Keeps the same enemy until it is lost", "ไม่สลับเป้าจนกว่าเป้าเดิมจะหลุด"), Default = true })
local target = tab:AddRightGroupbox(T("Aimbot Targeting", "การเลือกเป้า (เล็ง)"), "target")
target:AddDropdown("AimbotBone", { Text = T("Aim part", "จุดที่เล็ง"), Values = { "Head", "Torso" }, Default = "Head" })
target:AddDropdown("AimbotPriority", { Text = T("Priority", "เลือกเป้าตาม"), Values = priorities, Default = "Crosshair" })
target:AddCheckbox("AimbotVisible", { Text = T("Visible only", "เฉพาะที่มองเห็น"), Default = true })
target:AddSlider("AimbotFov", { Text = T("FOV", "ขนาดวง"), Min = 20, Max = 800, Default = 150, Suffix = "px" })
target:AddToggle("AimbotShowFov", { Text = T("Show FOV circle", "แสดงวง FOV") })
target:AddSlider("AimbotMaxDistance", { Text = T("Max distance", "ระยะสูงสุด"), Min = 50, Max = 3000, Default = 1500, Suffix = "m" })
end
function Reicht.UI.BuildSilent(window)
local tab = window:AddTab(T("Silent Aim", "ไซเลนต์เอม"), "bomb", T("Your shots find the enemy for you", "กระสุนวิ่งหาศัตรูเอง"))
local main = tab:AddLeftGroupbox(T("Silent Aim", "ไซเลนต์เอม"), "bomb")
Reicht.UI.NamedToggle(main, "SilentAim", { Text = T("Silent aim", "ไซเลนต์เอม"), Description = T("Shots you fire go to the enemy in the FOV", "นัดที่ยิงพุ่งไปหาศัตรูในวง FOV") })
:AddKeyPicker("SilentKey", { Default = "None", Mode = "Toggle" })
main:AddSlider("SilentHitChance", { Text = T("Hit chance", "โอกาสโดน"), Description = T("Lower looks more legit", "ยิ่งต่ำยิ่งดูเนียน"), Min = 1, Max = 100, Default = 100, Rounding = 0, Suffix = "%" })
main:AddSlider("SilentHeadChance", { Text = T("Headshot chance", "โอกาสเข้าหัว"), Description = T("The rest go to the body", "ที่เหลือเข้าลำตัว"), Min = 0, Max = 100, Default = 100, Rounding = 0, Suffix = "%" })
Library.Compat.NeedCap("SilentAim", { "HookFunction", "Gc" })
local target = tab:AddRightGroupbox(T("Silent Targeting", "การเลือกเป้า (ไซเลนต์)"), "target")
target:AddDropdown("SilentPriority", { Text = T("Priority", "เลือกเป้าตาม"), Values = priorities, Default = "Crosshair" })
target:AddCheckbox("SilentVisible", { Text = T("Visible only", "เฉพาะที่มองเห็น"), Description = T("Off = also through walls", "ปิด = ยิงทะลุกำแพงด้วย"), Default = true })
target:AddSlider("SilentFov", { Text = T("FOV", "ขนาดวง"), Min = 20, Max = 1000, Default = 220, Suffix = "px" })
target:AddToggle("SilentShowFov", { Text = T("Show FOV circle", "แสดงวง FOV") })
target:AddSlider("SilentMaxDistance", { Text = T("Max distance", "ระยะสูงสุด"), Min = 50, Max = 3000, Default = 2000, Suffix = "m" })
target:AddCheckbox("SilentPredict", { Text = T("Lead moving targets", "ยิงดักคนที่วิ่ง"), Default = false })
end
function Reicht.UI.BuildTrigger(window)
local tab = window:AddTab(T("Trigger & Rage", "ยิงออโต้ & เรจ"), "zap", T("Shoots for you", "ยิงให้อัตโนมัติ"))
local trigger = tab:AddLeftGroupbox(T("Triggerbot", "ยิงอัตโนมัติ"), "zap")
trigger:AddToggle("Triggerbot", { Text = T("Triggerbot", "ยิงอัตโนมัติ"), Description = T("Fires the moment an enemy is under your crosshair", "ยิงทันทีที่ศัตรูอยู่ใต้เป้า") })
:AddKeyPicker("TriggerKey", { Default = "T", Mode = "Toggle" })
Reicht.UI.AddKeyMode(trigger, "Triggerbot", "TriggerKey", "Toggle")
trigger:AddSlider("TriggerDelay", { Text = T("Reaction delay", "ดีเลย์ก่อนยิง"), Min = 0, Max = 400, Default = 0, Rounding = 0, Suffix = "ms" })
trigger:AddSlider("TriggerHitChance", { Text = T("Fire chance", "โอกาสยิง"), Min = 1, Max = 100, Default = 100, Rounding = 0, Suffix = "%" })
local rage = tab:AddRightGroupbox(T("Ragebot", "เรจบอท"), "bomb")
Reicht.UI.NamedToggle(rage, "Ragebot", { Text = T("Ragebot", "เรจบอท"), Description = T("Snaps to and kills any enemy it can reach on its own", "หันไปยิงศัตรูที่ยิงถึงเองทันที") })
:AddKeyPicker("RageKey", { Default = "None", Mode = "Toggle" })
rage:AddCheckbox("RageVisible", { Text = T("Visible only", "เฉพาะที่มองเห็น"), Description = T("Off = also through walls", "ปิด = ยิงทะลุกำแพงด้วย"), Default = true })
rage:AddSlider("RageMaxDistance", { Text = T("Max distance", "ระยะสูงสุด"), Min = 50, Max = 3000, Default = 2000, Suffix = "m" })
end
function Reicht.UI.BuildGuns(window)
local tab = window:AddTab(T("Gun Mods", "ม็อดปืน"), "swords", T("Recoil and spread", "แรงถีบและการกระจาย"))
local mods = tab:AddLeftGroupbox(T("Gun Mods", "ม็อดปืน"), "swords")
Reicht.UI.NamedToggle(mods, "NoRecoil", { Text = T("No recoil", "ไม่มีแรงถีบ"), Description = T("Your view stays still while spraying", "จอนิ่งตอนกดยิงค้าง") })
Reicht.UI.NamedToggle(mods, "NoSpread", { Text = T("No spread", "ไม่มีการกระจาย"), Description = T("Every bullet lands on the crosshair", "ทุกนัดลงกลางเป้า") })
Library.Compat.NeedCap("NoRecoil", "HookFunction")
Library.Compat.NeedCap("NoSpread", { "HookFunction", "Gc" })
end
function Reicht.UI.BuildVisuals(window)
window:AddTabSection(T("Visuals", "การมองเห็น"))
Reicht.Util.Try("visuals tab", function()
window:AddVisualsTab({ Provider = Reicht.Esp.Targets, Preview = true })
end)
local tab = window:AddTab(T("World", "โลก"), "globe", T("Lighting, flash and smoke", "แสง แฟลช และควัน"))
local world = tab:AddLeftGroupbox(T("World", "โลก"), "flower")
world:AddToggle("Fullbright", { Text = T("Fullbright", "สว่างทั้งแมพ") })
world:AddToggle("NoFlash", { Text = T("No flash", "กันแฟลช"), Description = T("Flashbangs do not blind you", "แฟลชไม่ทำให้ตาบอด") })
world:AddToggle("NoSmoke", { Text = T("No smoke", "ไม่มีควัน"), Description = T("See through smoke grenades", "มองทะลุควัน") })
local heard = tab:AddLeftGroupbox(T("Hidden Enemies", "ศัตรูหลังกำแพง"), "eye")
Reicht.UI.NamedToggle(heard, "SoundEsp", { Text = T("Sound ESP", "ESP จากเสียง"), Description = T("Shows where enemies walk and shoot, even behind walls", "โชว์จุดที่ศัตรูเดินและยิง แม้อยู่หลังกำแพง") })
heard:AddSlider("SoundEspLife", { Text = T("Show for", "แสดงนาน"), Min = 1, Max = 8, Default = 3, Rounding = 0, Suffix = "s" })
heard:AddSlider("EspMemory", { Text = T("Keep hidden enemies", "จำศัตรูที่หลบ"), Description = T("ESP keeps a box where an enemy was last seen or heard", "ESP ค้างกล่องไว้ที่ที่เห็นหรือได้ยินศัตรูล่าสุด"), Min = 0, Max = 15, Default = 5, Rounding = 0, Suffix = "s" })
Library.Compat.NeedCap("SoundEsp", "Upvalues")
local cam = tab:AddRightGroupbox(T("Camera", "กล้อง"), "eye")
Reicht.UI.NamedToggle(cam, "CameraFov", { Text = T("Custom FOV", "ปรับมุมมอง") })
cam:AddSlider("CameraFovValue", { Text = T("FOV", "มุมมอง"), Min = 70, Max = 120, Default = 100, Rounding = 0 })
end
local skinTitles = {
Pistol = { "Pistols", "ปืนพก", "coin" },
SMG = { "SMGs", "ปืนกลมือ", "zap" },
Rifle = { "Rifles", "ปืนไรเฟิล", "crosshair" },
Sniper = { "Snipers", "สไนเปอร์", "target" },
Heavy = { "Heavy", "ปืนหนัก", "bomb" },
Shotgun = { "Shotguns", "ลูกซอง", "bomb" },
["Machine Gun"] = { "Machine Guns", "ปืนกล", "zap" },
Knives = { "Knives", "มีด", "swords" },
Gloves = { "Gloves", "ถุงมือ", "shield" },
Grenades = { "Grenades", "ระเบิด", "bomb" },
Gear = { "Gear", "อุปกรณ์", "gear" },
}
function Reicht.UI.SkinGroup(tab, category, side)
local title = skinTitles[category] or { category, category, "star" }
local group = side == "Left" and tab:AddLeftGroupbox(T(title[1], title[2]), title[3]) or tab:AddRightGroupbox(T(title[1], title[2]), title[3])
for _, weapon in ipairs(Reicht.Skins.Items(category)) do
if weapon == "-" then continue end
local values = { "Default" }
for _, skin in ipairs(Reicht.Skins.List(weapon)) do values[#values + 1] = skin end
group:AddDropdown("Skin_" .. weapon, { Text = weapon, Values = values, Default = Reicht.Skins.Map[weapon] or "Default", Searchable = true, Images = Reicht.Skins.Images[weapon], Colors = Reicht.Skins.Colors[weapon], Callback = function(skin)
Reicht.Skins.Set(weapon, skin)
end })
end
end
function Reicht.UI.PlaceSkinGroup(tab, category, heights)
local side = heights.Left <= heights.Right and "Left" or "Right"
local rows = 1
for _, weapon in ipairs(Reicht.Skins.Items(category)) do
if weapon ~= "-" then rows += 1 end
end
if rows == 1 then return end
heights[side] += rows
Reicht.Util.Try("skins " .. category, Reicht.UI.SkinGroup, tab, category, side)
end
function Reicht.UI.SyncSkins()
for _, category in ipairs(Reicht.Skins.Categories()) do
for _, weapon in ipairs(Reicht.Skins.Items(category)) do
local picker = Library.Options["Skin_" .. weapon]
if picker then picker:SetValue(Reicht.Skins.Map[weapon] or "Default") end
end
end
end
function Reicht.UI.BuildSkins(window)
local tab = window:AddTab(T("Skins", "สกิน"), "star", T("Any skin, only on your screen", "ใส่สกินไหนก็ได้ เห็นแค่บนจอคุณ"))
local main = tab:AddLeftGroupbox(T("Skin Changer", "เปลี่ยนสกิน"), "star")
main:AddToggle("SkinChanger", { Text = T("Skin changer", "เปลี่ยนสกิน"), Description = T("Pick a skin below and it shows right away", "เลือกสกินด้านล่างแล้วขึ้นทันที") })
main:AddButton({ Text = T("Rarest On Everything", "หายากสุดทุกอัน"), Style = "Primary", Func = Reicht.UI.Detach(function()
local count = Reicht.Skins.SetAll(function(list) return list[1] end)
Reicht.UI.SyncSkins()
Library:Notify("Skins", "Set " .. count .. " items", 3, "Success")
end) })
main:AddButton({ Text = T("Random", "สุ่ม"), Func = Reicht.UI.Detach(function()
Reicht.Skins.SetAll(function(list) return list[math.random(#list)] end)
Reicht.UI.SyncSkins()
end) }):AddButton({ Text = T("Reset All", "ล้างทั้งหมด"), Style = "Danger", Func = Reicht.UI.Detach(function()
table.clear(Reicht.Skins.Map)
Reicht.Skins.Save()
Reicht.UI.SyncSkins()
end) })
local gear = { Knives = true, Gloves = true, Grenades = true, Gear = true }
local heights = { Left = Reicht.Config.SkinMainRows, Right = 0 }
for _, category in ipairs({ "Knives", "Gloves", "Grenades", "Gear" }) do
Reicht.UI.PlaceSkinGroup(tab, category, heights)
end
local guns = window:AddTab(T("Gun Skins", "สกินปืน"), "crosshair", T("Skins for every gun", "สกินปืนทุกกระบอก"))
heights = { Left = 0, Right = 0 }
local ok, categories = pcall(Reicht.Skins.Categories)
for _, category in ipairs(ok and categories or {}) do
if gear[category] then continue end
Reicht.UI.PlaceSkinGroup(guns, category, heights)
end
end
function Reicht.UI.BuildMisc(window)
window:AddTabSection(T("Misc", "อื่นๆ"))
local tab = window:AddTab(T("Misc", "อื่นๆ"), "gear", T("Buying, codes and utility", "ซื้อของ โค้ด และอื่นๆ"))
local buy = tab:AddLeftGroupbox(T("Auto Buy", "ซื้ออัตโนมัติ"), "shop")
Reicht.UI.NamedToggle(buy, "AutoRebuy", { Text = T("Auto rebuy", "ซื้อซ้ำอัตโนมัติ"), Description = T("Buys your last loadout every round", "ซื้อชุดล่าสุดของคุณให้ทุกรอบ") })
Library.Compat.NeedCap("AutoRebuy", "HookFunction")
Reicht.UI.Labels.Bought = buy:AddParagraph({ Title = T("Saved loadout", "ชุดที่จำไว้"), Content = "-" })
buy:AddButton({ Text = T("Rebuy Now", "ซื้อซ้ำตอนนี้"), Style = "Primary", Func = Reicht.UI.Detach(function()
Reicht.Util.Try("hook buys", Reicht.Economy.HookBuys)
local sent = Reicht.Economy.Rebuy()
Library:Notify("Auto Buy", sent > 0 and ("Bought " .. sent .. " items") or "Buy something once first", 3, sent > 0 and "Success" or "Info")
end) }):AddButton({ Text = T("Clear", "ล้าง"), Func = Reicht.UI.Detach(function()
table.clear(Reicht.State.Bought)
end) })
local codes = tab:AddLeftGroupbox(T("Codes", "โค้ด"), "key")
codes:AddButton({ Text = T("Redeem All Codes", "แลกโค้ดทั้งหมด"), Style = "Primary", Func = Reicht.UI.Detach(function()
local sent = Reicht.Economy.RedeemAll()
Library:Notify("Codes", "Sent " .. sent .. " codes (level 5+ needed)", 4, "Coin")
end) })
local util = tab:AddRightGroupbox(T("Utility", "อรรถประโยชน์"), "flower")
util:AddToggle("InfiniteJump", { Text = T("Infinite jump", "กระโดดไม่จำกัด"), Description = T("Lobby only, use Bunny hop in rounds", "ใช้ได้เฉพาะล็อบบี้ ในรอบใช้บันนี่ฮอป") })
util:AddToggle("BunnyHop", { Text = T("Bunny hop", "บันนี่ฮอป"), Description = T("Hold Space to keep hopping and carry your speed", "กด Space ค้างเพื่อกระโดดต่อเนื่องและรักษาความเร็ว") })
util:AddCheckbox("BunnyCrouch", { Text = T("Crouch jump", "ย่อตอนลอย"), Description = T("Crouches in the air like a CS crouch jump", "ย่อตัวกลางอากาศแบบ crouch jump ใน CS"), Default = true })
util:AddToggle("AntiAfk", { Text = T("Anti AFK", "กันหลุด AFK") })
util:AddButton({ Text = T("Rejoin", "เข้าใหม่"), Func = Reicht.UI.Detach(Reicht.World.Rejoin) })
:AddButton({ Text = T("Server Hop", "ย้ายเซิร์ฟ"), Func = Reicht.UI.Detach(Reicht.World.ServerHop) })
end
function Reicht.UI.RefreshStatus()
local labels, state = Reicht.UI.Labels, Reicht.State
if labels.Match then
labels.Match:SetText(("%s | %s | $%s"):format(tostring(Workspace:GetAttribute("Map") or "-"), tostring(Workspace:GetAttribute("GameState") or "-"), tostring(LocalPlayer:GetAttribute("Money") or 0)))
end
if labels.Combat then
local target = state.RageTarget or state.AimTarget or state.SilentTarget
target = target and target.Name or "none"
labels.Combat:SetText(("Target: %s | Kills %s | Shots %d | Aimed %d"):format(target, tostring(LocalPlayer:GetAttribute("Kills") or 0), state.Shots, state.Redirected))
end
if labels.Spectators then labels.Spectators:SetText(Reicht.Spectators.Text()) end
if labels.Esp then
local visuals = Library.Visuals
labels.Esp:SetText((visuals and visuals:Get("Enabled")) and (Reicht.Esp.Count .. " players") or "Off")
end
if labels.Bought then labels.Bought:SetText(Reicht.Economy.BoughtText()) end
end
function Reicht.UI.Drain()
local state = Reicht.State
if not (state.Halted[1] or state.Notices[1]) then return end
local stopped, notices = table.clone(state.Halted), table.clone(state.Notices)
table.clear(state.Halted)
table.clear(state.Notices)
for _, halt in ipairs(stopped) do
for _, key in ipairs(halt[3]) do
local toggle = Library.Options[key]
if toggle and toggle.Value == true then Reicht.Util.Try("halt " .. key, toggle.SetValue, toggle, false) end
end
Library:Notify("Reicht", halt[1] .. " stopped: " .. halt[2], 6, "Error")
end
for _, notice in ipairs(notices) do
Library:Notify(notice[1], notice[2], 5, "Warning")
end
end
function Reicht.UI.HookOnDemand()
local installers = {
SilentAim = Reicht.Silent.InstallHook,
Ragebot = Reicht.Silent.InstallHook,
Triggerbot = Reicht.Silent.InstallHook,
NoRecoil = Reicht.Guns.HookKick,
CameraFov = Reicht.Guns.BindFov,
NoSpread = Reicht.Guns.HookSpread,
NoSmoke = Reicht.World.HookEffects,
NoFlash = Reicht.World.HookEffects,
AutoRebuy = Reicht.Economy.HookBuys,
SoundEsp = Reicht.Sound.Install,
}
for idx, install in pairs(installers) do
local toggle = Library.Options[idx]
if not toggle then continue end
toggle:OnChanged(function(on)
if on then task.defer(Reicht.Util.Try, "hook " .. idx, install) end
end)
end
local trigger = Library.Options.Triggerbot
if trigger then
trigger:OnChanged(function(on)
if on then task.delay(Reicht.Config.HookSettle, Reicht.UI.WarnReducedTrigger) end
end)
end
end
function Reicht.UI.WarnReducedTrigger()
local state = Reicht.State
if state.Hooks.Shoot or state.TriggerWarned then return end
state.TriggerWarned = true
table.insert(state.Notices, { T("Triggerbot", "ยิงอัตโนมัติ"), T("Running in reduced mode on this executor; shot pacing is less exact", "ทำงานแบบจำกัดบน executor นี้ จังหวะยิงอาจไม่แม่นเท่าที่ควร") })
end
function Reicht.UI.BlockMissing()
local absent = Reicht.GameLib.Missing
local missing = {
Net = Reicht.GameLib.Net == nil and (absent.Remotes or true),
Character = Reicht.GameLib.Character == nil and (absent.CharacterController or true),
Skins = Reicht.Skins.Folder() == nil and "Absent",
}
if missing.Skins then warn("[BloxStrike] Assets.Skins not found, the skin changer is blocked") end
local unsupported = T("Not available on this executor", "ใช้กับ executor นี้ไม่ได้")
local outdated = T("Changed by a game update, wait for a script update", "เกมอัปเดตแล้ว รอสคริปต์อัปเดต")
for source, features in pairs(Reicht.Config.ModuleFeatures) do
local why = missing[source]
if not why then continue end
for _, idx in ipairs(features) do
Library.Compat.Block(idx, why == "Absent" and outdated or unsupported)
end
end
end
function Reicht.UI.Build()
local window = Library.Window
for _, build in ipairs({ Reicht.UI.BuildMain, Reicht.UI.BuildAimbot, Reicht.UI.BuildSilent, Reicht.UI.BuildTrigger, Reicht.UI.BuildGuns, Reicht.UI.BuildVisuals, Reicht.UI.BuildSkins, Reicht.UI.BuildMisc }) do
Reicht.Util.Try("build", build, window)
end
Reicht.Util.Try("settings tab", function() window:AddSettingsTab() end)
for key in pairs(Reicht.Options) do
local widget = Library.Options[key]
if widget then Reicht.Util.Try("bind " .. key, Reicht.UI.Bind, widget, key) end
end
Reicht.Util.Try("hooks", Reicht.UI.HookOnDemand)
Reicht.Util.Try("missing modules", Reicht.UI.BlockMissing)
Library:Every(Reicht.Config.StatusInterval, Reicht.UI.RefreshStatus)
Library:Every(Reicht.Config.StatusInterval, Reicht.UI.Drain)
end
function Reicht.Boot()
Reicht.Util.Try("skins load", Reicht.Skins.Load)
Reicht.Util.Try("combat", Reicht.Combat.Start)
Reicht:Connect(LocalPlayer.Idled, Reicht.World.OnIdled)
Reicht:Connect(UserInputService.JumpRequest, Reicht.World.OnJump)
Reicht:Connect(RunService.Heartbeat, Reicht.World.HopStep)
Reicht:Connect(UserInputService.InputBegan, function(input, processed) Reicht.World.OnSpace(input, true, processed) end)
Reicht:Connect(UserInputService.InputEnded, function(input) Reicht.World.OnSpace(input, false) end)
Reicht.Scheduler.Every("World", 0.2, Reicht.World.Step, { "Fullbright" }, Reicht.World.Step)
Reicht.Scheduler.Every("Auto Rebuy", 0.5, Reicht.Economy.Tick, { "AutoRebuy" })
Reicht.Scheduler.Every("Sound ESP", 0.1, Reicht.Sound.Step, { "SoundEsp" }, Reicht.Sound.Step)
Reicht.Scheduler.Every("Skin Changer", 0.15, Reicht.Skins.Step, { "SkinChanger" }, Reicht.Skins.Step)
Reicht.Util.Try("scheduler", Reicht.Scheduler.Boot)
end
function Reicht:Unload()
self.State.Alive = false
pcall(Reicht.Sound.Uninstall)
if Reicht.Esp.Folder then pcall(function() Reicht.Esp.Folder:Destroy() end) end
Reicht.Combat.Unload()
for _, key in ipairs({ "NoRecoil", "NoSpread", "Fullbright", "CameraFov", "BunnyHop", "SkinChanger" }) do
Reicht.Options[key] = false
end
pcall(Reicht.World.Step)
pcall(Reicht.World.SetCrouch, false)
Reicht.Guns.UnbindFov()
pcall(Reicht.Skins.Step)
for _, conn in ipairs(self.State.Connections) do pcall(function() conn:Disconnect() end) end
table.clear(self.State.Connections)
if Library then Reicht.Util.UnhookAll() end
environment.BloxStrikeUnload = nil
end
local function BuildInterface()
Library = Reicht.Util.LoadLibrary(Reicht.Config.UiSource)
if not Library then return false end
pcall(ReichtBanner.Step, "UI library")
Reicht.Library = Library
T = function(en, th) return Library:T(en, th) end
local opened, err = pcall(Library.CreateWindow, Library, {
Title = "Reicht",
SubTitle = "BloxStrike by Reicht",
MenuKey = Enum.KeyCode.RightControl,
ConfigFolder = Reicht.Config.SaveFolder,
Language = "Auto",
Theme = "Overworld",
Intro = true,
OnUnlocked = function()
Reicht.UI.Build()
task.defer(Reicht.Util.Try, "boot", Reicht.Boot)
task.defer(Reicht.Util.Try, "autoload config", function() Library:LoadAutoloadConfig() end)
end,
})
if not opened then
Reicht.Util.Alert("The menu failed to load on this executor: " .. tostring(err):match("^[^\n]*"), err)
return false
end
Library:OnUnload(function() Reicht:Unload() end)
return true
end
environment.BloxStrikeUnload = function()
if Reicht.Library and not Reicht.Library.Unloaded then
Reicht.Library:Unload()
else
Reicht:Unload()
end
end
pcall(ReichtBanner.Step, "Systems")
if not BuildInterface() then return end
pcall(ReichtBanner.Step, "Interface")
pcall(ReichtBanner.Ready)