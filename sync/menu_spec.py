#!/usr/bin/env python3
"""Extract a menu manifest (tab -> groupbox -> widget) from a Lua menu script.

Usage:
    python3 sync/menu_spec.py <file.lua> [--json out.json] [--summary]

Handles both direct chaining (`Window:AddTab(...):AddLeftGroupbox(...)`) and the
assignment style most scripts use (`Tabs.General = Window:AddTab(...)`, then
`Groupboxes.General_Character = Tabs.General:AddLeftGroupbox(...)`), which is why
receiver names are resolved through two maps instead of relying on scan order.
"""
import argparse
import json
import re
import sys

WIDGETS = (
    "AddToggle",
    "AddCheckbox",
    "AddSlider",
    "AddDropdown",
    "AddKeybind",
    "AddKeyPicker",
    "AddColorPicker",
    "AddInput",
    "AddButton",
    "AddLabel",
    "AddDivider",
    "AddImage",
    "AddStepper",
    "AddProgressBar",
    "AddTextbox",
)

RECEIVER = r"(?P<recv>[A-Za-z_][\w.]*|\([^()\n]*\)|(?:\w+\([^()\n]*\)))"
CALL = re.compile(RECEIVER + r"\s*:\s*(?P<kind>Add[A-Za-z]+)\s*\(", re.S)
ASSIGN = re.compile(r"(?P<var>[A-Za-z_][\w.]*)\s*=\s*$")
STR = re.compile(r"\s*(\"((?:[^\"\\]|\\.)*)\"|'((?:[^'\\]|\\.)*)')")


def first_string(text, pos):
    m = STR.match(text, pos)
    if not m:
        return None
    return m.group(2) if m.group(2) is not None else m.group(3)


def norm(recv):
    recv = recv.strip()
    if recv.startswith("("):
        return recv
    return recv


def parse(path):
    text = open(path, encoding="utf-8", errors="replace").read()
    tabs = {}     # receiver expression -> tab name
    groups = {}   # receiver expression -> (tab, group)
    rows = []
    for m in CALL.finditer(text):
        recv = norm(m.group("recv"))
        kind = m.group("kind")
        if kind.endswith("Tab") and kind not in ("AddLeftTabbox", "AddRightTabbox"):
            name = first_string(text, m.end())
            if name is None:
                continue
            label = name
            assign = ASSIGN.search(text[max(0, m.start() - 120):m.start()])
            if assign:
                var = assign.group("var")
                tabs[var] = label
                tabs[var.split(".")[-1]] = label
            else:
                tabs[recv] = label
            continue
        if kind.endswith("Groupbox"):
            name = first_string(text, m.end())
            if name is None:
                continue
            tab = tabs.get(recv) or tabs.get(recv.split(".")[-1]) or "(root)"
            assign = ASSIGN.search(text[max(0, m.start() - 120):m.start()])
            if assign:
                var = assign.group("var")
                groups[var] = (tab, name)
                groups[var.split(".")[-1]] = (tab, name)
            else:
                groups[recv] = (tab, name)
            rows.append({"tab": tab, "group": name, "kind": kind, "label": name})
            continue
        if kind not in WIDGETS:
            continue
        tab, group = groups.get(recv) or groups.get(recv.split(".")[-1]) or ((tabs.get(recv) or tabs.get(recv.split(".")[-1]) or "(root)"), "(root)")
        label = first_string(text, m.end())
        if label is None:
            label = ""
        rows.append({"tab": tab, "group": group, "kind": kind, "label": label})
    return rows


def main():
    ap = argparse.ArgumentParser()
    ap.add_argument("file")
    ap.add_argument("--json")
    ap.add_argument("--summary", action="store_true")
    args = ap.parse_args()
    rows = parse(args.file)
    if args.json:
        json.dump(rows, open(args.json, "w"), indent=1)
    if args.summary:
        stats = {}
        order = []
        for row in rows:
            if row["tab"] not in stats:
                stats[row["tab"]] = {"groups": set(), "widgets": 0}
                order.append(row["tab"])
            if row["kind"].endswith("Groupbox"):
                stats[row["tab"]]["groups"].add((row["tab"], row["group"]))
            else:
                stats[row["tab"]]["widgets"] += 1
        for name in order:
            entry = stats[name]
            print(f"{name}\tgroups={len(entry['groups'])}\twidgets={entry['widgets']}")
        print(f"TOTAL\twidgets={sum(1 for r in rows if not r['kind'].endswith(('Tab', 'Groupbox')))}")
    if not args.summary and not args.json:
        json.dump(rows, sys.stdout, indent=1)
        print()


if __name__ == "__main__":
    main()
