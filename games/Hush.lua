local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local UIS = game:GetService("UserInputService")
local GuiService = game:GetService("GuiService")
local RS = game:GetService("ReplicatedStorage")
local LocalPlayer = Players.LocalPlayer
local Library = loadstring(game:HttpGet("https://raw.githubusercontent.com/deividcomsono/Obsidian/main/Library.lua"))()
local Options = Library.Options
local WIN = Library:CreateWindow({
Title = "Hush",
Footer = "contest build v1",
Size = UDim2.fromOffset(640, 520),
Center = true,
AutoShow = true,
ShowCustomCursor = true,
})
local Tabs = {
Main = WIN:AddTab({ Title = "Main", Icon = "crosshair" }),
Player = WIN:AddTab({ Title = "Player", Icon = "user" }),
Visuals = WIN:AddTab({ Title = "Visuals", Icon = "eye" }),
World = WIN:AddTab({ Title = "World", Icon = "globe" }),
Settings = WIN:AddTab({ Title = "Settings", Icon = "settings" }),
}
local function notify(text, duration)
pcall(function()
WIN:Notify({ Title = "Hush", Description = text, Duration = duration or 4 })
end)
end
local function get(id, fallback)
local opt = Options[id]
if not opt then
return fallback
end
local v = opt.Value
if v == nil then
return fallback
end
return v
end
local function keyDown(id)
local v = get(id, nil)
return type(v) == "string" and v ~= "" and v or nil
end
local Enabled = {}
local Raid = workspace:FindFirstChild("Raid")
local function raidChild(name)
Raid = workspace:FindFirstChild("Raid")
if not Raid then
return nil
end
return Raid:FindFirstChild(name)
end
local function localCharacter()
local ch = LocalPlayer.Character
if not ch or not ch.Parent then
return nil, nil, nil
end
local root = ch:FindFirstChild("HumanoidRootPart")
local hum = ch:FindFirstChildOfClass("Humanoid")
if not root or not hum or hum.Health <= 0 then
return nil, nil, nil
end
return ch, root, hum
end
local function zombieContainer()
local r = workspace:FindFirstChild("Raid")
if r then
local z = r:FindFirstChild("Zombies")
if z then
return z
end
local m = r:FindFirstChild("Map")
if m then
local z2 = m:FindFirstChild("Zombies")
if z2 then
return z2
end
end
end
local hl = workspace:FindFirstChild("HushLocal")
if hl then
local z3 = hl:FindFirstChild("Zombies")
if z3 then
return z3
end
end
return workspace:FindFirstChild("Zombies")
end
local function lootContainer()
local r = workspace:FindFirstChild("Raid")
if r then
local c = r:FindFirstChild("Containers")
if c then
return c
end
end
return workspace:FindFirstChild("Lootables")
end
local function partOf(model)
if not model or not model.Parent then
return nil
end
local ok, part = pcall(function()
return model:FindFirstChild("Head")
or model:FindFirstChild("HumanoidRootPart")
or model.PrimaryPart
end)
if ok and part then
return part
end
return nil
end
local function isAlive(model)
local part = partOf(model)
if not part then
return false
end
local hum = model:FindFirstChildOfClass("Humanoid")
if hum and hum.Health <= 0 then
return false
end
return true
end
local function flatten(v)
return Vector3.new(v.X, 0, v.Z)
end
local Camera = {
cam = nil,
yaw = 0,
pitch = 0,
dist = 14,
loaded = false,
}
local function currentCam()
if not Camera.cam or not Camera.cam.Parent then
Camera.cam = workspace.CurrentCamera
Camera.loaded = false
end
return Camera.cam
end
local function applyCamera()
local cam = currentCam()
if not cam then
return
end
local _, root = localCharacter()
local subject = root and root.Position
if not subject then
local cf = cam and cam.CFrame
subject = (cf and cf.Position) or Vector3.new(0, 5, 0)
end
local dist = tonumber(Camera.dist) or 14
local rot = CFrame.fromEulerAnglesYXZ(math.rad(tonumber(Camera.pitch) or -15), math.rad(tonumber(Camera.yaw) or 0), 0)
local look = rot.LookVector
if not (subject and look) then
return
end
local target = subject + look * -dist
cam.CFrame = CFrame.lookAt(target, subject)
end
local function setCustom(on)
local cam = currentCam()
if not cam then
return
end
if on then
cam.CameraType = Enum.CameraType.Scriptable
Camera.loaded = true
applyCamera()
elseif cam.CameraType == Enum.CameraType.Scriptable then
cam.CameraType = Enum.CameraType.Custom
Camera.loaded = false
end
end
pcall(function()
local cam = currentCam()
if cam then
Camera.dist = get("CamDist", 14)
Camera.yaw = 0
Camera.pitch = -15
end
end)
RunService:BindToRenderStep("HushCam", Enum.RenderPriority.Camera.Value + 1, function()
if not Enabled.NormalCam then
return
end
local cam = currentCam()
if not cam then
return
end
local _, root = localCharacter()
if not root then
return
end
if get("FaceMove", false) then
local vel = root.AssemblyLinearVelocity
local flat = flatten(vel)
if flat.Magnitude > 0.6 then
local want = math.deg(math.atan2(-flat.X, -flat.Z))
local delta = ((want - Camera.yaw + 540) % 360) - 180
Camera.yaw = Camera.yaw + delta * 0.12
end
end
local fov = get("FOV", 70)
if cam.FieldOfView ~= fov then
cam.FieldOfView = fov
end
Camera.dist = get("CamDist", 14)
applyCamera()
end)
do
local dragging = false
UIS.InputBegan:Connect(function(input, processed)
if processed then
return
end
if input.UserInputType == Enum.UserInputType.MouseButton2 and Enabled.NormalCam then
dragging = true
end
end)
UIS.InputEnded:Connect(function(input)
if input.UserInputType == Enum.UserInputType.MouseButton2 then
dragging = false
end
end)
UIS.InputChanged:Connect(function(input)
if input.UserInputType == Enum.UserInputType.MouseMovement and dragging then
local sens = get("CamSens", 0.5)
Camera.yaw = Camera.yaw - input.Delta.X * sens
Camera.pitch = math.clamp(Camera.pitch - input.Delta.Y * sens, -85, 80)
elseif input.UserInputType == Enum.UserInputType.MouseWheel and Enabled.NormalCam then
local cam = currentCam()
if cam then
local fov = cam.FieldOfView
cam.FieldOfView = math.clamp(fov - input.Position.Z * 4, 15, 120)
end
end
end)
end
local ESP = { drawings = {}, glows = {} }
local function blank()
return {
box = nil, nameDraw = nil, health = nil, dist = nil,
owner = nil,
}
end
local function newDrawing(class)
local ok, d = pcall(function()
return Drawing.new(class)
end)
if ok then
return d
end
return nil
end
local function ensure(e, idx)
if not e.box then
e.box = newDrawing("Square")
if e.box then
e.box.Thickness = 1.5
e.box.Filled = false
e.box.Transparency = 1
end
e.nameDraw = newDrawing("Text")
if e.nameDraw then
e.nameDraw.Size = 14
e.nameDraw.Center = true
e.nameDraw.Outline = true
e.nameDraw.Transparency = 1
pcall(function() e.nameDraw.Font = Drawing.Fonts.Plex end)
end
e.health = newDrawing("Line")
if e.health then
e.health.Thickness = 2
e.health.Transparency = 1
end
e.dist = newDrawing("Text")
if e.dist then
e.dist.Size = 13
e.dist.Center = true
e.dist.Outline = true
e.dist.Transparency = 1
pcall(function() e.dist.Font = Drawing.Fonts.Plex end)
end
e.owner = idx
end
return e
end
local function hide(e)
for _, d in pairs({ e.box, e.nameDraw, e.health, e.dist }) do
if d then
pcall(function()
d.Visible = false
end)
end
end
if e.glow then
pcall(function()
e.glow.Enabled = false
end)
end
end
local function glowFor(model)
if not ESP.glows[model] then
local ok, hl = pcall(function()
local h = Instance.new("Highlight")
h.FillTransparency = 0.7
h.OutlineTransparency = 0.2
h.DepthMode = Enum.HighlightDepthMode.AlwaysOnTop
h.Parent = model
return h
end)
ESP.glows[model] = (ok and hl) or false
end
local g = ESP.glows[model]
return g ~= false and g or nil
end
local function project(cam, pos)
local ok, sp, onScreen = pcall(function()
local v = cam:WorldToViewportPoint(pos)
return v, true
end)
if not ok or not sp or sp.Z <= 0 then
return nil
end
return sp.X, sp.Y, sp.Z
end
local function drawModel(e, cam, model, cfg)
local part = partOf(model)
if not part then
hide(e)
return
end
local pos = part.Position
local _, root = localCharacter()
if root then
local d = (pos - root.Position).Magnitude
if cfg.maxDist and cfg.maxDist > 0 and d > cfg.maxDist then
hide(e)
return
end
e.lastDist = d
end
local x, y, z = project(cam, pos)
if not x then
hide(e)
return
end
local scale = 1200 / z
local h = math.clamp(scale * cfg.heightScale, 18, 620)
local w = h * 0.62
if cfg.box and e.box then
e.box.Size = Vector2.new(w, h)
e.box.Position = Vector2.new(x - w / 2, y - h / 2)
e.box.Color = cfg.color
e.box.Visible = true
elseif e.box then
e.box.Visible = false
end
if cfg.name and e.nameDraw then
local hum = model:FindFirstChildOfClass("Humanoid")
local label = cfg.label or (hum and hum.DisplayName) or model.Name
e.nameDraw.Text = tostring(label)
e.nameDraw.Position = Vector2.new(x, y - h / 2 - 15)
e.nameDraw.Color = cfg.color
e.nameDraw.Visible = true
elseif e.nameDraw then
e.nameDraw.Visible = false
end
if cfg.health and e.health then
local hum = model:FindFirstChildOfClass("Humanoid")
if hum then
local frac = math.clamp(hum.Health / math.max(hum.MaxHealth, 1), 0, 1)
local top = y - h / 2
e.health.From = Vector2.new(x - w / 2 - 6, top + h * (1 - frac))
e.health.To = Vector2.new(x - w / 2 - 6, top + h)
e.health.Color = Color3.fromRGB(math.floor(255 * (1 - frac)), math.floor(255 * frac), 60)
e.health.Visible = true
else
e.health.Visible = false
end
elseif e.health then
e.health.Visible = false
end
if e.dist and cfg.textSize then
e.dist.Size = cfg.textSize
end
if cfg.showDist and e.dist and e.lastDist then
e.dist.Text = string.format("%d m", math.floor(e.lastDist / 3))
e.dist.Position = Vector2.new(x, y + h / 2 + 2)
e.dist.Color = cfg.color
e.dist.Visible = true
elseif e.dist then
e.dist.Visible = false
end
if cfg.glow then
local g = glowFor(model)
if g then
g.FillColor = cfg.glowColor
g.OutlineColor = cfg.glowColor
g.Enabled = true
end
else
local g = ESP.glows[model]
if g and g ~= false then
g.Enabled = false
end
end
end
local function sweep(store, cam, container, cfg, filter)
if not container then
return
end
local seen = {}
local i = 0
for _, model in ipairs(container:GetChildren()) do
if model:IsA("Model") and not filter(model) then
i = i + 1
local e = store[model]
if not e then
e = blank()
store[model] = e
end
seen[model] = true
local ok = pcall(drawModel, e, cam, model, cfg)
if not ok then
hide(e)
end
end
end
for model, e in pairs(store) do
if not seen[model] then
hide(e)
if e.glow and e.glow ~= false then
pcall(function()
e.glow:Destroy()
end)
end
store[model] = nil
end
end
end
local espZombie, espLoot, espPlayer = {}, {}, {}
RunService.RenderStepped:Connect(function()
local cam = workspace.CurrentCamera
if not cam then
return
end
local me = LocalPlayer.Character
if Enabled.EspEnabled then
sweep(espZombie, cam, zombieContainer(), {
box = get("EspBox", true),
name = get("EspName", false),
color = get("ESPColor", Color3.fromRGB(255, 80, 80)),
glow = get("EspGlow", false),
glowColor = get("GlowColor", Color3.fromRGB(255, 80, 80)),
maxDist = get("EspMaxDist", 3000),
heightScale = 1.9,
health = false,
showDist = true,
}, function(m)
return m == me
end)
else
for model, e in pairs(espZombie) do
hide(e)
espZombie[model] = nil
end
end
if Enabled.LootEnabled then
sweep(espLoot, cam, lootContainer(), {
box = true,
name = true,
color = get("LootColor", Color3.fromRGB(200, 200, 60)),
glow = false,
maxDist = get("LootMaxDist", 150),
heightScale = 0.8,
health = false,
textSize = get("LootTextSize", 16),
showDist = get("LootDist", false),
}, function()
return false
end)
else
for model, e in pairs(espLoot) do
hide(e)
espLoot[model] = nil
end
end
if Enabled.PlrEnabled then
local cfg = {
box = get("PlrBox", true),
name = get("PlrName", true),
color = get("PlrColor", Color3.fromRGB(90, 170, 255)),
glow = get("PlrGlow", false),
glowColor = get("PlrGlowColor", Color3.fromRGB(90, 170, 255)),
maxDist = get("PlrMaxDist", 3000),
heightScale = 1.9,
health = get("PlrHealth", false),
showDist = true,
}
local seen = {}
for _, plr in ipairs(Players:GetPlayers()) do
if plr ~= LocalPlayer and plr.Character and plr.Character.Parent then
seen[plr.Character] = true
local e = espPlayer[plr]
if not e then
e = blank()
espPlayer[plr] = e
end
pcall(drawModel, e, cam, plr.Character, cfg)
end
end
for plr, e in pairs(espPlayer) do
if not seen[plr.Character or false] then
hide(e)
espPlayer[plr] = nil
end
end
else
for plr, e in pairs(espPlayer) do
hide(e)
espPlayer[plr] = nil
end
end
end)
local fovCircle = newDrawing("Circle")
if fovCircle then
fovCircle.Thickness = 1.5
fovCircle.NumSides = 64
fovCircle.Filled = false
fovCircle.Transparency = 1
end
local function mousePos()
local ok, p = pcall(function()
return GuiService:GetMouseLocation()
end)
if not ok or not p then
return Vector2.new(0, 0)
end
return Vector2.new(p.X, p.Y)
end
RunService.RenderStepped:Connect(function()
if not fovCircle then
return
end
if not (get("ShowFov", false) and Enabled.SilentAim) then
fovCircle.Visible = false
return
end
local m = mousePos()
local r = get("FovSize", 30)
fovCircle.Position = m
fovCircle.Radius = r
fovCircle.Color = get("FovColor", Color3.fromRGB(255, 255, 255))
fovCircle.Visible = true
end)
local function withinFov(cam, pos, fovPx)
if not cam then
return false
end
local ok, sp = pcall(function()
return cam:WorldToViewportPoint(pos)
end)
if not ok or not sp or sp.Z <= 0 then
return false
end
local d = (Vector2.new(sp.X, sp.Y) - mousePos()).Magnitude
return d <= fovPx, d
end
local function pickTarget(cam)
local _, root = localCharacter()
if not root or not cam then
return nil
end
local range = get("GunRange", 500)
local fovPx = get("FovSize", 30)
local best, bestDist
local pools = { zombieContainer() }
for _, container in ipairs(pools) do
if container then
for _, model in ipairs(container:GetChildren()) do
if model:IsA("Model") and isAlive(model) then
local part = partOf(model)
if part then
local pos = part.Position
if (pos - root.Position).Magnitude <= range then
local inside, d = withinFov(cam, pos, fovPx)
if inside and (not bestDist or d < bestDist) then
best, bestDist = model, d
end
end
end
end
end
end
end
return best
end
do
local namecall
local hooked = false
local ok, old = pcall(function()
return hookmetamethod(game, "__namecall", function(self, ...)
local method = getnamecallmethod()
if Enabled.SilentAim and method == "FireServer" and typeof(self) == "Instance" then
local parent = self.Parent
if parent and parent.Name == "HushNet" then
local target = pickTarget(workspace.CurrentCamera)
if target then
local part = partOf(target)
if part then
return namecall(self, part.Position, ...)
end
end
end
end
return namecall(self, ...)
end)
end)
hooked = ok
namecall = old or function() end
end
do
local last = 0
RunService.Heartbeat:Connect(function()
if not Enabled.MeleeAura then
return
end
local now = os.clock()
local rate = get("MeleeRate", 0.5)
if now - last < rate then
return
end
local _, root = localCharacter()
if not root then
return
end
local range = get("MeleeRange", 16)
local container = zombieContainer()
if not container then
return
end
for _, model in ipairs(container:GetChildren()) do
if model:IsA("Model") and isAlive(model) then
local part = partOf(model)
if part then
local delta = part.Position - root.Position
local flat = flatten(delta)
if flat.Magnitude <= range then
local dir = flatten(root.CFrame.LookVector)
if dir.Magnitude > 0 then
dir = dir.Unit
end
if flat.Magnitude < 2.5 or (flat.Unit):Dot(dir) > 0.1 then
local net = RS:FindFirstChild("HushNet")
local remote = net and (net:FindFirstChild("combat.melee") or net:FindFirstChild("combat_melee"))
if remote then
pcall(function()
remote:FireServer(model)
end)
last = now
return
end
end
end
end
end
end
end)
end
do
local bv, bg
local function stopFly()
local ch = LocalPlayer.Character
local hum = ch and ch:FindFirstChildOfClass("Humanoid")
if hum then
pcall(function()
hum.PlatformStand = false
end)
end
if bv then
pcall(function()
bv:Destroy()
end)
bv = nil
end
if bg then
pcall(function()
bg:Destroy()
end)
bg = nil
end
end
RunService.Heartbeat:Connect(function()
if not Enabled.Fly then
if bv then
stopFly()
end
return
end
local ch, root, hum = localCharacter()
if not root or not hum then
stopFly()
return
end
if not bv or bv.Parent ~= root then
stopFly()
local ok, made = pcall(function()
local v = Instance.new("BodyVelocity")
v.Name = "HushFly"
v.MaxForce = Vector3.new(math.huge, math.huge, math.huge)
v.Velocity = Vector3.zero
v.Parent = root
return v
end)
bv = ok and made or nil
if not bv then
return
end
end
local speed = get("FlySpeed", 22)
local dir = Vector3.zero
local cam = workspace.CurrentCamera
if cam then
local look = cam.CFrame.LookVector
local right = cam.CFrame.RightVector
if UIS:IsKeyDown(Enum.KeyCode.W) then
dir = dir + look
end
if UIS:IsKeyDown(Enum.KeyCode.S) then
dir = dir - look
end
if UIS:IsKeyDown(Enum.KeyCode.D) then
dir = dir + right
end
if UIS:IsKeyDown(Enum.KeyCode.A) then
dir = dir - right
end
end
if UIS:IsKeyDown(Enum.KeyCode.Space) then
dir = dir + Vector3.new(0, 1, 0)
end
if UIS:IsKeyDown(Enum.KeyCode.LeftControl) then
dir = dir - Vector3.new(0, 1, 0)
end
if dir.Magnitude > 0 then
dir = dir.Unit * speed
end
bv.Velocity = dir
hum.PlatformStand = true
end)
end
do
RunService.Stepped:Connect(function()
if not Enabled.Noclip then
return
end
local ch = LocalPlayer.Character
if not ch then
return
end
for _, part in ipairs(ch:GetDescendants()) do
if part:IsA("BasePart") and part.CanCollide then
pcall(function()
part.CanCollide = false
end)
end
end
end)
end
local function clearFolder(path, label)
local node = workspace
for _, seg in ipairs(path) do
node = node and node:FindFirstChild(seg)
end
if not node then
notify(label .. " not found", 4)
return
end
local n = 0
for _, child in ipairs(node:GetChildren()) do
if child:IsA("BasePart") or child:IsA("Model") then
pcall(function()
child:Destroy()
end)
n = n + 1
end
end
notify(string.format("%s cleared (%d removed)", label, n), 4)
end
local camGroup = Tabs.Main:AddLeftGroupbox("Camera")
camGroup:AddToggle("NormalCam", {
Text = "Normal camera",
Default = false,
Callback = function(on)
Enabled.NormalCam = on
setCustom(on)
end,
})
camGroup:AddKeyPicker("NormalCamKey", {
Text = "Toggle",
Default = "Default",
Mode = "Toggle",
SyncToggleState = true,
})
camGroup:AddToggle("FaceMove", {
Text = "Face movement direction",
Default = false,
})
camGroup:AddKeyPicker("FaceMoveKey", { Text = "Face move", Default = "Default", Mode = "Toggle" })
camGroup:AddSlider("CamDist", {
Text = "Distance",
Default = 14,
Min = 4,
Max = 60,
Rounding = 1,
})
camGroup:AddSlider("CamSens", {
Text = "Sensitivity",
Default = 0.5,
Min = 0.1,
Max = 2,
Rounding = 2,
})
camGroup:AddSlider("FOV", {
Text = "Field of View",
Default = 70,
Min = 40,
Max = 120,
Rounding = 0,
})
local espGroup = Tabs.Main:AddRightGroupbox("Zombie ESP")
espGroup:AddToggle("EspEnabled", {
Text = "Enabled",
Default = false,
Callback = function(on)
Enabled.EspEnabled = on
end,
})
espGroup:AddKeyPicker("EspEnabledKey", { Text = "ESP", Default = "Default", Mode = "Toggle", SyncToggleState = true })
espGroup:AddToggle("EspName", { Text = "Names", Default = false })
espGroup:AddKeyPicker("EspNameKey", { Text = "Names", Default = "Default", Mode = "Toggle" })
espGroup:AddToggle("EspBox", { Text = "Boxes", Default = true })
espGroup:AddKeyPicker("EspBoxKey", { Text = "Boxes", Default = "Default", Mode = "Toggle" })
espGroup:AddColorPicker("ESPColor", {
Title = "ESP color",
Default = Color3.fromRGB(255, 80, 80),
})
espGroup:AddToggle("EspGlow", { Text = "Glow (Highlight)", Default = false })
espGroup:AddKeyPicker("EspGlowKey", { Text = "Glow", Default = "Default", Mode = "Toggle" })
espGroup:AddColorPicker("GlowColor", {
Title = "Glow color",
Default = Color3.fromRGB(255, 80, 80),
})
espGroup:AddSlider("EspMaxDist", {
Text = "Max distance (0 = inf)",
Default = 3000,
Min = 0,
Max = 5000,
Rounding = 0,
})
local lootGroup = Tabs.Main:AddRightGroupbox("Lootable ESP")
lootGroup:AddToggle("LootEnabled", {
Text = "Enabled",
Default = false,
Callback = function(on)
Enabled.LootEnabled = on
end,
})
lootGroup:AddKeyPicker("LootEnabledKey", { Text = "Loot", Default = "Default", Mode = "Toggle", SyncToggleState = true })
lootGroup:AddColorPicker("LootColor", { Title = "Loot color", Default = Color3.fromRGB(200, 200, 60) })
lootGroup:AddToggle("LootDist", { Text = "Show distance", Default = false })
lootGroup:AddKeyPicker("LootDistKey", { Text = "Distance", Default = "Default", Mode = "Toggle" })
lootGroup:AddSlider("LootTextSize", { Text = "Text size", Default = 24, Min = 10, Max = 24, Rounding = 0 })
lootGroup:AddSlider("LootMaxDist", { Text = "Max distance", Default = 150, Min = 150, Max = 2000, Rounding = 0 })
local plrGroup = Tabs.Main:AddRightGroupbox("Player ESP")
plrGroup:AddToggle("PlrEnabled", {
Text = "Enabled",
Default = false,
Callback = function(on)
Enabled.PlrEnabled = on
end,
})
plrGroup:AddKeyPicker("PlrEnabledKey", { Text = "Players", Default = "Default", Mode = "Toggle", SyncToggleState = true })
plrGroup:AddToggle("PlrName", { Text = "Names", Default = true })
plrGroup:AddKeyPicker("PlrNameKey", { Text = "Names", Default = "Default", Mode = "Toggle" })
plrGroup:AddToggle("PlrBox", { Text = "Boxes", Default = true })
plrGroup:AddKeyPicker("PlrBoxKey", { Text = "Boxes", Default = "Default", Mode = "Toggle" })
plrGroup:AddColorPicker("PlrColor", { Title = "Player color", Default = Color3.fromRGB(90, 170, 255) })
plrGroup:AddToggle("PlrHealth", { Text = "Health bar", Default = false })
plrGroup:AddKeyPicker("PlrHealthKey", { Text = "Health", Default = "Default", Mode = "Toggle" })
plrGroup:AddToggle("PlrGlow", { Text = "Glow (Highlight)", Default = false })
plrGroup:AddKeyPicker("PlrGlowKey", { Text = "Glow", Default = "Default", Mode = "Toggle" })
plrGroup:AddColorPicker("PlrGlowColor", { Title = "Glow color", Default = Color3.fromRGB(90, 170, 255) })
plrGroup:AddSlider("PlrMaxDist", { Text = "Max distance (0 = inf)", Default = 3000, Min = 0, Max = 5000, Rounding = 0 })
local meleeGroup = Tabs.Player:AddLeftGroupbox("Melee")
meleeGroup:AddToggle("MeleeAura", {
Text = "Kill Aura",
Default = false,
Callback = function(on)
Enabled.MeleeAura = on
end,
})
meleeGroup:AddKeyPicker("MeleeAuraKey", { Text = "Kill Aura", Default = "Default", Mode = "Toggle", SyncToggleState = true })
meleeGroup:AddSlider("MeleeRange", { Text = "Melee range (studs)", Default = 16, Min = 4, Max = 40, Rounding = 0 })
meleeGroup:AddSlider("MeleeRate", { Text = "Swing interval (s)", Default = 0.5, Min = 0.3, Max = 1, Rounding = 2 })
local gunGroup = Tabs.Player:AddLeftGroupbox("Gun")
gunGroup:AddToggle("SilentAim", {
Text = "Silent Aim",
Default = false,
Callback = function(on)
Enabled.SilentAim = on
end,
})
gunGroup:AddKeyPicker("SilentAimKey", { Text = "Silent Aim", Default = "Default", Mode = "Toggle", SyncToggleState = true })
gunGroup:AddSlider("GunRange", { Text = "Aim range (studs)", Default = 500, Min = 50, Max = 2000, Rounding = 0 })
gunGroup:AddToggle("ShowFov", { Text = "Show FOV circle", Default = false })
gunGroup:AddKeyPicker("ShowFovKey", { Text = "FOV circle", Default = "Default", Mode = "Toggle" })
gunGroup:AddColorPicker("FovColor", { Title = "FOV color", Default = Color3.fromRGB(255, 255, 255) })
gunGroup:AddSlider("FovSize", { Text = "FOV radius (px)", Default = 30, Min = 10, Max = 300, Rounding = 0 })
local mvGroup = Tabs.Player:AddRightGroupbox("Movement")
mvGroup:AddToggle("Fly", {
Text = "Fly (WASD + Space/Ctrl)",
Default = false,
Callback = function(on)
Enabled.Fly = on
end,
})
mvGroup:AddKeyPicker("FlyKey", { Text = "Fly", Default = "Default", Mode = "Toggle", SyncToggleState = true })
mvGroup:AddSlider("FlySpeed", { Text = "Fly speed (keep low to avoid rollback)", Default = 22, Min = 8, Max = 120, Rounding = 0 })
mvGroup:AddToggle("Noclip", {
Text = "Noclip",
Default = false,
Callback = function(on)
Enabled.Noclip = on
end,
})
mvGroup:AddKeyPicker("NoclipKey", { Text = "Noclip", Default = "Default", Mode = "Toggle", SyncToggleState = true })
Tabs.World:AddLeftGroupbox("Map"):AddButton({
Text = "Remove Rain",
Func = function()
clearFolder({ "Raid", "Map", "Rain" }, "Rain")
end,
})
Tabs.World:AddLeftGroupbox("Map"):AddButton({
Text = "Remove Props",
Func = function()
clearFolder({ "Raid", "Map", "Props" }, "Props")
end,
})
Tabs.World:AddLeftGroupbox("Map"):AddButton({
Text = "Remove Nature",
Func = function()
clearFolder({ "Raid", "Map", "Nature" }, "Nature")
end,
})
local setGroup = Tabs.Settings:AddLeftGroupbox("Menu")
setGroup:AddLabel("Menu toggle")
setGroup:AddKeyPicker("MenuKey", { Text = "Menu", Default = "RightShift", Mode = "Toggle", SyncToggleState = true })
setGroup:AddButton({
Text = "Unload",
Func = function()
Enabled.SilentAim, Enabled.MeleeAura, Enabled.Fly, Enabled.Noclip = false, false, false, false
Enabled.EspEnabled, Enabled.LootEnabled, Enabled.PlrEnabled = false, false, false
for _, e in pairs(espZombie) do
hide(e)
end
for _, e in pairs(espLoot) do
hide(e)
end
for _, e in pairs(espPlayer) do
hide(e)
end
for model, g in pairs(ESP.glows) do
if g and g ~= false then
pcall(function()
g:Destroy()
end)
end
ESP.glows[model] = nil
end
if fovCircle then
pcall(function()
fovCircle.Visible = false
end)
end
pcall(function()
Library:Unload()
end)
notify("Unloaded", 3)
end,
})
notify("Hush loaded — Main / Player / Visuals / World / Settings", 6)
