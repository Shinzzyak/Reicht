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
