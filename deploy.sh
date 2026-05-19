#!/usr/bin/env bash
set -euo pipefail

DEST="/opt/guild"

echo "Installing Guild to ${DEST}..."
mkdir -p "${DEST}"
cp -r skills "${DEST}/"
cp -r commands "${DEST}/"
cp -r prompts "${DEST}/"
cp AGENTS.md "${DEST}/"
cp guild-agents.json "${DEST}/"
cp README.md "${DEST}/"

echo "Guild installed at ${DEST}"
echo ""
echo "Next steps:"
echo "  1. Verify opencode.json has MCP key 'flint'"
echo "  2. Restart OpenCode to pick up new MCP config"
echo "  3. Run 'flint migrate' to copy data from ~/.nt-cli/ to ~/.flint/"
echo "  4. Verify: flint doctor && flint recall 'test'"
