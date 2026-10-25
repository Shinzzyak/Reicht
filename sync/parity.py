#!/usr/bin/env python3
"""Report menu drift between the vendored upstream snapshot and what we ship.

One command for "what is missing": compares every upstream game against
`games/<same name>.lua` and prints the widgets upstream has that we do not.
Exit code 1 means real drift, so this can gate a commit.

    python3 sync/parity.py            # every upstream game
    python3 sync/parity.py Doors      # one game (substring match)
"""
import sys
from pathlib import Path

sys.path.insert(0, str(Path(__file__).resolve().parent))
from menu_spec import parse  # noqa: E402  (same extractor the smoke tests use)

HERE = Path(__file__).resolve().parent.parent
UPSTREAM = HERE / "sync" / "upstream" / "All Map"


def flat(records):
    return {(r["tab"], r["group"], r["kind"], r["label"]) for r in records}


def main(argv):
    want = (argv[1] if len(argv) > 1 else "").lower()
    if not UPSTREAM.is_dir():
        print(f"missing upstream snapshot: {UPSTREAM}")
        return 2
    drift = 0
    for src in sorted(UPSTREAM.glob("*.lua")):
        if want and want not in src.stem.lower():
            continue
        ours = HERE / "games" / src.name
        if not ours.exists():
            print(f"{src.stem}|NOT BUILT")
            drift += 1
            continue
        up, mine = flat(parse(str(src))), flat(parse(str(ours)))
        missing = sorted(up - mine)
        print(f"{src.stem}|up={len(up)}|ours={len(mine)}|MISSING={len(missing)}")
        for rec in missing[:10]:
            print("   MISS", rec)
        drift += len(missing)
    print(f"\ntotal missing widgets: {drift}")
    return 1 if drift else 0


if __name__ == "__main__":
    sys.exit(main(sys.argv))
