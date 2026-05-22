#!/bin/bash

# install-agents-minimal.sh - Minimal script to install Guild agents into Pi's global agent directory.

set -euo pipefail

# Config
GUILD_AGENTS_DIR=".pi/agents"
PI_AGENTS_DIR="$HOME/.pi/agent/agents"

# Verify Pi is installed
if [ ! -d "$HOME/.pi" ]; then
    echo "[Guild] ERROR: Pi is not installed. Please install Pi first: https://opencode.ai/pi"
    exit 1
fi

# Create Pi agents directory if it doesn't exist
mkdir -p "$PI_AGENTS_DIR"

# Copy all guild-* agents
for agent in "$GUILD_AGENTS_DIR"/guild-*.md; do
    if [ -f "$agent" ]; then
        echo "[Guild] Installing $(basename "$agent")"
        cp "$agent" "$PI_AGENTS_DIR"/
    fi
done

# Check if Flint is installed (optional)
if ! command -v flint &> /dev/null; then
    echo "[Guild] WARNING: Flint is not installed. Some agents will have limited functionality."
    echo "[Guild] To install Flint: https://github.com/opencode-ai/flint"
fi

# Success message
echo "[Guild] Guild agents installed successfully!"
echo "[Guild] Restart Pi to see the changes: systemctl --user restart pi-agent"