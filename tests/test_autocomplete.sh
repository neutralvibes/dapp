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

for token in '@all' '@list=' '@list-file=' '@save-status' '@list-help'; do
    if ! grep -q "${token}" <<<"$OUT"; then
        echo "AUTOCOMPLETE: expected token ${token} in output" >&2
        exit 4
    fi
done

echo "AUTOCOMPLETE test passed."
