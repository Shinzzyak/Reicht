--[[
Draconic Evade / WeAreDevs payload harvester.

Static route is exhausted: the string pool cipher is cracked (see sync/deobf/wad_pool.py,
self-check against the payload's own "Tamper Detected!" literal), but the 384 remaining
pool entries are a second layer that only the payload's own pseudo-VM decrypts, and that
VM refuses to dispatch anything until it sees a real Roblox environment
(GetService=0, HttpGet=0, LOAD=0 under a fake environment).

So the last step needs real Lua under a real executor. This script does that: it wraps
load/loadstring/setfenv and string.char, runs the untouched payload, and writes every
chunk the payload hands to the compiler plus every rebuilt string to a file.

Usage (executor attached to any Roblox place):
    local payload = readfile("draconic_evade.lua")   -- or paste the URL fetch below
    loadstring(readfile("harvest_executor.lua"))()(payload)

Output: deobf_dump.lua in the executor workspace (or printed in 4 KiB chunks if the
executor has no writefile).
--]]

local CHUNK_FILE = "deobf_dump.lua"
local STRING_FILE = "deobf_strings.txt"

local function new_capture()
    return { chunks = {}, strings = {}, seen = {} }
end

local writefile = writefile or function(name, data)
    -- no filesystem: print in chunks the console can carry
    local step = 4096
    for i = 1, #data, step do
        print(string.sub(data, i, i + step - 1))
    end
    return true
end

-- capture state is rebound per run so repeated harvests never mix
local chunks, strings, seen

local function record_string(value)
    if type(value) ~= "string" or #value < 3 then return end
    if not string.match(value, "^[%w%p%s]+$") then return end
    if seen[value] then return end
    seen[value] = true
    strings[#strings + 1] = value
end

local function install_hooks()
    local originals = {
        load = load,
        loadstring = loadstring or load,
        loadfile = loadfile,
    }

    local function wrap(name, original)
        return function(source, chunkname, ...)
            if type(source) == "string" then
                chunks[#chunks + 1] = {
                    kind = name,
                    name = tostring(chunkname or "?"),
                    body = source,
                }
            end
            return original(source, chunkname, ...)
        end
    end

    _G.load = wrap("load", originals.load)
    _G.loadstring = wrap("loadstring", originals.loadstring)
    if originals.loadfile then
        _G.loadfile = wrap("loadfile", originals.loadfile)
    end

    -- string.char is how every string-rebuild obfuscator materialises text
    local char = string.char
    originals.char = char
    local buffer = {}
    local function flush()
        if #buffer > 0 then
            record_string(table.concat(buffer))
            buffer = {}
        end
    end
    string.char = function(...)
        local value = char(...)
        for i = 1, #value do
            local byte = string.byte(value, i)
            if byte >= 32 and byte < 127 then
                buffer[#buffer + 1] = string.sub(value, i, i)
            else
                flush()
            end
        end
        if #buffer > 512 then flush() end
        return value
    end

    return originals, flush
end

local function restore(originals)
    _G.load = originals.load
    _G.loadstring = originals.loadstring
    if originals.loadfile then _G.loadfile = originals.loadfile end
    if originals.char then string.char = originals.char end
end

local function serialise(source)
    -- keep the dumped chunk loadable: long-bracket it with a fence wide enough
    local fence = "="
    while string.find(source, "]" .. fence .. "]", 1, true) do
        fence = fence .. "="
    end
    return "return [" .. fence .. "[" .. source .. "]" .. fence .. "]"
end

return function(payload)
    payload = payload or readfile and readfile("draconic_evade.lua")
    if type(payload) ~= "string" then
        error("no payload given: pass the obfuscated source as the first argument")
    end

    local capture = new_capture()
    chunks, strings, seen = capture.chunks, capture.strings, capture.seen

    local originals, flush = install_hooks()
    local ok, err = pcall(function()
        local loader = originals.loadstring or originals.load
        local chunk = loader(payload, "=payload")
        if not chunk then error("payload did not compile") end
        chunk()
    end)
    restore(originals)
    flush()

    local out = { "-- harvest: " .. tostring(ok and "clean" or err), "" }
    for index, entry in ipairs(chunks) do
        out[#out + 1] = "-- chunk " .. index .. " (" .. entry.kind .. " " .. entry.name .. ", " .. #entry.body .. " bytes)"
        out[#out + 1] = serialise(entry.body)
        out[#out + 1] = ""
    end
    writefile(CHUNK_FILE, table.concat(out, "\n"))

    table.sort(strings, function(a, b) return #a > #b end)
    writefile(STRING_FILE, table.concat(strings, "\n"))

    print(string.format("harvest: %d chunks, %d rebuilt strings, run=%s",
        #chunks, #strings, tostring(ok)))
    if not ok then print("harvest error: " .. tostring(err)) end
    return #chunks, #strings
end
