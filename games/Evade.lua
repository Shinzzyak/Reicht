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
local VirtualUser = game:GetService("VirtualUser")
local StarterGui = game:GetService("StarterGui")
local Lighting = game:GetService("Lighting")
local Workspace = game:GetService("Workspace")
local LocalPlayer = Players.LocalPlayer
local UI_URL = "https://raw.githubusercontent.com/Shinzzyak/Reicht/refs/heads/main/ui.lua"
local SAVE_FOLDER = "Reicht/Evade"
local State = {
Alive = true,
Opt = {},
Connections = {},
Tracers = {},
}
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
local function Connect(signal, fn)
local connection = signal:Connect(fn)
table.insert(State.Connections, connection)
return connection
end
local function Character()
local character = LocalPlayer.Character
if not character or not character.Parent then return nil, nil, nil end
return character, character:FindFirstChildOfClass("Humanoid"), character:FindFirstChild("HumanoidRootPart")
end
local function Unload()
State.Alive = false
for _, connection in ipairs(State.Connections) do
pcall(function() connection:Disconnect() end)
end
State.Connections = {}
for _, tracer in pairs(State.Tracers) do
pcall(function() tracer:Remove() end)
end
State.Tracers = {}
pcall(function()
local gui = LocalPlayer:FindFirstChild("PlayerGui")
local screen = gui and gui:FindFirstChild("Reicht")
if screen then screen:Destroy() end
end)
end
local function Events()
return ReplicatedStorage:FindFirstChild("Events")
end
local function Event(name)
local events = Events()
local remote = events and events:FindFirstChild(name)
if remote and remote:IsA("RemoteEvent") then return remote end
return nil
end
local function TagOf(model)
if not model then return nil end
return model:GetAttribute("Tag")
end
local function KeybindRemote()
local services = ReplicatedStorage:FindFirstChild("Services")
local client = services and services:FindFirstChild("Client")
local keybind = client and client:FindFirstChild("KeybindService")
return keybind and keybind:FindFirstChild("SendKeybindEvent")
end
local function SendKeybind(key, down)
local remote = KeybindRemote()
if not remote then return false end
return pcall(function() remote:Fire({ Down = down, Key = key }) end)
end
local function Respawn()
local remote = Event("SetPlayerMode")
if not remote then return false end
return pcall(function() remote:FireServer(true) end)
end
local function ReviveTag(tag)
local remote = Event("Interact")
if not remote or not tag then return false end
return pcall(function()
remote:FireServer("Revive", tag)
remote:FireServer("Revive", tag, true)
end)
end
local function Interact(kind, tag)
local remote = Event("Interact")
if not remote or not tag then return false end
return pcall(function() remote:FireServer(kind, tag) end)
end
local function Vote(index, mode)
local remote = Event("Vote")
if not remote then return false end
return pcall(function()
if mode then remote:FireServer(index, true) else remote:FireServer(index) end
end)
end
local function VotePopup()
local gui = LocalPlayer:FindFirstChild("PlayerGui")
local shared = gui and gui:FindFirstChild("Shared")
local popups = shared and shared:FindFirstChild("Popups")
if not popups then return nil end
local active = popups:FindFirstChild("VoteActive")
if active and active.Visible then return active end
local vote = popups:FindFirstChild("Vote")
if vote and vote.Visible then return vote end
return nil
end
local function MovementValueSet(kind, value)
local remote = Event("CharacterTask")
local character = Character()
local tag = character and character:GetAttribute("Tag")
if not remote or not tag or not firesignal then return false end
return pcall(function()
firesignal(remote.OnClientEvent, tag, "ModifyMovement", { kind, value })
end)
end
local function PlayerModels()
local folder = Workspace:FindFirstChild("Players")
return folder
end
local function IsDowned(model)
if not model then return false end
if model:GetAttribute("Downed") == true then return true end
local folder = PlayerModels()
local mirror = folder and folder:FindFirstChild(model.Name)
if mirror and mirror:GetAttribute("Downed") == true then return true end
return false
end
local function FarmTargets()
local folder = PlayerModels()
local out = {}
if not folder then return out end
for _, model in ipairs(folder:GetChildren()) do
if model:IsA("Model")
and model ~= LocalPlayer.Character
and model:FindFirstChild("HumanoidRootPart")
and TagOf(model) ~= nil
then
table.insert(out, model)
end
end
return out
end
local function NearestDowned()
local _, _, root = Character()
if not root then return nil end
local best, bestDist = nil, 20
for _, player in ipairs(Players:GetPlayers()) do
if player ~= LocalPlayer then
local character = player.Character
local hrp = character and character:FindFirstChild("HumanoidRootPart")
if hrp and IsDowned(character) then
local distance = (root.Position - hrp.Position).Magnitude
if distance < bestDist then
best, bestDist = player, distance
end
end
end
end
return best
end
local function Objectives()
local out = {}
local map = Workspace:FindFirstChild("Map")
if not map then
local gameFolder = Workspace:FindFirstChild("Game")
map = gameFolder and gameFolder:FindFirstChild("Map")
end
if not map then return out end
local parts = map:FindFirstChild("Parts") or map:FindFirstChild("MapLogic")
local folder = parts and parts:FindFirstChild("Objectives")
if not folder then return out end
for _, item in ipairs(folder:GetChildren()) do
if item:GetAttribute("Completed") ~= true then
local part = item.PrimaryPart or item:FindFirstChildWhichIsA("BasePart")
if part or item:IsA("BasePart") then
table.insert(out, { Instance = item, Part = part or item, Tag = TagOf(item), Name = item.Name })
end
end
end
return out
end
local function TicketsFolder()
local effects = Workspace:FindFirstChild("Effects")
return effects and effects:FindFirstChild("Tickets")
end
local function NextbotFolder()
local gameFolder = Workspace:FindFirstChild("Game")
return gameFolder and gameFolder:FindFirstChild("Players")
end
local function IsNextbot(model)
if not model or not model:IsA("Model") then return false end
if model:GetAttribute("Team") == "Nextbot" then return true end
return model:FindFirstChild("Hitbox") ~= nil
end
local function ServerRegistry()
if State.Registry ~= nil then return State.Registry or nil end
State.Registry = false
for _, item in ipairs(ReplicatedStorage:GetDescendants()) do
if item:IsA("ModuleScript") and item.Name == "ServerStateRegistryService" then
local ok, module = pcall(require, item)
if ok and type(module) == "table" then State.Registry = module end
break
end
end
return State.Registry or nil
end
local function RegistryValue(key)
local service = ServerRegistry()
local registry = service and service.Registry
if not registry then return nil end
local ok, value = pcall(function() return registry[key] end)
if ok then return value end
return nil
end
local FarmPad
local function AFKFarming()
local _, _, root = Character()
if not root then return end
if not FarmPad or not FarmPad.Parent then
FarmPad = Instance.new("Part")
FarmPad.Size = Vector3.new(10, 1, 10)
FarmPad.Anchored = true
FarmPad.CanCollide = true
FarmPad.Name = "ReichtFarmPad"
FarmPad.CFrame = CFrame.new(1131, 1015, 2222)
FarmPad.Parent = Workspace
end
root.CFrame = FarmPad.CFrame + Vector3.new(0, 3, 0)
end
local function TokenFarmTarget()
local valid = FarmTargets()
if #valid == 0 then return nil end
return valid[math.random(1, #valid)]
end
local function StartTokenFarm()
if State.TokenConn then return end
State.TokenTarget = nil
State.TokenLast = 0
State.TokenConn = Connect(RunService.Heartbeat, function()
if not State.Alive then return end
local _, _, root = Character()
if not root then return end
local target = State.TokenTarget
if not target or not target.Parent or not target:FindFirstChild("HumanoidRootPart") then
target = TokenFarmTarget()
State.TokenTarget = target
end
if not target then return end
local targetRoot = target:FindFirstChild("HumanoidRootPart")
if not targetRoot then return end
root.CFrame = targetRoot.CFrame + (State.Opt.TokenOffset or Vector3.new(0, -8, 0))
local tag = TagOf(target)
if not tag then return end
local now = tick()
if now - State.TokenLast >= (State.Opt.TokenDelay or 2) then
State.TokenLast = now
ReviveTag(tag)
end
end)
end
local function StopTokenFarm()
if State.TokenConn then
State.TokenConn:Disconnect()
State.TokenConn = nil
end
State.TokenTarget = nil
State.TokenLast = 0
end
local function StartTicketFarm()
if State.TicketConn then return end
State.TicketConn = Connect(RunService.Heartbeat, function()
if not State.Alive then return end
local _, _, root = Character()
if not root then return end
local folder = TicketsFolder()
if not folder then
AFKFarming()
return
end
for _, item in ipairs(folder:GetDescendants()) do
if item:IsA("BasePart") and item.Name == "HumanoidRootPart" then
root.CFrame = CFrame.new(item.Position)
return
end
end
AFKFarming()
end)
end
local function StopTicketFarm()
if State.TicketConn then
State.TicketConn:Disconnect()
State.TicketConn = nil
end
end
local function PointFarm()
local list = Objectives()
if #list == 0 then return 0 end
local fired = 0
for _, objective in ipairs(list) do
if objective.Instance:FindFirstChild("WhenActivated") and objective.Tag then
if Interact("Dynamic", objective.Tag) then fired += 1 end
task.wait(0.2)
end
end
return fired
end
local function StartAutoRespawn()
if State.RespawnConn then return end
State.RespawnLast = 0
State.RespawnConn = Connect(RunService.Heartbeat, function()
if not State.Alive then return end
local character = Character()
if not character or not IsDowned(character) then return end
local now = tick()
if now - (State.RespawnLast or 0) < 0.5 then return end
State.RespawnLast = now
Respawn()
end)
end
local function StopAutoRespawn()
if State.RespawnConn then
State.RespawnConn:Disconnect()
State.RespawnConn = nil
end
end
local function StartAutoCarry()
if State.CarryConn then return end
State.CarryLast = 0
State.CarryConn = Connect(RunService.Heartbeat, function()
if not State.Alive then return end
local now = tick()
if now - (State.CarryLast or 0) < 0.5 then return end
State.CarryLast = now
local target = NearestDowned()
if target and target.Character then
Interact("Carry", TagOf(target.Character))
end
end)
end
local function StopAutoCarry()
if State.CarryConn then
State.CarryConn:Disconnect()
State.CarryConn = nil
end
end
local function CreateBillboard(name, part, color, size)
if not part or part:FindFirstChild(name) then return nil end
local gui = Instance.new("BillboardGui")
gui.Name = name
gui.Parent = part
gui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
gui.AlwaysOnTop = true
gui.Size = UDim2.new(0, 200, 0, 50)
gui.StudsOffset = Vector3.new(0, 2.5, 0)
gui.MaxDistance = 1000
local label = Instance.new("TextLabel")
label.Parent = gui
label.BackgroundTransparency = 1
label.Size = UDim2.new(1, 0, 1, 0)
label.Font = Enum.Font.SourceSans
label.TextSize = size or 14
label.TextColor3 = color or Color3.fromRGB(255, 255, 255)
local stroke = Instance.new("UIStroke")
stroke.Parent = label
stroke.Thickness = 1
stroke.Color = Color3.new(0, 0, 0)
return gui
end
local function UpdateBillboard(name, part, text, color, size)
if not part then return end
local gui = part:FindFirstChild(name)
local label = gui and gui:FindFirstChildOfClass("TextLabel")
if not label then return end
local camera = Workspace.CurrentCamera
if color then label.TextColor3 = color end
if size then label.TextSize = size end
if camera then
local distance = math.floor((camera.CFrame.Position - part.Position).Magnitude)
label.Text = string.format("%s - [ %d M ]", text or part.Name, distance)
else
label.Text = text or part.Name
end
end
local function ClearBillboard(name)
local roots = {}
local folder = PlayerModels()
if folder then table.insert(roots, folder) end
local bots = NextbotFolder()
if bots then table.insert(roots, bots) end
local tickets = TicketsFolder()
if tickets then table.insert(roots, tickets) end
for _, player in ipairs(Players:GetPlayers()) do
if player.Character then table.insert(roots, player.Character) end
end
for _, root in ipairs(roots) do
for _, item in ipairs(root:GetDescendants()) do
if item.Name == name then item:Destroy() end
end
end
end
local function CreateTracer(key, part, color, thickness)
if not Drawing or not part then return end
local tracer = Drawing.new("Line")
tracer.Thickness = thickness or 2
tracer.Color = color or Color3.fromRGB(255, 255, 255)
tracer.Transparency = 1
tracer.Visible = false
State.Tracers[key] = { Line = tracer, Part = part }
end
local function UpdateTracer(key, color)
local entry = State.Tracers[key]
if not entry then return end
local tracer, part = entry.Line, entry.Part
local camera = Workspace.CurrentCamera
if not part or not part.Parent or not camera then
pcall(function() tracer:Remove() end)
State.Tracers[key] = nil
return
end
local ok, screen, onScreen = pcall(function()
return camera:WorldToViewportPoint(part.Position)
end)
if not ok or not onScreen then
tracer.Visible = false
return
end
if color then tracer.Color = color end
tracer.From = Vector2.new(camera.ViewportSize.X / 2, camera.ViewportSize.Y)
tracer.To = Vector2.new(screen.X, screen.Y)
tracer.Visible = true
end
local function ClearTracers()
for key, entry in pairs(State.Tracers) do
pcall(function() entry.Line:Remove() end)
State.Tracers[key] = nil
end
end
local function Highlight(name, model, fill, transparency)
if not model or model:FindFirstChild(name) then return end
local highlight = Instance.new("Highlight")
highlight.Name = name
highlight.Adornee = model
highlight.FillColor = fill
highlight.FillTransparency = transparency or 0.55
highlight.OutlineColor = Color3.fromRGB(255, 255, 255)
highlight.DepthMode = Enum.HighlightDepthMode.AlwaysOnTop
highlight.Parent = model
end
local function ClearHighlights()
local roots = {}
for _, player in ipairs(Players:GetPlayers()) do
if player.Character then table.insert(roots, player.Character) end
end
local bots = NextbotFolder()
if bots then table.insert(roots, bots) end
for _, root in ipairs(roots) do
for _, item in ipairs(root:GetDescendants()) do
if item.Name == "ReichtEsp" then item:Destroy() end
end
end
end
local function ShowTimer()
local gui = LocalPlayer:FindFirstChild("PlayerGui")
if not gui or gui:FindFirstChild("ReichtTimer") then return end
local screen = Instance.new("ScreenGui")
screen.Name = "ReichtTimer"
screen.ResetOnSpawn = false
screen.Parent = gui
local label = Instance.new("TextLabel")
label.Parent = screen
label.Size = UDim2.new(0, 200, 0, 50)
label.Position = UDim2.new(0.5, -100, 0.1, 0)
label.BackgroundTransparency = 1
label.TextScaled = true
label.Font = Enum.Font.SourceSans
label.TextColor3 = Color3.new(1, 1, 1)
label.Text = "0:00"
State.TimerLabel = label
end
local function HideTimer()
State.TimerLabel = nil
local gui = LocalPlayer:FindFirstChild("PlayerGui")
local screen = gui and gui:FindFirstChild("ReichtTimer")
if screen then screen:Destroy() end
end
local function ShowSpecialRound()
local gui = LocalPlayer:FindFirstChild("PlayerGui")
if not gui or gui:FindFirstChild("ReichtSpecial") then return end
local screen = Instance.new("ScreenGui")
screen.Name = "ReichtSpecial"
screen.ResetOnSpawn = false
screen.Parent = gui
local label = Instance.new("TextLabel")
label.Parent = screen
label.Size = UDim2.new(0, 300, 0, 40)
label.Position = UDim2.new(0.5, -150, 0.16, 0)
label.BackgroundTransparency = 1
label.TextScaled = true
label.Font = Enum.Font.SourceSans
label.TextColor3 = Color3.new(1, 1, 1)
label.Text = ""
State.SpecialLabel = label
end
local function HideSpecialRound()
State.SpecialLabel = nil
local gui = LocalPlayer:FindFirstChild("PlayerGui")
local screen = gui and gui:FindFirstChild("ReichtSpecial")
if screen then screen:Destroy() end
end
local function SpecialRoundTitle(key)
local info = ReplicatedStorage:FindFirstChild("Info")
local folder = info and info:FindFirstChild("SpecialRounds")
local module = folder and folder:FindFirstChild(tostring(key))
if module and module:IsA("ModuleScript") then
local ok, data = pcall(require, module)
if ok and type(data) == "table" and data.Title then return data.Title end
end
return tostring(key)
end
local function SuperBounce()
local character = Character()
local humanoid = character and character:FindFirstChildOfClass("Humanoid")
local root = character and character:FindFirstChild("HumanoidRootPart")
if not humanoid or not root then return end
local previous = character:FindFirstChild("R15Visual") and 0.75 or -1.25
root.CanCollide = false
humanoid.HipHeight = -100
task.wait(2)
root.CanCollide = true
humanoid.HipHeight = previous
end
local function StartLagSwitch()
if State.LagConn then return end
State.LagConn = Connect(RunService.Heartbeat, function()
if not State.Alive or not State.Opt.LagSwitch then return end
local character = Character()
local root = character and character:FindFirstChild("HumanoidRootPart")
if not root then return end
local velocity = root.AssemblyLinearVelocity
if velocity.Magnitude < 1 then return end
local window = (State.Opt.LagMs or 200) * 0.002
local start = tick()
while tick() - start < window do end
if setfflag then
pcall(setfflag, "MaxMissedWorldStepsRemembered", "9999")
end
end)
end
local function StopLagSwitch()
if State.LagConn then
State.LagConn:Disconnect()
State.LagConn = nil
end
end
local EdgeParams = RaycastParams.new()
EdgeParams.FilterType = Enum.RaycastFilterType.Blacklist
local function EdgeTrimp()
local character = Character()
local root = character and character:FindFirstChild("HumanoidRootPart")
if not root then return end
local velocity = root.AssemblyLinearVelocity
local horizontal = Vector3.new(velocity.X, 0, velocity.Z)
local speed = horizontal.Magnitude
if speed < 22 or velocity.Y >= 0 then return end
local moveDir = horizontal.Unit
EdgeParams.FilterDescendantsInstances = { character }
local predictTime = math.clamp(speed / 110, 0.14, 0.24)
local futurePos = root.Position + horizontal * predictTime + moveDir * 2.5
local hit = Workspace:Raycast(futurePos + Vector3.new(0, 2, 0), Vector3.new(0, -6, 0), EdgeParams)
if not hit then return end
local drop = root.Position.Y - hit.Position.Y
if drop < (State.Opt.TrimpDrop or 6) then return end
local height = math.clamp(speed * 0.7, 22, 85) * (State.Opt.TrimpHeight or 1.4)
root.AssemblyLinearVelocity = horizontal * 1.05 + Vector3.new(0, height, 0)
end
local function EmoteDash()
local emoteId = State.Opt.EmoteId
local remote = Event("CharacterTask")
if emoteId and remote then
pcall(function() remote:FireServer("Emote", emoteId) end)
end
SendKeybind("Crouching", true)
task.wait(0.1)
SendKeybind("Crouching", false)
end
local function WalkToolData(visit)
local tools = ReplicatedStorage:FindFirstChild("Tools")
if not tools then return 0 end
local touched = 0
for _, tool in ipairs(tools:GetChildren()) do
if tool:IsA("ModuleScript") then
local ok, data = pcall(require, tool)
if ok and type(data) == "table" and data.Tasks then
for _, entry in ipairs(data.Tasks) do
for _, fn in ipairs(entry.Functions or {}) do
for _, activation in ipairs(fn.Activations or {}) do
for _, method in ipairs(activation.Methods or {}) do
if method.Info then
visit(method.Info)
touched += 1
end
end
end
end
for _, auto in ipairs(entry.AutomaticFunctions or {}) do
for _, method in ipairs(auto.Methods or {}) do
if method.Info then
visit(method.Info)
touched += 1
end
end
end
end
end
end
end
return touched
end
local function SetInfiniteRange(data)
if type(data) ~= "table" then return end
for key, value in pairs(data) do
if (key == "Range" or key == "LungeRange" or key == "HearingRange") and type(value) == "number" then
data[key] = math.huge
elseif key == "DamageDistanceInterval" and type(value) == "table" and #value >= 2 then
value[2] = math.huge
elseif type(value) == "table" then
SetInfiniteRange(value)
end
end
end
local function SetNoCooldown(data)
if type(data) ~= "table" then return end
for key, value in pairs(data) do
if key == "Cooldown" and type(value) == "number" then
data[key] = 1 / 65536
elseif type(value) == "table" then
SetNoCooldown(value)
end
end
end
local function GameChild(...)
local node = Workspace:FindFirstChild("Game")
for _, name in ipairs({ ... }) do
if not node then return nil end
node = node:FindFirstChild(name)
end
return node
end
local Adjustments = {}
local function CollectAdjustments()
table.clear(Adjustments)
local character = LocalPlayer.Character
if not character or not getgc then return 0 end
for _, value in pairs(getgc(true)) do
if type(value) == "table" then
local owner = rawget(value, "Character")
if typeof(owner) == "Instance" and owner == character then
local override = rawget(value, "overrideMovementStats")
local default = rawget(value, "defaultMovementStats")
if type(override) == "table" then table.insert(Adjustments, override) end
if type(default) == "table" then table.insert(Adjustments, default) end
end
end
end
return #Adjustments
end
local function SetAdjustment(key, value)
if #Adjustments == 0 then CollectAdjustments() end
local touched = 0
for _, stats in ipairs(Adjustments) do
if rawget(stats, key) ~= nil then
rawset(stats, key, value)
touched += 1
end
end
return touched
end
local function ResetAdjustments()
if #Adjustments == 0 then CollectAdjustments() end
local touched = 0
for _, stats in ipairs(Adjustments) do
for key, value in pairs({
Speed = 16,
Friction = 5,
AirStrafeAcceleration = 182,
AirAcceleration = 3,
BhopEnabled = false,
JumpHeight = 7.2,
JumpCap = 80,
}) do
if rawget(stats, key) ~= nil then
rawset(stats, key, value)
touched += 1
end
end
end
return touched
end
local function DisableTouch(folder)
if not folder then return 0 end
local touched = 0
for _, part in ipairs(folder:GetDescendants()) do
if part:IsA("BasePart") and part.CanTouch then
part.CanTouch = false
touched += 1
end
end
return touched
end
local function RemoveSafeZones()
local safe = GameChild("Map", "SafeZones")
if not safe then return 0 end
local removed = 0
for _, part in ipairs(safe:GetDescendants()) do
if part:IsA("BasePart") then
part:Destroy()
removed += 1
end
end
return removed
end
local function DisableCameraShake()
local scripts = LocalPlayer:FindFirstChild("PlayerScripts")
local camera = scripts and scripts:FindFirstChild("Camera")
local adjusters = camera and camera:FindFirstChild("FOVAdjusters")
local set = camera and camera:FindFirstChild("CameraSet")
if not adjusters or not set then return false end
adjusters:SetAttribute("Fear", 1)
pcall(function() set:Invoke("CFrameOffset", "Shake", CFrame.new()) end)
return true
end
local function DisableVignette()
local shared = LocalPlayer:FindFirstChild("Shared")
local hud = shared and shared:FindFirstChild("HUD")
local noise = hud and hud:FindFirstChild("NextbotNoise")
if not noise then return false end
noise.ImageTransparency = 1
local inner = noise:FindFirstChild("Noise") or noise:FindFirstChild("Noise2")
if inner then inner.ImageTransparency = 1 end
return true
end
local function EventNPC()
local folder = GameChild("Players")
if not folder then return nil end
for _, model in ipairs(folder:GetChildren()) do
if model.Name == "Lupen" and model:FindFirstChild("HumanoidRootPart") then return model end
end
return nil
end
local function TeleportEventNPC()
local npc = EventNPC()
if not npc then return false end
local _, _, root = Character()
local npcRoot = npc:FindFirstChild("HumanoidRootPart")
local npcHumanoid = npc:FindFirstChildOfClass("Humanoid")
if not root or not npcRoot then return false end
local offset = npcHumanoid and npcHumanoid.MoveDirection or Vector3.zero
root.CFrame = CFrame.new(npcRoot.Position + offset)
return true
end
local function SetMovableEmote(name, speed)
local items = ReplicatedStorage:FindFirstChild("Items")
local folder = items and items:FindFirstChild("Emotes")
local module = folder and folder:FindFirstChild(name or "")
if not module then return false end
local ok, data = pcall(require, module)
if not ok or type(data) ~= "table" or type(data.EmoteInfo) ~= "table" then return false end
data.EmoteInfo.SpeedMult = speed
return true
end
local function ChangeAnimation(folder, version)
if not folder or not version then return 0 end
local r15 = folder:FindFirstChild("PossibleOptions")
local r6 = folder:FindFirstChild("PossibleOptionsClassic")
local changed = 0
local function swap(optionSet, targetName, backupName)
local option = optionSet and optionSet:FindFirstChild(version)
local animation = option and option:FindFirstChildWhichIsA("Animation")
local target = folder:FindFirstChild(targetName)
if not animation or not target then return end
if not folder:FindFirstChild(backupName) then
local backup = Instance.new("StringValue")
backup.Name = backupName
backup.Value = target.AnimationId
backup.Parent = folder
end
target.AnimationId = animation.AnimationId
changed += 1
end
swap(r15, "Animation", "OriginalAnimId")
swap(r6, "AnimationClassic", "OriginalAnimIdClassic")
return changed
end
local function EmoteFolders()
local items = ReplicatedStorage:FindFirstChild("Items")
local folder = items and items:FindFirstChild("Emotes")
local out = {}
if not folder then return out end
for _, module in ipairs(folder:GetChildren()) do
if module:FindFirstChild("PossibleOptions") or module:FindFirstChild("PossibleOptionsClassic") then
table.insert(out, module)
end
end
return out
end
local function InstantRevive()
local remote = ReplicatedStorage:FindFirstChild("Events")
and ReplicatedStorage.Events:FindFirstChild("Character")
and ReplicatedStorage.Events.Character:FindFirstChild("Interact")
local target = NearestDowned()
if not remote or not target then return false end
local name = tostring(target)
return pcall(function()
for _ = 1, 7 do
remote:FireServer("Revive", nil, name)
remote:FireServer("Revive", false, name)
remote:FireServer("Revive", true, name)
end
end)
end
local function WhistleRemote()
local remote = ReplicatedStorage:FindFirstChild("Events")
and ReplicatedStorage.Events:FindFirstChild("Character")
and ReplicatedStorage.Events.Character:FindFirstChild("Whistle")
if not remote then return false end
return pcall(function() remote:FireServer() end)
end
local function ApplyKorblox(side, meshId)
local character = Character()
if not character then return end
local legName = (side == "Right")
and (character:FindFirstChild("Right Leg") and "Right Leg" or "RightUpperLeg")
or (character:FindFirstChild("Left Leg") and "Left Leg" or "LeftUpperLeg")
local leg = character:FindFirstChild(legName)
if not leg then return end
for _, child in ipairs(leg:GetChildren()) do
if child:IsA("SpecialMesh") then child:Destroy() end
end
leg.Color = Color3.fromRGB(50, 50, 50)
local mesh = Instance.new("SpecialMesh")
mesh.Name = "ReichtKorblox"
mesh.MeshType = Enum.MeshType.FileMesh
mesh.MeshId = meshId
mesh.Parent = leg
end
local function ApplyHeadless()
local character = Character()
local head = character and character:FindFirstChild("Head")
if not head then return end
head.Transparency = 1
local face = head:FindFirstChild("face")
if face then face:Destroy() end
if head:FindFirstChild("ReichtHeadless") then return end
local mesh = Instance.new("SpecialMesh")
mesh.Name = "ReichtHeadless"
mesh.MeshType = Enum.MeshType.FileMesh
mesh.MeshId = "rbxassetid://1095708"
mesh.Scale = Vector3.new(0.001, 0.001, 0.001)
mesh.Parent = head
end
local function UpdateCosmetics()
if State.Opt.KorbloxR then ApplyKorblox("Right", "rbxassetid://101851696") end
if State.Opt.KorbloxL then ApplyKorblox("Left", "rbxassetid://101851582") end
if State.Opt.Headless then ApplyHeadless() end
end
local Parity = {}
local registry
function Parity.Registry()
if registry ~= nil then return registry or nil end
local items = ReplicatedStorage:FindFirstChild("Items")
local module = items and items:FindFirstChild("Registry")
if not module then
registry = false
return nil
end
local ok, value = pcall(require, module)
registry = ok and value or false
return registry or nil
end
function Parity.ItemByName(name)
local reg = Parity.Registry()
if not reg or not name or name == "" then return nil end
if reg.TryGetByName then
local ok, entry = pcall(reg.TryGetByName, reg, name)
if ok then return entry end
end
return nil
end
function Parity.ItemConfig(idOrName)
local reg = Parity.Registry()
if not reg then return nil end
local id = tonumber(idOrName)
if not id and reg.TryGetByName then
local ok, entry = pcall(reg.TryGetByName, reg, tostring(idOrName))
if ok and entry then id = entry.Id end
end
if id and reg.GetConfig then
local ok, config = pcall(reg.GetConfig, reg, id)
if ok then return config, id end
end
return nil, id
end
function Parity.ShopItems()
local out = {}
local reg = Parity.Registry()
if not reg or not reg.GetAll then return out end
local ok, ids = pcall(reg.GetAll, reg)
if not ok or type(ids) ~= "table" then return out end
for id in pairs(ids) do
local config = select(1, Parity.ItemConfig(id))
local purchase = config and config.PurchaseInfo
if purchase and purchase.AppearsIn == "Shop" and purchase.OwnershipType == "Multiple" then
local appearance = config.AppearanceInfo
table.insert(out, (appearance and appearance.Name) or config.Name or tostring(id))
end
end
table.sort(out)
return out
end
function Parity.Purchase(name, amount)
local reg = Parity.Registry()
if not reg or not reg.GetAll or not name or name == "" then return false, "no registry" end
local ok, ids = pcall(reg.GetAll, reg)
if not ok or type(ids) ~= "table" then return false, "registry empty" end
local target
for id in pairs(ids) do
local config = select(1, Parity.ItemConfig(id))
local purchase = config and config.PurchaseInfo
if purchase and purchase.AppearsIn == "Shop" and purchase.OwnershipType == "Multiple" then
local appearance = config.AppearanceInfo
local label = (appearance and appearance.Name) or config.Name
if label == name then
target = id
break
end
end
end
if not target then return false, "item not in shop" end
local remote = ReplicatedStorage:FindFirstChild("Shared")
and ReplicatedStorage.Shared:FindFirstChild("UserData")
and ReplicatedStorage.Shared.UserData:FindFirstChild("Events")
and ReplicatedStorage.Shared.UserData.Events:FindFirstChild("Requests")
and ReplicatedStorage.Shared.UserData.Events.Requests:FindFirstChild("Purchase")
if not remote then return false, "no purchase remote" end
local sent = pcall(function() remote:FireServer(target, amount or 1) end)
if not sent then return false, "fire failed" end
return true
end
Parity.CosmeticSwaps = {}
local function scanDescendants(root, folderName, itemName, budget)
budget = budget or 4000
local stack = { root }
local seen = 0
while #stack > 0 and seen < budget do
local node = table.remove(stack)
seen += 1
if node.Name == folderName then
local hit = node:FindFirstChild(itemName)
if hit then return hit end
end
for _, child in ipairs(node:GetChildren()) do
if child:IsA("Folder") or child:IsA("Model") or child:IsA("Configuration") then
table.insert(stack, child)
end
end
end
return nil
end
function Parity.CosmeticNames()
local out = {}
local reg = Parity.Registry()
if not reg or not reg.GetByCategory then return out end
local ok, bucket = pcall(reg.GetByCategory, reg, "Cosmetics")
if not ok or type(bucket) ~= "table" then
ok, bucket = pcall(reg.GetByCategory, reg, "Cosmetic")
end
if not ok or type(bucket) ~= "table" then return out end
for _, entry in pairs(bucket) do
if type(entry) == "table" and entry.Module then table.insert(out, entry.Module.Name) end
end
table.sort(out)
return out
end
function Parity.SwapCosmetics(first, second)
if not first or not second or first == "" or second == "" or first == second then
return false, "pick two different items"
end
local items = ReplicatedStorage:FindFirstChild("Items")
if not items then return false, "no Items folder" end
local source = scanDescendants(items, "Cosmetics", first)
local target = scanDescendants(items, "Cosmetics", second)
if not source or not target then return false, "cosmetic not found" end
local holder = Instance.new("Folder")
holder.Name = "ReichtSwap"
holder.Parent = ReplicatedStorage
local sourceKids, targetKids = source:GetChildren(), target:GetChildren()
for _, child in ipairs(sourceKids) do child.Parent = holder end
for _, child in ipairs(targetKids) do child.Parent = source end
for _, child in ipairs(holder:GetChildren()) do child.Parent = target end
holder:Destroy()
table.insert(Parity.CosmeticSwaps, { first, second })
return true
end
function Parity.RestoreCosmetics()
local swaps = Parity.CosmeticSwaps
if #swaps == 0 then return 0 end
local undone = 0
for index = #swaps, 1, -1 do
local pair = swaps[index]
if Parity.SwapCosmetics(pair[2], pair[1]) then undone += 1 end
table.remove(swaps, index)
end
Parity.CosmeticSwaps = {}
return undone
end
function Parity.Emotes()
local out = {}
local items = ReplicatedStorage:FindFirstChild("Items")
if not items then return out end
local stack = { items }
while #stack > 0 do
local node = table.remove(stack)
if node.Name == "Emotes" then
for _, module in ipairs(node:GetChildren()) do
if module:IsA("ModuleScript") then
table.insert(out, { Name = module.Name, ID = module:GetAttribute("ID"), Module = module })
end
end
else
for _, child in ipairs(node:GetChildren()) do
if child:IsA("Folder") then table.insert(stack, child) end
end
end
end
table.sort(out, function(a, b) return a.Name < b.Name end)
return out
end
function Parity.FindEmote(input)
if not input or input == "" then return nil end
local numeric = tonumber(input)
local list = Parity.Emotes()
if numeric then
for _, entry in ipairs(list) do
if entry.ID == numeric then return entry end
end
return { Name = tostring(numeric), ID = numeric }
end
local needle = tostring(input):lower():gsub("%s+", "")
for _, entry in ipairs(list) do
if entry.Name:lower():gsub("%s+", "") == needle then return entry end
end
local reg = Parity.Registry()
if reg and reg.TryGetByName then
local ok, found = pcall(reg.TryGetByName, reg, input)
if ok and found and found.Module then
return { Name = found.Module.Name, ID = found.Id or found.Module:GetAttribute("ID"), Module = found.Module }
end
end
return nil
end
function Parity.SetEmote(id)
if not id then return false end
local character = Character()
local tag = character and character:GetAttribute("Tag")
local remote = Event("UpdateCharacterDataRegistry")
if not tag or not remote or not firesignal then return false end
return pcall(function()
local packed = buffer.create(2)
buffer.writeu16(packed, 0, tag)
firesignal(remote.OnClientEvent, { buffer.fromstring("\24\1"), id, packed })
end)
end
function Parity.SwapEmote(first, second)
local target = Parity.FindEmote(second)
if not target or not target.ID then return false, "target emote not found" end
local sent = Parity.SetEmote(target.ID)
if not sent then return false, "emote signal failed" end
return true
end
Parity.EmoteHook = { Active = false, Map = {} }
function Parity.StartEmoteWatcher()
if Parity.EmoteHook.Active then return true end
local objects = ReplicatedStorage:FindFirstChild("Objects")
local items = objects and objects:FindFirstChild("Items")
local module = items and items:FindFirstChild("Emote")
if not module then return false end
local ok, class = pcall(require, module)
if not ok or type(class) ~= "table" then return false end
Parity.EmoteHook.Original = class.Activate
Parity.EmoteHook.Class = class
local original = class.Activate
if type(original) ~= "function" then return false end
class.Activate = function(self, ...)
original(self, ...)
local name = self.EmoteModule and self.EmoteModule.Name
local replacement = name and Parity.EmoteHook.Map[name]
if replacement and Parity.EmoteHook.Last ~= name then
Parity.EmoteHook.Last = name
Parity.SetEmote(replacement)
end
end
Parity.EmoteHook.Active = true
return true
end
function Parity.StopEmoteWatcher()
local hook = Parity.EmoteHook
if not hook.Active then return end
if hook.Class and hook.Original then hook.Class.Activate = hook.Original end
hook.Active = false
hook.Last = nil
end
function Parity.BuildEmoteMap(currentName, targetName)
local current = Parity.FindEmote(currentName)
local target = Parity.FindEmote(targetName)
if not current or not target or not target.ID then return false, "emote not found" end
Parity.EmoteHook.Map[current.Name] = target.ID
return true, current.Name .. " -> " .. target.Name
end
function Parity.Status(player)
if not player or not player.Character then return "DEAD" end
local character = player.Character
local services = ReplicatedStorage:FindFirstChild("Services")
local asset = services and services:FindFirstChild("Asset")
local module = asset and asset:FindFirstChild("CharacterService")
if module then
local ok, service = pcall(require, module)
if ok and service and service.GetCharacterFromPlayer then
local got, data = pcall(function() return service:GetCharacterFromPlayer(player) end)
if got and data and data.DataRegistry then
local downed = data.DataRegistry:Get("Downed")
if downed then return "DOWNED" end
end
end
end
local folder = Workspace:FindFirstChild("Players")
local mirror = folder and folder:FindFirstChild(player.Name)
if mirror then
local downed = mirror:GetAttribute("Downed")
if downed == true or downed == 1 or downed == "true" then return "DOWNED" end
end
if character:GetAttribute("Downed") == true then return "DOWNED" end
local humanoid = character:FindFirstChildOfClass("Humanoid")
if humanoid and humanoid.Health > 0 then return "ALIVE" end
return "DEAD"
end
function Parity.Ragdolled(player)
local character = player and player.Character
if not character then return false end
if character:FindFirstChild("RagdollConstraints") then return true end
local primary = character.PrimaryPart
if primary and primary.Anchored then return true end
return false
end
function Parity.DownedModel()
local folder = Workspace:FindFirstChild("Players")
if not folder then return nil end
for _, model in ipairs(folder:GetChildren()) do
if model:GetAttribute("Downed") and model:FindFirstChild("HumanoidRootPart") then
return model
end
end
return nil
end
function Parity.TeleportToDowned()
local model = Parity.DownedModel()
local _, _, root = Character()
local target = model and model:FindFirstChild("HumanoidRootPart")
if not root or not target then return false end
root.CFrame = CFrame.new(target.Position + Vector3.new(0, 2, 0))
return true
end
function Parity.SafeCFrame(mode, root, distance, threat)
if mode == "Spawn" then
local gameFolder = Workspace:FindFirstChild("Game")
local map = gameFolder and gameFolder:FindFirstChild("Map")
local spawns = map and (map:FindFirstChild("ItemSpawns")
or map:FindFirstChild("Spawns") or map:FindFirstChild("MapLogic"))
if spawns then
local parts = {}
for _, part in ipairs(spawns:GetDescendants()) do
if part:IsA("BasePart") then table.insert(parts, part) end
end
if #parts > 0 then
local pick = parts[math.random(1, #parts)]
return CFrame.new(pick.Position + Vector3.new(0, 3, 0))
end
end
elseif mode == "Players" then
local pool = {}
for _, player in ipairs(Players:GetPlayers()) do
local other = player.Character
if player ~= LocalPlayer and other and other:FindFirstChild("HumanoidRootPart") then
table.insert(pool, other.HumanoidRootPart)
end
end
if #pool > 0 then
local pick = pool[math.random(1, #pool)]
return pick.CFrame + Vector3.new(0, 3, 0)
end
elseif mode == "Distance" and root and threat then
local away = root.Position - threat
if away.Magnitude > 0.1 then
return CFrame.new(root.Position + away.Unit * (distance or 100))
end
end
return root and (root.CFrame + Vector3.new(0, 50, 0)) or CFrame.new(0, 100, 0)
end
function Parity.AntiNextbot()
local _, _, root = Character()
if not root then return false end
local range = State.Opt.AntiBotRange or 50
local mode = State.Opt.AntiBotMode or "Spawn"
local folder = NextbotFolder()
local moved = false
local function sweep(container)
if not container then return end
for _, model in ipairs(container:GetChildren()) do
local bot = model:FindFirstChild("HumanoidRootPart")
if bot and IsNextbot(model) and (root.Position - bot.Position).Magnitude < range then
root.CFrame = Parity.SafeCFrame(mode, root, 100, bot.Position)
moved = true
return
end
end
end
sweep(folder)
if not moved then
local players = PlayerModels()
sweep(players)
end
return moved
end
function Parity.InvisParts(state)
local gameFolder = Workspace:FindFirstChild("Game")
local map = gameFolder and gameFolder:FindFirstChild("Map")
local folder = map and (map:FindFirstChild("InvisParts") or map:FindFirstChild("MapLogic"))
if not folder then return 0 end
local touched = 0
for _, part in ipairs(folder:GetDescendants()) do
if part:IsA("BasePart") then
part.CanCollide = state and true or false
touched += 1
end
end
return touched
end
local STAT_KEYS = {
Speed = "Speed",
Friction = "Friction",
AirAcceleration = "AirAcceleration",
AirStrafeAcceleration = "AirStrafeAcceleration",
SprintAcceleration = "SprintAcceleration",
SprintCap = "SprintCap",
JumpHeight = "JumpHeight",
JumpSpeedMultiplier = "JumpSpeedMultiplier",
JumpCap = "JumpCap",
GroundAcceleration = "GroundAcceleration",
BhopEnabled = "BhopEnabled",
}
function Parity.Stat(key, value)
local mapped = STAT_KEYS[key]
if not mapped then return false end
return MovementValueSet(mapped, value)
end
function Parity.ResetStats()
MovementValueSet("Speed", 16)
MovementValueSet("Friction", 5)
MovementValueSet("AirAcceleration", 1)
MovementValueSet("AirStrafeAcceleration", 182)
MovementValueSet("SprintAcceleration", 1)
MovementValueSet("SprintCap", 2)
MovementValueSet("JumpHeight", 3)
MovementValueSet("JumpSpeedMultiplier", 1.45)
MovementValueSet("JumpCap", 1)
MovementValueSet("BhopEnabled", false)
end
function Parity.Bounce()
local character, humanoid = Character()
if not humanoid then return end
if not State.Opt.Bounce then
humanoid.WalkSpeed = 16
return
end
local state = character:GetAttribute("State")
if state == "Default" or state == "Downed" then
humanoid.WalkSpeed = 0
elseif state == "Emoting" or state == "EmotingAir" or state == "EmotingSlide" or state == "EmotingSlideAir" then
humanoid.WalkSpeed = State.Opt.BounceEmote or 60
else
humanoid.WalkSpeed = State.Opt.BounceDefault or 30
end
end
function Parity.Speedometer()
local gui = LocalPlayer:FindFirstChild("PlayerGui")
local node = gui and gui:FindFirstChild("Shared")
for _, step in ipairs({ "HUD", "Overlay", "Default", "CharacterInfo", "Item", "Speedometer", "Players" }) do
node = node and node:FindFirstChild(step)
if not node then return nil end
end
return node
end
function Parity.Loadouts()
local out = {}
local items = ReplicatedStorage:FindFirstChild("Items")
local folder = items and items:FindFirstChild("Loadout")
if not folder then return out end
for _, child in ipairs(folder:GetChildren()) do
if child:IsA("ModuleScript") or child:IsA("LocalScript") then
table.insert(out, child.Name)
end
end
table.sort(out)
return out
end
function Parity.RevertCosmetics()
local character = Character()
if not character then return false end
local head = character:FindFirstChild("Head")
if head then
head.Transparency = 0
local mesh = head:FindFirstChild("ReichtHeadless")
if mesh then mesh:Destroy() end
end
for _, name in ipairs({ "Right Leg", "RightUpperLeg", "Left Leg", "LeftUpperLeg" }) do
local leg = character:FindFirstChild(name)
if leg then
leg.Color = Color3.new(1, 1, 1)
local mesh = leg:FindFirstChild("ReichtKorblox")
if mesh then mesh:Destroy() end
end
end
State.Opt.Headless = false
State.Opt.KorbloxR = false
State.Opt.KorbloxL = false
return true
end
function Parity.ToggleButton(name, label, callback)
local gui = LocalPlayer:FindFirstChild("PlayerGui")
if not gui or gui:FindFirstChild(name) then return nil end
local screen = Instance.new("ScreenGui")
screen.Name = name
screen.ResetOnSpawn = false
screen.Parent = gui
local frame = Instance.new("Frame")
frame.Name = name
frame.Size = UDim2.new(0, 160, 0, 44)
frame.Position = UDim2.new(0.02, 0, 0.35, 0)
frame.BackgroundColor3 = Color3.fromRGB(20, 20, 24)
frame.BackgroundTransparency = 0.15
frame.Parent = screen
local corner = Instance.new("UICorner")
corner.CornerRadius = UDim.new(0, 12)
corner.Parent = frame
local stroke = Instance.new("UIStroke")
stroke.Color = Color3.fromRGB(90, 200, 255)
stroke.Thickness = 1.5
stroke.Parent = frame
local button = Instance.new("TextButton")
button.Size = UDim2.new(1, 0, 1, 0)
button.BackgroundTransparency = 1
button.Text = label or name
button.Font = Enum.Font.SourceSansBold
button.TextSize = 18
button.TextColor3 = Color3.new(1, 1, 1)
button.Parent = frame
local dragging, dragStart, frameStart = false, nil, nil
button.InputBegan:Connect(function(input)
if input.UserInputType == Enum.UserInputType.MouseButton1
or input.UserInputType == Enum.UserInputType.Touch then
dragging = true
dragStart = input.Position
frameStart = frame.Position
input.Changed:Connect(function()
if input.UserInputState == Enum.UserInputState.End then dragging = false end
end)
end
end)
button.InputChanged:Connect(function(input)
if not dragging then return end
if input.UserInputType ~= Enum.UserInputType.MouseMovement
and input.UserInputType ~= Enum.UserInputType.Touch then return end
local delta = input.Position - dragStart
frame.Position = UDim2.new(
frameStart.X.Scale, frameStart.X.Offset + delta.X,
frameStart.Y.Scale, frameStart.Y.Offset + delta.Y
)
end)
button.Activated:Connect(function()
if callback then callback() end
end)
table.insert(State.Connections, screen)
return frame
end
function Parity.DropButton(name)
local gui = LocalPlayer:FindFirstChild("PlayerGui")
local screen = gui and gui:FindFirstChild(name)
if screen then screen:Destroy() end
end
function Parity.RealName(folder, input)
if not input or input == "" then return nil end
local entry = Parity.ItemByName(input)
if entry and entry.Module then return entry.Module.Name end
if not folder then return nil end
local needle = tostring(input):lower():gsub("%s+", "")
for _, item in ipairs(folder:GetChildren()) do
if item.Name:lower():gsub("%s+", "") == needle then return item.Name end
end
return nil
end
function Parity.InfiniteSlide()
local character = Character()
if not character then return end
local state = character:GetAttribute("State")
if state == "Slide" or state == "EmotingSlide" or state == "CarrySlide" then
MovementValueSet("GroundAcceleration", State.Opt.SlideAcceleration or 40)
else
MovementValueSet("GroundAcceleration", 5)
end
end
function Parity.SetBhop(enabled, hold)
State.Opt.Bhop = enabled and true or false
State.Opt.BhopHold = hold and true or false
local mode = State.Opt.BhopMode or "Acceleration"
local flag = (State.Opt.Bhop or State.Opt.BhopHold) and mode ~= "No Acceleration"
MovementValueSet("BhopEnabled", flag and true or false)
end
Parity.EmoteDash = { Active = false, Multiplier = 1 }
function Parity.StartAggressiveEmote()
if Parity.EmoteDash.Active then return true end
local objects = ReplicatedStorage:FindFirstChild("Objects")
local gameFolder = objects and objects:FindFirstChild("Game")
local character = gameFolder and gameFolder:FindFirstChild("Character")
local client = character and character:FindFirstChild("Client")
local module = client and client:FindFirstChild("Movement")
if not module then return false end
local ok, movement = pcall(require, module)
if not ok or type(movement) ~= "table" then return false end
local original = movement.RegistryTermUpdated
if type(original) ~= "function" then return false end
Parity.EmoteDash.Movement = movement
Parity.EmoteDash.Original = original
movement.RegistryTermUpdated = function(self, term)
if term ~= "Emote" then return original(self, term) end
local id = self.DataRegistry and self.DataRegistry:Get("Emote")
if not id or id == 0 then
if self.MoveStats then self.MoveStats:SpeedChange("Emote", nil) end
return
end
local multiplier = Parity.EmoteDash.Multiplier
if State.Opt.EmoteDashBlatant then
multiplier = multiplier * ((State.Opt.EmoteDashSpeed or 1000) / 1000)
end
if self.MoveStats then self.MoveStats:SpeedChange("Emote", multiplier) end
return
end
Parity.EmoteDash.Active = true
return true
end
function Parity.StopAggressiveEmote()
local state = Parity.EmoteDash
if not state.Active then return end
if state.Movement and state.Original then
state.Movement.RegistryTermUpdated = state.Original
end
state.Active = false
end
function Parity.ClearEmoteMap()
Parity.StopEmoteWatcher()
Parity.EmoteHook.Map = {}
return true
end
Parity.Admin = { LastMap = 0, LastSpecial = 0, LastTime = 0 }
local function adminSend(command)
local remote = ReplicatedStorage:FindFirstChild("Events")
and ReplicatedStorage.Events:FindFirstChild("Admin")
and ReplicatedStorage.Events.Admin:FindFirstChild("Command")
if not remote then return false end
return pcall(function() remote:FireServer(command) end)
end
local function normalizeText(text)
return tostring(text or ""):gsub("%s+", ""):lower()
end
function Parity.AutoAdmin()
if not State.Opt.AutoAdmin then return end
local now = os.clock()
local map = State.Opt.AutoMapName
if State.Opt.AutoMap and map and map ~= "" and now - Parity.Admin.LastMap >= 1 then
local current = RegistryValue("Map")
if normalizeText(current) ~= normalizeText(map) then
if type(RegistryValue("MapLoading")) ~= "string" then
adminSend("!Map " .. map)
Parity.Admin.LastMap = now
end
end
end
local special = State.Opt.AutoSpecialName
if State.Opt.AutoSpecial and special and special ~= "" and now - Parity.Admin.LastSpecial >= 1 then
local current = RegistryValue("SpecialRound")
if normalizeText(current) ~= normalizeText(special) then
adminSend("!SpecialRound " .. special)
Parity.Admin.LastSpecial = now
end
end
local seconds = State.Opt.AutoTime
if seconds and tonumber(seconds) and now - Parity.Admin.LastTime >= 3 then
local current = RegistryValue("Time")
local wanted = tonumber(seconds)
if wanted and current ~= wanted then
adminSend("!Time " .. tostring(wanted))
Parity.Admin.LastTime = now
end
end
end
local body = game:HttpGet(UI_URL)
if type(body) ~= "string" or not body:sub(-64):find("return Library%s*$") then
Alert("Could not download the menu. Check the connection and try again.")
return
end
local chunk = loadstring(body)
local Library = chunk and select(2, pcall(chunk))
if type(Library) ~= "table" then
Alert("The menu failed to load on this executor.")
return
end
local win = Library:CreateWindow({
Title = "Reicht",
SubTitle = "Evade",
MenuKey = Enum.KeyCode.LeftControl,
ConfigFolder = SAVE_FOLDER,
Language = "Auto",
Theme = "Overworld",
})
local playerTab = win:AddTab("Player", "user", "Movement, physics, utility")
local farmTab = win:AddTab("Farm", "tractor", "Tokens, tickets, objectives")
local autoTab = win:AddTab("Auto", "repeat", "Revive, carry, voting")
local espTab = win:AddTab("Visuals", "eye", "ESP, tracers, overlay")
local miscTab = win:AddTab("Misc", "settings", "Tools, admin, unload")
local moveGroup = playerTab:AddLeftGroupbox("Movement", "wind")
moveGroup:AddToggle("SpeedOn", {
Text = "Speed",
Default = false,
Description = "Uses the game's own ModifyMovement event",
Callback = function(on)
State.Opt.SpeedOn = on
if on then
MovementValueSet("Speed", State.Opt.Speed or 60)
else
MovementValueSet("Speed", 16)
end
end,
})
moveGroup:AddSlider("Speed", {
Text = "Speed Value",
Min = 16,
Max = 500,
Default = 60,
Rounding = 0,
Callback = function(value)
State.Opt.Speed = value
if State.Opt.SpeedOn then MovementValueSet("Speed", value) end
end,
})
moveGroup:AddToggle("JumpOn", {
Text = "Jump Power",
Default = false,
Callback = function(on)
State.Opt.JumpOn = on
local _, humanoid = Character()
if not humanoid then return end
humanoid.UseJumpPower = true
humanoid.JumpPower = on and (State.Opt.Jump or 80) or 50
end,
})
moveGroup:AddSlider("Jump", {
Text = "Jump Value",
Min = 0,
Max = 500,
Default = 80,
Rounding = 0,
Callback = function(value)
State.Opt.Jump = value
if State.Opt.JumpOn then
local _, humanoid = Character()
if humanoid then humanoid.JumpPower = value end
end
end,
})
moveGroup:AddToggle("Fly", {
Text = "Fly",
Default = false,
Callback = function(on)
State.Opt.Fly = on
local _, humanoid, root = Character()
if not humanoid or not root then return end
humanoid.PlatformStand = on
if not on then root.AssemblyLinearVelocity = Vector3.zero end
end,
})
moveGroup:AddSlider("FlySpeed", {
Text = "Fly Speed",
Min = 10,
Max = 400,
Default = 90,
Rounding = 0,
Callback = function(value) State.Opt.FlySpeed = value end,
})
moveGroup:AddToggle("Bhop", {
Text = "Bhop",
Default = false,
Description = "Jumps the frame you land",
Callback = function(on) State.Opt.Bhop = on end,
})
moveGroup:AddToggle("Noclip", {
Text = "Noclip",
Default = false,
Callback = function(on) State.Opt.Noclip = on end,
})
moveGroup:AddToggle("AutoWhistle", {
Text = "Auto Whistle",
Default = false,
Description = "Holds the game's Whistle keybind every second",
Callback = function(on)
State.Opt.AutoWhistle = on
if not on then return end
task.spawn(function()
while State.Alive and State.Opt.AutoWhistle do
SendKeybind("Whistle", true)
task.wait(0.05)
SendKeybind("Whistle", false)
task.wait(1)
end
end)
end,
})
moveGroup:AddToggle("CrouchSpam", {
Text = "Crouch Toggle",
Default = false,
Description = "Repeatedly taps the Crouching keybind",
Callback = function(on)
State.Opt.CrouchSpam = on
if not on then
SendKeybind("Crouching", false)
return
end
task.spawn(function()
while State.Alive and State.Opt.CrouchSpam do
SendKeybind("Crouching", true)
task.wait(0.1)
SendKeybind("Crouching", false)
task.wait(0.1)
end
end)
end,
})
local physicsGroup = playerTab:AddRightGroupbox("Physics", "activity")
physicsGroup:AddSlider("Gravity", {
Text = "Gravity",
Min = 0,
Max = 250,
Default = 196,
Rounding = 0,
Callback = function(value) Workspace.Gravity = value end,
})
physicsGroup:AddToggle("EdgeTrimp", {
Text = "Modify Edge Trimp",
Default = false,
Description = "Adds lift when you run off a ledge",
Callback = function(on) State.Opt.EdgeTrimp = on end,
})
physicsGroup:AddSlider("TrimpDrop", {
Text = "Falling Threshold",
Min = 1,
Max = 40,
Default = 4.5,
Rounding = 0,
Callback = function(value) State.Opt.TrimpDrop = value end,
})
physicsGroup:AddSlider("TrimpHeight", {
Text = "Height Multiplier",
Min = 0.5,
Max = 4,
Default = 1.5,
Rounding = 1,
Callback = function(value) State.Opt.TrimpHeight = value end,
})
physicsGroup:AddToggle("LagSwitch", {
Text = "Lag Switch (Button)",
Default = false,
Description = "Freezes the frame while moving",
Callback = function(on)
State.Opt.LagSwitch = on
if on then StartLagSwitch() else StopLagSwitch() end
end,
})
physicsGroup:AddSlider("LagMs", {
Text = "Delay MS",
Min = 50,
Max = 1000,
Default = 200,
Rounding = 0,
Suffix = " ms",
Callback = function(value) State.Opt.LagMs = value end,
})
physicsGroup:AddButton({
Text = "Super Bounce",
Func = function()
task.spawn(SuperBounce)
Alert("Super bounce fired.")
end,
})
physicsGroup:AddButton({
Text = "Emote Dash",
Func = function()
task.spawn(EmoteDash)
Alert("Emote dash fired.")
end,
})
physicsGroup:AddInput("EmoteId", {
Text = "Select Emote ID",
Placeholder = "numeric id",
Callback = function(text)
local id = tonumber(text)
State.Opt.EmoteId = id
end,
})
local farmGroup = farmTab:AddLeftGroupbox("Automation", "tractor")
farmGroup:AddToggle("TokenFarm", {
Text = "Auto Farm Token",
Default = false,
Description = "Teleports under a random workspace.Players child and fires Revive",
Callback = function(on)
State.Opt.TokenFarm = on
if on then StartTokenFarm() else StopTokenFarm() end
end,
})
farmGroup:AddSlider("TokenDelay", {
Text = "Token Farm Delay",
Min = 1,
Max = 4,
Default = 2,
Rounding = 1,
Suffix = " s",
Callback = function(value) State.Opt.TokenDelay = value end,
})
farmGroup:AddToggle("TicketFarm", {
Text = "Auto Farm Tickets",
Default = false,
Description = "Walks onto every spawned ticket",
Callback = function(on)
State.Opt.TicketFarm = on
if on then StartTicketFarm() else StopTicketFarm() end
end,
})
farmGroup:AddToggle("PointFarm", {
Text = "Auto Complete Objective",
Default = false,
Description = "Interact Dynamic on every live objective",
Callback = function(on)
State.Opt.PointFarm = on
if not on then return end
task.spawn(function()
while State.Alive and State.Opt.PointFarm do
PointFarm()
task.wait(1)
end
end)
end,
})
farmGroup:AddButton({
Text = "Objective Now",
Func = function()
local fired = PointFarm()
Alert(string.format("Objective fired %d", fired))
end,
})
farmGroup:AddToggle("AutoAFK", {
Text = "AFK Farm",
Default = false,
Description = "Holds you on the hub's safe pad",
Callback = function(on)
State.Opt.AutoAFK = on
if not on then
if FarmPad then
FarmPad:Destroy()
FarmPad = nil
end
return
end
task.spawn(function()
while State.Alive and State.Opt.AutoAFK do
AFKFarming()
task.wait(1)
end
end)
end,
})
local reviveGroup = farmTab:AddRightGroupbox("Revive", "heart")
reviveGroup:AddButton({
Text = "Respawn",
Func = function()
if Respawn() then Alert("Respawn sent.") end
end,
})
reviveGroup:AddButton({
Text = "Revive Everyone",
Func = function()
local targets = FarmTargets()
local fired = 0
for _, model in ipairs(targets) do
local tag = TagOf(model)
if tag and ReviveTag(tag) then fired += 1 end
end
Alert(string.format("Revive fired %d / tracked %d", fired, #targets))
end,
})
reviveGroup:AddButton({
Text = "Revive Nearest",
Func = function()
local target = NearestDowned()
if target and target.Character then
if ReviveTag(TagOf(target.Character)) then Alert("Revive sent to " .. target.Name) end
else
Alert("No downed player within 20 studs.")
end
end,
})
reviveGroup:AddToggle("AutoRespawn", {
Text = "Auto Respawn",
Default = false,
Description = "Fires the respawn remote the moment you go down",
Callback = function(on)
State.Opt.AutoRespawn = on
if on then StartAutoRespawn() else StopAutoRespawn() end
end,
})
reviveGroup:AddToggle("AutoRevive", {
Text = "Self Revive (Button)",
Default = false,
Description = "Revives every tracked player on a loop",
Callback = function(on)
State.Opt.AutoRevive = on
if not on then return end
task.spawn(function()
while State.Alive and State.Opt.AutoRevive do
for _, model in ipairs(FarmTargets()) do
local tag = TagOf(model)
if tag then ReviveTag(tag) end
end
task.wait(1)
end
end)
end,
})
reviveGroup:AddToggle("AutoCarry", {
Text = "Auto Carry",
Default = false,
Description = "Carries the nearest downed player",
Callback = function(on)
State.Opt.AutoCarry = on
if on then StartAutoCarry() else StopAutoCarry() end
end,
})
local voteGroup = autoTab:AddLeftGroupbox("Map Voting", "map")
voteGroup:AddSlider("VoteMap", {
Text = "Map Section",
Min = 1,
Max = 12,
Default = 1,
Rounding = 0,
Callback = function(value) State.Opt.VoteMap = value end,
})
voteGroup:AddSlider("VoteMode", {
Text = "Gamemode Section",
Min = 1,
Max = 8,
Default = 1,
Rounding = 0,
Callback = function(value) State.Opt.VoteMode = value end,
})
voteGroup:AddButton({
Text = "Vote Now",
Func = function()
if Vote(State.Opt.VoteMap or 1) then Alert("Vote sent.") end
end,
})
voteGroup:AddToggle("AutoVoteMap", {
Text = "Auto Vote Map",
Default = false,
Description = "Only fires while the vote popup is open",
Callback = function(on)
State.Opt.AutoVoteMap = on
if not on then return end
task.spawn(function()
while State.Alive and State.Opt.AutoVoteMap do
if VotePopup() then Vote(State.Opt.VoteMap or 1) end
task.wait(0.5)
end
end)
end,
})
voteGroup:AddToggle("AutoVoteMode", {
Text = "Auto Vote Mode",
Default = false,
Callback = function(on)
State.Opt.AutoVoteMode = on
if not on then return end
task.spawn(function()
while State.Alive and State.Opt.AutoVoteMode do
if VotePopup() then Vote(State.Opt.VoteMode or 1, true) end
task.wait(0.5)
end
end)
end,
})
local adminGroup = autoTab:AddRightGroupbox("Admin", "terminal")
adminGroup:AddInput("AdminCmd", {
Text = "Command",
Placeholder = "command string",
Callback = function(text) State.Opt.AdminCmd = text end,
})
adminGroup:AddButton({
Text = "Send Command",
Func = function()
local remote = ReplicatedStorage:FindFirstChild("Events")
and ReplicatedStorage.Events:FindFirstChild("Admin")
and ReplicatedStorage.Events.Admin:FindFirstChild("Command")
local command = State.Opt.AdminCmd
if not remote or not command or command == "" then
Alert("No admin remote or empty command.")
return
end
local ok = pcall(function() remote:FireServer(command) end)
Alert(ok and "Command sent." or "Command failed.")
end,
})
local espGroup = espTab:AddLeftGroupbox("ESP", "eye")
espGroup:AddToggle("EspPlayers", {
Text = "Player ESP",
Default = false,
Callback = function(on)
State.Opt.EspPlayers = on
if not on then ClearHighlights() end
end,
})
espGroup:AddToggle("EspBots", {
Text = "NextBot ESP",
Default = false,
Callback = function(on)
State.Opt.EspBots = on
if not on then ClearHighlights() end
end,
})
espGroup:AddToggle("BillboardPlayers", {
Text = "Billboard Players",
Default = false,
Description = "Name plus distance, green when downed",
Callback = function(on)
State.Opt.BillboardPlayers = on
if not on then ClearBillboard("ReichtPlayerESP") end
end,
})
espGroup:AddToggle("BillboardBots", {
Text = "Billboard Nextbots",
Default = false,
Callback = function(on)
State.Opt.BillboardBots = on
if not on then ClearBillboard("ReichtBotESP") end
end,
})
espGroup:AddToggle("BillboardTickets", {
Text = "Billboard Tickets",
Default = false,
Callback = function(on)
State.Opt.BillboardTickets = on
if not on then ClearBillboard("ReichtTicketESP") end
end,
})
local tracerGroup = espTab:AddRightGroupbox("Tracers", "crosshair")
tracerGroup:AddToggle("TracerPlayers", {
Text = "Tracer Players",
Default = false,
Description = "Needs a Drawing library",
Callback = function(on)
State.Opt.TracerPlayers = on
if not on then ClearTracers() end
end,
})
tracerGroup:AddToggle("TracerBots", {
Text = "Tracer Bots",
Default = false,
Callback = function(on)
State.Opt.TracerBots = on
if not on then ClearTracers() end
end,
})
tracerGroup:AddToggle("TracerTickets", {
Text = "Tracer Tickets",
Default = false,
Callback = function(on)
State.Opt.TracerTickets = on
if not on then ClearTracers() end
end,
})
local overlayGroup = espTab:AddLeftGroupbox("Overlay", "sun")
overlayGroup:AddToggle("Fullbright", {
Text = "Fullbright",
Default = false,
Callback = function(on)
if on then
State.Brightness = State.Brightness or Lighting.Brightness
Lighting.Brightness = 2
Lighting.OutdoorAmbient = Color3.fromRGB(255, 255, 255)
Lighting.Ambient = Color3.fromRGB(255, 255, 255)
Lighting.GlobalShadows = false
else
Lighting.Brightness = State.Brightness or 1
Lighting.GlobalShadows = true
end
end,
})
overlayGroup:AddToggle("ShowTimer", {
Text = "Show Timer",
Default = false,
Callback = function(on)
State.Opt.ShowTimer = on
if on then ShowTimer() else HideTimer() end
end,
})
overlayGroup:AddToggle("ShowSpecial", {
Text = "Show Special Round",
Default = false,
Callback = function(on)
State.Opt.ShowSpecial = on
if on then ShowSpecialRound() else HideSpecialRound() end
end,
})
overlayGroup:AddToggle("NoVignette", {
Text = "Disable Vignette",
Default = false,
Callback = function(on)
pcall(function()
local shared = ReplicatedStorage:FindFirstChild("Shared")
local userData = shared and shared:FindFirstChild("UserData")
local events = userData and userData:FindFirstChild("Events")
local requests = events and events:FindFirstChild("Requests")
local remote = requests and requests:FindFirstChild("SetSetting")
if remote then remote:FireServer("NextbotVignette", not on) end
end)
end,
})
overlayGroup:AddSlider("Fov", {
Text = "Camera FOV",
Min = 30,
Max = 120,
Default = 70,
Rounding = 0,
Callback = function(value)
State.Opt.Fov = value
local camera = Workspace.CurrentCamera
if camera then camera.FieldOfView = value end
end,
})
local toolGroup = miscTab:AddLeftGroupbox("Tool Patches", "wrench")
toolGroup:AddButton({
Text = "Set to Infinite Range",
Func = function()
local touched = WalkToolData(SetInfiniteRange)
Alert(string.format("Range patched on %d methods", touched))
end,
})
toolGroup:AddButton({
Text = "No Cooldown",
Func = function()
local touched = WalkToolData(SetNoCooldown)
Alert(string.format("Cooldown patched on %d methods", touched))
end,
})
local clientGroup = miscTab:AddRightGroupbox("Client", "cpu")
clientGroup:AddToggle("AntiAfk", {
Text = "Anti-AFK",
Default = true,
Callback = function(on) State.Opt.AntiAfk = on end,
})
clientGroup:AddButton({
Text = "Unload Reicht",
Func = function() Unload() end,
})
local statGroup = miscTab:AddLeftGroupbox("Stat Override", "gauge")
statGroup:AddButton({
Text = "Scan Movement Tables",
Func = function()
local found = CollectAdjustments()
Alert(found > 0 and string.format("Found %d movement tables", found)
or "No movement tables in the GC (getgc unavailable)")
end,
})
statGroup:AddSlider("OverrideSpeed", {
Text = "Player Speed",
Min = 0,
Max = 300,
Default = 16,
Rounding = 0,
Callback = function(value) SetAdjustment("Speed", value) end,
})
statGroup:AddSlider("OverrideFriction", {
Text = "Friction",
Min = 0,
Max = 100,
Default = 5,
Rounding = 0,
Callback = function(value) SetAdjustment("Friction", value) end,
})
statGroup:AddSlider("OverrideStrafe", {
Text = "Player Strafe Acceleration",
Min = 0,
Max = 500,
Default = 182,
Rounding = 0,
Callback = function(value) SetAdjustment("AirStrafeAcceleration", value) end,
})
statGroup:AddToggle("OverrideBhop", {
Text = "Bhop Enabled",
Default = false,
Callback = function(on) SetAdjustment("BhopEnabled", on) end,
})
statGroup:AddButton({
Text = "Reset Stats",
Func = function()
local touched = ResetAdjustments()
Alert(string.format("Reset %d movement values", touched))
end,
})
local mapGroup = miscTab:AddRightGroupbox("Map & FX", "shield")
mapGroup:AddButton({
Text = "No Touch Triggers",
Func = function()
local touched = DisableTouch(GameChild("Map"))
Alert(string.format("Disabled touch on %d parts", touched))
end,
})
mapGroup:AddButton({
Text = "Remove Safe Zones",
Func = function()
local removed = RemoveSafeZones()
Alert(string.format("Removed %d safe zone parts", removed))
end,
})
mapGroup:AddButton({
Text = "Kill Camera Shake",
Func = function()
Alert(DisableCameraShake() and "Camera shake killed" or "Camera shake hook not found")
end,
})
mapGroup:AddButton({
Text = "Kill Vignette",
Func = function()
Alert(DisableVignette() and "Nextbot vignette killed" or "Vignette not found")
end,
})
mapGroup:AddButton({
Text = "Teleport Event NPC",
Func = function()
Alert(TeleportEventNPC() and "Teleported to event NPC" or "Event NPC not in the map")
end,
})
local emoteGroup = miscTab:AddLeftGroupbox("Emotes & Cosmetics", "shirt")
local movableInput = emoteGroup:AddInput("MovableEmote", {
Text = "Current Emote",
Default = "",
Placeholder = "Emote folder name",
})
emoteGroup:AddSlider("MovableSpeed", {
Text = "Select Emote",
Min = 0,
Max = 10,
Default = 1,
Rounding = 1,
Callback = function(value) State.Opt.MovableSpeed = value end,
})
emoteGroup:AddButton({
Text = "Make Emote Movable",
Func = function()
local name = movableInput.Value
local ok = SetMovableEmote(name, State.Opt.MovableSpeed or 1)
Alert(ok and string.format("SpeedMult set on %s", tostring(name)) or "Emote module not found")
end,
})
local function AnimationVersions()
local out = {}
local folder = EmoteFolders()[1]
local options = folder and (folder:FindFirstChild("PossibleOptions") or folder:FindFirstChild("PossibleOptionsClassic"))
if options then
for _, child in ipairs(options:GetChildren()) do table.insert(out, child.Name) end
end
if #out == 0 then out = { "None" } end
return out
end
State.Opt.AnimationVersion = AnimationVersions()[1]
emoteGroup:AddDropdown("AnimationVersion", {
Text = "Animation Version",
Values = AnimationVersions(),
Default = 1,
Callback = function(value) State.Opt.AnimationVersion = value end,
})
emoteGroup:AddButton({
Text = "Swap Emote Animations",
Func = function()
local version = State.Opt.AnimationVersion
local changed = 0
for _, folder in ipairs(EmoteFolders()) do
changed += ChangeAnimation(folder, version)
end
Alert(string.format("Swapped %d animation ids to %s", changed, tostring(version)))
end,
})
emoteGroup:AddToggle("KorbloxR", {
Text = "Korblox Right Leg",
Default = false,
Callback = function(on)
State.Opt.KorbloxR = on
UpdateCosmetics()
end,
})
emoteGroup:AddToggle("KorbloxL", {
Text = "Korblox Left Leg",
Default = false,
Callback = function(on)
State.Opt.KorbloxL = on
UpdateCosmetics()
end,
})
emoteGroup:AddToggle("Headless", {
Text = "Headless",
Default = false,
Callback = function(on)
State.Opt.Headless = on
UpdateCosmetics()
end,
})
emoteGroup:AddButton({
Text = "Whistle (remote)",
Func = function()
Alert(WhistleRemote() and "Whistled" or "Whistle remote missing")
end,
})
emoteGroup:AddButton({
Text = "Instant Revive",
Func = function()
Alert(InstantRevive() and "Revive spam sent" or "No downed player nearby")
end,
})
State.Opt.AntiAfk = true
State.Opt.Speed = 60
State.Opt.Jump = 80
State.Opt.FlySpeed = 90
State.Opt.VoteMap = 1
State.Opt.VoteMode = 1
State.Opt.TokenDelay = 2
State.Opt.LagMs = 200
State.Opt.TrimpDrop = 6
State.Opt.AntiBotRange = 50
State.Opt.AntiBotMode = "Spawn"
State.Opt.ShopAmount = 1
State.Opt.BounceDefault = 30
State.Opt.BhopMode = "Acceleration"
State.Opt.SlideAcceleration = 40
State.Opt.EmoteDashSpeed = 1000
State.Opt.BounceEmote = 60
State.Opt.TrimpHeight = 1.4
LocalPlayer.Idled:Connect(function()
if not State.Opt.AntiAfk then return end
pcall(function()
VirtualUser:CaptureController()
VirtualUser:ClickButton2(Vector2.new())
end)
end)
Connect(RunService.RenderStepped, function()
if not State.Alive then return end
local character, humanoid, root = Character()
if State.Opt.Fly and humanoid and root then
local camera = Workspace.CurrentCamera
local move = humanoid.MoveDirection
local speed = State.Opt.FlySpeed or 90
local lift = 0
if UserInputService:IsKeyDown(Enum.KeyCode.Space) then lift += speed end
if UserInputService:IsKeyDown(Enum.KeyCode.LeftShift) then lift -= speed end
if camera then
root.AssemblyLinearVelocity = (camera.CFrame.LookVector * move.Z + camera.CFrame.RightVector * move.X) * speed
+ Vector3.new(0, lift, 0)
end
end
if State.Opt.Noclip and character then
for _, part in ipairs(character:GetDescendants()) do
if part:IsA("BasePart") and part.CanCollide then part.CanCollide = false end
end
end
end)
Connect(RunService.Heartbeat, function()
if not State.Alive then return end
local character, humanoid = Character()
if State.Opt.Bhop and humanoid and UserInputService:IsKeyDown(Enum.KeyCode.Space) then
local state = humanoid:GetState()
if state ~= Enum.HumanoidStateType.Jumping and state ~= Enum.HumanoidStateType.Freefall then
humanoid:ChangeState(Enum.HumanoidStateType.Jumping)
end
end
if State.Opt.EdgeTrimp and character then EdgeTrimp() end
if State.Opt.Bounce then Parity.Bounce() end
if State.Opt.AntiBot then Parity.AntiNextbot() end
if State.Opt.InfSlide then Parity.InfiniteSlide() end
if State.Opt.BhopHold and UserInputService:IsKeyDown(Enum.KeyCode.Space) then
local _, holdHumanoid = Character()
if holdHumanoid then
local state = holdHumanoid:GetState()
if state ~= Enum.HumanoidStateType.Jumping and state ~= Enum.HumanoidStateType.Freefall then
holdHumanoid:ChangeState(Enum.HumanoidStateType.Jumping)
end
end
end
if State.Opt.AutoAdmin then Parity.AutoAdmin() end
if State.Opt.EspPlayers then
for _, player in ipairs(Players:GetPlayers()) do
local other = player.Character
if other and player ~= LocalPlayer then
Highlight("ReichtEsp", other, Color3.fromRGB(255, 60, 60), 0.55)
end
end
end
if State.Opt.EspBots then
local bots = NextbotFolder()
if bots then
for _, bot in ipairs(bots:GetChildren()) do
if IsNextbot(bot) then
Highlight("ReichtEsp", bot, Color3.fromRGB(120, 200, 255), 0.6)
end
end
end
end
if State.Opt.BillboardPlayers then
for _, player in ipairs(Players:GetPlayers()) do
local other = player.Character
local hrp = other and other:FindFirstChild("HumanoidRootPart")
if hrp and player ~= LocalPlayer then
if not hrp:FindFirstChild("ReichtPlayerESP") then
CreateBillboard("ReichtPlayerESP", hrp, Color3.fromRGB(255, 255, 255), 14)
end
local color = IsDowned(other) and Color3.fromRGB(0, 255, 0) or Color3.fromRGB(255, 255, 255)
UpdateBillboard("ReichtPlayerESP", hrp, player.Name, color, 14)
end
end
end
if State.Opt.BillboardBots then
local bots = NextbotFolder()
if bots then
for _, bot in ipairs(bots:GetChildren()) do
local hrp = bot:FindFirstChild("HumanoidRootPart")
if hrp and IsNextbot(bot) then
if not hrp:FindFirstChild("ReichtBotESP") then
CreateBillboard("ReichtBotESP", hrp, Color3.fromRGB(255, 0, 0), 18)
end
UpdateBillboard("ReichtBotESP", hrp, bot.Name, Color3.fromRGB(255, 0, 0), 18)
end
end
end
end
if State.Opt.BillboardTickets then
local folder = TicketsFolder()
if folder then
for _, item in ipairs(folder:GetDescendants()) do
if item:IsA("BasePart") and item.Name == "HumanoidRootPart" then
if not item:FindFirstChild("ReichtTicketESP") then
CreateBillboard("ReichtTicketESP", item, Color3.fromRGB(255, 213, 128), 18)
end
local parent = item.Parent
UpdateBillboard("ReichtTicketESP", item, parent and parent.Name or "Ticket", Color3.fromRGB(255, 213, 128), 18)
end
end
end
end
if State.Opt.TracerPlayers then
for _, player in ipairs(Players:GetPlayers()) do
local other = player.Character
local hrp = other and other:FindFirstChild("HumanoidRootPart")
if hrp and player ~= LocalPlayer then
local key = "player_" .. player.Name
if not State.Tracers[key] then CreateTracer(key, hrp, Color3.fromRGB(255, 60, 60), 2) end
UpdateTracer(key, Color3.fromRGB(255, 60, 60))
end
end
end
if State.Opt.TracerBots then
local bots = NextbotFolder()
if bots then
for _, bot in ipairs(bots:GetChildren()) do
local hrp = bot:FindFirstChild("HumanoidRootPart")
if hrp and IsNextbot(bot) then
local key = "bot_" .. bot.Name
if not State.Tracers[key] then CreateTracer(key, hrp, Color3.fromRGB(120, 200, 255), 2) end
UpdateTracer(key, Color3.fromRGB(120, 200, 255))
end
end
end
end
if State.Opt.TracerTickets then
local folder = TicketsFolder()
if folder then
for _, item in ipairs(folder:GetDescendants()) do
if item:IsA("BasePart") and item.Name == "HumanoidRootPart" then
local key = "ticket_" .. tostring(item.Name) .. "_" .. tostring(item.Position.X) .. tostring(item.Position.Z)
if not State.Tracers[key] then CreateTracer(key, item, Color3.fromRGB(255, 213, 128), 1.5) end
UpdateTracer(key, Color3.fromRGB(255, 213, 128))
end
end
end
end
if State.Opt.ShowTimer and State.TimerLabel then
local seconds = RegistryValue("Time")
if type(seconds) == "number" and seconds >= 0 then
State.TimerLabel.Text = string.format("%d:%02d", math.floor(seconds / 60), math.floor(seconds % 60))
else
State.TimerLabel.Text = "--:--"
end
end
if State.Opt.ShowSpecial and State.SpecialLabel then
local special = RegistryValue("SpecialRound")
if special and special ~= false and special ~= "" then
State.SpecialLabel.Text = SpecialRoundTitle(special)
else
State.SpecialLabel.Text = ""
end
end
end)
local extraTab = win:AddTab("Extras", "package", "Shop, emotes, anti nextbot, stats")
local shopGroup = extraTab:AddLeftGroupbox("Shop", "shopping-cart")
local shopNames = Parity.ShopItems()
shopGroup:AddDropdown("ShopItem", {
Text = "Select Item",
Values = shopNames,
Default = 1,
Callback = function(value) State.Opt.ShopItem = value end,
})
shopGroup:AddSlider("ShopAmount", {
Text = "Purchase Amount",
Min = 1,
Max = 100,
Default = 1,
Rounding = 0,
Callback = function(value) State.Opt.ShopAmount = value end,
})
shopGroup:AddButton({
Text = "Buy Item",
Func = function()
local name = State.Opt.ShopItem or shopNames[1]
local ok, why = Parity.Purchase(name, State.Opt.ShopAmount or 1)
Alert(ok and string.format("Bought %s x%d", tostring(name), State.Opt.ShopAmount or 1)
or string.format("Buy failed: %s", tostring(why)))
end,
})
shopGroup:AddButton({
Text = "Refresh Item List",
Func = function()
shopNames = Parity.ShopItems()
Alert(string.format("%d shop items in the registry", #shopNames))
end,
})
local cosGroup = extraTab:AddRightGroupbox("Cosmetics", "shirt")
local cosNames = Parity.CosmeticNames()
cosGroup:AddDropdown("CosCurrent", {
Text = "Current Cosmetic",
Values = cosNames,
Default = 1,
Callback = function(value) State.Opt.CosCurrent = value end,
})
cosGroup:AddDropdown("CosTarget", {
Text = "New Cosmetic",
Values = cosNames,
Default = 1,
Callback = function(value) State.Opt.CosTarget = value end,
})
swapGroup:AddButton({
Text = "Swap Cosmetics",
Func = function()
local ok, why = Parity.SwapCosmetics(State.Opt.CosCurrent, State.Opt.CosTarget)
Alert(ok and "Cosmetics swapped" or tostring(why))
end,
})
cosGroup:AddButton({
Text = "Restore Cosmetics",
Func = function()
local undone = Parity.RestoreCosmetics()
Alert(string.format("Restored %d cosmetic swaps", undone))
end,
})
local emoteSwapGroup = extraTab:AddLeftGroupbox("Emote Replace", "smile")
local emoteNames = {}
for _, entry in ipairs(Parity.Emotes()) do table.insert(emoteNames, entry.Name) end
if #emoteNames == 0 then emoteNames = { "None" } end
emoteSwapGroup:AddDropdown("EmotePlay", {
Text = "Current Emote ",
Values = emoteNames,
Default = 1,
Callback = function(value) State.Opt.EmotePlay = value end,
})
emoteSwapGroup:AddDropdown("EmoteShow", {
Text = "Select Emote ",
Values = emoteNames,
Default = 1,
Callback = function(value) State.Opt.EmoteShow = value end,
})
emoteSwapGroup:AddButton({
Text = "Add Mapping",
Func = function()
local ok, why = Parity.BuildEmoteMap(State.Opt.EmotePlay, State.Opt.EmoteShow)
Alert(ok and why or tostring(why))
end,
})
emoteSwapGroup:AddToggle("EmoteWatcher", {
Text = "Emote Watcher",
Default = false,
Callback = function(on)
State.Opt.EmoteWatcher = on
local ok = on and Parity.StartEmoteWatcher() or not Parity.StopEmoteWatcher()
Alert(on and (ok and "Watcher installed" or "Emote class not found") or "Watcher removed")
end,
})
emoteSwapGroup:AddButton({
Text = "Play Emote Now",
Func = function()
local ok, why = Parity.SwapEmote(State.Opt.EmotePlay, State.Opt.EmoteShow)
Alert(ok and "Emote signal sent" or tostring(why))
end,
})
local botGroup = extraTab:AddRightGroupbox("Anti Nextbot", "shield-off")
botGroup:AddToggle("AntiBot", {
Text = "Anti Nextbot Toggle",
Default = false,
Callback = function(on) State.Opt.AntiBot = on end,
})
botGroup:AddDropdown("AntiBotMode", {
Text = "Anti Nextbot Teleport Type",
Values = { "Spawn", "Players" },
Default = 1,
Callback = function(value) State.Opt.AntiBotMode = value end,
})
botGroup:AddSlider("AntiBotRange", {
Text = "Anti Nextbot Distance",
Min = 5,
Max = 200,
Default = 15,
Rounding = 0,
Callback = function(value) State.Opt.AntiBotRange = value end,
})
botGroup:AddToggle("InvisWalk", {
Text = "Remove Invisible Walls",
Default = false,
Callback = function(on)
local touched = Parity.InvisParts(not on)
Alert(string.format("%s on %d parts", on and "Collision off" or "Collision on", touched))
end,
})
botGroup:AddButton({
Text = "Scan Player States",
Func = function()
local downed, ragdolled = 0, 0
for _, player in ipairs(Players:GetPlayers()) do
if player ~= LocalPlayer then
if Parity.Status(player) == "DOWNED" then downed += 1 end
if Parity.Ragdolled(player) then ragdolled += 1 end
end
end
Alert(string.format("%d downed, %d ragdolled", downed, ragdolled))
end,
})
botGroup:AddButton({
Text = "Teleport To Downed",
Func = function()
Alert(Parity.TeleportToDowned() and "Moved to downed body" or "Nobody is downed")
end,
})
local statGroup2 = extraTab:AddLeftGroupbox("Movement Stats", "activity")
local statRows = {
{ "StatSpeed", "Speed", "Speed", 0, 500, 16 },
{ "StatFriction", "Friction", "Friction", 0, 100, 5 },
{ "StatAirAccel", "Air Acceleration", "AirAcceleration", 0, 100, 1 },
{ "StatAirStrafe", "Air Strafe", "AirStrafeAcceleration", 0, 500, 182 },
{ "StatSprintAccel", "Sprint Acceleration", "SprintAcceleration", 0, 50, 1 },
{ "StatSprintCap", "Sprint Cap", "SprintCap", 0, 50, 2 },
{ "StatJumpHeight", "Jump Height", "JumpHeight", 0, 100, 3 },
{ "StatJumpMult", "Jump Multiplier", "JumpSpeedMultiplier", 0, 20, 1.45 },
{ "StatJumpCap", "Jump Cap", "JumpCap", 0, 50, 1 },
}
for _, row in ipairs(statRows) do
local key, label, mapped, low, high, default = row[1], row[2], row[3], row[4], row[5], row[6]
statGroup2:AddSlider(key, {
Text = label,
Min = low,
Max = high,
Default = default,
Rounding = mapped == "JumpSpeedMultiplier" and 2 or 0,
Callback = function(value) Parity.Stat(mapped, value) end,
})
end
statGroup2:AddToggle("StatBhop", {
Text = "Bhop Enabled",
Default = false,
Callback = function(on) Parity.Stat("BhopEnabled", on) end,
})
statGroup2:AddButton({
Text = "Reset Movement Stats",
Func = function()
Parity.ResetStats()
Alert("Movement stats reset")
end,
})
local toolGroup2 = extraTab:AddRightGroupbox("On Screen", "layout")
local toggleLabelInput = toolGroup2:AddInput("ToggleLabel", {
Text = "Button Label",
Default = "Reicht",
Placeholder = "text on the button",
})
toolGroup2:AddButton({
Text = "Add Toggle Button",
Func = function()
local label = toggleLabelInput.Value
local frame = Parity.ToggleButton("ReichtToggle", label, function()
State.Opt.Bounce = not State.Opt.Bounce
Alert(State.Opt.Bounce and "Bounce on" or "Bounce off")
end)
Alert(frame and "Button added" or "Button already on screen")
end,
})
toolGroup2:AddButton({
Text = "Remove Toggle Button",
Func = function()
Parity.DropButton("ReichtToggle")
Alert("Button removed")
end,
})
toolGroup2:AddToggle("Bounce", {
Text = "Modify Bounce",
Default = false,
Callback = function(on) State.Opt.Bounce = on end,
})
toolGroup2:AddSlider("BounceDefault", {
Text = "Player Bounce",
Min = 0,
Max = 200,
Default = 80,
Rounding = 0,
Callback = function(value) State.Opt.BounceDefault = value end,
})
toolGroup2:AddSlider("BounceEmote", {
Text = "Emote Bounce",
Min = 0,
Max = 200,
Default = 120,
Rounding = 0,
Callback = function(value) State.Opt.BounceEmote = value end,
})
toolGroup2:AddButton({
Text = "Speedometer Reading",
Func = function()
local meter = Parity.Speedometer()
Alert(meter and ("Speedometer: " .. tostring(meter.Text)) or "Speedometer not found")
end,
})
toolGroup2:AddButton({
Text = "Revert Headless / Korblox",
Func = function()
Alert(Parity.RevertCosmetics() and "Visuals reverted" or "No character")
end,
})
toolGroup2:AddButton({
Text = "List Loadouts",
Func = function()
local names = Parity.Loadouts()
Alert(#names > 0 and table.concat(names, ", ") or "No loadout folder")
end,
})
local leftoverGroup = extraTab:AddLeftGroupbox("Physics & Admin", "zap")
leftoverGroup:AddToggle("InfSlide", {
Text = "Infinite Slide",
Default = false,
Callback = function(on) State.Opt.InfSlide = on end,
})
leftoverGroup:AddSlider("SlideAcceleration", {
Text = "Slide Speed (Negative Only)",
Min = -50,
Max = 0,
Default = -3,
Rounding = 0,
Callback = function(value) State.Opt.SlideAcceleration = value end,
})
leftoverGroup:AddDropdown("BhopMode", {
Text = "BHOP Mode",
Values = { "Acceleration", "Ground Acceleration", "No Acceleration" },
Default = 1,
Callback = function(value)
State.Opt.BhopMode = value
Parity.SetBhop(State.Opt.Bhop, State.Opt.BhopHold)
end,
})
leftoverGroup:AddToggle("BhopFlag", {
Text = "BHOP Toggle",
Default = false,
Callback = function(on) Parity.SetBhop(on, State.Opt.BhopHold) end,
})
leftoverGroup:AddToggle("BhopHold", {
Text = "BHOP Hold Jump",
Default = false,
Callback = function(on) Parity.SetBhop(State.Opt.Bhop, on) end,
})
leftoverGroup:AddToggle("EmoteDashAggressive", {
Text = "Aggressive Emote Dash",
Default = false,
Callback = function(on)
State.Opt.EmoteDashAggressive = on
local ok = on and Parity.StartAggressiveEmote() or not Parity.StopAggressiveEmote()
Alert(on and (ok and "Emote dash hooked" or "Movement module not found") or "Emote dash unhooked")
end,
})
leftoverGroup:AddSlider("EmoteDashSpeed", {
Text = "Aggressive Emote Speed",
Min = 1,
Max = 3000,
Default = 2000,
Rounding = 0,
Callback = function(value) State.Opt.EmoteDashSpeed = value end,
})
leftoverGroup:AddDropdown("EmoteDashBlatant", {
Text = "Aggressive Emote Type",
Values = { "Legit", "Blatant" },
Default = 2,
Callback = function(value)
State.Opt.EmoteDashBlatant = value == "Blatant"
if State.Opt.EmoteDashAggressive then Parity.StartAggressiveEmote() end
end,
})
leftoverGroup:AddButton({
Text = "Clear Emote Map",
Func = function()
Parity.ClearEmoteMap()
Alert("Emote mappings cleared")
end,
})
local autoAdminGroup = extraTab:AddRightGroupbox("Auto Admin", "terminal")
autoAdminGroup:AddToggle("AutoAdminOn", {
Text = "Enabled",
Default = false,
Callback = function(on) State.Opt.AutoAdmin = on end,
})
autoAdminGroup:AddToggle("AutoMapOn", {
Text = "Auto Set Map",
Default = false,
Callback = function(on) State.Opt.AutoMap = on end,
})
autoAdminGroup:AddInput("AutoMapName", {
Text = "Map Input",
Placeholder = "DesertBus",
Callback = function(text) State.Opt.AutoMapName = text end,
})
autoAdminGroup:AddToggle("AutoSpecialOn", {
Text = "Auto Set Special Round",
Default = false,
Callback = function(on) State.Opt.AutoSpecial = on end,
})
autoAdminGroup:AddInput("AutoSpecialName", {
Text = "Special Round Input",
Placeholder = "Plushie Hell",
Callback = function(text) State.Opt.AutoSpecialName = text end,
})
autoAdminGroup:AddInput("AutoTimeInput", {
Text = "Timer Input",
Placeholder = "180",
Callback = function(text) State.Opt.AutoTime = tonumber(text) end,
})
local function RigsFolder()
return Workspace:FindFirstChild("Rigs")
end
function Parity.DestroyHighlight(name, model)
local highlight = model and model:FindFirstChild(name)
if highlight and highlight:IsA("Highlight") then
highlight:Destroy()
return true
end
return false
end
function Parity.ClearHighlight(name)
for _, folder in ipairs({ RigsFolder(), PlayerModels(), TicketsFolder() }) do
if folder then
for _, model in ipairs(folder:GetChildren()) do
Parity.DestroyHighlight(name, model)
local root = model:FindFirstChild("HumanoidRootPart")
if root then Parity.DestroyHighlight(name, root) end
end
end
end
end
function Parity.HighlightTick()
local rigs = RigsFolder()
local folder = PlayerModels()
if State.Opt.HighlightBots and rigs then
for _, rig in ipairs(rigs:GetChildren()) do
local owner = folder and folder:FindFirstChild(rig.Name)
if owner and owner:GetAttribute("Team") == "Nextbot" then
Highlight("ReichtBotHL", rig, Color3.fromRGB(255, 0, 0), 0.5)
end
end
end
if State.Opt.HighlightPlayers and rigs then
for _, rig in ipairs(rigs:GetChildren()) do
if rig.Name ~= LocalPlayer.Name then
local owner = folder and folder:FindFirstChild(rig.Name)
local team = owner and owner:GetAttribute("Team")
if team ~= "Nextbot" then
Highlight("ReichtPlayerHL", rig, Color3.fromRGB(255, 255, 255), 0.5)
local player = Players:FindFirstChild(rig.Name)
local downed = player and Parity.Status(player) == "DOWNED"
local highlight = rig:FindFirstChild("ReichtPlayerHL")
if highlight then
highlight.FillColor = downed and Color3.fromRGB(0, 255, 0)
or Color3.fromRGB(255, 255, 255)
end
end
end
end
end
if State.Opt.HighlightTickets then
local tickets = TicketsFolder()
if tickets then
for _, item in ipairs(tickets:GetDescendants()) do
if item:IsA("BasePart") and item.Name == "HumanoidRootPart" then
Highlight("ReichtTicketHL", item, Color3.fromRGB(255, 213, 128), 0.5)
end
end
end
end
end
Parity.Buttons = {}
function Parity.DestroyButton(name)
Parity.Buttons[name] = nil
local gui = LocalPlayer:FindFirstChild("PlayerGui")
local screen = gui and gui:FindFirstChild(name)
if screen then screen:Destroy() end
end
function Parity.ButtonSize(name, scale)
local gui = LocalPlayer:FindFirstChild("PlayerGui")
local screen = gui and gui:FindFirstChild(name)
local button = screen and screen:FindFirstChild("Button")
if not button then return false end
local grow = (scale or 0) * 100
button.Size = UDim2.new(0, 130 + grow, 0, 34 + grow * 0.34)
return true
end
function Parity.CreateButton(name, text, scale, fn)
Parity.DestroyButton(name)
local gui = LocalPlayer:FindFirstChild("PlayerGui")
if not gui then return nil end
local screen = Instance.new("ScreenGui")
screen.Name = name
screen.ResetOnSpawn = false
screen.DisplayOrder = 900
screen.Parent = gui
local button = Instance.new("TextButton")
button.Name = "Button"
button.Position = UDim2.new(0.02, 0, 0.22, 0)
button.BackgroundColor3 = Color3.fromRGB(22, 22, 26)
button.BackgroundTransparency = 0.15
button.TextColor3 = Color3.fromRGB(255, 255, 255)
button.Font = Enum.Font.GothamMedium
button.TextSize = 14
button.Text = text
button.BorderSizePixel = 0
button.AutoButtonColor = true
button.Parent = screen
Parity.ButtonSize(name, scale)
local dragging, dragStart, startPos = false, nil, nil
button.InputBegan:Connect(function(input)
local kind = input.UserInputType
if kind == Enum.UserInputType.MouseButton1 or kind == Enum.UserInputType.Touch then
dragging, dragStart, startPos = true, input.Position, button.Position
end
end)
button.InputChanged:Connect(function(input)
local kind = input.UserInputType
if dragging and (kind == Enum.UserInputType.MouseMovement or kind == Enum.UserInputType.Touch) then
local delta = input.Position - dragStart
button.Position = UDim2.new(startPos.X.Scale, startPos.X.Offset + delta.X,
startPos.Y.Scale, startPos.Y.Offset + delta.Y)
end
end)
button.InputEnded:Connect(function(input)
local kind = input.UserInputType
if kind == Enum.UserInputType.MouseButton1 or kind == Enum.UserInputType.Touch then
dragging = false
end
end)
button.Activated:Connect(function()
local ok, err = pcall(fn, button)
if not ok then Alert("button " .. name .. ": " .. tostring(err)) end
end)
Parity.Buttons[name] = button
return button
end
function Parity.SuperBounce()
local character, humanoid = Character()
local root = character and character:FindFirstChild("HumanoidRootPart")
if not root or not humanoid then return false end
local previous = character:FindFirstChild("R15Visual") and 0.75 or -1.25
root.CanCollide = false
humanoid.HipHeight = -100
task.delay(2, function()
if root and root.Parent then root.CanCollide = true end
if humanoid and humanoid.Parent then humanoid.HipHeight = previous end
end)
return true
end
function Parity.StartLag(ms)
local _, _, root = Character()
if not root then return false end
local lag = (ms or 200) * 0.002
if root.AssemblyLinearVelocity.Magnitude < 1 then return false end
local mode = State.Opt.LagMode or "Normal"
local start = os.clock()
while os.clock() - start < lag do end
if (mode == "FastFlag" or lag < 0.2) and setfflag then
pcall(setfflag, "MaxMissedWorldStepsRemembered", "9999")
end
return true
end
function Parity.HumanoidTick()
local character, humanoid = Character()
if not character or not humanoid then return end
if State.Opt.JumpPowerOn then
humanoid.UseJumpPower = true
humanoid.JumpPower = State.Opt.JumpPower or 20
end
if State.Opt.WalkCfOn then
local direction = humanoid.MoveDirection
if direction.Magnitude > 0 then
character:TranslateBy(direction * (State.Opt.WalkCf or 5) * 0.1)
end
end
end
function Parity.CameraStretch(x, y)
pcall(function()
LocalPlayer:SetAttribute("StretchX", x or 1)
LocalPlayer:SetAttribute("StretchY", y or 1)
end)
return true
end
function Parity.CameraFov(mult)
local service
for _, item in ipairs(ReplicatedStorage:GetDescendants()) do
if item:IsA("ModuleScript") and item.Name == "CameraService" then
local ok, module = pcall(require, item)
if ok and type(module) == "table" then
service = module
break
end
end
end
if service and service.AdjustFOV then
local ok = pcall(function() service:AdjustFOV("ReichtFov", mult or 1) end)
if ok then return true end
end
local camera = Workspace.CurrentCamera
if not camera then return false end
camera.FieldOfView = 70 * (mult or 1)
return true
end
function Parity.InfiniteAmmo()
local tools = ReplicatedStorage:FindFirstChild("Tools")
if not tools then return 0 end
local touched = 0
for _, tool in ipairs(tools:GetChildren()) do
if tool:IsA("ModuleScript") then
local ok, data = pcall(require, tool)
if ok and type(data) == "table" and data.Tasks then
for _, entry in ipairs(data.Tasks) do
local resource = entry.ResourceInfo
if resource and resource.Type == "Clip" then
resource.Reserve = 9999999999
resource.Cap = 9999999999
touched += 1
end
end
end
end
end
return touched
end
function Parity.InvisibleWalls(collide)
local map = GameChild("Map")
if not map then return 0 end
local invis = map:FindFirstChild("InvisParts") or map:FindFirstChild("MapLogic")
if not invis then return 0 end
local touched = 0
for _, part in ipairs(invis:GetDescendants()) do
if part:IsA("BasePart") then
part.CanCollide = collide and true or false
touched += 1
end
end
return touched
end
function Parity.SelfRevive()
local method = State.Opt.RespawnType or "Spawnpoint"
if method == "Fake Revive" then
local character = LocalPlayer.Character
local tag = character and character:GetAttribute("Tag")
if not tag then return false end
return ReviveTag(tag)
end
return Respawn()
end
Parity.Crouch = { Holding = false, Last = 0 }
function Parity.CrouchFunction()
local now = os.clock()
local debounce = State.Opt.CrouchDebounce or 0.1
if now - Parity.Crouch.Last < debounce then return false end
Parity.Crouch.Holding = not Parity.Crouch.Holding
SendKeybind("Crouching", Parity.Crouch.Holding)
Parity.Crouch.Last = now
return true
end
Parity.Bhop = { LastFriction = nil }
function Parity.BhopTick()
local character, humanoid = Character()
if not character or not humanoid then return end
local state = character:GetAttribute("State")
local airborne = humanoid.FloorMaterial == Enum.Material.Air
local mode = State.Opt.BhopMode or "Acceleration"
local active = State.Opt.Bhop or State.Opt.BhopHold
local desired
if State.Opt.InfSlide and (state == "Slide" or state == "EmotingSlide" or state == "CarrySlide") then
desired = State.Opt.SlideAcceleration or -8
elseif active and airborne and mode ~= "No Acceleration" then
if State.Opt.AutoAccel then
local root = character:FindFirstChild("HumanoidRootPart")
local speed = root and root.AssemblyLinearVelocity.Magnitude or 0
local maxSpeed = State.Opt.AutoAccelMaxSpeed or 70
if speed > maxSpeed then
desired = State.Opt.AutoAccelMaxAccel or 3
elseif speed < maxSpeed then
desired = State.Opt.AutoAccelMinAccel or -1
else
desired = State.Opt.BhopAcceleration or -0.1
end
else
desired = State.Opt.BhopAcceleration or -0.1
end
end
if desired ~= Parity.Bhop.LastFriction then
MovementValueSet("Friction", desired or 5)
Parity.Bhop.LastFriction = desired
end
if State.Opt.SpiderHop and (state == "WallrunRight" or state == "WallrunLeft") then
pcall(function() humanoid:ChangeState(Enum.HumanoidStateType.Jumping) end)
end
if State.Opt.JumpType == "Realistic" and active and not airborne
and (not State.Opt.BhopHold or UserInputService:IsKeyDown(Enum.KeyCode.Space)) then
pcall(function() humanoid.Jump = true end)
end
end
Parity.Buy = { Last = 0 }
function Parity.AutoBuyTick()
if not State.Opt.AutoBuy then return end
local now = os.clock()
if now - Parity.Buy.Last < 4 then return end
Parity.Buy.Last = now
local name = State.Opt.ShopItem
if not name then return end
local ok, bought = pcall(Parity.Purchase, name, State.Opt.ShopAmount or 1)
if not ok or not bought then return end
end
function Parity.EmoteCarryTick()
if not State.Opt.EmoteCarry then return end
local character = LocalPlayer.Character
if not character then return end
local state = character:GetAttribute("State")
if state ~= "Emoting" and state ~= "EmotingAir" and state ~= "EmotingSlide" then return end
local now = os.clock()
if now - (Parity.Buy.CarryLast or 0) < 0.5 then return end
Parity.Buy.CarryLast = now
local target = NearestDowned()
if target and target.Character then
Interact("Carry", TagOf(target.Character))
end
end
Connect(RunService.Heartbeat, function()
if not State.Alive then return end
if State.Opt.HighlightBots or State.Opt.HighlightPlayers or State.Opt.HighlightTickets then
Parity.HighlightTick()
end
if State.Opt.JumpPowerOn or State.Opt.WalkCfOn then Parity.HumanoidTick() end
if State.Opt.Bhop or State.Opt.BhopHold or State.Opt.SpiderHop or State.Opt.InfSlide then
Parity.BhopTick()
end
if State.Opt.AutoCrouch then Parity.CrouchFunction() end
Parity.AutoBuyTick()
Parity.EmoteCarryTick()
end)
local dragTab = win:AddTab("Draconic", "flame", "Options the original Overhaul menu exposes")
local hlGroup = dragTab:AddLeftGroupbox("Highlight ESP", "eye")
hlGroup:AddToggle("HighlightBots", {
Text = "Highlight Nextbots",
Default = false,
Callback = function(on)
State.Opt.HighlightBots = on
if not on then Parity.ClearHighlight("ReichtBotHL") end
end,
})
hlGroup:AddToggle("HighlightPlayers", {
Text = "Highlight Players",
Default = false,
Callback = function(on)
State.Opt.HighlightPlayers = on
if not on then Parity.ClearHighlight("ReichtPlayerHL") end
end,
})
hlGroup:AddToggle("HighlightTickets", {
Text = "Highlight Tickets",
Default = false,
Callback = function(on)
State.Opt.HighlightTickets = on
if not on then Parity.ClearHighlight("ReichtTicketHL") end
end,
})
local hudGroup = dragTab:AddRightGroupbox("On Screen Buttons", "pointer")
local function ButtonToggle(id, label, key, text, sizeKey, onToggle, sizeLabel)
hudGroup:AddToggle(id, {
Text = label,
Default = false,
Callback = function(on)
if not on then
Parity.DestroyButton(id .. "Gui")
if onToggle then onToggle(false) end
return
end
Parity.CreateButton(id .. "Gui", text, State.Opt[sizeKey] or 0, function(button)
if onToggle then
local label2 = onToggle(true)
if label2 then button.Text = label2 end
end
end)
end,
})
hudGroup:AddInput(id .. "Size", {
Text = sizeLabel or (label .. " Gui Size"),
Numeric = true,
Placeholder = "0",
Callback = function(value)
local percent = tonumber(value) or 0
State.Opt[sizeKey] = percent * 0.01
Parity.ButtonSize(id .. "Gui", State.Opt[sizeKey])
end,
})
end
ButtonToggle("RespawnBtn", "Respawn (Button)", "RespawnBtn", "Respawn", "RespawnSize", function()
Parity.SelfRevive()
return "Respawn"
end, "Respawn Gui Size")
ButtonToggle("SelfReviveBtn", "Self Revive (Button)", "SelfReviveBtn", "Self Revive", "SelfReviveSize", function()
local character = LocalPlayer.Character
local tag = character and character:GetAttribute("Tag")
if not tag then return "Self Revive" end
ReviveTag(tag, true)
return "Self Revive"
end, "Self Revive Gui Size")
ButtonToggle("SuperBounceBtn", "Super Bounce Button", "SuperBounceBtn", "Super Bounce", "SuperBounceSize", function()
Parity.SuperBounce()
return "Super Bounce"
end)
ButtonToggle("LagBtn", "Lag Switch (Button)", "LagBtn", "Start Lag", "LagSize", function()
Parity.StartLag(State.Opt.LagMs or 200)
return "Start Lag"
end, "Lag Switch Gui Size")
ButtonToggle("SlideBtn", "Infinite Slide (Button)", "SlideBtn", "Infinite Slide: OFF", "SlideSize", function()
State.Opt.InfSlide = not State.Opt.InfSlide
return State.Opt.InfSlide and "Infinite Slide: ON" or "Infinite Slide: OFF"
end, "Infinite Slide Gui Size")
ButtonToggle("BhopBtn", "Show BHOP Button", "BhopBtn", "BHOP: OFF", "BhopSize", function()
State.Opt.Bhop = not State.Opt.Bhop
return State.Opt.Bhop and "BHOP: ON" or "BHOP: OFF"
end, "BHOP Gui Size")
ButtonToggle("CrouchBtn", "Auto Crouch (Button)", "CrouchBtn", "Auto Crouch: OFF", "CrouchSize", function()
State.Opt.AutoCrouch = not State.Opt.AutoCrouch
return State.Opt.AutoCrouch and "Auto Crouch: ON" or "Auto Crouch: OFF"
end, "Auto Crouch Gui Size")
ButtonToggle("GravityBtn", "Gravity Button", "GravityBtn", "Gravity: OFF", "GravitySize", function()
State.Opt.GravityOn = not State.Opt.GravityOn
return State.Opt.GravityOn and "Gravity: ON" or "Gravity: OFF"
end, "Gravity Gui Size")
local adjGroup = dragTab:AddLeftGroupbox("Player Adjustments", "gauge")
adjGroup:AddSlider("AdjJumpHeight", {
Text = "Player Jump",
Min = 0,
Max = 200,
Default = 7,
Rounding = 1,
Callback = function(value) SetAdjustment("JumpHeight", value) end,
})
adjGroup:AddSlider("AdjJumpAccel", {
Text = "Player Jump Acceleration",
Min = 0,
Max = 100,
Default = 10,
Rounding = 1,
Callback = function(value) SetAdjustment("JumpAcceleration", value) end,
})
adjGroup:AddSlider("AdjJumpCap", {
Text = "Player Jump Cap",
Min = 0,
Max = 500,
Default = 80,
Rounding = 0,
Callback = function(value) SetAdjustment("JumpCap", value) end,
})
adjGroup:AddSlider("AdjAirAccel", {
Text = "Air Acceleration",
Min = 0,
Max = 100,
Default = 3,
Rounding = 1,
Callback = function(value) SetAdjustment("AirAcceleration", value) end,
})
adjGroup:AddToggle("JumpPowerOn", {
Text = "Jump Power Toggle",
Default = false,
Callback = function(on) State.Opt.JumpPowerOn = on end,
})
adjGroup:AddInput("JumpPowerValue", {
Text = "Player Jump Power",
Numeric = true,
Placeholder = "20",
Callback = function(value) State.Opt.JumpPower = tonumber(value) or 20 end,
})
adjGroup:AddToggle("WalkCfOn", {
Text = "Walkspeed Toggle",
Default = false,
Callback = function(on)
State.Opt.WalkCfOn = on
end,
})
adjGroup:AddInput("WalkCfValue", {
Text = "Player Walkspeed",
Numeric = true,
Placeholder = "5",
Callback = function(value) State.Opt.WalkCf = tonumber(value) or 5 end,
})
local camGroup = dragTab:AddRightGroupbox("Camera & Gun", "camera")
camGroup:AddInput("CamX", {
Text = "Stretch Horizontal",
Numeric = true,
Placeholder = "1",
Callback = function(value) State.Opt.CamX = tonumber(value) or 1 end,
})
camGroup:AddInput("CamY", {
Text = "Stretch Vertical",
Numeric = true,
Placeholder = "1",
Callback = function(value) State.Opt.CamY = tonumber(value) or 1 end,
})
camGroup:AddButton({
Text = "Set Camera Stretch",
Func = function()
Parity.CameraStretch(State.Opt.CamX or 1, State.Opt.CamY or 1)
Alert(string.format("Stretch set to %s x %s", tostring(State.Opt.CamX or 1), tostring(State.Opt.CamY or 1)))
end,
})
camGroup:AddInput("FovMult", {
Text = "Player FOV",
Numeric = true,
Placeholder = "Number (multiplier)",
Callback = function(value)
local mult = tonumber(value) or 1
Alert(Parity.CameraFov(mult) and string.format("FOV x%s", tostring(mult)) or "Camera service not found")
end,
})
camGroup:AddButton({
Text = "Set to Infinite Ammo",
Func = function()
Alert(string.format("Ammo patched on %d clips", Parity.InfiniteAmmo()))
end,
})
camGroup:AddButton({
Text = "Remove Invisible Walls",
Func = function()
Alert(string.format("Disabled collision on %d parts", Parity.InvisibleWalls(false)))
end,
})
local moveGroup2 = dragTab:AddLeftGroupbox("Movement Modification", "wind")
moveGroup2:AddDropdown("JumpType", {
Text = "Auto Jump Mode",
Values = { "Simulation", "Realistic" },
Default = 1,
Callback = function(value) State.Opt.JumpType = value end,
})
moveGroup2:AddToggle("BackwardBhop", {
Text = "BHOP Backwards",
Default = false,
Description = "Stored like the original; the payload body never reads it",
Callback = function(on) State.Opt.BackwardBhop = on end,
})
moveGroup2:AddToggle("SpiderHop", {
Text = "Spider Hop (Beta)",
Default = false,
Callback = function(on) State.Opt.SpiderHop = on end,
})
moveGroup2:AddInput("BhopAcceleration", {
Text = "BHOP Acceleration (negative only)",
Numeric = true,
Placeholder = "-0.1",
Callback = function(value) State.Opt.BhopAcceleration = tonumber(value) or -0.1 end,
})
moveGroup2:AddToggle("AutoAccel", {
Text = "Auto Acceleration (Legit)",
Default = false,
Callback = function(on) State.Opt.AutoAccel = on end,
})
moveGroup2:AddInput("AutoAccelMaxAccel", {
Text = "Max Acceleration",
Numeric = true,
Placeholder = "3",
Callback = function(value) State.Opt.AutoAccelMaxAccel = tonumber(value) or 3 end,
})
moveGroup2:AddInput("AutoAccelMinAccel", {
Text = "Min Acceleration",
Numeric = true,
Placeholder = "-1",
Callback = function(value) State.Opt.AutoAccelMinAccel = tonumber(value) or -1 end,
})
moveGroup2:AddInput("AutoAccelMaxSpeed", {
Text = "Max Speed",
Numeric = true,
Placeholder = "70",
Callback = function(value) State.Opt.AutoAccelMaxSpeed = tonumber(value) or 70 end,
})
moveGroup2:AddDropdown("CrouchType", {
Text = "Select Crouch Type",
Values = { "Rapid", "Ground", "Air", "Normal" },
Default = 1,
Callback = function(value) State.Opt.CrouchType = value end,
})
moveGroup2:AddInput("CrouchDebounce", {
Text = "Crouch Speed",
Numeric = true,
Placeholder = "0.1",
Callback = function(value) State.Opt.CrouchDebounce = tonumber(value) or 0.1 end,
})
moveGroup2:AddToggle("AutoCrouch", {
Text = "Auto Crouch",
Default = false,
Callback = function(on)
State.Opt.AutoCrouch = on
if not on and Parity.Crouch.Holding then
SendKeybind("Crouching", false)
Parity.Crouch.Holding = false
end
end,
})
local autoGroup2 = dragTab:AddRightGroupbox("Automation", "play")
autoGroup2:AddDropdown("RespawnType", {
Text = "Respawn Type",
Values = { "Spawnpoint", "Fake Revive" },
Default = 1,
Callback = function(value) State.Opt.RespawnType = value end,
})
autoGroup2:AddDropdown("LagMode", {
Text = "Lag Mode",
Values = { "Normal", "Demon", "FastFlag" },
Default = 1,
Callback = function(value) State.Opt.LagMode = value end,
})
autoGroup2:AddToggle("AutoBuy", {
Text = "Auto Purchase Selected Item",
Default = false,
Callback = function(on)
State.Opt.AutoBuy = on
Parity.Buy.Last = os.clock()
end,
})
autoGroup2:AddToggle("EmoteCarry", {
Text = "Carry While Emote",
Default = false,
Callback = function(on) State.Opt.EmoteCarry = on end,
})
autoGroup2:AddKeybind("LagKey", {
Text = "Lag Switch Keybind",
Default = "H",
Mode = "Toggle",
Callback = function()
task.spawn(function() Parity.StartLag(State.Opt.LagMs or 200) end)
end,
ChangedCallback = function(name) State.Opt.LagKey = name end,
})
autoGroup2:AddKeybind("CrouchKey", {
Text = "Keybind to Auto Crouch (Hold)",
Default = "RightControl",
Mode = "Hold",
Callback = function(down)
State.Opt.CrouchHeld = down
if not down then return end
task.spawn(function()
while State.Opt.CrouchHeld do
Parity.CrouchFunction()
task.wait(0.05)
end
end)
end,
ChangedCallback = function(name) State.Opt.CrouchKey = name end,
})
autoGroup2:AddKeybind("BhopKey", {
Text = "Keybind to BHOP",
Default = "B",
Mode = "Toggle",
Callback = function(down)
State.Opt.Bhop = down and true or false
Parity.SetBhop(State.Opt.Bhop)
end,
ChangedCallback = function(name) State.Opt.BhopKey = name end,
})
local farmGroup2 = dragTab:AddLeftGroupbox("Farm Extras", "seedling")
farmGroup2:AddInput("TokenFarmOffset", {
Text = "Token Farm Offset",
Placeholder = "0 -8 0",
Callback = function(text)
local x, y, z = tostring(text):match("^%s*([%-%d%.]+)%s+([%-%d%.]+)%s+([%-%d%.]+)%s*$")
if x and y and z then
State.Opt.TokenOffset = Vector3.new(tonumber(x), tonumber(y), tonumber(z))
end
end,
})
farmGroup2:AddDropdown("TimerRoundState", {
Text = "Auto Timer Round State",
Values = { "Round Started", "Intermission", "All" },
Default = 1,
Callback = function(value) State.Opt.TimerRoundState = value end,
})
farmGroup2:AddInput("EmoteDashAccel", {
Text = "Aggressive Emote Acceleration (negative only)",
Numeric = true,
Placeholder = "-2",
Callback = function(value) State.Opt.EmoteDashAccel = tonumber(value) or -2 end,
})
farmGroup2:AddToggle("GravityToggle", {
Text = "Gravity",
Default = false,
Callback = function(on)
State.Opt.GravityOn = on
Workspace.Gravity = on and (State.Opt.Gravity or 10) or State.NormalGravity
end,
})
farmGroup2:AddInput("GravityAdjust", {
Text = "Gravity Adjustment",
Numeric = true,
Placeholder = "10",
Callback = function(value)
State.Opt.Gravity = tonumber(value) or 10
if State.Opt.GravityOn then Workspace.Gravity = State.Opt.Gravity end
end,
})
local moreGroup = dragTab:AddRightGroupbox("Buttons & Keybinds", "keyboard")
ButtonToggle("CarryBtn", "Auto Carry (Button)", "CarryBtn", "Auto Carry: OFF", "CarrySize", function()
State.Opt.AutoCarry = not State.Opt.AutoCarry
if State.Opt.AutoCarry then StartAutoCarry() else StopAutoCarry() end
return State.Opt.AutoCarry and "Auto Carry: ON" or "Auto Carry: OFF"
end, "Auto Carry Gui Size")
ButtonToggle("EmoteBtn", "Auto Emote Dash Button", "EmoteBtn", "Start Emote", "EmoteSize", function()
State.Opt.EmoteDashAggressive = not State.Opt.EmoteDashAggressive
if State.Opt.EmoteDashAggressive then
Parity.StartAggressiveEmote()
end
return State.Opt.EmoteDashAggressive and "Stop Emote" or "Start Emote"
end, "Auto Emote Dash Gui Size")
ButtonToggle("FlyBtn", "Fly Button", "FlyBtn", "Fly: OFF", "FlySize", function()
State.Opt.Fly = not State.Opt.Fly
return State.Opt.Fly and "Fly: ON" or "Fly: OFF"
end)
moreGroup:AddKeybind("CarryKey", {
Text = "Keybind to Carry",
Default = "Q",
Mode = "Toggle",
Callback = function(down)
State.Opt.AutoCarry = down and true or false
if State.Opt.AutoCarry then StartAutoCarry() else StopAutoCarry() end
end,
ChangedCallback = function(name) State.Opt.CarryKey = name end,
})
moreGroup:AddKeybind("EmoteKey", {
Text = "Keybind to Emote Dash",
Default = "RightControl",
Mode = "Toggle",
Callback = function(down)
State.Opt.EmoteDashAggressive = down and true or false
if down then Parity.StartAggressiveEmote() end
end,
ChangedCallback = function(name) State.Opt.EmoteKey = name end,
})
moreGroup:AddKeybind("GravityKey", {
Text = "Gravity Keybind",
Default = "J",
Mode = "Toggle",
Callback = function(down)
State.Opt.GravityOn = down and true or false
Workspace.Gravity = State.Opt.GravityOn and (State.Opt.Gravity or 10) or State.NormalGravity
end,
ChangedCallback = function(name) State.Opt.GravityKey = name end,
})
State.Opt.TimerRoundState = State.Opt.TimerRoundState or "Any"
State.Opt.TokenOffset = State.Opt.TokenOffset or Vector3.new(0, -8, 0)
function Parity.ForceRespawn()
local events = ReplicatedStorage:FindFirstChild("Events")
local setMode = events and events:FindFirstChild("SetPlayerMode")
if not setMode then return false end
setMode:FireServer(true)
return true
end
function Parity.OpenLeaderboard()
SendKeybind("Leaderboard", true)
task.delay(0.1, function() SendKeybind("Leaderboard", false) end)
return true
end
Parity.FrontCamera = { On = false }
function Parity.FrontCameraToggle()
local character, humanoid = Character()
local camera = Workspace.CurrentCamera
if not character or not humanoid or not camera then return false end
Parity.FrontCamera.On = not Parity.FrontCamera.On
camera.CameraSubject = Parity.FrontCamera.On and character:FindFirstChild("Head") or humanoid
return Parity.FrontCamera.On
end
local surfaceGroup = dragTab:AddLeftGroupbox("Game & Map Modification", "shield")
surfaceGroup:AddToggle("DisableShake", {
Text = "Disable Camera Shake",
Default = false,
Callback = function(on)
if on then
Alert(DisableCameraShake() and "Camera shake killed" or "Camera shake hook not found")
end
end,
})
surfaceGroup:AddToggle("DisableVignette", {
Text = "Disable Vignette",
Default = false,
Callback = function(on)
if on then
Alert(DisableVignette() and "Nextbot vignette killed" or "Vignette not found")
end
end,
})
surfaceGroup:AddToggle("RemoveRewards", {
Text = "Remove Reducing Rewards",
Default = false,
Callback = function(on)
if on then
Alert(string.format("Removed %d safe zone parts", RemoveSafeZones()))
end
end,
})
surfaceGroup:AddButton({
Text = "Force Respawn",
Func = function()
Alert(Parity.ForceRespawn() and "SetPlayerMode fired" or "SetPlayerMode not found")
end,
})
surfaceGroup:AddButton({
Text = "Open Leaderboard",
Func = function()
Alert(Parity.OpenLeaderboard() and "Leaderboard keybind sent" or "KeybindService not found")
end,
})
surfaceGroup:AddButton({
Text = "Enable Front Camera",
Func = function()
Alert(Parity.FrontCameraToggle() and "Front camera on" or "Front camera off")
end,
})
local cosmeticsGroup = dragTab:AddRightGroupbox("Cosmetics & Emote Changer", "shirt")
cosmeticsGroup:AddButton({
Text = "Reset Cosmetics",
Func = function()
local touched = Parity.RestoreCosmetics()
Alert(string.format("Restored %d cosmetics", touched or 0))
end,
})
cosmeticsGroup:AddButton({
Text = "Apply Emote Mappings",
Func = function()
Parity.BuildEmoteMap(State.Opt.EmotePlay, State.Opt.EmoteShow)
Parity.StartEmoteWatcher()
Alert("Emote mapping applied, watcher running")
end,
})
cosmeticsGroup:AddButton({
Text = "Reset Emote Mappings",
Func = function()
Parity.ClearEmoteMap()
Alert("Emote mappings cleared")
end,
})
cosmeticsGroup:AddLabel("Warning: Do not use locked emotes from the emote changer or you may get banned easily")
cosmeticsGroup:AddLabel("To change it back to the original, please rejoin.")
local vipGroup = dragTab:AddLeftGroupbox("VIP Automations", "play")
vipGroup:AddDropdown("MapSection", {
Text = "Map Section",
Values = { "Map 1", "Map 2", "Map 3", "Map 4" },
Default = 1,
Callback = function(value)
State.Opt.VoteMap = tonumber(tostring(value):match("%d+")) or 1
end,
})
vipGroup:AddDropdown("GamemodeSection", {
Text = "Gamemode Section",
Values = { "Mode 1", "Mode 2", "Mode 3", "Mode 4" },
Default = 1,
Callback = function(value)
State.Opt.VoteMode = tonumber(tostring(value):match("%d+")) or 1
end,
})
vipGroup:AddToggle("AutoSetTimer", {
Text = "Auto Set Timer",
Default = false,
Callback = function(on)
State.Opt.AutoTimeOn = on
if on then State.Opt.LastTimerSet = State.Opt.LastTimerSet or os.clock() end
end,
})
Connect(RunService.Heartbeat, function()
if not State.Alive then return end
if not (State.Opt.AutoMap or State.Opt.AutoSpecial or State.Opt.AutoTimeOn) then return end
local now = os.clock()
if now - (State.Opt.LastVipTick or 0) < 1 then return end
State.Opt.LastVipTick = now
local roundState = State.Opt.TimerRoundState or "All"
local inRound = State.RoundState == "Round Started"
if roundState == "Round Started" and not inRound then return end
if roundState == "Intermission" and inRound then return end
if State.Opt.AutoMap and State.Opt.AutoMapName then
Parity.AutoAdmin("!Map " .. State.Opt.AutoMapName)
end
if State.Opt.AutoSpecial and State.Opt.AutoSpecialName then
Parity.AutoAdmin("!SpecialRound " .. State.Opt.AutoSpecialName)
end
if State.Opt.AutoTimeOn and State.Opt.AutoTime then
Parity.AutoAdmin("!Time " .. tostring(State.Opt.AutoTime))
end
end)
local clientTools = dragTab:AddRightGroupbox("Client", "wrench")
clientTools:AddButton({
Text = "Remove FPS Counter",
Func = function()
local gui = LocalPlayer:FindFirstChild("PlayerGui")
local counter = gui and (gui:FindFirstChild("FpsCounter") or gui:FindFirstChild("FPS"))
if counter then
counter:Destroy()
Alert("FPS counter removed")
else
Alert("FPS counter not found")
end
end,
})
clientTools:AddButton({
Text = "Load Extension",
Func = function()
local path = State.Opt.ExtensionPath
if not path or path == "" then
Alert("Set an extension path first")
return
end
if not (readfile and loadstring) then
Alert("Executor has no readfile; extension loading unavailable")
return
end
local ok, body = pcall(readfile, path)
if not ok or type(body) ~= "string" then
Alert("Could not read " .. tostring(path))
return
end
local chunk, err = loadstring(body)
if not chunk then
Alert("Extension failed to compile: " .. tostring(err))
return
end
local ran, why = pcall(chunk)
Alert(ran and "Extension loaded" or ("Extension error: " .. tostring(why)))
end,
})
clientTools:AddInput("ExtensionPath", {
Text = "Extension Path",
Placeholder = "Reicht/ext.lua",
Callback = function(text) State.Opt.ExtensionPath = text end,
})
State.Opt.RespawnType = State.Opt.RespawnType or "Spawnpoint"
State.Opt.LagMode = State.Opt.LagMode or "Normal"
State.Opt.JumpType = State.Opt.JumpType or "Simulation"
State.Opt.CrouchDebounce = State.Opt.CrouchDebounce or 0.1
State.Opt.BhopAcceleration = State.Opt.BhopAcceleration or -0.1
State.Opt.CrouchType = State.Opt.CrouchType or "Rapid"
State.NormalGravity = Workspace.Gravity
State.Opt.Gravity = State.Opt.Gravity or 10
Connect(Players.PlayerRemoving, function(player)
local character = player.Character
local highlight = character and character:FindFirstChild("ReichtEsp")
if highlight then highlight:Destroy() end
local key = "player_" .. player.Name
local entry = State.Tracers[key]
if entry then
pcall(function() entry.Line:Remove() end)
State.Tracers[key] = nil
end
end)
if Library.Notify then
pcall(Library.Notify, Library, "Reicht", "Evade loaded", 4, "Check")
end
