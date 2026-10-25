#!/usr/bin/env python3
"""Build the Reicht hub tree from an upstream snapshot.

Upstream is the third-party hub this repo mirrors. The snapshot lives in
`sync/upstream/` (override with `$UPSTREAM_DIR`): it must contain `loader.lua`,
`ui.lua` and `All Map/*.lua`, exactly as the raw GitHub URLs served them.

The snapshot is vendored because the upstream repo is gone (404 since 2026-10-25)
and /tmp does not survive a reboot. A build that cannot find its snapshot is broken,
so the default points inside the repo, never at a temp directory.

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
import fcntl
import shutil
import subprocess
import sys

SRC = os.environ.get("UPSTREAM_DIR") or os.path.join(
    os.path.dirname(os.path.abspath(__file__)), "upstream"
)
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


def add_button_registry(text):
    """Expose every button on `Library.Buttons`.

    A button keeps its callback in a closure, so nothing outside the widget can
    reach it -- which leaves every button-driven feature untestable by the smoke
    run. One list plus one insert at creation time fixes that.
    """
    text = resub(
        text,
        r'(local Library = \{\n(\s*)Version = "1\.0",\n(\s*)Options = \{\},)',
        lambda m: m.group(1) + "\n" + m.group(2) + "Buttons = {},",
        "ui.lua button registry: list",
    )
    text = resub(
        text,
        r'(\n(\s*)local button = setmetatable\(\{[^\n]*\}, Button\))',
        lambda m: m.group(1) + "\n" + m.group(2) + "table.insert(Library.Buttons, button)",
        "ui.lua button registry: insert",
    )
    return text


def warn_duplicate_ids(text):
    """Warn when two widgets claim the same id.

    Library.Options is keyed by id, so a second widget with an existing id
    silently steals the first one's slot: the toggle keeps working through its
    closure while config save/load quietly targets the wrong widget. A payload
    that reuses an id for a toggle and its paired input hits this exactly.
    """
    text = resub(
        text,
        r"(\n(\s*)if idx ~= nil then\n\s*Library\.Options\[idx\] = option)",
        lambda m: (m.group(1).replace("Library.Options[idx] = option",
                                      "if Library.Options[idx] then\n"
                                      + m.group(2) + "    warn(\"[Reicht] duplicate widget id: \" .. tostring(idx))\n"
                                      + m.group(2) + "end\n"
                                      + m.group(2) + "Library.Options[idx] = option")),
        "ui.lua duplicate id warning",
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

VD_EXTRA = r"""
-- Merge layer: the hub shipped without these, and every one of them is local-only.
-- Nothing here invents a remote name, so a game update cannot turn these into
-- silent no-ops the way a guessed remote does.
Reicht.Extra = { FlyBody = nil, FreeCamAt = nil, WarnAt = 0 }
Reicht.Extra.Defaults = {
Fly = false, FlySpeed = 60,
FreeCam = false, FreeCamSpeed = 40,
FieldOfView = 70, JumpPower = 50,
FpsBoost = false, KillerWarn = false, DangerDistance = 60,
EspMaxDistance = 0, EspTextSize = 13,
}
function Reicht.Extra.Seed()
for key, value in pairs(Reicht.Extra.Defaults) do
if Reicht.Options[key] == nil then Reicht.Options[key] = value end
end
end
function Reicht.Extra.Direction(look, right)
local dx, dy, dz = 0, 0, 0
local function add(vector, sign)
dx = dx + vector.X * sign
dy = dy + vector.Y * sign
dz = dz + vector.Z * sign
end
local up = vector3New(0, 1, 0)
if UserInputService:IsKeyDown(Enum.KeyCode.W) then add(look, 1) end
if UserInputService:IsKeyDown(Enum.KeyCode.S) then add(look, -1) end
if UserInputService:IsKeyDown(Enum.KeyCode.D) then add(right, 1) end
if UserInputService:IsKeyDown(Enum.KeyCode.A) then add(right, -1) end
if UserInputService:IsKeyDown(Enum.KeyCode.Space) then add(up, 1) end
if UserInputService:IsKeyDown(Enum.KeyCode.LeftControl) then add(up, -1) end
local length = math.sqrt(dx * dx + dy * dy + dz * dz)
if length > 0 then dx, dy, dz = dx / length, dy / length, dz / length end
return vector3New(dx, dy, dz)
end
function Reicht.Extra.FlyRelease()
local body = Reicht.Extra.FlyBody
Reicht.Extra.FlyBody = nil
if body then pcall(function() body:Destroy() end) end
local humanoid = Reicht.Player.Humanoid
if humanoid then pcall(function() humanoid.PlatformStand = false end) end
end
function Reicht.Extra.Fly()
if not Reicht.Options.Fly then Reicht.Extra.FlyRelease() return end
local hrp = Reicht.Player.Root
if not hrp then return end
local body = Reicht.Extra.FlyBody
if not body or not body.Parent then
body = Instance.new("BodyVelocity")
body.Name = "ReichtFly"
body.MaxForce = vector3New(mathHuge, mathHuge, mathHuge)
body.Parent = hrp
Reicht.Extra.FlyBody = body
end
local camera = Workspace.CurrentCamera
local look = camera and camera.CFrame.LookVector or vectorZero
local right = camera and camera.CFrame.RightVector or vectorZero
local direction = Reicht.Extra.Direction(look, right)
body.Velocity = direction * (Reicht.Options.FlySpeed or 60)
local humanoid = Reicht.Player.Humanoid
if humanoid then humanoid.PlatformStand = true end
end
function Reicht.Extra.FreeCam()
local camera = Workspace.CurrentCamera
if not camera then return end
if not Reicht.Options.FreeCam then
if Reicht.Extra.FreeCamAt then
Reicht.Extra.FreeCamAt = nil
pcall(function() camera.CameraType = Enum.CameraType.Custom end)
end
return
end
local current = camera.CFrame
Reicht.Extra.FreeCamAt = Reicht.Extra.FreeCamAt or current
pcall(function() camera.CameraType = Enum.CameraType.Scriptable end)
local direction = Reicht.Extra.Direction(current.LookVector, current.RightVector)
local speed = Reicht.Options.FreeCamSpeed or 40
camera.CFrame = cframeNew(current.Position + direction * speed)
end
function Reicht.Extra.ApplyCamera()
local camera = Workspace.CurrentCamera
if camera then camera.FieldOfView = Reicht.Options.FieldOfView or 70 end
end
function Reicht.Extra.ApplyBody()
local humanoid = Reicht.Player.Humanoid
if not humanoid then return end
pcall(function() humanoid.UseJumpPower = true end)
humanoid.JumpPower = Reicht.Options.JumpPower or 50
end
function Reicht.Extra.ApplyGraphics()
local on = Reicht.Options.FpsBoost and true or false
Lighting.GlobalShadows = not on
pcall(function() Lighting:SetAttribute("ReichtFpsBoost", on) end)
if on then pcall(setfpscap, 60) end
end
function Reicht.Extra.Warn()
if not Reicht.Options.KillerWarn then return end
local killer = Reicht.Player.Killer()
local hrp = Reicht.Player.Root
local character = killer and killer.Character
local target = character and character:FindFirstChild("HumanoidRootPart")
if not hrp or not target then return end
local distance = (target.Position - hrp.Position).Magnitude
if distance > (Reicht.Options.DangerDistance or 60) then return end
if osClock() - Reicht.Extra.WarnAt < 4 then return end
Reicht.Extra.WarnAt = osClock()
Library:Notify(T("Danger", "อันตราย"), (T("Killer %d studs away", "ฆาตกรห่าง %d สตัด")):format(math.floor(distance)), 3, "Warning")
end
function Reicht.Extra.EspLimits()
local hrp = Reicht.Player.Root
local maxDistance = Reicht.Options.EspMaxDistance or 0
local size = Reicht.Options.EspTextSize or 13
for _, mark in pairs(Reicht.Esp.Marks) do
if mark.Text then mark.Text.TextSize = size end
if mark.Board then
local part = mark.Board.Adornee
if maxDistance > 0 and hrp and part then
mark.Board.Enabled = (part.Position - hrp.Position).Magnitude <= maxDistance
else
mark.Board.Enabled = true
end
end
end
end
function Reicht.Extra.Step()
Util.Try("extra fly", Reicht.Extra.Fly)
Util.Try("extra freecam", Reicht.Extra.FreeCam)
Util.Try("extra killer warning", Reicht.Extra.Warn)
Util.Try("extra esp limits", Reicht.Extra.EspLimits)
end
function Reicht.UI.BuildExtra(window)
Reicht.Extra.Seed()
local tab = window:AddTab(T("Extra", "เพิ่มเติม"), "sparkles", T("Flight, camera and limits", "บิน กล้อง และขีดจำกัด"))
local flight = tab:AddLeftGroupbox(T("Flight", "การบิน"), "zap")
flight:AddToggle("Fly", { Text = T("Fly", "บิน"), Description = T("Camera-relative flight, Space up and Ctrl down", "บินตามทิศกล้อง Space ขึ้น Ctrl ลง"), Callback = function(value)
Reicht.Options.Fly = value
Reicht.Extra.Fly()
end }):AddKeyPicker("FlyKey", { Default = "None", Mode = "Toggle" })
flight:AddSlider("FlySpeed", { Text = T("Fly speed", "ความเร็วบิน"), Min = 20, Max = 200, Default = 60, Callback = function(value) Reicht.Options.FlySpeed = value end })
local view = tab:AddLeftGroupbox(T("Camera", "กล้อง"), "eye")
view:AddToggle("FreeCam", { Text = T("Free cam", "กล้องอิสระ"), Description = T("Detaches the camera from your body", "แยกกล้องออกจากตัว"), Callback = function(value)
Reicht.Options.FreeCam = value
Reicht.Extra.FreeCam()
end })
view:AddSlider("FreeCamSpeed", { Text = T("Free cam speed", "ความเร็วกล้อง"), Min = 10, Max = 120, Default = 40, Callback = function(value) Reicht.Options.FreeCamSpeed = value end })
view:AddSlider("FieldOfView", { Text = T("Field of view", "องศามอง"), Min = 40, Max = 120, Default = 70, Callback = function(value)
Reicht.Options.FieldOfView = value
Reicht.Extra.ApplyCamera()
end })
local body = tab:AddRightGroupbox(T("Body", "ร่างกาย"), "user")
body:AddSlider("JumpPower", { Text = T("Jump power", "พลังกระโดด"), Min = 50, Max = 300, Default = 50, Callback = function(value)
Reicht.Options.JumpPower = value
Reicht.Extra.ApplyBody()
end })
body:AddToggle("FpsBoost", { Text = T("FPS boost", "เพิ่ม FPS"), Description = T("Drops shadows and caps the frame rate", "ปิดเงาและจำกัดเฟรมเรต"), Callback = function(value)
Reicht.Options.FpsBoost = value
Reicht.Extra.ApplyGraphics()
end })
body:AddToggle("KillerWarn", { Text = T("Killer proximity warning", "เตือนเมื่อฆาตกรใกล้"), Callback = function(value)
Reicht.Options.KillerWarn = value
Reicht.Extra.Warn()
end })
body:AddSlider("DangerDistance", { Text = T("Warn distance", "ระยะเตือน"), Min = 10, Max = 200, Default = 60, Callback = function(value) Reicht.Options.DangerDistance = value end })
local limits = tab:AddRightGroupbox(T("ESP limits", "ขีดจำกัด ESP"), "eye")
limits:AddSlider("EspMaxDistance", { Text = T("ESP max distance", "ระยะ ESP สูงสุด"), Description = T("0 keeps every tag, any other value hides the far ones", "0 = แสดงทั้งหมด"), Min = 0, Max = 2000, Default = 0, Callback = function(value)
Reicht.Options.EspMaxDistance = value
Reicht.Extra.EspLimits()
end })
limits:AddSlider("EspTextSize", { Text = T("ESP text size", "ขนาดตัวอักษร ESP"), Min = 8, Max = 28, Default = 13, Callback = function(value)
Reicht.Options.EspTextSize = value
Reicht.Extra.EspLimits()
end })
limits:AddButton({ Text = T("Copy Job ID", "คัดลอก Job ID"), Func = Reicht.UI.Detach(function()
if Util.Copy(game.JobId) then
Library:Notify(T("Job ID", "Job ID"), T("Copied", "คัดลอกแล้ว"), 3, "Success")
else
Library:Notify(T("Job ID", "Job ID"), tostring(game.JobId), 6, "Info")
end
end) })
end
"""


def violence_district_extra(text, where):
    """Fold the features this repo adds on top of upstream Violence District.

    Kept in build.py rather than in the upstream file: upstream stays authoritative
    for everything it already ships, and this block is only ever additive.
    """
    text = sub(text, "function Reicht.UI.BuildMain(window)", VD_EXTRA + "\nfunction Reicht.UI.BuildMain(window)", where + " extra module")
    text = sub(
        text,
        'for _, section in ipairs({ "BuildMain", "BuildSurvivor", "BuildKiller", "BuildPlayer", "BuildShop", "BuildVisuals" }) do',
        'for _, section in ipairs({ "BuildMain", "BuildSurvivor", "BuildKiller", "BuildPlayer", "BuildShop", "BuildVisuals", "BuildExtra" }) do',
        where + " extra tab",
    )
    text = sub(
        text,
        "Library:Every(Reicht.Config.StatusInterval, Reicht.UI.Pump)",
        "Library:Every(Reicht.Config.StatusInterval, Reicht.UI.Pump)\nLibrary:Every(0.2, function() Util.Try(\"extra\", Reicht.Extra.Step) end)",
        where + " extra loop",
    )
    return text


def build_game(text, where):
    text = strip_attribution(text)
    if where == "Violence District.lua":
        text = violence_district_extra(text, where)

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



MINIMAL_THEME = """
-- Reicht minimal theme. Appended after the upstream config so an upstream refresh
-- cannot quietly bring the seasonal chrome back. Every field below is an upstream
-- name: we retune their knobs instead of forking their renderer.
do
    Config.SeasonTheme = "Minimal"
    Config.Particles.Count = 0

    Themes.Minimal = Palette({
        Backdrop = "0E1014", BackdropAlt = "12151A", Topbar = "14181E",
        Sidebar = "11141A", SidebarAlt = "161A21",
        SidebarText = "E7E9ED", SidebarMuted = "8B929E",
        TabActive = "1F242C", TabActiveText = "FFFFFF",
        Panel = "161A21", PanelHeader = "1A1F27", Element = "1E232B", Hover = "252B34",
        Outline = "262C35", Shadow = "000000",
        Text = "E8EAEE", SubText = "A5ACB8", Muted = "6E7581", Track = "262C35",
        Cloud = "0E1014", CloudAlpha = 0,
        Accent = "D64C40", AccentDark = "A0342C",
        Grass = "1A1F27", GrassDark = "14181E", Brick = "1E232B", BrickDark = "14181E",
        Decor = { "None" },
        Particle = { ".", false, "262C35" },
    })
    table.insert(Themes.Order, 1, "Minimal")

    local W = Config.Window
    W.Width, W.Height = 720, 500
    W.MinWidth, W.MinHeight = 300, 240
    W.TouchMinWidth, W.TouchMinHeight = 300, 240
    W.Topbar, W.Sidebar, W.SidebarCompact = 46, 168, 56
    W.Header, W.UserCard = 52, 46
    W.Ground = 0
    W.Margin, W.TouchMargin = 16, 8
    W.Radius, W.Stroke, W.Shadow = 10, 1, 0

    -- Touch targets grow: the hub is used on phones first.
    local T = Config.Metrics.Touch
    T.Row, T.Box, T.Item, T.Tab = 40, 40, 38, 46
    T.Check, T.Knob = 26, 22
    T.Switch = Vector2.new(50, 26)
    T.SwitchKnob = 20
    T.Radius = 10

    local D = Config.Metrics.Desktop
    D.Radius, D.Depth = 9, 2
    Config.Group.Radius, Config.Group.Stroke, Config.Group.Shadow = 10, 1, 0
    Config.Button.Depth, Config.Button.PadX = 2, 12
    Config.Selectable.Radius = 8
    Config.Page.ScrollBar = 4
