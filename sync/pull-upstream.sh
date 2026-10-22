#!/usr/bin/env bash
# Fetch the upstream snapshot into $UPSTREAM_DIR, then rebuild the served tree.
#
# Exits non-zero on any failure. The caller must treat a non-zero exit as "keep the
# files that are already committed" — never as "delete them".
set -euo pipefail

UPSTREAM_OWNER="${UPSTREAM_OWNER:-xDTaraZz}"
UPSTREAM_REPO="${UPSTREAM_REPO:-Roblox-Scripts}"
UPSTREAM_REF="${UPSTREAM_REF:-main}"
UPSTREAM_DIR="${UPSTREAM_DIR:-$(mktemp -d)}"
API="https://api.github.com/repos/${UPSTREAM_OWNER}/${UPSTREAM_REPO}"
RAWUP="https://raw.githubusercontent.com/${UPSTREAM_OWNER}/${UPSTREAM_REPO}/refs/heads/${UPSTREAM_REF}"

echo "upstream: ${UPSTREAM_OWNER}/${UPSTREAM_REPO}@${UPSTREAM_REF}"
echo "snapshot: ${UPSTREAM_DIR}"

# A missing or unreachable upstream is a failure, not an empty tree. Bail before
# touching anything so the committed files stay exactly as they are.
head_sha=$(curl -sSf --max-time 30 \
  -H 'Accept: application/vnd.github+json' \
  "${API}/commits/${UPSTREAM_REF}" \
  | python3 -c 'import json,sys; print(json.load(sys.stdin)["sha"])')
echo "upstream head: ${head_sha}"

mkdir -p "${UPSTREAM_DIR}"

fetch() {
  local remote_path="$1" local_path="$2"
  local encoded
  encoded=$(python3 -c 'import sys,urllib.parse; print(urllib.parse.quote(sys.argv[1]))' "${remote_path}")
  mkdir -p "$(dirname "${local_path}")"
  curl -sSf --max-time 120 -o "${local_path}" "${RAWUP}/${encoded}"
}

fetch "loader.lua" "${UPSTREAM_DIR}/loader.lua"
fetch "ui.lua" "${UPSTREAM_DIR}/ui.lua"

# Enumerate games from the tree API rather than guessing names: a new game appears
# in the tree before any human notices.
curl -sSf --max-time 60 -H 'Accept: application/vnd.github+json' \
  "${API}/git/trees/${UPSTREAM_REF}?recursive=1" \
  > "${UPSTREAM_DIR}/tree.json"

python3 - "${UPSTREAM_DIR}/tree.json" <<'PY' > "${UPSTREAM_DIR}/games.txt"
import json, sys
tree = json.load(open(sys.argv[1]))["tree"]
for entry in tree:
    path = entry["path"]
    if entry["type"] == "blob" and path.startswith("All Map/") and path.endswith(".lua"):
        print(path)
PY

while IFS= read -r path; do
  [ -n "${path}" ] || continue
  name="${path#All Map/}"
  fetch "${path}" "${UPSTREAM_DIR}/All Map/${name}"
  echo "  fetched ${name}"
done < "${UPSTREAM_DIR}/games.txt"

count=$(find "${UPSTREAM_DIR}/All Map" -name '*.lua' | wc -l)
echo "games fetched: ${count}"
if [ "${count}" -lt 1 ]; then
  echo "upstream served zero game scripts; refusing to rebuild" >&2
  exit 1
fi

export UPSTREAM_DIR
python3 "$(dirname "$0")/build.py"

echo "${head_sha}" > "$(dirname "$0")/../.upstream-sha"
echo "sync complete: ${head_sha}"
