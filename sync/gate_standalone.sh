#!/bin/bash
# Standalone proof: with the raw.githubusercontent host dead, the verbatim layer
# must fall back to the embedded copy and still load the author's script.
cd /home/ubuntu/reicht-hub || exit 1
echo "=== normal (network path) ==="
for g in Doors Evade; do
  out=$(python3 sync/smoke.py "games/$g.lua" 2>&1)
  echo "$g: $(echo "$out" | grep -E '^SMOKE' | tail -1)"
  echo "$out" | grep -E 'standalone copy is embedded|upstream loads the author' | sed 's/^/  /'
  echo "$out" | grep -c 'PROOF|FAIL' | sed 's/^/  proof_fails=/'
  echo "$out" | grep -E '^WROTE\|(Abysall|Draconic)Upstream\|SetAttribute\|(Source|EmbeddedBytes)=' | sed 's/^/  /'
done
echo "=== offline (the author's repo is gone, everything else reachable) ==="
# Block the upstream repo path, not the whole host: the library still has to load for
# the test to mean anything, so only the verbatim fetch is denied.
block_for() {
  case "$1" in
    Doors) echo "AbysallContinued" ;;
    Evade) echo "Draconic-Hub-X" ;;
  esac
}
for g in Doors Evade; do
  out=$(REICHT_UI_BLOCK="$(block_for "$g")" python3 sync/smoke.py "games/$g.lua" 2>&1)
  echo "$g: $(echo "$out" | grep -E '^SMOKE' | tail -1)"
  echo "$out" | grep -E 'standalone copy is embedded|upstream loads the author' | sed 's/^/  /'
  echo "$out" | grep -E '^WROTE\|(Abysall|Draconic)Upstream\|SetAttribute\|(Source|Bytes|EmbeddedBytes)=' | sed 's/^/  /'
done

echo "=== hub's own layer offline (Shinzzyak/Reicht unreachable) ==="
# ui.lua, FloatingButton.lua and the seven Abysall components all live on other
# people's repos. This is the section that proves the menu still opens when every
# one of those is gone -- the whole point of baking them into the artifact.
for g in Doors Evade; do
  out=$(REICHT_UI_BLOCK="Shinzzyak" python3 sync/smoke.py "games/$g.lua" 2>&1)
  echo "$g: $(echo "$out" | grep -E '^SMOKE' | tail -1)"
  echo "$out" | grep -E 'ui source:|floating button source:' | sed 's/^/  /'
  echo "$out" | grep -E '^WROTE\|AbysallUpstream\|SetAttribute\|Component' | sed 's/^/  /'
  echo "$out" | grep -c 'PROOF|FAIL' | sed 's/^/  proof_fails=/'
done

for g in Doors Evade; do
  out=$(REICHT_UI_BLOCK="Shinzzyak" python3 sync/smoke.py "games/$g.lua" 2>&1)
  if ! echo "$out" | grep -q 'ui source: embedded'; then
    echo "FAIL: $g did not fall back to the embedded menu"; exit 1
  fi
done
echo "hub layer offline: PASS (both games served the menu from the artifact)"
