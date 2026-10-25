local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local UIS = game:GetService("UserInputService")
local RS = game:GetService("ReplicatedStorage")
local WS = game:GetService("Workspace")
local TS = game:GetService("TweenService")
local TeleportService = game:GetService("TeleportService")
local HttpService = game:GetService("HttpService")
local LocalPlayer = Players.LocalPlayer
local Library = loadstring(game:HttpGet("https://raw.githubusercontent.com/deividcomsono/Obsidian/main/Library.lua"))()
local Options = Library.Options
local WIN = Library:CreateWindow({
Title = "Army Commander",
Footer = "reicht build",
Size = UDim2.fromOffset(660, 540),
Center = true,
AutoShow = true,
ShowCustomCursor = true,
})
local Tabs = {
Farm = WIN:AddTab({ Title = "Farm", Icon = "zap" }),
Army = WIN:AddTab({ Title = "Army", Icon = "flag" }),
Combat = WIN:AddTab({ Title = "Combat", Icon = "crosshair" }),
Visuals = WIN:AddTab({ Title = "Visuals", Icon = "eye" }),
Player = WIN:AddTab({ Title = "Player", Icon = "user" }),
Misc = WIN:AddTab({ Title = "Misc", Icon = "settings" }),
Settings = WIN:AddTab({ Title = "Settings", Icon = "sliders" }),
}
local function notify(text, duration)
pcall(function()
WIN:Notify({ Title = "Army Commander", Description = text, Duration = duration or 4 })
end)
end
local function get(id, fallback)
local opt = Options[id]
if not opt then return fallback end
local v = opt.Value
if v == nil then return fallback end
return v
end
local function num(id, fallback)
local v = tonumber(get(id, fallback))
if v == nil then return fallback end
return v
end
local function character()
local c = LocalPlayer and LocalPlayer.Character
if c and c.Parent then return c end
local ok, c2 = pcall(function() return LocalPlayer.Character end)
if ok then return c2 end
return nil
end
local function humanoid()
local c = character()
if not c then return nil end
local h = c:FindFirstChildOfClass("Humanoid")
return h
end
local function root()
local c = character()
if not c then return nil end
return c:FindFirstChild("HumanoidRootPart") or c.PrimaryPart
end
local function alive()
local h = humanoid()
if not h then return false end
return h.Health > 0
end
local function cam()
local c = WS.CurrentCamera
if c and c.Parent then return c end
local ok, c2 = pcall(function() return WS.CurrentCamera end)
if ok then return c2 end
return nil
end
local function vecXYZ(v)
if not v then return nil end
local ok, x, y, z = pcall(function() return v.X, v.Y, v.Z end)
if ok and type(x) == "number" and type(y) == "number" and type(z) == "number" then
return x, y, z
end
return nil
end
local function distance(a, b)
if not (a and b) then return math.huge end
local okA, ap = pcall(function() return a.Position end)
local okB, bp = pcall(function() return b.Position end)
if not (okA and okB) then return math.huge end
local x1, y1, z1 = vecXYZ(ap)
if not x1 then return math.huge end
local x2, y2, z2 = vecXYZ(bp)
if not x2 then return math.huge end
local dx, dy, dz = x1 - x2, y1 - y2, z1 - z2
return math.sqrt(dx * dx + dy * dy + dz * dz)
end
local function say(text)
pcall(function()
Library:Notify({ Title = "Army Commander", Description = tostring(text), Duration = 5 })
end)
warn("[ACT] " .. tostring(text))
end
local function copy(text)
pcall(function() setclipboard(tostring(text)) end)
end
local function firePrompt(prompt)
if not prompt then return false end
if type(fireproximityprompt) == "function" then
local ok = pcall(fireproximityprompt, prompt)
if ok then return true end
end
local ok2 = pcall(function()
if prompt.HoldDuration and prompt.HoldDuration > 0 then
prompt:InputHoldBegin()
prompt:InputHoldEnd()
else
prompt:InputHoldBegin()
prompt:InputHoldEnd()
end
end)
return ok2
end
local function fireClick(detector)
if not detector then return false end
if type(fireclickdetector) == "function" then
return pcall(fireclickdetector, detector)
end
local ok = pcall(function() detector:FireClick() end)
return ok
end
local Scan = {
stamp = 0,
prompts = {},
clicks = {},
cash = {},
points = {},
remotes = {},
units = {},
}
local CASH_WORDS = { "cash", "money", "coin", "income", "payout", "reward", "pumpkin" }
local POINT_WORDS = { "point", "capture", "flag", "zone", "objective", "base", "airfield", "outpost" }
local UNIT_WORDS = { "unit", "soldier", "troop", "enemy", "army", "squad", "vehicle", "tank", "jet", "heli", "turret" }
local function containsAny(text, words)
if type(text) ~= "string" then return false end
local low = string.lower(text)
for _, w in ipairs(words) do
if string.find(low, w, 1, true) then return true end
end
return false
end
local function promptLabel(prompt)
local parts = {}
local ok, a = pcall(function() return prompt.ActionText end)
if ok and type(a) == "string" then table.insert(parts, a) end
local ok2, o = pcall(function() return prompt.ObjectText end)
if ok2 and type(o) == "string" then table.insert(parts, o) end
local ok3, p = pcall(function() return prompt.Parent and prompt.Parent.Name end)
if ok3 and type(p) == "string" then table.insert(parts, p) end
return table.concat(parts, " "), (ok and a or ""), (ok2 and o or "")
end
local function refreshScan()
Scan.prompts, Scan.clicks, Scan.cash, Scan.points, Scan.remotes, Scan.units = {}, {}, {}, {}, {}, {}
local okAll, descendants = pcall(function() return WS:GetDescendants() end)
if okAll and type(descendants) == "table" then
for _, obj in ipairs(descendants) do
local cls = obj.ClassName
if cls == "ProximityPrompt" then
local label, action, object = promptLabel(obj)
table.insert(Scan.prompts, { prompt = obj, label = label, action = action, object = object })
elseif cls == "ClickDetector" then
table.insert(Scan.clicks, { detector = obj, label = obj.Parent and obj.Parent.Name or "ClickDetector" })
elseif cls == "Part" or cls == "MeshPart" or cls == "UnionOperation" then
local name = obj.Name
local isCash = containsAny(name, CASH_WORDS)
if isCash then
local billboard = obj:FindFirstChildWhichIsA("BillboardGui", true)
if billboard ~= nil or true then
table.insert(Scan.cash, { part = obj, name = name })
end
end
if containsAny(name, UNIT_WORDS) then
table.insert(Scan.units, obj)
end
elseif cls == "Model" or cls == "Folder" then
if containsAny(obj.Name, POINT_WORDS) then
local p = obj:FindFirstChild("Flag") or obj.PrimaryPart
if p then table.insert(Scan.points, { model = obj, name = obj.Name, part = p }) end
end
end
end
end
local okRS, rsRoot = pcall(function() return RS end)
if okRS and rsRoot then
local okDesc, rsDesc = pcall(function() return rsRoot:GetDescendants() end)
if okDesc and type(rsDesc) == "table" then
for _, obj in ipairs(rsDesc) do
local cls = obj.ClassName
if cls == "RemoteEvent" or cls == "RemoteFunction" or cls == "UnreliableRemoteEvent" then
table.insert(Scan.remotes, { remote = obj, name = obj.Name, cls = cls })
end
end
else
local okChild, kids = pcall(function() return rsRoot:GetChildren() end)
if okChild and type(kids) == "table" then
for _, obj in ipairs(kids) do
if obj.ClassName == "RemoteEvent" or obj.ClassName == "RemoteFunction" then
table.insert(Scan.remotes, { remote = obj, name = obj.Name, cls = obj.ClassName })
end
end
end
end
end
Scan.stamp = os.clock()
end
local function ensureScan(force)
if force or os.clock() - (Scan.stamp or 0) > 2 then
pcall(refreshScan)
end
return Scan
end
local Farm = {
lastPrompt = 0,
lastClick = 0,
cool = setmetatable({}, {__mode = "k"}),
}
local function cooledDown(prompt, seconds)
local last = Farm.cool[prompt]
local now = os.clock()
if last and now - last < seconds then return false end
Farm.cool[prompt] = now
return true
end
local function filterAllows(label, action, object, mode)
if mode == "All" or mode == nil then return true end
local blurbs = string.lower(label or "") .. "|" .. string.lower(action or "") .. "|" .. string.lower(object or "")
local map = {
Build = { "build", "construct", "place" },
Buy = { "buy", "purchase", "unlock", "unit", "hire", "upgrade" },
Oil = { "oil", "pump", "fuel", "drill" },
Crate = { "crate", "daily", "claim", "reward" },
Capture = { "capture", "claim", "point", "flag", "objective" },
Promote = { "promote", "rebirth", "rank" },
}
local words = map[mode]
if not words then return true end
for _, w in ipairs(words) do
if string.find(blurbs, w, 1, true) then return true end
end
return false
end
local function runPrompts()
if not get("AutoPrompt", false) then return end
local delay = math.max(num("PromptDelay", 0.35), 0.1)
local now = os.clock()
if now - Farm.lastPrompt < delay then return end
local hrp = root()
if not hrp then return end
local range = num("PromptRange", 250)
local mode = get("PromptMode", "All")
local fired = 0
local scan = ensureScan(false)
for _, entry in ipairs(scan.prompts) do
local prompt = entry.prompt
if prompt and prompt.Parent then
local enabled = true
pcall(function() enabled = prompt.Enabled end)
if enabled and filterAllows(entry.label, entry.action, entry.object, mode) then
local parentPart = prompt.Parent
local dist = distance(hrp, parentPart)
if dist <= range and cooledDown(prompt, num("PromptCooldown", 3)) then
firePrompt(prompt)
fired = fired + 1
if fired >= 3 then break end
end
end
end
end
if fired > 0 then Farm.lastPrompt = now end
end
local function runClicks()
if not get("AutoClick", false) then return end
local delay = math.max(num("ClickDelay", 0.5), 0.1)
local now = os.clock()
if now - Farm.lastClick < delay then return end
local hrp = root()
if not hrp then return end
local range = num("PromptRange", 250)
local fired = 0
local scan = ensureScan(false)
for _, entry in ipairs(scan.clicks) do
local det = entry.detector
if det and det.Parent then
local dist = distance(hrp, det.Parent)
if dist <= range then
fireClick(det)
fired = fired + 1
if fired >= 2 then break end
end
end
end
if fired > 0 then Farm.lastClick = now end
end
local touchBusy = false
local function runCash()
if not get("AutoCash", false) then return end
if touchBusy then return end
if type(firetouchinterest) ~= "function" then return end
local hrp = root()
if not hrp then return end
local range = num("CashRange", 120)
local scan = ensureScan(false)
for _, entry in ipairs(scan.cash) do
local part = entry.part
if part and part.Parent and distance(hrp, part) <= range then
touchBusy = true
pcall(firetouchinterest, hrp, part, 0)
pcall(firetouchinterest, hrp, part, 1)
touchBusy = false
break
end
end
end
local function runArmy()
if not get("AutoCapture", false) then return end
local delay = math.max(num("CaptureDelay", 1), 0.2)
local scan = ensureScan(false)
local hrp = root()
if not hrp then return end
local now = os.clock()
if now - (Farm.lastCapture or 0) < delay then return end
for _, entry in ipairs(scan.points) do
local part = entry.part
if part and part.Parent then
for _, p in ipairs(scan.prompts) do
local prompt = p.prompt
if prompt and prompt.Parent then
local host = prompt.Parent
local rootModel = part.Parent or part
local okIn, inside = pcall(function()
if host == part then return true end
return host:IsDescendantOf(rootModel)
end)
if okIn and inside then
if filterAllows(p.label, p.action, p.object, "Capture") or filterAllows(entry.name, entry.name, "", "Capture") then
firePrompt(prompt)
Farm.lastCapture = now
return
end
end
end
end
end
end
end
local function enemiesInRange(range)
local out = {}
local hrp = root()
if not hrp then return out end
local scan = ensureScan(false)
for _, part in ipairs(scan.units) do
if part and part.Parent then
local d = distance(hrp, part)
if d <= range then
table.insert(out, { part = part, dist = d })
end
end
end
table.sort(out, function(a, b) return a.dist < b.dist end)
return out
end
local function runCombat()
if not get("AutoFire", false) then return end
local h = humanoid()
if not h then return end
local range = num("CombatRange", 180)
local targets = enemiesInRange(range)
if #targets == 0 then return end
local target = targets[1]
local targetPart = target.part
local tool = nil
local c = character()
if c then tool = c:FindFirstChildOfClass("Tool") end
if not tool then return end
if get("FaceTarget", true) and targetPart then
local hrp = root()
if hrp and targetPart.Position then
pcall(function()
local look = CFrame.lookAt(hrp.Position, Vector3.new(targetPart.Position.X, hrp.Position.Y, targetPart.Position.Z))
hrp.CFrame = look
end)
end
end
pcall(function()
if tool.Activated and typeof(tool.Activated) == "RBXScriptSignal" then
tool:Activate()
end
end)
if get("Aura", false) then
for i = 2, math.min(#targets, num("AuraCount", 5)) do
pcall(function() tool:Activate() end)
end
end
end
local PlayerState = {
flyConn = nil,
noclipConn = nil,
origSpeed = 16,
origJump = 50,
}
local function applySpeed()
local h = humanoid()
if not h then return end
if get("SpeedEnabled", false) then
pcall(function() h.WalkSpeed = num("WalkSpeed", 16) end)
else
pcall(function() h.WalkSpeed = PlayerState.origSpeed or 16 end)
end
end
local function applyJump()
local h = humanoid()
if not h then return end
if get("JumpEnabled", false) then
pcall(function() h.JumpPower = num("JumpPower", 50) end)
else
pcall(function() h.JumpPower = PlayerState.origJump or 50 end)
end
end
local function stopFly()
if PlayerState.flyConn then
pcall(function() PlayerState.flyConn:Disconnect() end)
PlayerState.flyConn = nil
end
local h = humanoid()
if h then pcall(function() h.PlatformStand = false end) end
end
local function startFly()
stopFly()
local speed = num("FlySpeed", 60)
PlayerState.flyConn = RunService.RenderStepped:Connect(function()
if not get("Fly", false) then stopFly() return end
local hrp = root()
local c = cam()
if not (hrp and c) then return end
local dir = Vector3.new(0, 0, 0)
if UIS:IsKeyDown(Enum.KeyCode.W) then dir = dir + c.CFrame.LookVector end
if UIS:IsKeyDown(Enum.KeyCode.S) then dir = dir - c.CFrame.LookVector end
if UIS:IsKeyDown(Enum.KeyCode.A) then dir = dir - c.CFrame.RightVector end
if UIS:IsKeyDown(Enum.KeyCode.D) then dir = dir + c.CFrame.RightVector end
if UIS:IsKeyDown(Enum.KeyCode.Space) then dir = dir + Vector3.new(0, 1, 0) end
if UIS:IsKeyDown(Enum.KeyCode.LeftControl) then dir = dir - Vector3.new(0, 1, 0) end
if dir.Magnitude > 0 then
dir = dir.Unit
hrp.CFrame = hrp.CFrame + dir * (speed * (1 / 60))
end
end)
local h = humanoid()
if h then pcall(function() h.PlatformStand = true end) end
end
local function startNoclip()
if PlayerState.noclipConn then return end
PlayerState.noclipConn = RunService.Stepped:Connect(function()
if not get("Noclip", false) then return end
local c = character()
if not c then return end
local ok, parts = pcall(function() return c:GetDescendants() end)
if not ok or type(parts) ~= "table" then return end
for _, p in ipairs(parts) do
if p:IsA("BasePart") and p.CanCollide then
pcall(function() p.CanCollide = false end)
end
end
end)
end
local function runInfJump()
if not get("InfJump", false) then return end
local h = humanoid()
if not h then return end
if UIS:IsKeyDown(Enum.KeyCode.Space) then
pcall(function()
local st = h:GetState()
if st == Enum.HumanoidStateType.Freefall or st == Enum.HumanoidStateType.FallingDown then
h:ChangeState(Enum.HumanoidStateType.Jumping)
end
end)
end
end
local function startAntiAfk()
if PlayerState.antiAfk then return end
PlayerState.antiAfk = true
local vu = nil
pcall(function() vu = game:GetService("VirtualUser") end)
local idle = LocalPlayer and LocalPlayer.Idled
if idle and idle.Connect then
pcall(function()
PlayerState.idleConn = idle:Connect(function()
if not get("AntiAfk", true) then return end
if vu then
pcall(function() vu:CaptureController() end)
pcall(function() vu:ClickButton2(Vector2.new()) end)
end
end)
end)
end
end
local Draw = {objects = {}}
local function newDrawing(cls)
local ok, obj = pcall(function() return Drawing.new(cls) end)
if not ok then return nil end
return obj
end
local function releaseDrawings()
for _, obj in pairs(Draw.objects) do
pcall(function() obj:Remove() end)
end
Draw.objects = {}
end
local function ensurePlayerEsp()
local wanted = get("PlayerEsp", false)
if not wanted then
for _, key in ipairs({ "psquare", "pname" }) do
local o = Draw.objects[key]
if o then pcall(function() o.Visible = false end) end
end
return
end
if not Draw.objects.psquare then
local box = newDrawing("Square")
local label = newDrawing("Text")
if not (box and label) then return end
pcall(function()
box.Thickness = 1
box.Color = Color3.fromRGB(120, 200, 255)
box.Filled = false
label.Size = 14
label.Color = Color3.fromRGB(255, 255, 255)
label.Center = true
label.Outline = true
end)
Draw.objects.psquare = box
Draw.objects.pname = label
end
local c = cam()
if not c then return end
local box = Draw.objects.psquare
local label = Draw.objects.pname
local okPlayers, players = pcall(function() return Players:GetPlayers() end)
if not okPlayers or type(players) ~= "table" then return end
local shown = 0
for _, plr in ipairs(players) do
if plr ~= LocalPlayer then
local char = plr.Character
local hrp = char and (char:FindFirstChild("HumanoidRootPart") or char.PrimaryPart)
if hrp then
local pos, visible = c:WorldToViewportPoint(hrp.Position)
if visible and shown < 12 then
shown = shown + 1
if shown == 1 then
pcall(function()
box.Visible = true
box.Size = Vector2.new(40, 60)
box.Position = Vector2.new(pos.X - 20, pos.Y - 30)
label.Visible = true
label.Position = Vector2.new(pos.X, pos.Y + 34)
label.Text = plr.Name
end)
end
end
end
end
end
if shown == 0 then
pcall(function() box.Visible = false; label.Visible = false end)
end
end
local function ensurePromptEsp()
if not get("PromptEsp", false) then
if Draw.objects.promptPool then
for _, obj in ipairs(Draw.objects.promptPool) do pcall(function() obj.Visible = false end) end
end
return
end
local c = cam()
if not c then return end
local scan = ensureScan(false)
Draw.objects.promptPool = Draw.objects.promptPool or {}
local pool = Draw.objects.promptPool
local used = 0
for _, entry in ipairs(scan.prompts) do
local prompt = entry.prompt
local parent = prompt and prompt.Parent
if parent and parent.Position then
local pos, visible = c:WorldToViewportPoint(parent.Position)
if visible and used < 40 then
used = used + 1
local obj = pool[used]
if not obj then
obj = newDrawing("Text")
if not obj then break end
pcall(function()
obj.Size = 13
obj.Center = true
obj.Outline = true
obj.Color = Color3.fromRGB(255, 220, 120)
end)
pool[used] = obj
end
pcall(function()
obj.Visible = true
obj.Position = Vector2.new(pos.X, pos.Y)
obj.Text = entry.action ~= "" and entry.action or entry.label
end)
end
end
end
for i = used + 1, #pool do pcall(function() pool[i].Visible = false end) end
end
local function ensureFullbright()
if not get("Fullbright", false) then return end
pcall(function()
local lighting = game:GetService("Lighting")
lighting.Brightness = 2
lighting.ClockTime = 14
lighting.FogEnd = 100000
lighting.GlobalShadows = false
lighting.OutdoorAmbient = Color3.fromRGB(160, 160, 160)
end)
end
local function ensureFog()
if not get("NoFog", false) then return end
pcall(function()
local lighting = game:GetService("Lighting")
lighting.FogEnd = 100000
lighting.FogStart = 0
end)
end
local function teleportTo(part)
if not part then return end
local hrp = root()
if not hrp then return end
pcall(function()
local target = part.Position + Vector3.new(0, 4, 0)
hrp.CFrame = CFrame.new(target)
end)
end
local function buildTeleportGroup()
local group = Tabs.Army:AddLeftGroupbox("Teleport")
group:AddButton({
Text = "Refresh points",
Func = function()
ensureScan(true)
notify(string.format("%d points, %d prompts, %d remotes", #Scan.points, #Scan.prompts, #Scan.remotes))
end,
})
group:AddButton({
Text = "Nearest capture point",
Func = function()
ensureScan(false)
local hrp = root()
if not hrp then return end
local best, bestD = nil, math.huge
for _, entry in ipairs(Scan.points) do
local d = distance(hrp, entry.part)
if d < bestD then best, bestD = entry, d end
end
if best then teleportTo(best.part); notify("Moved to " .. best.name) else notify("No capture point found") end
end,
})
group:AddButton({
Text = "Base",
Func = function()
ensureScan(false)
local hrp = root()
if not hrp then return end
for _, entry in ipairs(Scan.points) do
if string.find(string.lower(entry.name), "base", 1, true) then
teleportTo(entry.part)
notify("Moved to " .. entry.name)
return
end
end
notify("No base model found")
end,
})
end
local function dumpRemotes()
ensureScan(true)
local lines = {}
for _, entry in ipairs(Scan.remotes) do
table.insert(lines, entry.cls .. " " .. entry.name)
end
if #lines == 0 then
notify("No remotes found in ReplicatedStorage")
return
end
local text = table.concat(lines, "\n")
copy(text)
notify(string.format("%d remotes copied to clipboard", #lines))
end
local function fireRemoteByName()
local wanted = tostring(get("RemoteName", ""))
if wanted == "" then
notify("Type a remote name first")
return
end
ensureScan(false)
for _, entry in ipairs(Scan.remotes) do
if entry.name == wanted then
local ok = pcall(function()
if entry.cls == "RemoteFunction" then
entry.remote:InvokeServer()
else
entry.remote:FireServer()
end
end)
notify(ok and ("Fired " .. wanted) or ("Failed " .. wanted))
return
end
end
notify("Remote not found: " .. wanted)
end
Tabs.Farm:AddLeftGroupbox("Prompts")
Tabs.Farm:AddToggle("AutoPrompt", { Text = "Auto trigger prompts", Default = false, Callback = function(v)
if v then ensureScan(true) end
end })
Tabs.Farm:AddDropdown("PromptMode", { Text = "Prompt filter", Values = { "All", "Build", "Buy", "Oil", "Crate", "Capture", "Promote" }, Default = "All", Multi = false })
Tabs.Farm:AddSlider("PromptDelay", { Text = "Trigger delay", Default = 0.35, Min = 0.1, Max = 3, Rounding = 2 })
Tabs.Farm:AddSlider("PromptRange", { Text = "Range (studs)", Default = 250, Min = 5, Max = 2000, Rounding = 0 })
Tabs.Farm:AddSlider("PromptCooldown", { Text = "Per prompt cooldown", Default = 3, Min = 0.5, Max = 30, Rounding = 1 })
Tabs.Farm:AddRightGroupbox("Cash and clicks")
Tabs.Farm:AddToggle("AutoClick", { Text = "Auto click detectors", Default = false })
Tabs.Farm:AddSlider("ClickDelay", { Text = "Click delay", Default = 0.5, Min = 0.1, Max = 5, Rounding = 2 })
Tabs.Farm:AddToggle("AutoCash", { Text = "Auto touch cash parts", Default = false })
Tabs.Farm:AddSlider("CashRange", { Text = "Cash range", Default = 120, Min = 5, Max = 800, Rounding = 0 })
Tabs.Army:AddLeftGroupbox("Orders")
Tabs.Army:AddToggle("AutoCapture", { Text = "Auto capture points", Default = false })
Tabs.Army:AddSlider("CaptureDelay", { Text = "Capture delay", Default = 1, Min = 0.2, Max = 10, Rounding = 2 })
Tabs.Army:AddToggle("KeepArmy", { Text = "Keep army on auto", Default = false })
buildTeleportGroup()
Tabs.Combat:AddLeftGroupbox("Combat")
Tabs.Combat:AddToggle("AutoFire", { Text = "Auto activate tool", Default = false })
Tabs.Combat:AddToggle("Aura", { Text = "Multi activate (aura)", Default = false })
Tabs.Combat:AddSlider("AuraCount", { Text = "Aura targets", Default = 5, Min = 2, Max = 20, Rounding = 0 })
Tabs.Combat:AddSlider("CombatRange", { Text = "Combat range", Default = 180, Min = 10, Max = 1000, Rounding = 0 })
Tabs.Combat:AddToggle("FaceTarget", { Text = "Face nearest target", Default = true })
Tabs.Visuals:AddLeftGroupbox("ESP")
Tabs.Visuals:AddToggle("PlayerEsp", { Text = "Player ESP", Default = false })
Tabs.Visuals:AddToggle("PromptEsp", { Text = "Prompt ESP (action text)", Default = false })
Tabs.Visuals:AddToggle("UnitEsp", { Text = "Unit count in notify", Default = false })
Tabs.Visuals:AddRightGroupbox("World")
Tabs.Visuals:AddToggle("Fullbright", { Text = "Fullbright", Default = false })
Tabs.Visuals:AddToggle("NoFog", { Text = "No fog", Default = false })
Tabs.Player:AddLeftGroupbox("Movement")
Tabs.Player:AddToggle("SpeedEnabled", { Text = "WalkSpeed", Default = false, Callback = applySpeed })
Tabs.Player:AddSlider("WalkSpeed", { Text = "Speed", Default = 16, Min = 8, Max = 200, Rounding = 0, Callback = applySpeed })
Tabs.Player:AddToggle("JumpEnabled", { Text = "JumpPower", Default = false, Callback = applyJump })
Tabs.Player:AddSlider("JumpPower", { Text = "Jump", Default = 50, Min = 50, Max = 400, Rounding = 0, Callback = applyJump })
Tabs.Player:AddToggle("InfJump", { Text = "Infinite jump", Default = false })
Tabs.Player:AddRightGroupbox("Fly and noclip")
Tabs.Player:AddToggle("Fly", { Text = "Fly", Default = false, Callback = function(v)
if v then startFly() else stopFly() end
end })
Tabs.Player:AddSlider("FlySpeed", { Text = "Fly speed", Default = 60, Min = 10, Max = 300, Rounding = 0 })
Tabs.Player:AddToggle("Noclip", { Text = "Noclip", Default = false, Callback = function(v)
if v then startNoclip() end
end })
Tabs.Player:AddToggle("AntiAfk", { Text = "Anti AFK", Default = true })
Tabs.Misc:AddLeftGroupbox("Session")
Tabs.Misc:AddButton({ Text = "Rejoin", Func = function()
pcall(function() TeleportService:Teleport(game.PlaceId, LocalPlayer) end)
end })
Tabs.Misc:AddButton({ Text = "Copy remote list", Func = dumpRemotes })
Tabs.Misc:AddInput("RemoteName", { Text = "Remote name", Default = "", Placeholder = "e.g. BuildRequest" })
Tabs.Misc:AddButton({ Text = "Fire named remote", Func = fireRemoteByName })
Tabs.Misc:AddRightGroupbox("Client")
Tabs.Misc:AddSlider("FpsCap", { Text = "FPS cap (0 = off)", Default = 0, Min = 0, Max = 240, Rounding = 0, Callback = function(v)
pcall(function()
if type(setfpscap) == "function" then
setfpscap(v)
end
end)
end })
Tabs.Misc:AddButton({ Text = "Low graphics", Func = function()
pcall(function()
local lighting = game:GetService("Lighting")
lighting.GlobalShadows = false
lighting.FogEnd = 500
end)
for _, obj in ipairs(WS:GetDescendants()) do
if obj:IsA("BasePart") and obj.Material ~= Enum.Material.SmoothPlastic then
pcall(function() obj.Material = Enum.Material.SmoothPlastic end)
end
end
notify("Graphics flattened")
end })
Tabs.Settings:AddLeftGroupbox("Build")
Tabs.Settings:AddButton({ Text = "Refresh scan", Func = function() ensureScan(true); notify("Rescanned world") end })
Tabs.Settings:AddButton({ Text = "Unload", Func = function()
releaseDrawings()
stopFly()
pcall(function() if PlayerState.noclipConn then PlayerState.noclipConn:Disconnect() end end)
pcall(function() if PlayerState.idleConn then PlayerState.idleConn:Disconnect() end end)
pcall(function() Library:Unload() end)
end })
local function step()
if not LocalPlayer then return end
pcall(runPrompts)
pcall(runClicks)
pcall(runCash)
pcall(runArmy)
pcall(runCombat)
pcall(runInfJump)
pcall(ensureFullbright)
pcall(ensureFog)
pcall(ensurePlayerEsp)
pcall(ensurePromptEsp)
if get("KeepArmy", false) then
pcall(function()
local scan = ensureScan(false)
for i = 1, math.min(#scan.prompts, 3) do
local entry = scan.prompts[i]
if entry and entry.prompt and entry.prompt.Parent and filterAllows(entry.label, entry.action, entry.object, "Buy") then
firePrompt(entry.prompt)
end
end
end)
end
end
startAntiAfk()
RunService.RenderStepped:Connect(step)
task.spawn(function()
while true do
pcall(refreshScan)
task.wait(3)
end
end)
notify("Army Commander loaded — Farm tab drives prompts, Misc tab lists remotes")
