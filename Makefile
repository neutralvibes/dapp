SHELL := /usr/bin/env bash

.PHONY: help lint test ci

help:
	@echo "Available targets:"
	@echo "  make lint   - lint shell scripts with shellcheck"
	@echo "  make test   - run install and dcd test suites"
	@echo "  make ci     - run lint and test"

lint:
	@command -v shellcheck >/dev/null 2>&1 || { echo "shellcheck is required but not installed"; exit 1; }
	shellcheck dapp_cmd tests/*.sh tests/run_tests.sh

test:
	@chmod +x tests/run_tests.sh tests/test_install_dcd.sh tests/test_install_self.sh
	@./tests/run_tests.sh

ci: lint test
	@echo "CI checks complete."