end
"""


def minimal_ui(text):
    """Retune the upstream hub chrome to one flat, minimal, touch-first theme.

    The upstream ui.lua is a Mario-styled shell: twelve seasonal palettes, drifting
    clouds, particles and a grass strip. All of it is decoration that costs frames
    on a phone and buries the controls. The override lands just before `return
    Library`, which is after Config/Themes exist and before any game calls
    CreateWindow, so every widget built later already sees the new numbers.
    """
    if "Reicht minimal theme" in text:
        return text
    marker = "\nLibrary.CloseSheet = Sheet.Close\n"
    if text.count(marker) != 1:
        raise SystemExit("ui.lua minimal theme: CloseSheet marker not found")
    return text.replace(marker, marker + MINIMAL_THEME)


def defensive_ui(text):
    """Two upstream one-liners that abort a whole frame handler on real data.

    Both are nil-safety, not behaviour: a radar range that was never persisted and
    a lang spec whose EN is itself a table (hubs hand their own lang tables to the
    Add* helpers). Upstream assumes a shape the games do not always produce.
    """
    text = resub(
        text,
        r"local offset = Vector2\.new\(rel:Dot\(right\), -rel:Dot\(look\)\) / settings\.RadarRange \* radius",
        lambda m: ("local offset = Vector2.new(rel:Dot(right), -rel:Dot(look)) "
                   "/ (settings.RadarRange or 250) * radius"),
        "ui.lua radar range nil",
    )
    text = resub(
        text,
        r"table\.insert\(labels, Dropdown\.FormatValue\(entry\)\)",
        lambda m: "table.insert(labels, tostring(Dropdown.FormatValue(entry)))",
        "ui.lua dropdown label non-string",
    )
    text = resub(
        text,
        r'return \(\(spec\.EN or ""\) \.\. " " \.\. \(spec\.TH or ""\)\):lower\(\)',
        lambda m: 'return (tostring(spec.EN or "") .. " " .. tostring(spec.TH or "")):lower()',
        "ui.lua lang search non-string spec",
    )
    return text

def strip_stats_ui(text):
    """Drop the watermark overlay: it is the FPS/ping/playtime box the operator reads
    as clutter. The floating button stays -- that is the only chrome he wants on a
    phone screen. Kept as a build patch because ui.lua is generated, never hand-edited.
    """
    if "Watermark overlay removed on purpose" in text:
        return text
    pattern = re.compile(
        r"[ \t]*Watermark\.Build\(options\.WatermarkTitle or window\.Title\)\s*\n"
        r"[ \t]*Watermark\.SetVisible\(options\.Watermark ~= false\)\s*\n"
    )
    if len(pattern.findall(text)) != 1:
        raise SystemExit("ui.lua watermark strip: call pair not found exactly once")
    text = pattern.sub(
        "    -- Watermark overlay removed on purpose: the floating button is the only chrome.\n"
        "    Watermark.SetVisible(false)\n",
        text,
    )
    # The switch that drove it is now a dead toggle: SetVisible is a no-op with no
    # frame built. Drop the row so the settings tab has no control that does nothing.
    toggle = re.compile(r"[ \t]*interface:AddToggle\(\"MarioWatermark\".*?\n")
    if len(toggle.findall(text)) != 1:
        raise SystemExit("ui.lua watermark strip: toggle row not found exactly once")
    return toggle.sub(
        "    -- MarioWatermark toggle removed: no overlay left to switch.\n",
        text,
    )


EMBED_RE = re.compile(r'REICHT_EMBED\("([^"]+)"\)')


def embed_payloads(stage):
    """Inline vendored upstream scripts into the artifacts that fall back to them.

    A verbatim layer that fetches from GitHub is only verbatim while GitHub answers.
    The author's file is vendored under `upstream/ref/`, so the build pastes it into the
    runner as one long string and the game keeps working when the upstream repo is gone,
    a route is blocked, or the player is offline.

    Runs AFTER minify on purpose: the payload is a binary-ish blob and must never pass
    through a line stripper. The compile gate still covers the result.
    """
    ref_dir = os.path.join(os.path.dirname(os.path.abspath(__file__)), "upstream", "ref")
    games = os.path.join(stage, "games")
    embedded = []
    for entry in sorted(os.listdir(games)):
        if not entry.endswith(".lua"):
            continue
        path = os.path.join(games, entry)
        with open(path, encoding="utf-8", errors="surrogateescape") as handle:
            text = handle.read()
        if "REICHT_EMBED(" not in text:
            continue

        def repl(match):
            name = match.group(1)
            ref = os.path.join(ref_dir, name)
            if not os.path.isfile(ref):
                raise SystemExit(f"{entry}: embedded payload missing: {ref}")
            with open(ref, encoding="utf-8", errors="surrogateescape") as handle:
                payload = handle.read()
            level = 0
            while ("]" + "=" * level + "]") in payload:
                level += 1
            embedded.append((entry, name, len(payload)))
            return "[" + "=" * level + "[" + payload + "]" + "=" * level + "]"

        text = EMBED_RE.sub(repl, text)
        with open(path, "w", encoding="utf-8", errors="surrogateescape") as handle:
            handle.write(text)
    return embedded


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
    #
    # The stage path is fixed, so two overlapping builds rmtree each other's tree and
    # the loser still exits 0 with soft patches silently missing -- a green build with
    # fewer patches than the run before it. Hold an exclusive lock for the whole build.
    lock_handle = open(os.path.join(DST, ".build.lock"), "w")
    try:
        fcntl.flock(lock_handle, fcntl.LOCK_EX | fcntl.LOCK_NB)
    except OSError:
        raise SystemExit("another build holds .build.lock; refusing to race it")

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
    ui_text = strip_attribution(open(ui_path, encoding="utf-8").read())
    ui_text = add_press_mode(ui_text)
    ui_text = warn_duplicate_ids(ui_text)
    ui_text = add_button_registry(ui_text)
    ui_text = minimal_ui(ui_text)
    ui_text = defensive_ui(ui_text)
    ui_text = strip_stats_ui(ui_text)
    open(os.path.join(stage, "ui.lua"), "w", encoding="utf-8").write(ui_text)

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

    # Standalone layer: paste the vendored upstream scripts into the artifact so a dead
    # route costs freshness, not the feature. After minify, before the compile gate.
    for entry, ref_name, size in embed_payloads(stage):
        print(f"  embedded {ref_name} -> {entry} ({size} bytes)")

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
