#!/usr/bin/env bash
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
DAPP_SCRIPT="$SCRIPT_DIR/dapp_cmd"

# Use a temporary HOME to avoid touching the real ~/.bashrc
TMP_HOME=$(mktemp -d)
BASHRC="$TMP_HOME/.bashrc"

export HOME="$TMP_HOME"
export DAPP_VERBOSE=1

echo "Starting test with HOME=$HOME"

# Ensure no bashrc exists
rm -f "$BASHRC"

# Run install using the new --yes flag
bash "$DAPP_SCRIPT" --yes --install-dcd

if grep -qF 'dcd() {' "$BASHRC"; then
    echo "INSTALL: dcd found in $BASHRC"
else
    echo "INSTALL: dcd NOT found in $BASHRC" >&2
    exit 2
fi

# Run uninstall
bash "$DAPP_SCRIPT" --yes --uninstall-dcd

if grep -qF 'dcd() {' "$BASHRC"; then
    echo "UNINSTALL: dcd still present in $BASHRC" >&2
    exit 3
else
    echo "UNINSTALL: dcd removed"
fi

# Cleanup
rm -rf "$TMP_HOME"

echo "All tests passed."
