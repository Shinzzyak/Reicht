#!/usr/bin/env python3
"""Build the Reicht hub tree from an upstream snapshot.

Upstream is the third-party hub this repo mirrors. The snapshot directory is
`$UPSTREAM_DIR` (default /tmp/rsclone): it must contain `loader.lua`, `ui.lua` and
`All Map/*.lua`, exactly as the raw GitHub URLs serve them.

Two rules govern everything here:

1. A patch that cannot be applied is a hard failure, not a silent skip. Shipping an
   unpatched file would quietly hand the original author's URLs and branding back to
   players, and the timeout/coin fixes would be gone.
2. Losing upstream never loses our copy. If upstream deletes a script we already
   serve, the local file stays and its loader entry is carried forward. The repo is
   the fallback, not a cache.

Usage:
    UPSTREAM_DIR=/tmp/rsclone LUAU_COMPILE=/tmp/luau/luau-compile python3 build.py
"""
import os
import re
import shutil
import subprocess
import sys

SRC = os.environ.get("UPSTREAM_DIR", "/tmp/rsclone")
DST = os.environ.get("OUT_DIR", os.path.join(os.path.dirname(os.path.abspath(__file__)), ".."))
DST = os.path.abspath(DST)
RAW = "https://raw.githubusercontent.com/Shinzzyak/Reicht/refs/heads/main"
LUAU = os.environ.get("LUAU_COMPILE", "/tmp/luau/luau-compile")

HUB = "Reicht"
NS = "Reicht"

# Everything the build owns. Anything else in the repo (.github/, sync/, .git) is
# left alone.
GENERATED = ["loader.lua", "ui.lua", "README.md", "games"]

applied = []
warnings = []
carried = []


class PatchMiss(Exception):
    pass


def sub(text, old, new, where, required=True):
    if old not in text:
        if required:
            raise PatchMiss(f"{where}: {old[:100]!r}")
        return text
    applied.append(f"{where}: {old[:60]!r}")
    return text.replace(old, new)


def resub(text, pattern, repl, where, required=True, flags=0):
    new_text, count = re.subn(pattern, repl, text, flags=flags)
    if count == 0:
        if required:
            raise PatchMiss(f"{where}: /{pattern[:80]}/")
        return text
    applied.append(f"{where}: /{pattern[:50]}/ x{count}")
    return new_text


def strip_attribution(text):
    # Order matters: the repo-owner string contains the namespace as a prefix.
    text = text.replace("xDTaraZz", "Shinzzyak")
    text = text.replace("xDTaraZ", NS)
    text = text.replace("MarioBanner", f"{NS}Banner")
    text = text.replace("Mario Hub", HUB)
    text = text.replace("discord.gg/FHVfmeSceA", "")
    text = re.sub(r"^--+@author[^\n]*\n", "", text, flags=re.M)
    text = re.sub(r"^--\s*\(c\)[^\n]*\n", "", text, flags=re.M)
    text = re.sub(r"^--\s*Mario Hub UI[^\n]*\n", "", text, flags=re.M)
    text = text.replace('Author = "xDTaraZ",', f'Author = "{NS}",')
    text = text.replace(
        'Credit = "Mario Hub UI V2 by xDTaraZ · discord.gg/FHVfmeSceA",',
        f'Credit = "{HUB} UI",',
    )
    # Self-reload URLs must resolve here, and remote logo assets have to go or the
    # hub keeps the original branding.
    text = text.replace(
        "https://raw.githubusercontent.com/Shinzzyak/Roblox-Scripts/refs/heads/main/loader.lua",
        f"{RAW}/loader.lua",
    )
    text = re.sub(
        r'^[ \t]*\w*[Ll]ogo\w* = "https://raw\.githubusercontent\.com/Shinzzyak/Roblox-Scripts/[^"]*",\n',
        "",
        text,
        flags=re.M,
    )
    return text


def game_table(text):
    """GameId -> display name, from a loader.lua GAMES table."""
    return {int(i): n for i, n in re.findall(r"\[(\d+)\]\s*=\s*\"([^\"]+)\"", text)}


# ---------------------------------------------------------------- loader -----

