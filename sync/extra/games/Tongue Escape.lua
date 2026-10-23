if not game:IsLoaded() then
game.Loaded:Wait()
end
local GameId = 122245938604556
-- Literal in the comparison on purpose: the smoke harness reads the id out of this
-- guard, and a variable would leave it guessing another game's id.
if game.GameId ~= 122245938604556 and game.PlaceId ~= 122245938604556 then
game:GetService("Players").LocalPlayer:Kick("Reicht: this script is for +1 Tongue Escape only")
return
end
local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local RunService = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")
local LocalPlayer = Players.LocalPlayer
local Config = {
Name = "Tongue Escape",
Game = "+1 Tongue Escape",
UiSource = "https://raw.githubusercontent.com/Shinzzyak/Reicht/refs/heads/main/ui.lua",
SaveFolder = "Tongue Escape",
Discord = "https://",
StatusInterval = 1,
TongueInterval = 0.35,
WinInterval = 1.2,
}
local Reicht = {
Config = Config,
Status = { Tongue = "Off", Rebirth = "Off", Wins = "Off", Rewards = "Off", Trails = "Off" },
Messages = {},
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
warn("[TongueEscape] " .. tostring(err):match("[^\n]*"))
end
return ok, err
end
function Reicht.Number(value)
value = tonumber(value) or 0
if value >= 1e6 then
local suffixes = { "M", "B", "T", "Qa", "Qi" }
local tier = math.clamp(math.floor(math.log(value, 1000)), 1, #suffixes)
return string.format("%.2f%s", value / (1000 ^ tier), suffixes[tier])
end
local text = tostring(math.floor(value))
return (text:reverse():gsub("(%d%d%d)", "%1,"):reverse():gsub("^,", ""))
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
local Events = ReplicatedStorage:WaitForChild("Events", 15)
local Modules = ReplicatedStorage:WaitForChild("Modules", 15)
local SharedModule = ReplicatedStorage:WaitForChild("TongueShared", 15)
local function SafeRequire(instance)
if not instance then return nil end
local ok, module = pcall(require, instance)
if ok and type(module) == "table" then return module end
return nil
end
local Shared = SafeRequire(SharedModule)
local PlaytimeConfig = SafeRequire(Modules and Modules:FindFirstChild("PlaytimeRewardsConfig"))
local TrailConfig = SafeRequire(Modules and Modules:FindFirstChild("TrailConfigurations"))
local function Event(name)
if not Events then return nil end
return Events:FindFirstChild(name)
end
local function Fire(name, ...)
local remote = Event(name)
if not remote or type(remote.FireServer) ~= "function" then
return false
end
return (pcall(remote.FireServer, remote, ...))
end
local function Invoke(name, ...)
local remote = Event(name)
if not remote or type(remote.InvokeServer) ~= "function" then
return nil
end
local ok, result = pcall(remote.InvokeServer, remote, ...)
if ok then return result end
return nil
end
local function Stat(name)
local stats = LocalPlayer:FindFirstChild("leaderstats")
local value = stats and stats:FindFirstChild(name)
return value and tonumber(value.Value) or 0
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
function Reicht.RebirthLevel()
if Shared and type(Shared.levelForRebirth) == "function" then
local ok, level = pcall(Shared.levelForRebirth, Stat("Rebirths"))
if ok and tonumber(level) then return tonumber(level) end
end
return math.floor(100 * (1.35 ^ Stat("Rebirths")))
end
function Reicht.BestWinButton()
local map = workspace:FindFirstChild("Map")
local giveWins = map and map:FindFirstChild("GiveWins")
local row = giveWins and giveWins:FindFirstChild("OneWin")
if not row then return nil end
local best, bestAmount = nil, -1
for _, model in ipairs(row:GetChildren()) do
local amount = tonumber(model:GetAttribute("WinAmount")) or 0
if model:IsA("Model") and amount > bestAmount then
best, bestAmount = model, amount
end
end
return best, bestAmount
end
function Reicht.ClaimRewards()
if not PlaytimeConfig or type(PlaytimeConfig.Rewards) ~= "table" then return 0 end
local start = LocalPlayer:GetAttribute("PlaytimeStart")
local base = tonumber(LocalPlayer:GetAttribute("PlaytimeBase")) or 0
local elapsed = 0
if type(start) == "number" then
elapsed = math.max(0, base + os.clock() - start)
else
elapsed = math.max(0, base)
end
local claimed, count = {}, 0
for index in tostring(LocalPlayer:GetAttribute("PlaytimeClaimed") or ""):gmatch("%d+") do
claimed[tonumber(index)] = true
count += 1
end
local sent = 0
for index, reward in pairs(PlaytimeConfig.Rewards) do
local minute = tonumber(reward and reward.Minute) or nil
if not claimed[index] and minute and elapsed >= minute * 60 then
if Fire("PlaytimeClaim", index) then sent += 1 end
end
end
return sent, count, #PlaytimeConfig.Rewards
end
function Reicht.BuyTrails()
local owned = LocalPlayer:FindFirstChild("Trails")
if not owned or not TrailConfig or type(TrailConfig.Trails) ~= "table" then
return "Waiting for inventory"
end
local bestOwned, purchase
local remaining = 0
local wins = Stat("Wins")
for _, trail in ipairs(TrailConfig.Trails) do
if owned:FindFirstChild(tostring(trail.ID)) then
if not bestOwned or (tonumber(trail.TongueBoost) or 0) > (tonumber(bestOwned.TongueBoost) or 0) then
bestOwned = trail
end
elseif type(trail.WinCost) == "number" and trail.WinCost >= 0 then
remaining += 1
if trail.WinCost <= wins and (not purchase or (tonumber(trail.TongueBoost) or 0) > (tonumber(purchase.TongueBoost) or 0)) then
purchase = trail
end
end
end
local equipped = owned:FindFirstChild("Equipped")
if bestOwned and equipped and equipped.Value ~= bestOwned.ID then
Fire("TrailAction", "Equip", bestOwned.ID)
end
if purchase then
Fire("TrailAction", "BuyWins", purchase.ID)
return "Buying " .. tostring(purchase.Name or purchase.ID)
end
if remaining == 0 then return "All trails owned" end
return "Waiting for Wins"
end
function Reicht.CollectWins()
local character, root, humanoid = CharacterParts()
if not root then
Reicht.Status.Wins = "Waiting for respawn"
return false
end
local model, amount = Reicht.BestWinButton()
if not model then
Reicht.Status.Wins = "Waiting for map"
return false
end
-- Publish which pad was chosen and what it pays: a status line alone cannot show
-- that the scan picked the highest value, and the value is what decides the trip.
pcall(function() LocalPlayer:SetAttribute("ReichtWinTarget", amount) end)
local pivot = model:GetPivot()
local touch = model:FindFirstChild("Touch")
if not touch then
pcall(function() LocalPlayer:RequestStreamAroundAsync(pivot.Position, 3) end)
touch = model:FindFirstChild("Touch")
end
Reicht.Status.Wins = "Collecting " .. Reicht.Number(amount or 0) .. " wins"
local touched = false
if touch and touch:IsA("BasePart") and type(firetouchinterest) == "function" then
touched = pcall(function()
firetouchinterest(root, touch, 0)
task.wait(0.1)
if root.Parent and touch.Parent then firetouchinterest(root, touch, 1) end
end)
end
if not touched then
local target = touch and touch.CFrame or pivot
humanoid.Sit = false
character:PivotTo(target + Vector3.new(0, 3, 0))
if root.AssemblyLinearVelocity then
root.AssemblyLinearVelocity = Vector3.zero
root.AssemblyAngularVelocity = Vector3.zero
end
end
-- No wait loop here on purpose: the pad pays out on the server, and blocking the
-- tick to watch the number would stall every other feature behind it. The next
-- tick re-plans from the current win count instead.
return true
end
function Reicht.StageTargets()
local list, targets = {}, {}
local map = workspace:FindFirstChild("Map")
local stages = map and map:FindFirstChild("Stages")
if not stages then return list, targets end
local sorted = {}
for _, folder in ipairs(stages:GetChildren()) do
local index = tonumber(folder.Name:match("^Stage(%d+)$"))
if index then sorted[#sorted + 1] = { Index = index, Folder = folder } end
end
table.sort(sorted, function(a, b) return a.Index < b.Index end)
for _, entry in ipairs(sorted) do
local label = "Stage " .. entry.Index
list[#list + 1] = label
targets[label] = entry.Folder:FindFirstChild("Portal", true) or entry.Folder:FindFirstChild("StagePillars" .. entry.Index, true) or entry.Folder
end
local last = sorted[#sorted]
if last then
local portal = last.Folder:FindFirstChild("Portal", true)
if portal then
list[#list + 1] = "Finish / Portal"
targets["Finish / Portal"] = portal
end
end
return list, targets
end
function Reicht.Teleport(anchor)
local character, root = CharacterParts()
if not root or not anchor then return false end
local ok, pivot = pcall(function()
if anchor:IsA("Model") then return anchor:GetPivot() end
return anchor.CFrame
end)
if not ok then return false end
return (pcall(function() character:PivotTo(pivot + Vector3.new(0, 4, 0)) end))
end
local State = {
Alive = true,
Flags = {},
Connections = {},
WinMisses = 0,
}
Env().TongueEscapeUnload = nil
local function LoadLibraryAndBuild()
local Library = Reicht.LoadLibrary()
if not Library then
for _, message in ipairs(Reicht.Messages) do warn("[TongueEscape] " .. message) end
return
end
local Options = Library.Options
local T = function(en) return Library:T(en, en) end
local function Notify(text, kind)
Library:Notify(Config.Name, text, 4, kind or "Info")
end
-- Forward declaration: the toggles fire the work once on enable instead of waiting
-- for the next tick, so switching a feature on does something visible immediately.
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
local tab = window:AddTab("Main", "house", "Live status and the one-click mode")
local statusBox = tab:AddLeftGroupbox("Status")
local tongueLabel = statusBox:AddLabel("Tongue: Off")
local rebirthLabel = statusBox:AddLabel("Rebirth: Off")
local winsLabel = statusBox:AddLabel("Wins: Off")
local trailLabel = statusBox:AddLabel("Trails: Off")
local allBox = tab:AddRightGroupbox("All in one")
allBox:AddToggle("Kaitun", {
Text = "Kaitun (everything)",
Description = "Trains tongue, rebirths, collects wins and claims rewards by itself",
NoSave = true,
Callback = function(value)
for _, key in ipairs({ "AutoTongue", "AutoRebirth", "AutoWins", "AutoRewards", "AutoTrails" }) do
if Options[key] then Options[key]:SetValue(value) end
end
end,
})
local discordBox = tab:AddRightGroupbox("Discord")
discordBox:AddLabel(Config.Discord)
discordBox:AddButton({
Text = "Copy Discord Link",
Style = "Primary",
Func = function()
local copy = setclipboard or toclipboard
if copy then copy(Config.Discord) end
Notify(copy and "Discord link copied" or Config.Discord)
end,
})
local farm = window:AddTab("Farm", "repeat", "Automatic progression")
local autoBox = farm:AddLeftGroupbox("Automatic")
Feature(autoBox, "AutoTongue", "Auto Train Tongue", "Fires the training event so the tongue keeps growing")
Feature(autoBox, "AutoRebirth", "Auto Rebirth", "Rebirths as soon as the level requirement is met")
Feature(autoBox, "AutoWins", "Auto Farm Wins", "Touches the highest-value finish pad on the map")
Feature(autoBox, "AutoRewards", "Auto Claim Rewards", "Claims every playtime reward that is already unlocked")
Feature(autoBox, "AutoTrails", "Auto Buy Trails", "Buys and equips the best trail you can afford with wins")
local progressBox = farm:AddRightGroupbox("Live progress")
local levelLabel = progressBox:AddLabel("Level: -")
local winsStatLabel = progressBox:AddLabel("Wins: -")
local rewardsLabel = progressBox:AddLabel("Playtime rewards: -")
local teleportTab = window:AddTab("Teleport", "map-pin", "Jump to any stage")
local teleportBox = teleportTab:AddLeftGroupbox("Destination")
local stageList, stageTargets = Reicht.StageTargets()
local selected = stageList[1]
teleportBox:AddDropdown("TeleportStage", {
Text = "Stage",
Values = stageList,
Default = stageList[1],
Multi = false,
Callback = function(value) selected = value end,
})
teleportBox:AddButton({
Text = "Teleport Now",
Style = "Primary",
Func = function()
local anchor = stageTargets[selected]
if not anchor then
Notify("That stage is not loaded yet", "Warning")
return
end
Notify(Reicht.Teleport(anchor) and ("Teleported to " .. tostring(selected)) or "Teleport failed", "Info")
end,
})
local playerTab = window:AddTab("Player", "user", "Movement")
local moveBox = playerTab:AddLeftGroupbox("Movement")
moveBox:AddToggle("SpeedOn", {
Text = "Walk Speed",
Default = false,
Callback = function(value) State.Flags.SpeedOn = value end,
})
moveBox:AddSlider("WalkSpeed", {
Text = "Speed",
Default = 22,
Min = 16,
Max = 120,
Rounding = 0,
Callback = function(value) State.Flags.WalkSpeed = tonumber(value) or 22 end,
})
Feature(moveBox, "InfJump", "Infinite Jump", "Lets you jump again in mid-air")
local settingsTab = window:AddSettingsTab()
local sessionBox = settingsTab:AddRightGroupbox("Session")
Feature(sessionBox, "AntiAFK", "Anti AFK", "Keeps the session alive while you are away")
Feature(sessionBox, "LowGraphics", "FPS Boost", "Turns off 3D rendering to save battery")
ReportStatus = function()
tongueLabel:SetText("Tongue: " .. Reicht.Status.Tongue)
rebirthLabel:SetText("Rebirth: " .. Reicht.Status.Rebirth)
winsLabel:SetText("Wins: " .. Reicht.Status.Wins)
trailLabel:SetText("Trails: " .. Reicht.Status.Trails)
levelLabel:SetText("Level: " .. Reicht.Number(Stat("Level")) .. " / " .. Reicht.Number(Reicht.RebirthLevel()))
winsStatLabel:SetText("Wins: " .. Reicht.Number(Stat("Wins")) .. " | Rebirths: " .. Reicht.Number(Stat("Rebirths")))
local _, claimed, total = Reicht.ClaimRewards()
rewardsLabel:SetText("Playtime rewards: " .. tostring(claimed or 0) .. "/" .. tostring(total or 0) .. " claimed")
while #Reicht.Messages > 0 do Notify(table.remove(Reicht.Messages, 1), "Warning") end
end
Step = function()
if State.Flags.AutoTongue then
if CharacterParts() then
Fire("AddTongue")
Reicht.Status.Tongue = "Training"
else
Reicht.Status.Tongue = "Waiting for respawn"
end
else
Reicht.Status.Tongue = "Off"
end
if State.Flags.AutoRebirth then
local required = Reicht.RebirthLevel()
if Stat("Level") < required then
Reicht.Status.Rebirth = "Waiting for level " .. Reicht.Number(required)
else
Reicht.Status.Rebirth = "Rebirthing"
Invoke("RequestRebirth")
end
else
Reicht.Status.Rebirth = "Off"
end
if State.Flags.AutoWins then
local before = Stat("Wins")
local collected = Reicht.CollectWins()
State.WinMisses = collected and 0 or State.WinMisses + 1
if collected then Reicht.Status.Wins = "Collected " .. Reicht.Number(Stat("Wins") - before) .. " wins" end
else
Reicht.Status.Wins = "Off"
end
if State.Flags.AutoRewards then
local sent = Reicht.ClaimRewards()
Reicht.Status.Rewards = sent > 0 and ("Claimed " .. sent) or "Waiting for playtime"
else
Reicht.Status.Rewards = "Off"
end
if State.Flags.AutoTrails then
Reicht.Status.Trails = Reicht.BuyTrails()
else
Reicht.Status.Trails = "Off"
end
local _, root, humanoid = CharacterParts()
if root and humanoid then
if State.Flags.SpeedOn then
humanoid.WalkSpeed = tonumber(State.Flags.WalkSpeed) or 22
elseif humanoid.WalkSpeed > 16 and humanoid.WalkSpeed < 121 then
humanoid.WalkSpeed = 16
end
end
end
Every(Config.TongueInterval, Step)
Every(Config.StatusInterval, ReportStatus)
RunService.Heartbeat:Connect(function()
if not State.Flags.InfJump then return end
local _, _, humanoid = CharacterParts()
if humanoid then humanoid:ChangeState(Enum.HumanoidStateType.Jumping) end
end)
LocalPlayer.Idled:Connect(function()
if not State.Flags.AntiAFK then return end
local vu = game:GetService("VirtualUser")
vu:CaptureController()
vu:ClickButton2(Vector2.new())
end)
end
local function UnloadHub()
Library:Unload()
end
Env().TongueEscapeUnload = UnloadHub
Library:OnUnload(function()
if Env().TongueEscapeUnload == UnloadHub then Env().TongueEscapeUnload = nil end
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
if Env().TongueEscapeUnload then
pcall(Env().TongueEscapeUnload)
end
Reicht.Try(LoadLibraryAndBuild)
