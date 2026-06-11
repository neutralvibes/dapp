#!/usr/bin/env bash
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
DAPP_SCRIPT="$SCRIPT_DIR/dapp_cmd"

echo "Testing --autocomplete output"

OUT=$(bash "$DAPP_SCRIPT" --autocomplete)

if ! grep -q '_dapp_completions()' <<<"$OUT"; then
    echo "AUTOCOMPLETE: function '_dapp_completions' missing" >&2
    exit 2
fi

if ! grep -q 'complete -F _dapp_completions dapp' <<<"$OUT"; then
    echo "AUTOCOMPLETE: completion binding missing" >&2
    exit 3
fi

echo "AUTOCOMPLETE test passed."
