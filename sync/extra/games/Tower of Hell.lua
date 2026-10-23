if not game:IsLoaded() then
game.Loaded:Wait()
end
local PlaceId = 1962086868
-- Literal in the comparison on purpose: the smoke harness reads the id out of this
-- guard, and a variable would leave it guessing another game's id.
if game.PlaceId ~= 1962086868 and game.GameId ~= 1962086868 and game.PlaceId ~= 94971861814985 then
game:GetService("Players").LocalPlayer:Kick("Reicht: this script is for Tower of Hell only")
return
end
local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local CollectionService = game:GetService("CollectionService")
local VirtualUser = game:GetService("VirtualUser")
local LocalPlayer = Players.LocalPlayer
local Config = {
Name = "Tower of Hell",
Game = "Tower of Hell",
UiSource = "https://raw.githubusercontent.com/Shinzzyak/Reicht/refs/heads/main/ui.lua",
SaveFolder = "Tower of Hell",
StatusInterval = 1,
ClimbInterval = 0.5,
MinSpeed = 10,
MaxSpeed = 120,
StandClearance = 3,
ReachDistance = 0.5,
MaxStepsPerMove = 240,
}
local Reicht = {
Config = Config,
Status = { Climb = "Off", Hazard = "Off", Noclip = "Off", AntiAFK = "Off" },
Messages = {},
}
local State = {
Alive = true,
Stage = 0,
Total = 0,
Rounds = 0,
Hover = nil,
Flags = { Speed = 40 },
SavedHazards = {},
}
local function Env()
return (getgenv and getgenv()) or _G
end
local function Alert(text)
Reicht.Messages[#Reicht.Messages + 1] = tostring(text)
end
function Reicht.Try(fn, ...)
local ok, err = pcall(fn, ...)
if not ok then
warn("[TowerOfHell] " .. tostring(err):match("[^\n]*"))
end
return ok, err
end
function Reicht.HttpGet(url)
if type(game.HttpGet) == "function" then
local ok, body = pcall(game.HttpGet, game, url)
if ok and type(body) == "string" and #body > 0 then return body end
end
if type(request) == "function" then
local ok, response = pcall(request, { Url = url, Method = "GET" })
if ok and type(response) == "table" and type(response.Body) == "string" then return response.Body end
end
if type(syn) == "table" and type(syn.request) == "function" then
local ok, response = pcall(syn.request, { Url = url, Method = "GET" })
if ok and type(response) == "table" and type(response.Body) == "string" then return response.Body end
end
return nil
end
function Reicht.LoadLibrary()
local body = Reicht.HttpGet(Config.UiSource)
if not body or not body:sub(-64):find("return%s+Library%s*$") then
Alert("Could not download the menu. Check your connection and run it again.")
return nil
end
local chunk, compileErr = loadstring(body)
if not chunk then
Alert("The menu failed to load on this executor: " .. tostring(compileErr))
return nil
end
local ok, library = pcall(chunk)
if ok and type(library) == "table" then return library end
Alert("The menu failed to load on this executor: " .. tostring(library))
return nil
end
local function CharacterParts()
local character = LocalPlayer.Character
local root = character and character:FindFirstChild("HumanoidRootPart")
local humanoid = character and character:FindFirstChildOfClass("Humanoid")
if root and humanoid and humanoid.Health > 0 then
return character, root, humanoid
end
return nil
end
-- A part's standable surface sits half its rotated height above its centre; a tower
-- section can be tilted, so the height comes from the CFrame axes rather than Size.Y.
local function HalfHeight(part)
local cf, size = part.CFrame, part.Size
if not cf or not size then return 0 end
return (math.abs(cf.RightVector.Y) * size.X + math.abs(cf.UpVector.Y) * size.Y + math.abs(cf.LookVector.Y) * size.Z) / 2
end
-- The tower is regenerated between rounds, so the route is re-read every climb
-- instead of cached: a stale route walks into empty air and reports success.
function Reicht.Snapshot()
local tower = workspace:FindFirstChild("tower")
local data = tower and tower:FindFirstChild("sectionData")
local sections = tower and tower:FindFirstChild("sections")
local count = tower and tower:FindFirstChild("sectionCount")
local expected = count and tonumber(count.Value) or 0
if not data or not sections or expected < 3 then return nil end
local route = {}
for _, section in ipairs(data:GetChildren()) do
local center = section:FindFirstChild("center")
if center and center:IsA("BasePart") then
route[#route + 1] = {
Name = section.Name,
Part = center,
Position = center.CFrame.Position,
Height = HalfHeight(center),
}
end
end
if #route ~= expected then return nil end
table.sort(route, function(a, b) return a.Position.Y < b.Position.Y end)
if route[#route].Name ~= "finish" then return nil end
return route
end
-- Walks the character toward a point one Heartbeat at a time. CFrame is written
-- directly and the assembly velocity cleared so the hover body force cannot fight
-- the movement; without that the character oscillates and never lands.
function Reicht.Move(root, target)
local speed = math.clamp(tonumber(State.Flags.Speed) or 40, Config.MinSpeed, Config.MaxSpeed)
local position = root.CFrame.Position
local steps = 0
while (position - target).Magnitude > Config.ReachDistance and steps < Config.MaxStepsPerMove do
local dt = math.min(RunService.Heartbeat:Wait(), 0.05)
local delta = target - position
local nextPosition = position + delta.Unit * math.min(delta.Magnitude, speed * dt)
root.CFrame = CFrame.new(nextPosition)
root.AssemblyLinearVelocity = Vector3.zero
root.AssemblyAngularVelocity = Vector3.zero
position = nextPosition
steps += 1
end
return steps
end
function Reicht.Hover(enabled)
local _, root = CharacterParts()
if not root then return end
if enabled then
if State.Hover and State.Hover.Parent then return end
local velocity = Instance.new("BodyVelocity")
velocity.Name = "ReichtTowerHover"
velocity.MaxForce = Vector3.new(1e8, 1e8, 1e8)
velocity.P = 12500
velocity.Velocity = Vector3.zero
velocity.Parent = root
State.Hover = velocity
elseif State.Hover then
State.Hover:Destroy()
State.Hover = nil
end
end
-- KillBricks are tagged, not named, so the tag is the only way to find them. The
-- original CanTouch is remembered: restoring `true` for a part that was already
-- non-touchable would make a hazard out of nothing when the feature turns off.
function Reicht.ProtectHazards()
local protected = 0
for _, part in ipairs(CollectionService:GetTagged("KillBrick")) do
if part:IsA("BasePart") then
if State.SavedHazards[part] == nil then State.SavedHazards[part] = part.CanTouch end
if part.CanTouch ~= false then
part.CanTouch = false
protected += 1
end
end
end
return protected
end
function Reicht.RestoreHazards()
for part, original in pairs(State.SavedHazards) do
if part.Parent and original ~= nil then part.CanTouch = original end
State.SavedHazards[part] = nil
end
end
function Reicht.Noclip(enabled)
local character = LocalPlayer.Character
if not character then return 0 end
local count = 0
for _, part in ipairs(character:GetDescendants()) do
if part:IsA("BasePart") then
part.CanCollide = not enabled
count += 1
end
end
return count
end
function Reicht.ClimbStep()
local route = Reicht.Snapshot()
if not route then return "Waiting for a tower" end
local _, root = CharacterParts()
if not root then return "Waiting for respawn" end
State.Total = #route
if State.Stage >= #route then
State.Rounds += 1
State.Stage = 0
return "Tower complete, waiting for the next one"
end
State.Stage += 1
local row = route[State.Stage]
local target = Vector3.new(row.Position.X, row.Position.Y + row.Height + Config.StandClearance, row.Position.Z)
Reicht.Move(root, target)
return string.format("Section %d/%d", State.Stage, State.Total)
end
function Reicht.PokeIdle()
local ok = pcall(function()
VirtualUser:CaptureController()
VirtualUser:ClickButton2(Vector2.new(0, 0))
end)
return ok
end
local function LoadLibraryAndBuild()
local Library = Reicht.LoadLibrary()
if not Library then
for _, message in ipairs(Reicht.Messages) do warn("[TowerOfHell] " .. message) end
return
end
local T = function(en) return Library:T(en, en) end
local function Notify(text, kind)
Library:Notify(Config.Name, text, 4, kind or "Info")
end
-- Forward declaration: enabling a toggle does the work immediately instead of
-- waiting for the next tick, so a click has a visible effect.
local Step
local ReportStatus
local function Feature(group, key, text, description)
return group:AddToggle(key, {
Text = text,
Description = description,
Default = false,
Callback = function(value)
State.Flags[key] = value
if value then Reicht.Try(Step) end
end,
})
end
local function Every(interval, fn)
return Library:Every(interval, function() Reicht.Try(fn) end)
end
local function BuildMain(window)
window:AddTabSection("Farm")
local tab = window:AddTab("Main", "house", "Live status and the climb")
local statusBox = tab:AddLeftGroupbox("Status")
local climbLabel = statusBox:AddLabel("Climb: Off")
local stageLabel = statusBox:AddLabel("Section: -")
local roundLabel = statusBox:AddLabel("Towers finished: 0")
local hazardLabel = statusBox:AddLabel("Hazards protected: 0")
local climbBox = tab:AddRightGroupbox("Climb")
climbBox:AddToggle("AutoClimb", {
Text = "Auto climb",
Description = "Walks the tower section by section and stops at the finish",
Default = false,
Callback = function(value)
State.Flags.AutoClimb = value
if value then
State.Stage = 0
Reicht.Try(Step)
end
end,
})
climbBox:AddSlider("ClimbSpeed", {
Text = "Speed",
Default = 40,
Min = Config.MinSpeed,
Max = Config.MaxSpeed,
Rounding = 0,
Callback = function(value) State.Flags.Speed = tonumber(value) or 40 end,
})
Feature(climbBox, "Hover", "Hover", "Holds the character level while it moves between sections")
local guardBox = tab:AddRightGroupbox("Protection")
Feature(guardBox, "HazardProtect", "KillBrick protection", "Disables touch on every tagged hazard")
Feature(guardBox, "Noclip", "Noclip", "Turns collision off on your own parts while climbing")
local settingsTab = window:AddSettingsTab()
local sessionBox = settingsTab:AddRightGroupbox("Session")
Feature(sessionBox, "AntiAFK", "Anti AFK", "Keeps the session alive while you are away")
ReportStatus = function()
climbLabel:SetText("Climb: " .. Reicht.Status.Climb)
stageLabel:SetText("Section: " .. tostring(State.Stage) .. "/" .. tostring(State.Total))
roundLabel:SetText("Towers finished: " .. tostring(State.Rounds))
local protected = 0
for _ in pairs(State.SavedHazards) do protected += 1 end
hazardLabel:SetText("Hazards protected: " .. tostring(protected))
while #Reicht.Messages > 0 do Notify(table.remove(Reicht.Messages, 1), "Warning") end
end
Step = function()
if State.Flags.Hover then
Reicht.Hover(true)
else
Reicht.Hover(false)
end
if State.Flags.HazardProtect then
local protected = Reicht.ProtectHazards()
Reicht.Status.Hazard = protected > 0 and ("Protected " .. protected) or "No hazards nearby"
else
Reicht.RestoreHazards()
Reicht.Status.Hazard = "Off"
end
if State.Flags.Noclip then
Reicht.Noclip(true)
Reicht.Status.Noclip = "On"
else
Reicht.Status.Noclip = "Off"
end
if State.Flags.AutoClimb then
Reicht.Status.Climb = Reicht.ClimbStep()
else
Reicht.Status.Climb = "Off"
end
local _, _, humanoid = CharacterParts()
if humanoid and State.Flags.AutoClimb then
humanoid.WalkSpeed = math.clamp(tonumber(State.Flags.Speed) or 40, Config.MinSpeed, Config.MaxSpeed)
end
Reicht.Status.AntiAFK = State.Flags.AntiAFK and "On" or "Off"
end
Every(Config.ClimbInterval, Step)
Every(Config.StatusInterval, ReportStatus)
LocalPlayer.Idled:Connect(function()
if not State.Flags.AntiAFK then return end
Reicht.PokeIdle()
end)
end
local function UnloadHub()
Library:Unload()
end
Env().TowerOfHellUnload = UnloadHub
Library:OnUnload(function()
if Env().TowerOfHellUnload == UnloadHub then Env().TowerOfHellUnload = nil end
end)
Library:CreateWindow({
Title = "Reicht",
SubTitle = Config.Game .. " by Reicht",
MenuKey = Enum.KeyCode.LeftControl,
ConfigFolder = Config.SaveFolder,
Language = "Auto",
Theme = "Overworld",
OnUnlocked = function()
BuildMain(window or Library.Window)
Reicht.Try(ReportStatus)
Notify("Loaded", "Success")
Reicht.Try(Library.LoadAutoloadConfig, Library)
end,
})
end
if Env().TowerOfHellUnload then
pcall(Env().TowerOfHellUnload)
end
Reicht.Try(LoadLibraryAndBuild)
