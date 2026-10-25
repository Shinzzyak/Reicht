-- Functional tests for sync/deobf/harvest_executor.lua.
-- Run from the repo root: lua5.1 sync/deobf/test_harvest.lua
-- Needs a Lua 5.1 interpreter (the payload's own VM dialect).

local outdir = os.getenv("DEOBF_TEST_OUT") or "/tmp"
local written = {}
writefile = function(name, data)
    local file = assert(io.open(outdir .. "/" .. name, "wb"))
    file:write(data)
    file:close()
    written[name] = data
    return true
end

local harvest = dofile("sync/deobf/harvest_executor.lua")
assert(type(harvest) == "function", "harvester must return a function")

local original_char = string.char
local original_loadstring = loadstring

local demo = [[
local s = string.char(72,101,108,108,111)
local ok, v = pcall(loadstring("return 42"))
print("demo", s, ok, v)
]]
local chunks, strings = harvest(demo)
assert(chunks == 1, "expected 1 captured chunk, got " .. tostring(chunks))
assert(written["deobf_dump.lua"]:find("return 42", 1, true), "dump must contain the inner chunk")
assert(written["deobf_strings.txt"]:find("Hello", 1, true), "string.char rebuild must be captured")
print("PASS 1 chunks and rebuilt strings captured (strings=" .. strings .. ")")

assert(string.char == original_char, "string.char must be restored")
assert(loadstring == original_loadstring, "loadstring must be restored")
assert(loadstring("return 7")() == 7, "loadstring must still work after restore")
print("PASS 2 hooks restored")

harvest([[loadstring("return 99")()]])
assert(not written["deobf_dump.lua"]:find("return 42", 1, true), "second run must not leak the first run's chunks")
assert(written["deobf_dump.lua"]:find("return 99", 1, true), "second run must capture its own chunk")
print("PASS 3 capture state isolated per run")

local file = io.open("sync/upstream/ref/draconic_evade.lua", "rb")
if file then
    local payload = file:read("*a")
    file:close()
    local ok, n, s = pcall(harvest, payload)
    assert(ok, "harvester itself must not crash on the real payload: " .. tostring(n))
    assert(written["deobf_dump.lua"], "dump file must be written even when the payload aborts")
    print(string.format("PASS 4 real payload harvested without host crash: %d chunks, %d strings", n, s))
    print("NOTE  outside Roblox the payload's VM aborts before dispatch; feature strings only appear in a live executor")
else
    print("SKIP 4 vendored payload missing")
end
print("ALL HARVESTER TESTS PASSED")
