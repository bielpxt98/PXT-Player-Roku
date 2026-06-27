#!/usr/bin/env bash
set -euo pipefail

# Build a sideloadable Roku channel ZIP for the Development Application Installer.
# Run from anywhere inside this repository:
#   scripts/package-roku.sh

ROOT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
OUT_DIR="${ROOT_DIR}/build"
OUT_ZIP="${1:-${OUT_DIR}/pxt-player-roku.zip}"

cd "${ROOT_DIR}"

fail() {
  echo "ERROR: $*" >&2
  exit 1
}

require_file() {
  [[ -f "$1" ]] || fail "Required file missing: $1"
}

require_dir() {
  [[ -d "$1" ]] || fail "Required directory missing: $1"
}

require_file "manifest"
require_dir "source"
require_dir "components"
require_file "source/main.brs"
require_file "components/MainScene.xml"
require_file "components/MainScene.brs"

# Validate the minimum manifest fields Roku needs to identify and launch the app.
for key in title major_version minor_version build_version main_scene; do
  grep -Eq "^[[:space:]]*${key}=" manifest || fail "manifest is missing ${key}="
done

grep -Eq '^main_scene=MainScene$' manifest || fail "manifest main_scene must be MainScene"
grep -Eq 'CreateScene\("MainScene"\)' source/main.brs || fail "source/main.brs must create MainScene"

# Verify every pkg:/ script URI referenced by component XML exists in the package.
while IFS= read -r uri; do
  path="${uri#pkg:/}"
  require_file "${path}"
done < <(python3 - <<'PY'
from pathlib import Path
import re
for xml in sorted(Path('components').glob('*.xml')):
    text = xml.read_text(encoding='utf-8')
    for match in re.finditer(r'uri="(pkg:/[^"]+)"', text):
        print(match.group(1))
PY
)

mkdir -p "${OUT_DIR}"
rm -f "${OUT_ZIP}"

# Optional images are included only when present. The app does not reference
# background.jpg, logo.png, or icon.png directly, so their absence cannot stop launch.
zip -r "${OUT_ZIP}" \
  manifest \
  source \
  components \
  images \
  videos \
  -x '*.DS_Store' '*/.gitkeep' '*/README.md' >/dev/null

echo "Created ${OUT_ZIP}"
echo "Upload this ZIP with the Roku Development Application Installer."
