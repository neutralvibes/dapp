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

# Use a separate HOME to avoid touching user's files
export HOME="$TMPROOT/home"
mkdir -p "$HOME"

echo "Starting install test with TMPROOT=$TMPROOT"

# Ensure paths are clean
rm -rf "$TMPROOT/usr" "$TMPROOT/completions"

# Run install
bash "$DAPP_SCRIPT" --yes --install

# Verify symlink exists and points to the script
if [[ -L "$DAPP_INSTALL_TARGET" || -f "$DAPP_INSTALL_TARGET" ]]; then
    echo "INSTALL: target exists: $DAPP_INSTALL_TARGET"
else
    echo "INSTALL: target missing: $DAPP_INSTALL_TARGET" >&2
    exit 2
fi

# Verify completion file
if [[ -f "$DAPP_COMPLETION_DIR/dapp" ]]; then
    if grep -q "_dapp_completions" "$DAPP_COMPLETION_DIR/dapp"; then
        echo "INSTALL: completion installed"
    else
        echo "INSTALL: completion file missing expected content" >&2
        exit 3
    fi
else
    echo "INSTALL: completion file missing" >&2
    exit 4
fi

# Run uninstall
bash "$DAPP_SCRIPT" --yes --uninstall

if [[ -f "$DAPP_INSTALL_TARGET" ]]; then
    echo "UNINSTALL: target still present" >&2
    exit 5
else
    echo "UNINSTALL: target removed"
fi

if [[ -f "$DAPP_COMPLETION_DIR/dapp" ]]; then
    echo "UNINSTALL: completion still present" >&2
    exit 6
else
    echo "UNINSTALL: completion removed"
fi

# Cleanup
rm -rf "$TMPROOT"

echo "Install/uninstall tests passed."
