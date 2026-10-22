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
import json
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


def resub(text, pattern, repl, where, required=True, flags=0, quiet=False):
    new_text, count = re.subn(pattern, repl, text, flags=flags)
    if count == 0:
        if required:
            raise PatchMiss(f"{where}: /{pattern[:80]}/")
        # A soft patch that silently misses is how a "fixed" feature quietly goes
        # back to broken. Record it so the CI log shows the gap -- except for the
        # patches that are meant to apply to some games only.
        if not quiet:
            warnings.append(f"soft patch missed: {where}")
        return text
    applied.append(f"{where}: /{pattern[:50]}/ x{count}")
    return new_text


def add_press_mode(text):
    """Teach the keybind picker a fourth mode, `Press`.

    The picker upstream ships Toggle / Hold / Always. `Press` fires the callback
    once on key-down and ignores the release -- the mode Draconic's own menu uses
    for one-shot actions (lag switch, emote dash). Patched at build time so an
    upstream ui.lua refresh cannot silently drop it.
    """
    text = sub(
        text,
        'Values = { "Toggle", "Hold", "Always" }',
        'Values = { "Toggle", "Hold", "Press", "Always" }',
        "ui.lua press mode: mode menu",
    )
    text = resub(
        text,
        r'(if self\.Mode == "Always" then\n\s*return\n\s*end\n)(\s*)(if self\.Mode == "Hold" then\n\s*self\.Held = down)',
        lambda m: (m.group(1) + m.group(2)
                   + 'if self.Mode == "Press" then\n'
                   + m.group(2) + '    self.Held = down\n'
                   + m.group(2) + '    if not down then\n'
                   + m.group(2) + '        return\n'
                   + m.group(2) + '    end\n'
                   + m.group(2) + '    Util.Try(self.Callback, true)\n'
                   + m.group(2) + '    return\n'
                   + m.group(2) + 'end\n'
                   + m.group(2) + m.group(3)),
        "ui.lua press mode: KeyPicker:Press",
    )
    text = resub(
        text,
        r'(function KeyPicker:GetState\(\)\n\s*if self\.Mode == "Always" then\n\s*return true\n\s*end\n)(\s*)(if self\.Mode == "Hold" then\n\s*return self\.Held\n\s*end)',
        lambda m: (m.group(1) + m.group(2)
                   + 'if self.Mode == "Press" then\n'
                   + m.group(2) + '    return self.Held\n'
                   + m.group(2) + 'end\n'
                   + m.group(2) + m.group(3)),
        "ui.lua press mode: KeyPicker:GetState",
    )
    return text


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

