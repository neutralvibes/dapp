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

echo "Running basic flags test..."
./tests/test_flags.sh

echo "All tests passed."
