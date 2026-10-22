if not game:IsLoaded() then
game.Loaded:Wait()
end
if game.GameId ~= 9872472334 then
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
root.CFrame = targetRoot.CFrame + Vector3.new(0, 1.5, 0)
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
Text = "Edge Trimp",
Default = false,
Description = "Adds lift when you run off a ledge",
Callback = function(on) State.Opt.EdgeTrimp = on end,
})
physicsGroup:AddSlider("TrimpDrop", {
Text = "Trimp Min Drop",
Min = 1,
Max = 40,
Default = 6,
Rounding = 0,
Callback = function(value) State.Opt.TrimpDrop = value end,
})
physicsGroup:AddSlider("TrimpHeight", {
Text = "Trimp Height",
Min = 0.5,
Max = 4,
Default = 1.4,
Rounding = 1,
Callback = function(value) State.Opt.TrimpHeight = value end,
})
physicsGroup:AddToggle("LagSwitch", {
Text = "Lag Switch",
Default = false,
Description = "Freezes the frame while moving",
Callback = function(on)
State.Opt.LagSwitch = on
if on then StartLagSwitch() else StopLagSwitch() end
end,
})
physicsGroup:AddSlider("LagMs", {
Text = "Lag Window",
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
Text = "Emote ID",
Placeholder = "numeric id",
Callback = function(text)
local id = tonumber(text)
State.Opt.EmoteId = id
end,
})
local farmGroup = farmTab:AddLeftGroupbox("Automation", "tractor")
farmGroup:AddToggle("TokenFarm", {
Text = "Token Farm",
Default = false,
Description = "Parks on a random player and revives them on a timer",
Callback = function(on)
State.Opt.TokenFarm = on
if on then StartTokenFarm() else StopTokenFarm() end
end,
})
farmGroup:AddSlider("TokenDelay", {
Text = "Revive Delay",
Min = 0.5,
Max = 6,
Default = 2,
Rounding = 1,
Suffix = " s",
Callback = function(value) State.Opt.TokenDelay = value end,
})
farmGroup:AddToggle("TicketFarm", {
Text = "Ticket Farm",
Default = false,
Description = "Walks onto every spawned ticket",
Callback = function(on)
State.Opt.TicketFarm = on
if on then StartTicketFarm() else StopTicketFarm() end
end,
})
farmGroup:AddToggle("PointFarm", {
Text = "Point Farm",
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
Text = "AFK Pad",
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
Text = "Auto Revive",
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
Text = "Map Number",
Min = 1,
Max = 12,
Default = 1,
Rounding = 0,
Callback = function(value) State.Opt.VoteMap = value end,
})
voteGroup:AddSlider("VoteMode", {
Text = "Mode Number",
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
Text = "Tracer Nextbots",
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
Text = "Round Timer",
Default = false,
Callback = function(on)
State.Opt.ShowTimer = on
if on then ShowTimer() else HideTimer() end
end,
})
overlayGroup:AddToggle("ShowSpecial", {
Text = "Special Round",
Default = false,
Callback = function(on)
State.Opt.ShowSpecial = on
if on then ShowSpecialRound() else HideSpecialRound() end
end,
})
overlayGroup:AddToggle("NoVignette", {
Text = "Remove Nextbot Vignette",
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
Text = "Infinite Range",
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
Text = "Anti AFK",
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
Text = "Speed",
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
Text = "Air Strafe Acceleration",
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
Text = "Emote Name",
Default = "",
Placeholder = "Emote folder name",
})
emoteGroup:AddSlider("MovableSpeed", {
Text = "Emote SpeedMult",
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
