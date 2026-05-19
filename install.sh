#!/usr/bin/env bash
set -euo pipefail

ID="com.kevin.plasma.quickclock"
OLD_ID="com.kevin.plasma.datedisplay"
SRC="$(cd "$(dirname "$0")/package" && pwd)"
DEST="${HOME}/.local/share/plasma/plasmoids/${ID}"

rm -rf "${DEST}"
mkdir -p "$(dirname "${DEST}")"
cp -a "${SRC}" "${DEST}"

if [[ -d "${HOME}/.local/share/plasma/plasmoids/${OLD_ID}" ]]; then
    echo "Removing old ${OLD_ID} plasmoid…"
    rm -rf "${HOME}/.local/share/plasma/plasmoids/${OLD_ID}"
fi

kbuildsycoca6 --noincremental 2>/dev/null || true

echo "Installed ${ID} to ${DEST}"
echo "Restart plasmashell, then add the Quick Clock widget to your panel."