def build_loader(text, keep, extra=None):
    """`keep` maps GameId -> name for games upstream dropped but we still serve.

    `extra` maps GameId -> name for games this repo authors itself. Those are not
    mirrors of anything: upstream has never heard of them.
    """
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
        # Upstream keys the table by universe id and looks it up with game.GameId.
        # Accept the place id too, so a place-only id in extra/games.json still hits.
        ("local name = GAMES[game.GameId]",
         "local name = GAMES[game.GameId] or GAMES[game.PlaceId]"),
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

    # Games this repo ships itself, written here rather than mirrored. Upstream has
    # no entry for them, so they get their own block and their own wording.
    if extra:
        block = "".join(f'    [{gid}] = "{name}",\n' for gid, name in sorted(extra.items()))
        text = resub(
            text,
            r"(local GAMES = \{\n)",
            lambda m: m.group(1) + "    -- Written and maintained in this repo. Not mirrored.\n" + block,
            "loader extra entries",
        )

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
                 where + " RemoteTimeout", required=False, quiet=True)
    text = resub(text, r"LoadTimeout = (\d+),",
                 lambda m: f"LoadTimeout = {max(int(m.group(1)), 30)},",
                 where + " LoadTimeout", required=False, quiet=True)

    # Coin prompts: upstream only tracks a prompt whose name is exactly
    # "ActivityCoinPrompt", so a rename by the game silently empties the table and
    # the loot toggle does nothing at all. Match any coin-looking prompt instead.
    text = resub(
        text,
        r'instance:IsA\("ProximityPrompt"\) and instance\.Name == "ActivityCoinPrompt"',
        'instance:IsA("ProximityPrompt") and instance.Name:lower():find("coin")',
        where + " coin prompt filter",
        required=False,
        quiet=True,
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
        quiet=True,
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
        quiet=True,
    )

    # ---------------------------------------------------------- colony replies ---
    # These four only exist in the Build An Ant Empire script. On the ant file they
    # are mandatory: a silent miss here is exactly how the claim loop went dead.
    ant = "ClaimRolledAnt" in text

    # Claim gate compared the offer currency against one hard-coded localised
    # string. Any rename by the game made every claim return false with nothing
    # logged, so rolled ants piled up and the toggle looked dead.
    text = resub(
        text,
        r'if offer\.Currency and offer\.Currency ~= "[^"]*" then return false end',
        'if offer.Currency and type(offer.Currency) == "string"\n'
        '        and offer.Currency ~= "\u91d1\u5e01" and offer.Currency ~= "Gold" and offer.Currency ~= "gold" then\n'
        "        return false\n"
        "    end",
        where + " claim currency tolerance",
        required=ant,
        quiet=not ant,
    )

    # A roll reply replaced the whole pending table, so an offer rolled one tick
    # earlier was destroyed before the claim loop could reach it. Merge and age
    # out instead: an offer stays claimable for 25s.
    text = resub(
        text,
        r"( *)State\.PendingRolls = \{\}\n"
        r"\s*State\.Metrics\.Rolls \+= 1\n"
        r"\s*for _, offer in ipairs\(data\.Results or \{\}\) do\n"
        r"\s*if type\(offer\) == \"table\" and type\(offer\.ClaimId\) == \"string\" then State\.PendingRolls\[offer\.ClaimId\] = offer end\n",
        lambda m: (
            f"{m.group(1)}State.Metrics.Rolls += 1\n"
            f"{m.group(1)}State.RollFails = 0\n"
            f"{m.group(1)}-- Merge, do not replace: an offer from the previous roll is still\n"
            f"{m.group(1)}-- claimable, and wiping the table dropped it silently.\n"
            f"{m.group(1)}local stamp = os.clock()\n"
            f"{m.group(1)}for stale, seen in pairs(State.PendingRolls) do\n"
            f"{m.group(1)}    if stamp - (seen._At or 0) > 25 then State.PendingRolls[stale] = nil end\n"
            f"{m.group(1)}end\n"
            f"{m.group(1)}for _, offer in ipairs(data.Results or {{}}) do\n"
            f"{m.group(1)}    if type(offer) == \"table\" and type(offer.ClaimId) == \"string\" then\n"
            f"{m.group(1)}        offer._At = stamp\n"
            f"{m.group(1)}        State.PendingRolls[offer.ClaimId] = offer\n"
            f"{m.group(1)}    end\n"
        ),
        where + " pending roll merge",
        required=ant,
        quiet=not ant,
    )

    # BuildEntry expects the live BackpackModel as self. A hand-built self can
    # throw, and an unguarded throw took down the entire claim pass with it.
    text = resub(
        text,
        r"( *)local entry = backpack and " + NS + r"\.GameLib\.Call\(backpack\.BuildEntry, backpack, \{\n"
        r"\s*Ecs = \{ Context = " + NS + r"\.GameLib\.Apis\.Context \},\n"
        r"\s*\}, \"Backpack\", offer\.V, 1, 0\)\n"
        r"\s*offers\[#offers \+ 1\] = \{ Id = claimId, Offer = offer, Attack = entry and entry\.Attack or 0 \}\n",
        lambda m: (
            f"{m.group(1)}local built, entry = pcall({NS}.GameLib.Call, backpack and backpack.BuildEntry,\n"
            f"{m.group(1)}    backpack, {{ Ecs = {{ Context = {NS}.GameLib.Apis.Context }} }}, \"Backpack\", offer.V, 1, 0)\n"
            f"{m.group(1)}local attack = built and type(entry) == \"table\" and tonumber(entry.Attack)\n"
            f"{m.group(1)}    or tonumber(offer.Attack) or 0\n"
            f"{m.group(1)}offers[#offers + 1] = {{ Id = claimId, Offer = offer, Attack = attack }}\n"
        ),
        where + " claim sort guard",
        required=ant,
        quiet=not ant,
    )

    # Rolls were fired every 0.15s with no confirmation and no backoff. When the
    # remote stops answering that is an unbounded spam loop with zero feedback.
    text = resub(
        text,
        r"( *)return " + NS + r"\.Util\.FireEcs\(\"RollAnt\", \{ Source = \"RollModel\" \}\)\n",
        lambda m: (
            f"{m.group(1)}local sent = {NS}.Util.FireEcs(\"RollAnt\", {{ Source = \"RollModel\" }})\n"
            f"{m.group(1)}if not sent then\n"
            f"{m.group(1)}    State.RollFails = (State.RollFails or 0) + 1\n"
            f"{m.group(1)}    State.NextRoll = now + 1\n"
            f"{m.group(1)}    if State.RollFails == 12 then\n"
            f"{m.group(1)}        {NS}.Util.Alert(\"Auto Roll\", \"Rolls are not going through. Close any open purchase prompt.\")\n"
            f"{m.group(1)}    end\n"
            f"{m.group(1)}end\n"
            f"{m.group(1)}return sent\n"
        ),
        where + " roll backoff",
        required=ant,
        quiet=not ant,
    )
    return text


