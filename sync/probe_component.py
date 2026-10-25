#!/usr/bin/env python3
"""Run a vendor component under the smoke harness and record the menu it builds.

The Abysall menu components ship as bytecode VMs; the New/Info/Settings tabs
cannot be read out of the source. They can still be *run*: the harness in
sync/smoke.py mocks Roblox and loads the real ui.lua, so the component believes
it is inside an executor. Everything it registers lands in the harness recorder.

    python3 sync/probe_component.py /tmp/abyc/SettingsTab.luau [--apply ApplySettingsTab]
"""
from __future__ import annotations

import argparse
import re
import subprocess
import sys
import tempfile
from pathlib import Path

ROOT = Path(__file__).resolve().parent.parent
sys.path.insert(0, str(ROOT / "sync"))

import smoke  # noqa: E402

LUAU = str(ROOT.parent / "tools" / "luau" / "luau")
if not Path(LUAU).exists():
    LUAU = "/tmp/luau/luau"

DRIVER = r"""
-- probe: build a window, hand it to the vendor component, let the recorder print.
local Library = (function()
    local chunk = loadstring(game:HttpGet("https://reicht.local/ui.lua"))
    return chunk()
end)()
assert(type(Library) == "table", "ui.lua did not return a library")

_G_WINDOW = Library:CreateWindow({
    Title = "Probe", SubTitle = "capture", Footer = "dsc.gg/probe",
    MenuKey = Enum.KeyCode.RightShift, ConfigFolder = "Probe",
    Language = "Auto", Theme = "Dark", Size = Vector2.new(640, 480),
})

local function spy(name)
    local store = {}
    return setmetatable(store, { __index = function(_, key)
        return function(_, ...)
            local args = table.pack(...)
            local bits = {}
            for i = 1, args.n do
                local v = args[i]
                bits[i] = type(v) == "table" and ("<" .. tostring(v.Name or "table") .. ">") or tostring(v)
            end
            print("CALL|" .. name .. "." .. tostring(key) .. "|" .. table.concat(bits, ","))
        end
    end })
end

_ABYSALL = {
    TotalExecutions = 4242,
    Environment = {
        identifyexecutor = function() return "ProbeExecutor", "9.9" end,
        Results = { "<probe: fine>" },
        cloneref = function(o) return o end,
    },
    Interface = {
        Library = Library,
        SaveManager = spy("SaveManager"),
        ThemeManager = spy("ThemeManager"),
    },
}
Abysall = _ABYSALL

local function report(tag)
    local tabs = 0
    if type(_G_WINDOW.Tabs) == "table" then tabs = #_G_WINDOW.Tabs end
    local opts = 0
    if type(Library.Options) == "table" then for _ in pairs(Library.Options) do opts = opts + 1 end end
    print("STATE|" .. tag .. "|tabs=" .. tabs .. "|opts=" .. opts)
end

local fn = loadstring(COMPONENT_SOURCE)
print("GETFENV|" .. tostring(getfenv) .. "|BUFFER|" .. tostring(buffer))

-- Roblox surface the vendor components expect but the smoke mock does not carry.
pcall(function()
    local players = game:GetService("Players")
    players.GetUserThumbnailAsync = function() return "rbxassetid://0" end
    players.GetUserIdFromNameAsync = function() return 1 end
end)

report("before")
local okLoad, module = pcall(fn)
print("LOAD|" .. tostring(okLoad) .. "|" .. type(module) .. "|" .. tostring(module))
if type(module) == "function" then
    local okApply, err = pcall(module, _G_WINDOW)
    print("APPLY|" .. tostring(okApply) .. "|" .. tostring(err))
end
report("after")

local function pick(child)
    if type(child) ~= "table" then return "" end
    if type(child.Info) == "table" then
        for _, k in ipairs({ "Text", "Name", "Title", "Content", "Description" }) do
            if type(child.Info[k]) == "string" then return child.Info[k] end
        end
    end
    if type(child.Row) == "table" and type(child.Row.Info) == "table" then
        for _, k in ipairs({ "Text", "Title", "Description" }) do
            if type(child.Row.Info[k]) == "string" then return child.Row.Info[k] end
        end
    end
    if type(child.Info) == "string" then return child.Info end
    return ""
end

local function manifest()
    local tabs = _G_WINDOW.Tabs
    if type(tabs) ~= "table" then return end
    for ti, tab in ipairs(tabs) do
        print("MNF|TAB|" .. ti .. "|" .. tostring(tab.Name or tab.Title or ("tab" .. ti)))
        for gi, box in ipairs(tab.Groupboxes or {}) do
            print("MNF|GROUP|" .. ti .. "." .. gi .. "|" .. tostring(box.Name or box.GroupName or box.SearchTitle or ""))
            for ii, item in ipairs(box.Items or {}) do
                local child = item.Child
                local kind = (type(child) == "table" and tostring(child.Type or "?")) or "?"
                print("MNF|ROW|" .. ti .. "." .. gi .. "." .. ii .. "|" .. kind .. "|" .. pick(child))
            end
        end
    end
end
manifest()
"""


def build(component_src: str) -> str:
    level = 0
    while "]" + "=" * level + "]" in component_src:
        level += 1
    long_src = "[" + "=" * level + "[" + component_src + "]" + "=" * level + "]"
    driver = DRIVER.replace("COMPONENT_SOURCE", long_src)
    # SCRIPT_SOURCE is used raw inside loadstring(...), so the driver has to arrive
    # as a long-bracket literal, exactly like smoke.main() does with the game source.
    wrap = 0
    while "]" + "=" * wrap + "]" in driver:
        wrap += 1
    driver_literal = "[" + "=" * wrap + "[" + driver + "]" + "=" * wrap + "]"
    script = smoke.HARNESS
    for token, value in (
        ("SCRIPT_SOURCE", driver_literal),
        ("GAME_ID", "3647333358"),
        ("__RS_PATHS__", "{}"),
        ("__REMOTE_PAIRS__", "{}"),
        ("__STRICT_WFC__", "false"),
        ("__NO_FPP__", "true"),
        ("__NO_MAINUI__", "false"),
        ("__FRAMES__", "30"),
        ("__WFC_MISS__", "{}"),
        ("__HTTP_BLOCK__", '""'),
        ("__UI_SOURCE__", smoke.lua_long((ROOT / "ui.lua").read_text(encoding="utf-8"))),
        ("__FBM_SOURCE__", smoke.lua_long("")),
    ):
        script = script.replace(token, value)
    return script


def main() -> int:
    ap = argparse.ArgumentParser()
    ap.add_argument("component")
    ap.add_argument("--keep", action="store_true")
    args = ap.parse_args()
    src = Path(args.component).read_text(encoding="utf-8", errors="replace")
    script = build(src)
    run = Path(tempfile.gettempdir()) / "probe_component.lua"
    run.write_text(script, encoding="utf-8")
    proc = subprocess.run([LUAU, str(run)], capture_output=True, text=True, timeout=300)
    out = proc.stdout
    for line in out.splitlines():
        if re.match(r"^(OPT|BTN|TAB|CALL|LOAD|APPLY|GETFENV|STATE|MNF|kicked|errors|RUNTIME)", line):
            print(line)
    if proc.stderr.strip():
        print("stderr: " + proc.stderr.strip()[:1500])
    if not args.keep:
        run.unlink(missing_ok=True)
    return 0


if __name__ == "__main__":
    raise SystemExit(main())
