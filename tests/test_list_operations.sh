#!/usr/bin/env bash
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
DAPP_SCRIPT="$SCRIPT_DIR/dapp_cmd"
TMPROOT=$(mktemp -d)
export DAPP_ALLOW_USER_INSTALL=1
export DAPP_ASSUME_YES=1
export DAPP_VERBOSE=1
export DAPP_INSTALL_TARGET="$TMPROOT/usr/local/bin/dapp"
export DAPP_COMPLETION_DIR="$TMPROOT/completions"
export HOME="$TMPROOT/home"
mkdir -p "$HOME"

if ! command -v docker >/dev/null 2>&1 || ! docker compose version >/dev/null 2>&1; then
    if command -v docker-compose >/dev/null 2>&1 && docker-compose version >/dev/null 2>&1; then
        true
    else
        echo "SKIP: Docker Compose not available, skipping list operation tests."
        rm -rf "$TMPROOT"
        exit 0
    fi
fi

mkdir -p "$TMPROOT/opt/dapps/app1"
mkdir -p "$TMPROOT/opt/dapps/app2"
printf 'services:\n  web:\n    image: nginx\n' > "$TMPROOT/opt/dapps/app1/compose.yml"
printf 'services:\n  web:\n    image: nginx\n' > "$TMPROOT/opt/dapps/app2/compose.yml"
export DAPP_DIR="$TMPROOT/opt/dapps"

# install dapp to ensure run_list_command is callable
bash "$DAPP_SCRIPT" --yes --install >/dev/null

# Set a safe whitelist for list operations
export DAPP_LIST_SAFE="ps;up -d;down;restart;logs"

# Validate @list-help output
if ! bash "$DAPP_SCRIPT" @list-help | grep -q 'Current whitelist:'; then
    echo "LIST-HELP: expected whitelist output" >&2
    exit 2
fi

# Validate @all simple command
if ! bash "$DAPP_SCRIPT" @all ps | grep -q '==== app1 ===='; then
    echo "LIST-ALL: expected app output for app1" >&2
    exit 3
fi

# Validate @list= selection
if ! bash "$DAPP_SCRIPT" '@list=app2' ps | grep -q '==== app2 ===='; then
    echo "LIST-SELECT: expected app2 output" >&2
    exit 4
fi

# Validate @save-status stopped file
bash "$DAPP_SCRIPT" @save-status stopped "$TMPROOT/stopped.txt"
if [[ ! -f "$TMPROOT/stopped.txt" ]]; then
    echo "SAVE-STATUS: expected stopped file" >&2
    exit 5
fi

# Validate invalid command blocked by whitelist
if bash "$DAPP_SCRIPT" @all up | grep -q 'not allowed'; then
    echo "WHITELIST: expected invalid command rejection" >&2
    exit 6
fi

# Cleanup
rm -rf "$TMPROOT"

echo "LIST operations tests passed."
