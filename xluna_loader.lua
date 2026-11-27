if not game:IsLoaded() then game.Loaded:Wait() end

--[[ XLunaHUB keyless mirror — 61 games, auto PlaceId dispatch. ]]
local BASE = "https://raw.githubusercontent.com/Shinzzyak/Reicht/refs/heads/main/games/xluna/"
local MAP_URL = BASE .. "_placeid.lua"

local StarterGui = game:GetService("StarterGui")
local function Notify(text, detail)
	warn("[Reicht/xLuna] " .. text, detail or "")
	task.spawn(function()
		for _ = 1, 20 do
			if pcall(StarterGui.SetCore, StarterGui, "SendNotification", {
				Title = "xLuna Hub", Text = text, Duration = 10,
			}) then return end
			task.wait(0.5)
		end
	end)
end

local function Fetch(url)
	local send = request or http_request or (syn and syn.request) or (http and http.request)
	for attempt = 1, 3 do
		local ok, body = pcall(function()
			if send then
				local r = send({ Url = url, Method = "GET" })
				if r and r.StatusCode == 200 then return r.Body end
				return nil
			end
			return game:HttpGet(url)
		end)
		if ok and type(body) == "string" and #body > 40 and not body:match("^%s*<") then
			return body
		end
		task.wait(1)
	end
	return nil
end

local mapSrc = Fetch(MAP_URL)
if not mapSrc then
	Notify("Gagal muat peta game xLuna. Cek koneksi.")
	return
end
local mapChunk, mapErr = loadstring(mapSrc)
if not mapChunk then
	Notify("Peta game rusak: " .. tostring(mapErr))
	return
end
local MAP = mapChunk()

local pid = game.PlaceId
local entry = MAP[pid] or MAP[tonumber(game.GameId)]
if not entry then
	Notify("Game ini tidak ada di daftar xLuna. PlaceId=" .. tostring(pid))
	return
end

Notify("Muat " .. entry.title .. " ...")
local src = Fetch(BASE .. entry.slug .. ".lua")
if not src then
	Notify("Gagal ambil script " .. entry.slug)
	return
end
local chunk, compileErr = loadstring(src)
if not chunk then
	Notify("Script " .. entry.slug .. " gagal compile: " .. tostring(compileErr))
	return
end
local ok, trace = xpcall(chunk, function(err) return debug.traceback(tostring(err), 2) end)
if not ok then
	Notify("Script " .. entry.slug .. " error: " .. tostring(trace):match("^[^\n]*"))
end
