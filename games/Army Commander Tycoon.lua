if not game:IsLoaded() then
game.Loaded:Wait()
end
local Players = game:GetService("Players")
local RS = game:GetService("ReplicatedStorage")
local WS = game:GetService("Workspace")
local VU = game:GetService("VirtualUser")
local LP = Players.LocalPlayer
if game.PlaceId ~= 10258991999 and game.GameId ~= 10768458048 and game.PlaceId ~= 119263815547952 then
LP:Kick("Reicht: this script is for Army Commander Tycoon only")
return
end
local Config = {
Name = "Army Commander Tycoon",
Game = "Army Commander Tycoon",
UiSource = "https://raw.githubusercontent.com/Shinzzyak/Reicht/refs/heads/main/ui.lua",
SaveFolder = "Army Commander Tycoon",
AttackInterval = 0.25,
StatusInterval = 1,
}
local Reicht = {
Config = Config,
Messages = {},
Status = { Farm = "Off", Prompt = "Off", AntiAFK = "On" },
}
local State = {
Running = false,
AutoPrompt = false,
AntiAFK = true,
Fired = 0,
Errors = 0,
LastError = "-",
Team = "-",
}
local function log(fmt, ...)
local ok, msg = pcall(string.format, fmt, ...)
print("[CAA] " .. (ok and msg or tostring(fmt)))
end
local function Env()
return (getgenv and getgenv()) or _G
end
local function Alert(text)
Reicht.Messages[#Reicht.Messages + 1] = tostring(text)
end
function Reicht.Try(fn, ...)
local ok, err = pcall(fn, ...)
if not ok then
warn("[CAA] " .. tostring(err):match("[^\\n]*"))
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
local function deepFind(root, name)
local hit = root:FindFirstChild(name)
if hit then
return hit
end
for _, d in ipairs(root:GetDescendants()) do
if d.Name == name then
return d
end
end
return nil
end
local Shared = RS:FindFirstChild("Shared") or deepFind(RS, "Shared")
local Remotes = Shared and (Shared:FindFirstChild("Remotes") or deepFind(Shared, "Remotes"))
Remotes = Remotes or deepFind(RS, "Remotes")
local function remote(name)
if Remotes then
local r = Remotes:FindFirstChild(name)
if r then
return r
end
end
return deepFind(RS, name)
end
local TroopStateRequest = remote("TroopStateRequest")
local TeamRequest = remote("TeamRequest")
local InProgressResponse = remote("InProgressResponse")
log("place %s - remotes %s - combat %s",
tostring(game.PlaceId),
Remotes and "ok" or "MISSING",
TroopStateRequest and "ok" or "MISSING")
local function fire(r, ...)
if not r then
return false
end
local ok, err = pcall(function(...)
r:FireServer(...)
end, ...)
if ok then
State.Fired = State.Fired + 1
else
State.Errors = State.Errors + 1
State.LastError = tostring(err):sub(1, 64)
end
return ok
end
local function joinTeam(side)
State.Team = side
fire(TeamRequest, side)
end
local function joinInProgress()
fire(InProgressResponse, true)
end
local function attack()
fire(TroopStateRequest, "Attack")
end
local function capability(name)
local e = Env()
local fn = e[name]
if fn == nil and getgenv then
local ok, g = pcall(getgenv)
if ok and type(g) == "table" then
fn = g[name]
end
end
return fn
end
local function collectPrompts()
local found = {}
local root = WS:FindFirstChild("Map") or WS
for _, d in ipairs(root:GetDescendants()) do
if d:IsA("ProximityPrompt") or d:IsA("ClickDetector") then
found[#found + 1] = d
end
end
return found
end
local function firePrompts()
local fireprompt = capability("fireproximityprompt")
local fireclick = capability("fireclickdetector")
for _, d in ipairs(collectPrompts()) do
if d:IsA("ProximityPrompt") then
if fireprompt then
pcall(fireprompt, d, 1)
else
pcall(function()
d:InputHoldBegin()
d:InputHoldEnd()
end)
end
elseif fireclick then
pcall(fireclick, d)
end
end
end
local function farmTick()
if not State.Running then
return
end
joinInProgress()
joinTeam(State.Team == "Defenders" and "Attackers" or "Defenders")
attack()
if State.AutoPrompt then
pcall(firePrompts)
end
end
LP.Idled:Connect(function()
if not State.AntiAFK then
return
end
pcall(function()
VU:CaptureController()
VU:ClickButton2(Vector2.new())
end)
end)
local function LoadLibraryAndBuild()
local Library = Reicht.LoadLibrary()
if not Library then
for _, message in ipairs(Reicht.Messages) do
warn("[CAA] " .. message)
end
return
end
local function Notify(text, kind)
Library:Notify(Config.Name, text, 4, kind or "Info")
end
local function BuildMain(window)
window:AddTabSection("Farm")
local tab = window:AddTab("Farm", "swords", "Troop state, team requests and prompt sweeps")
local statusBox = tab:AddLeftGroupbox("Status")
local stateLabel = statusBox:AddLabel("Farm: Off")
local teamLabel = statusBox:AddLabel("Team: -")
local fireLabel = statusBox:AddLabel("Fired: 0")
local errorLabel = statusBox:AddLabel("Errors: 0")
local combatBox = tab:AddLeftGroupbox("Combat")
combatBox:AddToggle("CAutoFarm", {
Text = "Auto farm",
Description = "Requests troop state and keeps the team queue alive",
Default = false,
Callback = function(value)
State.Running = value
Reicht.Status.Farm = value and "On" or "Off"
stateLabel:SetText("Farm: " .. Reicht.Status.Farm)
if value then
Reicht.Try(farmTick)
end
end,
})
combatBox:AddToggle("CAutoPrompt", {
Text = "Auto prompt",
Description = "Fires every proximity prompt and click detector in the map",
Default = false,
Callback = function(value)
State.AutoPrompt = value
Reicht.Status.Prompt = value and "On" or "Off"
if value then
Reicht.Try(firePrompts)
end
end,
})
combatBox:AddToggle("CAntiAFK", {
Text = "Anti AFK",
Description = "Clicks through the idle event so the session never drops",
Default = true,
Callback = function(value)
State.AntiAFK = value
Reicht.Status.AntiAFK = value and "On" or "Off"
end,
})
local teamBox = tab:AddRightGroupbox("Team")
teamBox:AddButton({
Text = "Join Attackers",
Func = function()
State.Team = "Attackers"
Reicht.Try(fire, TeamRequest, "Attackers")
teamLabel:SetText("Team: Attackers")
Notify("Joining attackers", "Success")
end,
})
teamBox:AddButton({
Text = "Join Defenders",
Func = function()
State.Team = "Defenders"
Reicht.Try(fire, TeamRequest, "Defenders")
teamLabel:SetText("Team: Defenders")
Notify("Joining defenders", "Success")
end,
})
teamBox:AddButton({
Text = "Respond in progress",
Func = function()
Reicht.Try(joinInProgress)
Notify("In-progress response sent", "Info")
end,
})
window:AddTabSection("Utility")
local utilTab = window:AddTab("Utility", "wrench", "Diagnostics and teardown")
local diagBox = utilTab:AddLeftGroupbox("Diagnostics")
diagBox:AddButton({
Text = "Dump remotes to console",
Func = function()
local lines = {}
if Remotes then
for _, d in ipairs(Remotes:GetChildren()) do
lines[#lines + 1] = d.ClassName .. "  " .. d.Name
end
end
for _, d in ipairs(RS:GetChildren()) do
if d:IsA("RemoteEvent") or d:IsA("RemoteFunction") then
lines[#lines + 1] = "root  " .. d.Name
end
end
for _, line in ipairs(lines) do
log("  %s", line)
end
log("total remotes: %d", #lines)
local clip = capability("setclipboard")
if clip then
pcall(clip, table.concat(lines, "\\n"))
log("copied to clipboard")
end
end,
})
diagBox:AddButton({
Text = "Unload",
Func = function()
State.Running = false
Library:Unload()
end,
})
Library:Every(Config.StatusInterval, function()
stateLabel:SetText("Farm: " .. Reicht.Status.Farm)
teamLabel:SetText("Team: " .. State.Team)
fireLabel:SetText("Fired: " .. State.Fired)
errorLabel:SetText("Errors: " .. State.Errors)
while #Reicht.Messages > 0 do
Notify(table.remove(Reicht.Messages, 1), "Warning")
end
end)
if State.Running then
Library:Every(Config.AttackInterval, function()
Reicht.Try(farmTick)
end)
end
end
local function UnloadHub()
Library:Unload()
end
Env().ArmyCommanderUnload = UnloadHub
Library:OnUnload(function()
if Env().ArmyCommanderUnload == UnloadHub then
Env().ArmyCommanderUnload = nil
end
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
Notify("Loaded", "Success")
Reicht.Try(Library.LoadAutoloadConfig, Library)
end,
})
end
if Env().ArmyCommanderUnload then
pcall(Env().ArmyCommanderUnload)
end
Reicht.Try(LoadLibraryAndBuild)
