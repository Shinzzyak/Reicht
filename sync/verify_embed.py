#!/usr/bin/env python3
"""Prove every embedded copy is byte-identical to the vendored ref it came from.

Covers both layers: the authors' own scripts, and the hub's own pieces (ui.lua,
FloatingButton.lua, the five Abysall components) that used to be fetched at run
time. If this says True the artifact carries the file itself, not a promise.
"""
import hashlib
import json
import os
import sys

ROOT = "/home/ubuntu/reicht-hub"
REFDIR = os.path.join(ROOT, "sync/upstream/ref")
MAN = json.load(open(os.path.join(REFDIR, "manifest.json")))

PAIRS = {
    "games/Doors.lua": [
        "abysall_doors.luau",
        "reicht_ui.lua",
        "abysall_env.luau",
        "abysall_esp.luau",
        "abysall_interface.luau",
        "abysall_16notice.luau",
        "abysall_analytics.luau",
        "abysall_stx.luau",
        "abysall_deathfarm.luau",
    ],
    "games/Evade.lua": [
        "draconic_evade.lua",
        "reicht_ui.lua",
        "reicht_floating.lua",
    ],
}


def main():
    bad = 0
    for artifact, refs in PAIRS.items():
        path = os.path.join(ROOT, artifact)
        raw = open(path, "rb").read()
        print(f"{artifact} ({len(raw)} bytes)")
        for ref in refs:
            want = open(os.path.join(REFDIR, ref), "rb").read()
            embedded = want in raw
            print(f"  {ref:26s} embedded={embedded!s:5s} "
                  f"md5 {hashlib.md5(want).hexdigest()[:10]} {len(want)} bytes")
            if not embedded:
                bad += 1
    print("manifest:", ", ".join(f"{k} {v['md5'][:10]}" for k, v in MAN.items()))
    return 1 if bad else 0


if __name__ == "__main__":
    sys.exit(main())