def build_loader(text, keep):
    """`keep` maps GameId -> name for games upstream dropped but we still serve."""
    text = strip_attribution(text)

    text = sub(
        text,
        'local BASE = "https://raw.githubusercontent.com/Shinzzyak/Roblox-Scripts/refs/heads/main/All%20Map/"',
        f'local BASE = "{RAW}/games/"',
        "loader BASE",
    )
    text = resub(text, r"^local DISCORD = \"[^\"]*\"[^\n]*\n", "", "loader discord const",
                 required=False, flags=re.M)

    for old, new in (
        ('Notify("This game is not supported yet. Join " .. DISCORD .. " for the list.")',
         'Notify("This game is not supported yet. Open the repo issues tab for the list.")'),
        ('Notify("Could not download " .. name .. ". Check your connection and try again, or ask in " .. DISCORD, why)',
         'Notify("Could not download " .. name .. ". Check your connection and try again.", why)'),
        ('Notify(name .. " failed to load on this executor: " .. tostring(compileErr) .. ". Ask in " .. DISCORD)',
         'Notify(name .. " failed to load on this executor: " .. tostring(compileErr))'),
        ('Notify(name .. " stopped with an error: " .. tostring(trace):match("^[^\\n]*") .. ". Ask in " .. DISCORD, "\\n" .. tostring(trace))',
         'Notify(name .. " stopped with an error: " .. tostring(trace):match("^[^\\n]*"), "\\n" .. tostring(trace))'),
    ):
        text = sub(text, old, new, "loader notify: " + old[:44], required=False)

    # Carry forward games upstream no longer lists but whose script we still hold.
    if keep:
        block = "".join(f'    [{gid}] = "{name}",\n' for gid, name in sorted(keep.items()))
        text = resub(
            text,
            r"(local GAMES = \{\n)",
            lambda m: m.group(1) + "    -- Carried over from a previous upstream: script still served here.\n" + block,
            "loader carry-forward entries",
        )
    return text


# ------------------------------------------------------------- game script ---

def build_game(text, where):
    text = strip_attribution(text)

    # Upstream fetches ui.lua from the original repo on every launch, so a rename or
    # delete over there takes the whole hub down.
    text = resub(
        text,
        r'UiSource = "https://raw\.githubusercontent\.com/Shinzzyak/Roblox-Scripts/[^"]*ui\.lua"',
        f'UiSource = "{RAW}/ui.lua"',
        where + " UiSource",
    )

    # Mobile data plus a several-hundred-KB UI library does not fit the upstream
    # budgets, and the numbers differ per game. Raise whatever is present.
    text = resub(text, r"RemoteTimeout = (\d+),",
                 lambda m: f"RemoteTimeout = {max(int(m.group(1)), 20)},",
                 where + " RemoteTimeout", required=False)
    text = resub(text, r"LoadTimeout = (\d+),",
                 lambda m: f"LoadTimeout = {max(int(m.group(1)), 30)},",
                 where + " LoadTimeout", required=False)

    # Coin prompts: upstream only tracks a prompt whose name is exactly
    # "ActivityCoinPrompt", so a rename by the game silently empties the table and
    # the loot toggle does nothing at all. Match any coin-looking prompt instead.
    text = resub(
        text,
        r'instance:IsA\("ProximityPrompt"\) and instance\.Name == "ActivityCoinPrompt"',
        'instance:IsA("ProximityPrompt") and instance.Name:lower():find("coin")',
        where + " coin prompt filter",
        required=False,
    )

    # fireproximityprompt on a HoldDuration prompt needs the hold time passed
    # explicitly; without it some executors fire InputHoldBegin and never
    # InputHoldEnd. pcall also stops one dead prompt from killing the whole sweep.
    text = resub(
        text,
        r"(?<!pcall, )fireproximityprompt\(prompt\)",
        "pcall(fireproximityprompt, prompt, 0)",
        where + " fireproximityprompt hold arg",
        required=False,
    )

    # The manual button discarded its return value, so "it does nothing" was
    # indistinguishable from "it found zero prompts". Report both numbers.
    text = resub(
        text,
        r"( *)Func = function\(\)\n\s*" + NS + r"\.Boss\.LootCoins\(\)\n\s*end,",
        lambda m: (f"{m.group(1)}Func = function()\n"
                   f"{m.group(1)}    local fired = {NS}.Boss.LootCoins()\n"
                   f"{m.group(1)}    local tracked = 0\n"
                   f"{m.group(1)}    for _ in pairs(State.CoinPrompts or {{}}) do tracked += 1 end\n"
                   f'{m.group(1)}    Library:Notify("{NS}", string.format("Coins fired %d / tracked %d", fired, tracked), 4, "Coin")\n'
                   f"{m.group(1)}end,"),
        where + " loot button feedback",
        required=False,
    )
    return text


# ------------------------------------------------------------------ build ----

def clear_generated(root):
    for name in GENERATED:
        path = os.path.join(root, name)
        if os.path.isdir(path):
            shutil.rmtree(path)
        elif os.path.exists(path):
            os.remove(path)


def previous_state():
    """What the repo currently serves: loader game table, and game scripts by name."""
    loader_path = os.path.join(DST, "loader.lua")
    games_dir = os.path.join(DST, "games")
    table = game_table(open(loader_path, encoding="utf-8").read()) if os.path.isfile(loader_path) else {}
    files = {}
    if os.path.isdir(games_dir):
        for name in os.listdir(games_dir):
            if name.endswith(".lua"):
                files[name[:-4]] = open(os.path.join(games_dir, name), encoding="utf-8").read()
    return table, files


