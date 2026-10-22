# Reicht Hub

A Luau script hub for the games listed in `loader.lua`. One loader, one UI library,
one script per game, all fetched over HTTP at runtime.

## Usage

```lua
loadstring(game:HttpGet("https://raw.githubusercontent.com/Shinzzyak/Reicht/refs/heads/main/loader.lua"))()
```

The loader waits for the game to load, reads `game.GameId`, and pulls the matching
script from `games/`. A game that is not in the table gets a notification and nothing
else happens.

## Layout

```
loader.lua          entry point; maps GameId to a script
ui.lua              the UI library every game script loads
games/<name>.lua    one script per game
```

Each `games/*.lua` is standalone: it fetches `ui.lua` itself and builds its own menu.
Nothing is shared in memory between games, so one broken script cannot take the loader
down for another game.

## Requirements

Any executor that provides `game:HttpGet`, `loadstring`, and the usual hook surface.
`fireproximityprompt` is needed for prompt-driven features and `setthreadidentity(2)`
for features that `require()` game modules; both are capability-probed before the
option is allowed on, and a missing one shows up as a notification instead of a
silently dead toggle.

## Adding a game

1. Put `games/<Display Name>.lua` in place. The file name must match the string in
   the `GAMES` table exactly, spaces included — the loader percent-encodes it.
2. Add `[<GameId>] = "<Display Name>"` to `GAMES` in `loader.lua`.
3. Make the script start with a guard, `if game.GameId ~= <GameId> then return end`,
   so a wrong entry cannot run against the wrong place.
4. Compile it before committing:

```bash
luau-compile --binary games/"<Display Name>.lua"
```

## Notes

- Scripts are fetched on every launch, so a change here reaches players without them
  updating anything. The flip side: a broken push breaks everyone at once. Compile
  before pushing.
- The UI library is fetched per game script, not by the loader. A 300 KB+ download on
  mobile data needs a timeout budget in the tens of seconds, not single digits.

## Mirror behaviour

This repo tracks an upstream hub and re-applies a patch set on top of it. The sync runs
from `.github/workflows/sync.yml` every six hours, and can be triggered by hand:

```bash
gh workflow run sync-upstream --ref main                      # mirror current upstream
gh workflow run sync-upstream -f ref=<sha> -f force=true      # pin to an older commit
```

What the sync guarantees:

- **A failed sync changes nothing.** The build stages into `.stage/`, compiles every file
  with `luau-compile`, and only swaps into the repo on a clean pass. A patch that no
  longer applies, a compile error, or a half-downloaded upstream all exit non-zero with
  the served files exactly as they were.
- **Upstream deleting something does not delete it here.** If a game script disappears
  upstream, the copy already committed stays, and its `GAMES` entry is carried forward
  so the loader keeps routing to it. Upstream vanishing entirely is just a failed sync.
- **A failed sync opens an issue** labelled `sync` with the tail of the log, so a silent
  breakage becomes visible instead of the mirror quietly going stale.

Patches live in `sync/build.py`, each as a literal string or regex replace that raises if
it cannot be applied. Adding a patch means adding a rule there, not editing the generated
files by hand — the next sync would overwrite them.

To rebuild locally without GitHub:

```bash
UPSTREAM_DIR=/tmp/upstream LUAU_COMPILE=/path/to/luau-compile bash sync/pull-upstream.sh
```
