# Deobfuscation workbench — Draconic Evade payload

Target: `sync/upstream/ref/draconic_evade.lua` (WeAreDevs-style obfuscator, Lua 5.1 VM).

## What is actually recovered

The string-pool cipher is **cracked and self-tested**, not guessed:

- every constant is stored as `"7" .. <digits>`
- digits are looked up in an inline **85-character permutation table** that lives in the payload
  itself (`local C={...}`); the tool parses and evaluates it, so nothing is hardcoded
- **5 digits -> 4 bytes**, big-endian, low 32 bits kept; a trailing short group emits `n-1` bytes
- known-plaintext oracle: the payload's own tamper-guard string `Tamper Detected!`

```sh
python3 sync/deobf/wad_pool.py --selftest
# SELFTEST PASS oracle='Tamper Detected!' alphabet=85 pool=404 text=20 binary=384

python3 sync/deobf/wad_pool.py sync/upstream/ref/draconic_evade.lua            # recovered text
python3 sync/deobf/wad_pool.py sync/upstream/ref/draconic_evade.lua --json --out /tmp/pool.json
```

Recovered text is the VM's own vocabulary (`tonumber`, `tostring`, `char`, `newproxy`,
`getmetatable`, `_ENV`, `__gc`, ...). The other 384 pool entries are the **second layer**:
byte histogram is 0x00-heavy with no single-byte-XOR solution, i.e. serialised VM data,
not XOR'd ASCII.

## What is not recovered, and why

The payload is a pseudo-VM, not a simple string-replace obfuscation. Feature strings
(UI labels, service names) are only materialised while that VM dispatches, and dispatch
stops before any Roblox call outside a live executor. Measured, not assumed:

- fake-environment sandbox: `GetService=0`, `HttpGet=0`, `LOAD=0`
- 9 executor identities swept, hook library stripped -> identical behaviour
- plain `lua5.1` + harvester: payload aborts at `attempt to index local 'FT'`, 0 chunks handed to the compiler

So the last step is runtime, not static.

## Runtime harvester (the remaining step)

`sync/deobf/harvest_executor.lua` wraps `load` / `loadstring` / `loadfile` and `string.char`,
runs the untouched payload, and writes:

- `deobf_dump.lua` — every chunk the payload hands to the compiler (long-bracketed, loadable)
- `deobf_strings.txt` — rebuilt strings, deduplicated, longest first

Hooks are restored afterwards and capture state is per-run.

In an executor attached to Roblox:

```lua
loadstring(game:HttpGet("https://raw.githubusercontent.com/Shinzzyak/Reicht/main/sync/deobf/harvest_executor.lua"))()(
    game:HttpGet("https://raw.githubusercontent.com/Shinzzyak/Reicht/main/sync/upstream/ref/draconic_evade.lua")
)
```

or read both files from disk and pass the payload string directly. Output lands in the
executor workspace; without `writefile` it prints in 4 KiB chunks.

## Tests

```sh
python3 sync/deobf/wad_pool.py --selftest
luac5.1 -p sync/deobf/harvest_executor.lua sync/deobf/test_harvest.lua
lua5.1 sync/deobf/test_harvest.lua
# PASS 1 chunks and rebuilt strings captured
# PASS 2 hooks restored
# PASS 3 capture state isolated per run
# PASS 4 real payload harvested without host crash
# ALL HARVESTER TESTS PASSED
```

## GitHub tooling surveyed

Searched for existing WeAreDevs / generic Lua deobfuscators before writing code:

- `Katarsis-Team/WeAreDevs-Deobfuscator` — repository not retrievable (HTTP error) at survey time
- `Fweak/De4Lua` and other "Lua-Deobfuscator" forks — target Luraph v1/v2/v3 and IronBrew-style
  VMs; none implement this payload's `"7"+base85` pool, so they cannot be pointed at it
- Luraph deobfuscators are the wrong tool here: this payload compiles as plain **Lua 5.1**
  (`luac5.1 -p` exit 0), it is not Luraph bytecode

Hence the in-repo decoder: it is the only implementation that decodes this pool, and the
self-test proves it against a string the payload itself contains.
