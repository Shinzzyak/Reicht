#!/usr/bin/env python3
"""WeAreDevs (WAD) string-pool decoder for the Draconic Evade payload.

The obfuscator stores every string constant as `"7" .. <base85 digits>`.
Digits are looked up in an inline permutation table (85 chars -> 0..84) that
lives in the payload itself, 5 digits -> 4 bytes, big-endian, low-32 masked.

Verified by a known plaintext: the payload's tamper guard string.

    python3 sync/deobf/wad_pool.py --selftest
    python3 sync/deobf/wad_pool.py sync/upstream/ref/draconic_evade.lua
"""
from __future__ import annotations

import argparse
import ast
import json
import pathlib
import re
import sys

CIPHER_PREFIX = "7"
ORACLE = b"Tamper Detected!"


# --- payload parsing -------------------------------------------------------

def _eval_int(expr: str) -> int | None:
    """Evaluate the obfuscator's integer arithmetic (`a%b+c-d`, no names)."""
    expr = expr.strip()
    if not re.fullmatch(r"[0-9%+\-*/() ]+", expr):
        return None
    tree = ast.parse(expr.replace("%", " % "), mode="eval")

    def walk(node):
        if isinstance(node, ast.Expression):
            return walk(node.body)
        if isinstance(node, ast.Constant) and isinstance(node.value, int):
            return node.value
        if isinstance(node, ast.BinOp):
            left, right = walk(node.left), walk(node.right)
            if left is None or right is None:
                return None
            if isinstance(node.op, ast.Add):
                return left + right
            if isinstance(node.op, ast.Sub):
                return left - right
            if isinstance(node.op, ast.Mult):
                return left * right
            if isinstance(node.op, ast.Mod):
                return left % right if right else None
            if isinstance(node.op, ast.Div):
                return left // right if right else None
            return None
        if isinstance(node, ast.UnaryOp):
            value = walk(node.operand)
            return None if value is None else -value
        return None

    return walk(tree)


def lua_unescape(text: str) -> str:
    """Resolve Lua string escapes far enough for pool digits (all ASCII)."""
    out: list[str] = []
    i = 0
    simple = {"\\": "\\", '"': '"', "'": "'", "n": "\n", "t": "\t", "r": "\r", "a": "\a", "b": "\b"}
    while i < len(text):
        char = text[i]
        if char == "\\" and i + 1 < len(text):
            nxt = text[i + 1]
            if nxt in simple:
                out.append(simple[nxt])
                i += 2
                continue
            if nxt.isdigit():
                j = i + 1
                digits = ""
                while j < len(text) and text[j].isdigit() and len(digits) < 3:
                    digits += text[j]
                    j += 1
                out.append(chr(int(digits)))
                i = j
                continue
            out.append(nxt)
            i += 2
            continue
        out.append(char)
        i += 1
    return "".join(out)


def _brace_span(text: str, open_index: int) -> int:
    depth = 0
    in_str = False
    escaped = False
    for j in range(open_index, len(text)):
        char = text[j]
        if in_str:
            if escaped:
                escaped = False
            elif char == "\\":
                escaped = True
            elif char == '"':
                in_str = False
            continue
        if char == '"':
            in_str = True
        elif char == "{":
            depth += 1
        elif char == "}":
            depth -= 1
            if depth == 0:
                return j
    raise ValueError("unbalanced table literal")


def parse_alphabet(source: str) -> dict[str, int]:
    """Pull the 85-entry char->digit permutation out of the payload."""
    anchor = source.find("local C={")
    if anchor < 0:
        raise ValueError("alphabet table 'local C={' not found")
    open_index = source.find("{", anchor)
    close_index = _brace_span(source, open_index)
    body = source[open_index + 1:close_index]

    entry_re = re.compile(
        r'\["((?:[^"\\]|\\.)*)"\]\s*=\s*([0-9%+\-*/() ]+)'
        r"|([A-Za-z0-9_])\s*=\s*([0-9%+\-*/() ]+)"
    )
    table: dict[str, int] = {}
    for match in entry_re.finditer(body):
        if match.group(1) is not None:
            key = lua_unescape(match.group(1))
            value = _eval_int(match.group(2))
        else:
            key = match.group(3)
            value = _eval_int(match.group(4))
        if key and len(key) == 1 and value is not None:
            table[key] = value

    if len(table) != 85 or sorted(table.values()) != list(range(85)):
        raise ValueError("alphabet is not an 85-entry permutation: %d entries" % len(table))
    return table


