#!/usr/bin/env python3
"""Comment/whitespace stripper for Luau source.

Two levels:
  --level 1 : strip comments + per-line outer whitespace, keep every line break
              (line numbers unchanged)
  --level 2 : level 1, then drop blank lines and join remaining lines

Correctness is not assumed: the caller verifies with luau-compile (level 1 must
produce byte-identical bytecode) and luau-ast (level 2 must produce an identical
AST once source locations are removed).
"""
import sys

LONG_OPEN = "["


def strip(src: str) -> str:
    out = []
    i, n = 0, len(src)

    def long_bracket_level(j):
        """If src[j] opens a long bracket ([, [=[, [==[ ...) return (level, after_open)."""
        if j >= n or src[j] != LONG_OPEN:
            return None
        k = j + 1
        eq = 0
        while k < n and src[k] == "=":
            eq += 1
            k += 1
        if k < n and src[k] == "[":
            return eq, k + 1
        return None

    while i < n:
        c = src[i]

        # long comment  --[[ ... ]] / --[=[ ... ]=]
        if c == "-" and src.startswith("--", i):
            lb = long_bracket_level(i + 2)
            if lb:
                level, body = lb
                close = "]" + "=" * level + "]"
                end = src.find(close, body)
                i = n if end < 0 else end + len(close)
                continue
            end = src.find("\n", i)
            i = n if end < 0 else end  # keep the newline itself
            continue

        # long string
        lb = long_bracket_level(i)
        if lb:
            level, body = lb
            close = "]" + "=" * level + "]"
            end = src.find(close, body)
            end = n if end < 0 else end + len(close)
            out.append(src[i:end])
            i = end
            continue

        # short string
        if c in "\"'":
            j = i + 1
            while j < n:
                if src[j] == "\\":
                    j += 2
                    continue
                if src[j] == c:
                    j += 1
                    break
                if src[j] == "\n":
                    break  # unterminated; bail out defensively
                j += 1
            out.append(src[i:j])
            i = j
            continue

        out.append(c)
        i += 1

    return "".join(out)


def main():
    path = sys.argv[1]
    level = int(sys.argv[2]) if len(sys.argv) > 2 else 1
    src = open(path, encoding="utf-8").read()
    text = strip(src)

    lines = [ln.rstrip() for ln in text.split("\n")]
    if level >= 2:
        lines = [ln for ln in lines if ln.strip()]
    lines = [ln.lstrip() for ln in lines]

    out = "\n".join(lines)
    if src.endswith("\n") and not out.endswith("\n"):
        out += "\n"
    sys.stdout.write(out)


if __name__ == "__main__":
    main()
