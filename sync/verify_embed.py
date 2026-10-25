#!/usr/bin/env python3
"""Prove the embedded upstream copies are byte-identical to the vendored refs."""
import hashlib
import json
import os
import re
import sys

ROOT = "/home/ubuntu/reicht-hub"
MAN = json.load(open(os.path.join(ROOT, "sync/upstream/ref/manifest.json")))


def extract(path):
    text = open(path, encoding="utf-8", errors="surrogateescape").read()
    out = {}
    for match in re.finditer(r"\[(=*)\[(.*?)\]\1\]", text, re.S):
        body = match.group(2)
        out.setdefault(len(body), []).append(body)
    return out


def main():
    pairs = [("games/Doors.lua", "abysall_doors.luau"),
             ("games/Evade.lua", "draconic_evade.lua")]
    bad = 0
    for artifact, ref in pairs:
        raw = open(os.path.join(ROOT, artifact), "rb").read()
        want = open(os.path.join(ROOT, "sync/upstream/ref", ref), "rb").read()
        embedded = want in raw
        got = len(raw)
        ref_md5 = hashlib.md5(want).hexdigest()[:10]
        print(f"{artifact}: contains {ref} byte-for-byte = {embedded} "
              f"(ref md5 {ref_md5}, {len(want)} bytes, artifact {got} bytes)")
        if not embedded:
            bad += 1
    print("manifest:", ", ".join(f"{k} {v['md5'][:10]}" for k, v in MAN.items()))
    return 1 if bad else 0


if __name__ == "__main__":
    sys.exit(main())
