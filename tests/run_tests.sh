#!/usr/bin/env bash
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
PROJECT_ROOT="$SCRIPT_DIR/.."
cd "$PROJECT_ROOT"

chmod +x dapp_cmd

chmod +x tests/*.sh

echo "Running shell syntax check..."
bash -n dapp_cmd

echo "Running dcd install/uninstall test..."
./tests/test_install_dcd.sh

echo "Running dapp install/uninstall test..."
./tests/test_install_self.sh

echo "Running autocomplete output test..."
./tests/test_autocomplete.sh

check_compose() {
    if command -v docker >/dev/null 2>&1 && docker compose version >/dev/null 2>&1; then
        return 0
    fi

    if command -v docker-compose >/dev/null 2>&1 && docker-compose version >/dev/null 2>&1; then
        return 0
    fi

    return 1
}

SKIP_LIST_REASON=""
if check_compose; then
    echo "Running list operations test..."
    ./tests/test_list_operations.sh
else
    SKIP_LIST_REASON="Docker Compose not available"
    echo "SKIP: ${SKIP_LIST_REASON}, skipping list operations test."
fi

echo "Running basic flags test..."
./tests/test_flags.sh

echo "All tests passed."

if [[ -n "$SKIP_LIST_REASON" ]]; then
    echo "NOTE: Some tests were skipped:"
    echo "  list operations: $SKIP_LIST_REASON"
fi