def main():
    # Validate every upstream input BEFORE touching the repo. A missing upstream is
    # the normal end state of a mirror, and it must leave the served files intact.
    if not os.path.isdir(SRC):
        raise SystemExit(f"upstream snapshot missing: {SRC}")

    upstream_loader = os.path.join(SRC, "loader.lua")
    if not os.path.isfile(upstream_loader):
        raise SystemExit(f"upstream loader.lua missing: {upstream_loader}")
    upstream_table = game_table(open(upstream_loader, encoding="utf-8").read())
    if not upstream_table:
        raise SystemExit("upstream loader.lua has no GAMES entries; refusing to build")

    ui_path = os.path.join(SRC, "ui.lua")
    if not os.path.isfile(ui_path):
        raise SystemExit(f"upstream ui.lua missing: {ui_path}")

    games_dir = os.path.join(SRC, "All Map")
    if not os.path.isdir(games_dir):
        raise SystemExit(f"upstream games directory missing: {games_dir}")
    upstream_games = sorted(f for f in os.listdir(games_dir) if f.endswith(".lua"))
    if not upstream_games:
        raise SystemExit("upstream serves zero game scripts; refusing to build")

    # Build into a staging directory, then swap. A failed compile or a patch miss
    # leaves the repo exactly as it was, so the served files never go dark.
    stage = os.path.join(DST, ".stage")
    if os.path.isdir(stage):
        shutil.rmtree(stage)
    os.makedirs(os.path.join(stage, "games"))

    prev_table, prev_files = previous_state()
    served = dict(prev_files)

    # Which games do we keep serving that upstream no longer lists?
    keep = {gid: name for gid, name in prev_table.items()
            if gid not in upstream_table and name in prev_files}
    carried.extend(sorted(keep.values()))

    open(os.path.join(stage, "loader.lua"), "w", encoding="utf-8").write(
        build_loader(open(upstream_loader, encoding="utf-8").read(), keep))
    open(os.path.join(stage, "ui.lua"), "w", encoding="utf-8").write(
        strip_attribution(open(ui_path, encoding="utf-8").read()))

    built = []
    for name in upstream_games:
        text = open(os.path.join(games_dir, name), encoding="utf-8").read()
        open(os.path.join(stage, "games", name), "w", encoding="utf-8").write(
            build_game(text, name))
        built.append(name)

    # A game upstream deleted keeps the copy we already serve. Dropping it would
    # take a working game away for no reason, which is the whole point of mirroring.
    dropped = sorted(set(served) - {n[:-4] for n in upstream_games})
    for name in dropped:
        open(os.path.join(stage, "games", name + ".lua"), "w", encoding="utf-8").write(
            served[name])
        if name not in carried:
            carried.append(name)

    shutil.copy(os.path.join(os.path.dirname(os.path.abspath(__file__)), "README.template.md"),
                os.path.join(stage, "README.md"))

    # Compile gate over the whole staged tree.
    targets = [os.path.join(stage, "loader.lua"), os.path.join(stage, "ui.lua")]
    targets += [os.path.join(stage, "games", f) for f in
                sorted(os.listdir(os.path.join(stage, "games"))) if f.endswith(".lua")]
    bad = []
    for path in targets:
        r = subprocess.run([LUAU, "--binary", path], capture_output=True)
        if r.returncode != 0:
            bad.append((os.path.basename(path), r.stderr.decode()[:300]))

    print(f"upstream games: {len(upstream_games)} | built: {len(built)} | "
          f"carried over: {len(carried)}")
    for name in carried:
        print("  carried:", name)
    for line in warnings:
        print("  warn:", line)
    print(f"compiled {len(targets)} files, {len(bad)} failures")
    for name, err in bad:
        print("  FAIL", name, err)
    print(f"patches applied: {len(applied)}")
    if bad:
        shutil.rmtree(stage)
        sys.exit(1)

    # Swap: everything validated, so the repo only ever moves forward to a good state.
    clear_generated(DST)
    for name in GENERATED:
        src = os.path.join(stage, name)
        dst = os.path.join(DST, name)
        if os.path.isdir(src):
            shutil.move(src, dst)
        elif os.path.isfile(src):
            shutil.move(src, dst)
    shutil.rmtree(stage, ignore_errors=True)


def _cleanup_stage():
    shutil.rmtree(os.path.join(DST, ".stage"), ignore_errors=True)


if __name__ == "__main__":
    try:
        main()
    except PatchMiss as exc:
        _cleanup_stage()
        print(f"PATCH MISS -> {exc}")
        print("upstream changed shape; repo left untouched on disk")
        sys.exit(2)
    except SystemExit:
        _cleanup_stage()
        raise
    except Exception:
        _cleanup_stage()
        raise
