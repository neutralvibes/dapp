#!/usr/bin/env bash
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
DAPP_SCRIPT="$SCRIPT_DIR/dapp_cmd"

echo "Testing basic flags"

if ! bash "$DAPP_SCRIPT" -v | grep -q 'dapp version'; then
    echo "VERSION: expected version output" >&2
    exit 2
fi

APPS_FOLDER=$(bash "$DAPP_SCRIPT" --apps-folder)
if [[ "$APPS_FOLDER" != "/opt/dapps" ]]; then
    echo "APPS-FOLDER: expected /opt/dapps, got: $APPS_FOLDER" >&2
    exit 3
fi

echo "FLAGS test passed."
