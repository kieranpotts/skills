#
# Task runners for this project's development lifecycle.
#

.PHONY: install help

help:
	@echo "Available targets:"
	@echo "  install  - Install skills into AI agents (--claude, --pi, --cursor, --copilot, --agents, --all)"
	@echo "  help     - Show this help message"

install:
	./run/install
