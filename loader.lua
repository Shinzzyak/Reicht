if not game:IsLoaded() then
game.Loaded:Wait()
end
local BASE = "https://raw.githubusercontent.com/Shinzzyak/Reicht/refs/heads/main/games/"
local GAMES = {
[9872472334] = "Evade",
[10436530264] = "Build An Ant Empire",
[10418224975] = "TNT Mining",
[10684750879] = "Loot To Forge",
[10765091041] = "Open Sea For Animals",
[66654135] = "Murder Mystery 2",
[1202096104] = "Driving Empire",
[9534705677] = "Sniper Arena",
[6739698191] = "Violence District",
[10708913337] = "Anime Dice",
[10035204815] = "Ride A Pet",
[10031505426] = "AirDrop Arena",
[7633926880] = "BloxStrike",
[10765298801] = "Stone Skipping",
[10765288803] = "Break and Steal an Egg",
[10765012427] = "Build the Pyramid",
}
local StarterGui = game:GetService("StarterGui")
local function Notify(text, detail)
warn("[Reicht] " .. text, detail or "")
task.spawn(function()
for _ = 1, 20 do
local shown = pcall(StarterGui.SetCore, StarterGui, "SendNotification", {
Title = "Reicht",
Text = text,
Duration = 10,
})
if shown then return end
task.wait(0.5)
end
end)
end
local function LooksLikeScript(body)
if type(body) ~= "string" or body == "" then return false end
local head = body:sub(1, 80)
return not (head:find("^%s*<") or head:find("^%d%d%d:"))
end
local function FetchOnce(url)
local ok, body = pcall(function() return game:HttpGet(url) end)
if ok and LooksLikeScript(body) then return body end
local send = request or http_request or (syn and syn.request) or (http and http.request)
if not send then return nil, ok and "bad reply from HttpGet" or tostring(body) end
local sent, reply = pcall(send, { Url = url, Method = "GET" })
if not sent or type(reply) ~= "table" then return nil, tostring(reply) end
if reply.StatusCode ~= 200 then return nil, "HTTP " .. tostring(reply.StatusCode) end
if not LooksLikeScript(reply.Body) then return nil, "bad reply body" end
return reply.Body
end
local function Fetch(url)
local why
for attempt = 1, 3 do
local body, err = FetchOnce(url)
if body then return body end
why = err
if attempt < 3 then task.wait(1) end
end
return nil, why
end
local name = GAMES[game.GameId]
if not name then
Notify("This game is not supported yet. Open the repo issues tab for the list.")
return
end
local source, why = Fetch(BASE .. (name:gsub(" ", "%%20")) .. ".lua")
if not source then
Notify("Could not download " .. name .. ". Check your connection and try again.", why)
return
end
local chunk, compileErr = loadstring(source)
if not chunk then
Notify(name .. " failed to load on this executor: " .. tostring(compileErr))
return
end
local ok, trace = xpcall(chunk, function(err)
return debug.traceback(tostring(err), 2)
end)
if not ok then
Notify(name .. " stopped with an error: " .. tostring(trace):match("^[^\n]*"), "\n" .. tostring(trace))
end