def parse_pool(source: str) -> list[str]:
    """The ciphertext pool is the first table of the payload, `local m={...}`."""
    match = re.search(r'=\{"' + CIPHER_PREFIX, source)
    if not match:
        raise ValueError("ciphertext pool not found")
    open_index = source.find("{", match.start())
    close_index = _brace_span(source, open_index)
    body = source[open_index + 1:close_index]

    entries: list[str] = []
    current: list[str] = []
    depth = 0
    in_str = False
    escaped = False
    for char in body:
        if in_str:
            current.append(char)
            if escaped:
                escaped = False
            elif char == "\\":
                escaped = True
            elif char == '"':
                in_str = False
            continue
        if char == '"':
            in_str = True
            current.append(char)
            continue
        if char in "{[(":
            depth += 1
        elif char in "}])":
            depth -= 1
        if char in ";," and depth == 0:
            entry = "".join(current).strip()
            if entry:
                entries.append(entry)
            current = []
            continue
        current.append(char)
    tail = "".join(current).strip()
    if tail:
        entries.append(tail)

    pool = []
    for entry in entries:
        if entry.startswith('"') and entry.endswith('"'):
            pool.append(lua_unescape(entry[1:-1]))
    return pool


# --- decoder ---------------------------------------------------------------

def decode_entry(cipher: str, alphabet: dict[str, int]) -> bytes | None:
    """`7<base85>` -> raw bytes. 5 digits per group, big-endian, low 32 bits."""
    body = cipher[len(CIPHER_PREFIX):]
    out = bytearray()
    for i in range(0, len(body), 5):
        group = body[i:i + 5]
        digits = [alphabet.get(char) for char in group]
        if any(d is None for d in digits):
            return None
        value = 0
        for digit in digits:
            value = value * 85 + digit
        raw = [(value >> 24) & 0xFF, (value >> 16) & 0xFF, (value >> 8) & 0xFF, value & 0xFF]
        out += bytes(raw[:len(digits) - 1] if len(digits) < 5 else raw)
    return bytes(out)


def decode_payload(source: str) -> dict:
    alphabet = parse_alphabet(source)
    pool = parse_pool(source)
    decoded = []
    text_count = 0
    for index, cipher in enumerate(pool, start=1):
        raw = decode_entry(cipher, alphabet)
        if raw is None:
            entry = {"index": index, "kind": "unmapped", "raw": ""}
        else:
            try:
                text = raw.decode("utf-8")
                is_text = bool(text) and all(32 <= ord(char) < 127 or char in "\n\t" for char in text)
            except UnicodeDecodeError:
                text, is_text = "", False
            if is_text:
                text_count += 1
                entry = {"index": index, "kind": "text", "raw": text}
            else:
                entry = {"index": index, "kind": "binary", "raw": raw.hex()}
        decoded.append(entry)
    return {
        "alphabet_size": len(alphabet),
        "pool_size": len(pool),
        "text_entries": text_count,
        "binary_entries": sum(1 for e in decoded if e["kind"] == "binary"),
        "entries": decoded,
    }


def text_strings(result: dict) -> list[str]:
    return [e["raw"] for e in result["entries"] if e["kind"] == "text"]


# --- cli -------------------------------------------------------------------

def main(argv: list[str]) -> int:
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument("payload", nargs="?", help="obfuscated payload .lua")
    parser.add_argument("--json", action="store_true", help="emit full JSON")
    parser.add_argument("--selftest", action="store_true", help="verify against the known plaintext")
    parser.add_argument("--out", help="write JSON result here")
    args = parser.parse_args(argv)

    if args.selftest:
        target = pathlib.Path(args.payload or "sync/upstream/ref/draconic_evade.lua")
        if not target.exists():
            print("FAIL no payload at %s" % target, file=sys.stderr)
            return 2
        result = decode_payload(target.read_text(encoding="utf-8", errors="replace"))
        strings = text_strings(result)
        blob = b"\n".join(s.encode("utf-8", "replace") for s in strings)
        if ORACLE not in blob:
            print("FAIL oracle %r missing (decoded %d text strings)" % (ORACLE, len(strings)), file=sys.stderr)
            return 1
        print("SELFTEST PASS oracle=%r alphabet=%d pool=%d text=%d binary=%d"
              % (ORACLE.decode(), result["alphabet_size"], result["pool_size"],
                 result["text_entries"], result["binary_entries"]))
        return 0

    if not args.payload:
        parser.error("payload required unless --selftest")
    result = decode_payload(pathlib.Path(args.payload).read_text(encoding="utf-8", errors="replace"))
    if args.out:
        pathlib.Path(args.out).write_text(json.dumps(result, indent=1), encoding="utf-8")
    if args.json:
        print(json.dumps(result, indent=1))
    else:
        for text in text_strings(result):
            print(text)
        print("-- %d text / %d binary of %d pool entries"
              % (result["text_entries"], result["binary_entries"], result["pool_size"]))
    return 0


if __name__ == "__main__":
    raise SystemExit(main(sys.argv[1:]))
