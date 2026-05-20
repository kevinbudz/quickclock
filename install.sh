#!/usr/bin/env bash
set -euo pipefail

ROOT="$(cd "$(dirname "$0")" && pwd)"
SRC="${ROOT}/package"
METADATA="${SRC}/metadata.json"

GLOBAL=0
RESTART=0

usage() {
    cat <<EOF
Usage: $(basename "$0") [OPTIONS]

Install quickclock to ~/.local/share/plasma/plasmoids/ (default).

Options:
  -g, --global    Install system-wide (requires write access to /usr/share/plasma/plasmoids)
  -r, --restart   Restart plasmashell after install
  -h, --help      Show this help
EOF
}

while [[ $# -gt 0 ]]; do
    case "$1" in
        -g|--global) GLOBAL=1 ;;
        -r|--restart) RESTART=1 ;;
        -h|--help)
            usage
            exit 0
            ;;
        *)
            echo "Unknown option: $1" >&2
            usage >&2
            exit 1
            ;;
    esac
    shift
done

if [[ ! -f "${METADATA}" ]]; then
    echo "error: missing ${METADATA}" >&2
    exit 1
fi

ID="$(
    grep -m1 '"Id"' "${METADATA}" \
        | sed -n 's/.*"Id"[[:space:]]*:[[:space:]]*"\([^"]*\)".*/\1/p'
)"
if [[ -z "${ID}" ]]; then
    echo "error: could not read plasmoid Id from metadata.json" >&2
    exit 1
fi

if [[ "${GLOBAL}" -eq 1 ]]; then
    DEST="/usr/share/plasma/plasmoids/${ID}"
    if [[ ! -w "$(dirname "${DEST}")" ]]; then
        echo "Installing system-wide (sudo required)…"
        sudo mkdir -p "$(dirname "${DEST}")"
        sudo rm -rf "${DEST}"
        sudo cp -a "${SRC}" "${DEST}"
    else
        rm -rf "${DEST}"
        mkdir -p "$(dirname "${DEST}")"
        cp -a "${SRC}" "${DEST}"
    fi
else
    DEST="${HOME}/.local/share/plasma/plasmoids/${ID}"
    rm -rf "${DEST}"
    mkdir -p "$(dirname "${DEST}")"
    cp -a "${SRC}" "${DEST}"
fi

if command -v kbuildsycoca6 >/dev/null 2>&1; then
    kbuildsycoca6 --noincremental 2>/dev/null || true
fi

echo "Installed ${ID} to ${DEST}"

if [[ "${RESTART}" -eq 1 ]]; then
    if command -v qdbus6 >/dev/null 2>&1; then
        qdbus6 org.kde.plasmashell /PlasmaShell org.kde.PlasmaShell.evaluateScript \
            'desktop.reloadConfig()' 2>/dev/null || true
    fi
    echo "Restarting plasmashell…"
    killall plasmashell 2>/dev/null || true
fi

cat <<EOF

Add or refresh the widget:
  Panel → Add Widgets → ${ID}
  (or search for "quickclock")

If the widget does not appear, log out and back in, or run:
  $(basename "$0") --restart
EOF
