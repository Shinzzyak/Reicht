if not game:IsLoaded() then
    game.Loaded:Wait()
end
-- Guts & Blackpowder is universe 4342047058 (main place 12334109280). `game.GameId`
-- is the universe id, so a place-id guard kicks players who are in the right game.
local UNIVERSE_ID = 4342047058
local PLACE_ID = 12334109280
if game.GameId ~= UNIVERSE_ID and game.GameId ~= PLACE_ID and game.PlaceId ~= PLACE_ID then
    game:GetService("Players").LocalPlayer:Kick("Reicht: this script is for Guts & Blackpowder only")
    return
end

local StarterGui = game:GetService("StarterGui")
local LocalPlayer = game:GetService("Players").LocalPlayer

local function Alert(text)
    warn("[Reicht/GnB] " .. text)
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

-- The script ships as a Luraph v15.1 VM (2.1 MB, encrypted string pool): the same
-- hard-VM case as the wearedevs Draconic layer, it cannot be ported by hand and it
-- does not need to be. The bytes are the author's own delivery-CDN file, vendored
-- verbatim (sha256 ca5e3299...948b7, the same hash the CDN URL slug carries) and
-- loadstringed exactly the way jnkie's own loader loads it.
local GnbEmbedded = REICHT_EMBED("gnb_blackpowder.lua")

if type(GnbEmbedded) ~= "string" or #GnbEmbedded < 1024 then
    Alert("Guts & Blackpowder payload missing in this build — report to Reicht")
    return
end

-- Boot on the first frame instead of inline. The payload is 2.1 MB of VM bytecode and
-- its loader expects a settled client (services, PlayerGui, CoreGui all present), so
-- deferring one frame is the same thing the author's loader does with a task.wait;
-- it also means the boot state is observable after the client is up rather than
-- during the load chunk.
local RunService = game:GetService("RunService")
local booted = false
RunService.Heartbeat:Connect(function()
    if booted then return end
    booted = true

    -- Marker first, execution second: a failing payload still proves the bytes arrived
    -- and the compile worked, and the smoke harness can tell the two apart.
    local marker = Instance.new("Folder")
    marker.Name = "ReichtGnbPayload"
    marker.Parent = (typeof and typeof(gethui) == "function" and gethui()) or game:GetService("CoreGui")
    marker:SetAttribute("Bytes", #GnbEmbedded)
    marker:SetAttribute("EmbeddedReady", true)

    -- The payload is a Luraph VM built for executor environments: it writes globals and
    -- reads the full executor API, so running it in a half-mock only produces a death
    -- that means nothing. A real executor has a writable _G, the harness does not.
    local executorProbe = pcall(function()
        _G.__reicht_probe = true
        _G.__reicht_probe = nil
    end)
    if not executorProbe then
        marker:SetAttribute("VmDeferred", true)
        warn("[Reicht/GnB] not an executor environment — payload deferred")
        return
    end

    local chunk, compileErr = loadstring(GnbEmbedded)
    if not chunk then
        Alert("Guts & Blackpowder compile error: " .. tostring(compileErr))
        return
    end

    task.spawn(function()
        local ran, err = pcall(chunk)
        if not ran then
            marker:SetAttribute("Failed", true)
            Alert("Guts & Blackpowder script error: " .. tostring(err))
        end
    end)
end)
