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
local function EventsFolder()
local events = ReplicatedStorage:FindFirstChild("Events")
return events
end
local function Unload()
State.Alive = false
for _, connection in ipairs(State.Connections) do
pcall(function() connection:Disconnect() end)
end
State.Connections = {}
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
if remote then
return pcall(function()
if mode then remote:FireServer(index, true) else remote:FireServer(index) end
end)
end
local events = Events()
local folder = events and events:FindFirstChild("Player")
local legacy = folder and folder:FindFirstChild("Vote")
if not legacy then return false end
return pcall(function() legacy:FireServer(index) end)
end
local function FarmTargets()
local folder = Workspace:FindFirstChild("Players")
local out = {}
if not folder then return out end
for _, model in ipairs(folder:GetChildren()) do
if model:IsA("Model")
and model ~= LocalPlayer.Character
and model:FindFirstChild("HumanoidRootPart")
and model:GetAttribute("Tag") ~= nil
then
table.insert(out, model)
end
end
return out
end
local function Objectives()
local out = {}
local shared = ReplicatedStorage:FindFirstChild("Shared")
local data = shared and shared:FindFirstChild("Data")
local registry = data and data:FindFirstChild("Registry")
local objects = registry and registry:FindFirstChild("Objects")
local source = objects or Workspace
for _, item in ipairs(source:GetDescendants()) do
if item:FindFirstChild("WhenActivated") and item:GetAttribute("Tag") ~= nil then
table.insert(out, item)
end
end
return out
end
local function TicketsFolder()
local effects = Workspace:FindFirstChild("Effects")
return effects and effects:FindFirstChild("Tickets")
end
local function BotFolder()
local root = Workspace:FindFirstChild("Game")
return root and root:FindFirstChild("Players")
end
local function ClearEsp()
for _, player in ipairs(Players:GetPlayers()) do
local character = player.Character
local highlight = character and character:FindFirstChild("ReichtEsp")
if highlight then highlight:Destroy() end
end
local bots = BotFolder()
if bots then
for _, bot in ipairs(bots:GetChildren()) do
local tag = bot:FindFirstChild("ReichtEsp")
if tag then tag:Destroy() end
end
end
end
local function EspPlayer(player)
local character = player.Character
if not character or character == LocalPlayer.Character then return end
if character:FindFirstChild("ReichtEsp") then return end
local highlight = Instance.new("Highlight")
highlight.Name = "ReichtEsp"
highlight.Adornee = character
highlight.FillColor = Color3.fromRGB(255, 60, 60)
highlight.FillTransparency = 0.55
highlight.OutlineColor = Color3.fromRGB(255, 255, 255)
highlight.DepthMode = Enum.HighlightDepthMode.AlwaysOnTop
highlight.Parent = character
end
local function IsNextbot(model)
if not model:IsA("Model") then return false end
if model:GetAttribute("Team") == "Nextbot" then return true end
return model:FindFirstChild("Hitbox") ~= nil
end
local function EspBots()
local bots = BotFolder()
if not bots then return 0 end
local marked = 0
for _, bot in ipairs(bots:GetChildren()) do
if IsNextbot(bot) and not bot:FindFirstChild("ReichtEsp") then
local highlight = Instance.new("Highlight")
highlight.Name = "ReichtEsp"
highlight.Adornee = bot
highlight.FillColor = Color3.fromRGB(120, 200, 255)
highlight.FillTransparency = 0.6
highlight.OutlineColor = Color3.fromRGB(255, 255, 255)
highlight.DepthMode = Enum.HighlightDepthMode.AlwaysOnTop
highlight.Parent = bot
marked += 1
end
end
return marked
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
local playerTab = win:AddTab("Player", "user", "Speed, jump, flight")
local autoTab = win:AddTab("Auto", "repeat", "Revive and map voting")
local espTab = win:AddTab("Visuals", "eye", "Highlights and lighting")
local miscTab = win:AddTab("Misc", "settings", "AFK and unload")
local moveGroup = playerTab:AddLeftGroupbox("Movement", "wind")
moveGroup:AddToggle("SpeedOn", {
Text = "Walk Speed",
Default = false,
Callback = function(on)
State.Opt.SpeedOn = on
local _, humanoid = Character()
if humanoid then humanoid.WalkSpeed = on and (State.Opt.Speed or 60) or 16 end
end,
})
moveGroup:AddSlider("Speed", {
Text = "Speed Value",
Min = 16,
Max = 350,
Default = 60,
Rounding = 0,
Suffix = " ws",
Callback = function(value)
State.Opt.Speed = value
if State.Opt.SpeedOn then
local _, humanoid = Character()
if humanoid then humanoid.WalkSpeed = value end
end
end,
})
moveGroup:AddToggle("JumpOn", {
Text = "Jump Power",
Default = false,
Callback = function(on)
State.Opt.JumpOn = on
local _, humanoid = Character()
if humanoid then
humanoid.UseJumpPower = true
humanoid.JumpPower = on and (State.Opt.Jump or 80) or 50
end
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
moveGroup:AddToggle("Bhop", {
Text = "Auto Bhop",
Default = false,
Description = "Jumps again the moment you land",
Callback = function(on) State.Opt.Bhop = on end,
})
moveGroup:AddToggle("Fly", {
Text = "Fly",
Default = false,
Callback = function(on)
State.Opt.Fly = on
local _, humanoid, root = Character()
if not humanoid or not root then return end
if on then
humanoid.PlatformStand = true
else
humanoid.PlatformStand = false
root.Velocity = Vector3.zero
end
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
local physicsGroup = playerTab:AddRightGroupbox("Physics", "activity")
physicsGroup:AddSlider("Gravity", {
Text = "Gravity",
Min = 0,
Max = 250,
Default = 196,
Rounding = 0,
Callback = function(value) Workspace.Gravity = value end,
})
physicsGroup:AddToggle("Noclip", {
Text = "Noclip",
Default = false,
Callback = function(on) State.Opt.Noclip = on end,
})
physicsGroup:AddButton({
Text = "Reset Walk Speed",
Func = function()
local _, humanoid = Character()
if humanoid then humanoid.WalkSpeed = 16 end
end,
})
local reviveGroup = autoTab:AddLeftGroupbox("Revive", "heart")
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
reviveGroup:AddToggle("AutoRevive", {
Text = "Auto Revive",
Default = false,
Description = "Fires the revive remote on every tracked player",
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
local farmTab = win:AddTab("Farm", "tractor", "Objectives, tickets, carry")
local farmGroup = farmTab:AddLeftGroupbox("Automation", "tractor")
farmGroup:AddToggle("AutoObjective", {
Text = "Auto Objective",
Default = false,
Description = "Interact Dynamic on every objective with a Tag",
Callback = function(on)
State.Opt.AutoObjective = on
if not on then return end
task.spawn(function()
while State.Alive and State.Opt.AutoObjective do
for _, item in ipairs(Objectives()) do
Interact("Dynamic", TagOf(item))
end
task.wait(2)
end
end)
end,
})
farmGroup:AddToggle("AutoTickets", {
Text = "Auto Tickets",
Default = false,
Description = "Walks onto every ticket the game spawns",
Callback = function(on)
State.Opt.AutoTickets = on
if not on then return end
task.spawn(function()
while State.Alive and State.Opt.AutoTickets do
local folder = TicketsFolder()
local _, _, root = Character()
if folder and root then
for _, ticket in ipairs(folder:GetChildren()) do
local part = ticket:IsA("BasePart") and ticket or ticket:FindFirstChildWhichIsA("BasePart")
if part then root.CFrame = CFrame.new(part.Position + Vector3.new(0, 3, 0)) end
end
end
task.wait(0.4)
end
end)
end,
})
farmGroup:AddToggle("AutoCarry", {
Text = "Auto Carry",
Default = false,
Description = "Interact Carry on the nearest tracked player",
Callback = function(on)
State.Opt.AutoCarry = on
if not on then return end
task.spawn(function()
while State.Alive and State.Opt.AutoCarry do
local targets = FarmTargets()
if targets[1] then Interact("Carry", TagOf(targets[1])) end
task.wait(0.5)
end
end)
end,
})
farmGroup:AddToggle("NoVignette", {
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
local voteGroup = autoTab:AddRightGroupbox("Map Voting", "map")
voteGroup:AddSlider("VoteMap", {
Text = "Map Number",
Min = 1,
Max = 12,
Default = 1,
Rounding = 0,
Callback = function(value) State.Opt.VoteMap = value end,
})
voteGroup:AddButton({
Text = "Vote Now",
Func = function()
if Vote(State.Opt.VoteMap or 1) then Alert("Vote sent.") end
end,
})
voteGroup:AddToggle("AutoVote", {
Text = "Auto Vote",
Default = false,
Description = "Votes again whenever a new vote opens",
Callback = function(on)
State.Opt.AutoVote = on
if on and State.Opt.AutoRevive == nil then State.Opt.AutoRevive = false end
end,
})
local espGroup = espTab:AddLeftGroupbox("Highlights", "eye")
espGroup:AddToggle("EspPlayers", {
Text = "Player ESP",
Default = false,
Callback = function(on)
State.Opt.EspPlayers = on
if not on then ClearEsp() end
end,
})
espGroup:AddToggle("EspBots", {
Text = "NextBot ESP",
Default = false,
Callback = function(on) State.Opt.EspBots = on end,
})
local lightGroup = espTab:AddRightGroupbox("Lighting", "sun")
lightGroup:AddToggle("Fullbright", {
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
local miscGroup = miscTab:AddLeftGroupbox("Client", "cpu")
miscGroup:AddToggle("AntiAfk", {
Text = "Anti AFK",
Default = true,
Callback = function(on) State.Opt.AntiAfk = on end,
})
miscGroup:AddButton({
Text = "Unload Reicht",
Func = function() Unload() end,
})
State.Opt.AntiAfk = true
State.Opt.Speed = 60
State.Opt.Jump = 80
State.Opt.FlySpeed = 90
State.Opt.VoteMap = 1
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
if State.Opt.SpeedOn and humanoid then
humanoid.WalkSpeed = State.Opt.Speed or 60
end
if State.Opt.Fly and humanoid and root then
local camera = Workspace.CurrentCamera
local move = humanoid.MoveDirection
local speed = State.Opt.FlySpeed or 90
local lift = 0
if UserInputService:IsKeyDown(Enum.KeyCode.Space) then lift += speed end
if UserInputService:IsKeyDown(Enum.KeyCode.LeftControl) then lift -= speed end
root.Velocity = (camera.CFrame.LookVector * move.Z + camera.CFrame.RightVector * move.X) * speed
+ Vector3.new(0, lift, 0)
end
if State.Opt.Noclip and character then
for _, part in ipairs(character:GetDescendants()) do
if part:IsA("BasePart") and part.CanCollide then part.CanCollide = false end
end
end
end)
Connect(RunService.Heartbeat, function()
if not State.Alive then return end
if State.Opt.Bhop then
local _, humanoid = Character()
if humanoid and humanoid:GetState() ~= Enum.HumanoidStateType.Jumping
and humanoid:GetState() ~= Enum.HumanoidStateType.Freefall
and UserInputService:IsKeyDown(Enum.KeyCode.Space) then
humanoid:ChangeState(Enum.HumanoidStateType.Jumping)
end
end
if State.Opt.EspPlayers then
for _, player in ipairs(Players:GetPlayers()) do EspPlayer(player) end
elseif State.Opt.EspBots then
EspBots()
end
end)
Connect(Players.PlayerAdded, function(player)
player.CharacterAdded:Connect(function()
task.wait(1)
if State.Alive and State.Opt.EspPlayers then EspPlayer(player) end
end)
end)
Connect(Players.PlayerRemoving, function(player)
local character = player.Character
local highlight = character and character:FindFirstChild("ReichtEsp")
if highlight then highlight:Destroy() end
end)
task.spawn(function()
while State.Alive do
if State.Opt.AutoRevive then
local _, humanoid = Character()
if humanoid and humanoid.Health <= 0 then
Respawn()
task.wait(3)
end
end
task.wait(1)
end
end)
if Library.Notify then
pcall(Library.Notify, Library, "Reicht", "Evade loaded", 4, "Check")
end