# ------------------------------------------------------------------ build ----

def shrink(minifier, path):
    """Rewrite one staged Lua file with comments and layout removed. Returns bytes saved."""
    before = os.path.getsize(path)
    result = subprocess.run([sys.executable, minifier, path, "2"], capture_output=True)
    if result.returncode != 0:
        raise SystemExit(f"minify failed for {path}: {result.stderr.decode()[:300]}")
    with open(path, "wb") as handle:
        handle.write(result.stdout)
    return before - len(result.stdout)


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


def extra_games():
    """Games authored in this repo: `extra/games.json` maps script stem -> {id, name}."""
    root = os.path.join(os.path.dirname(os.path.abspath(__file__)), "extra")
    manifest = os.path.join(root, "games.json")
    if not os.path.isfile(manifest):
        return {}, root
    with open(manifest, encoding="utf-8") as handle:
        data = json.load(handle)
    table = {int(entry["id"]): entry["name"] for entry in data.values()}
    for stem in data:
        if not os.path.isfile(os.path.join(root, "games", stem + ".lua")):
            raise SystemExit(f"extra/games.json lists {stem} but extra/games/{stem}.lua is missing")
    return table, root


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

    extra_table, extra_root = extra_games()
    extra_stems = {name for name in extra_table.values()}

    clash = set(extra_table) & set(upstream_table)
    if clash:
        raise SystemExit(f"extra/games.json claims game ids upstream already serves: {sorted(clash)}")

    # Which games do we keep serving that upstream no longer lists? A game we author
    # ourselves is never "dropped" -- it is rebuilt from extra/ every time.
    keep = {gid: name for gid, name in prev_table.items()
            if gid not in upstream_table and name in prev_files and name not in extra_stems}
    carried.extend(sorted(keep.values()))

    open(os.path.join(stage, "loader.lua"), "w", encoding="utf-8").write(
        build_loader(open(upstream_loader, encoding="utf-8").read(), keep, extra_table))
    open(os.path.join(stage, "ui.lua"), "w", encoding="utf-8").write(
        add_press_mode(strip_attribution(open(ui_path, encoding="utf-8").read())))

    built = []
    for name in upstream_games:
        text = open(os.path.join(games_dir, name), encoding="utf-8").read()
        open(os.path.join(stage, "games", name), "w", encoding="utf-8").write(
            build_game(text, name))
        built.append(name)

    # Games authored here. They go through the same compile gate and the same
    # minifier, but not through the upstream patch set -- those patterns belong to
    # files we do not own.
    for stem in sorted(extra_table.values()):
        source = os.path.join(extra_root, "games", stem + ".lua")
        shutil.copy(source, os.path.join(stage, "games", stem + ".lua"))
        built.append(stem + ".lua")

    # A game upstream deleted keeps the copy we already serve. Dropping it would
    # take a working game away for no reason, which is the whole point of mirroring.
    dropped = sorted(set(served) - {n[:-4] for n in upstream_games} - extra_stems)
    for name in dropped:
        open(os.path.join(stage, "games", name + ".lua"), "w", encoding="utf-8").write(
            served[name])
        if name not in carried:
            carried.append(name)

    shutil.copy(os.path.join(os.path.dirname(os.path.abspath(__file__)), "README.template.md"),
                os.path.join(stage, "README.md"))

    # Ship lean: comments, blank lines and indentation are ~15% of the payload and
    # a 300 KB+ script on mobile data is the difference between loading and not.
    # Patching happens above on the readable source, so nothing here is lossy for
    # maintenance -- the source of truth is upstream plus this file.
    minify = os.path.join(os.path.dirname(os.path.abspath(__file__)), "minify.py")
    saved = 0
    for name in GENERATED:
        path = os.path.join(stage, name)
        if os.path.isdir(path):
            for entry in os.listdir(path):
                if entry.endswith(".lua"):
                    saved += shrink(minify, os.path.join(path, entry))
        elif path.endswith(".lua") and os.path.isfile(path):
            saved += shrink(minify, path)
    print(f"minified: saved {saved} bytes")

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
