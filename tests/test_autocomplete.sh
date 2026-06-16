#!/usr/bin/env bash
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
DAPP_SCRIPT="$SCRIPT_DIR/dapp_cmd"

echo "Testing --autocomplete output"

COMPFN=$(bash "$DAPP_SCRIPT" --autocomplete)
COMPDATA=$(bash "$DAPP_SCRIPT" --autocomplete-data)

if ! grep -q '_dapp_completions()' <<<"$COMPFN"; then
    echo "AUTOCOMPLETE: function '_dapp_completions' missing" >&2
    exit 2
fi

if ! grep -q 'complete -F _dapp_completions dapp' <<<"$COMPFN"; then
    echo "AUTOCOMPLETE: completion binding missing" >&2
    exit 3
fi

for token in 'start' 'restart' 'stop' 'pull' 'down'; do
    if ! grep -q "${token}" <<<"$COMPDATA"; then
        echo "AUTOCOMPLETE: expected token ${token} in output" >&2
        exit 4
    fi
done

for token in '@list-all' '@list=' '@list-file=' '@status-save' '@list-help'; do
    if ! grep -q "${token}" <<<"$COMPDATA"; then
        echo "AUTOCOMPLETE: expected token ${token} in output" >&2
        exit 5
    fi
done

echo "AUTOCOMPLETE test passed."
