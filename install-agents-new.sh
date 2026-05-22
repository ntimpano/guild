#!/bin/bash

# install-agents-new.sh - Installs Guild agents into Pi's global agent directory.
# Usage: ./install-agents-new.sh [--uninstall] [--dry-run]

set -euo pipefail

DRY_RUN=false
if [ "${1:-}" = "--dry-run" ]; then
    DRY_RUN=true
    shift
fi

# --- Config ---
GUILD_AGENTS_DIR=".pi/agents"
PI_AGENTS_DIR="$HOME/.pi/agent/agents"
BACKUP_DIR="$HOME/.pi/agent/agents_backup_$(date +%Y%m%d_%H%M%S)"

# --- Functions ---
log() {
    echo "[Guild] $1"
}

error() {
    echo "[Guild] ERROR: $1" >&2
    exit 1
}

warn() {
    echo "[Guild] WARNING: $1" >&2
}

dry_run_msg() {
    if [ "$DRY_RUN" = true ]; then
        echo " (DRY RUN - no changes will be made)"
    fi
}

verify_pi_installed() {
    if [ ! -d "$HOME/.pi" ]; then
        error "Pi is not installed. Please install Pi first: https://opencode.ai/pi"
    fi
}

verify_flint_installed() {
    if ! command -v flint &> /dev/null; then
        warn "Flint is not installed. Some agents (guild-init, guild-archivist) will have limited functionality."
        warn "To install Flint: https://github.com/opencode-ai/flint"
        return 1
    fi
    return 0
}

verify_pi_tools() {
    local missing_tools=()
    for tool in read edit bash; do
        if ! pi tool list 2>/dev/null | grep -q "$tool"; then
            missing_tools+=("$tool")
        fi
    done
    
    if [ ${#missing_tools[@]} -gt 0 ]; then
        warn "The following Pi tools are missing: ${missing_tools[*]}. Some agents may not work correctly."
    fi
}

backup_existing_agents() {
    if [ -d "$PI_AGENTS_DIR" ] && [ -n "$(ls -A "$PI_AGENTS_DIR")" ]; then
        log "Backing up existing agents to $BACKUP_DIR$(dry_run_msg)"
        if [ "$DRY_RUN" = false ]; then
            mkdir -p "$BACKUP_DIR"
            cp -r "$PI_AGENTS_DIR"/* "$BACKUP_DIR"/ || error "Failed to backup agents"
        fi
    fi
}

install_agents() {
    log "Installing Guild agents to $PI_AGENTS_DIR$(dry_run_msg)"
    if [ "$DRY_RUN" = false ]; then
        mkdir -p "$PI_AGENTS_DIR"
    fi
    
    # Check dependencies
    verify_flint_installed || true  # Continue even if Flint is missing
    verify_pi_tools
    
    # Copy all guild-* agents
    for agent in "$GUILD_AGENTS_DIR"/guild-*.md; do
        if [ -f "$agent" ]; then
            log "Installing $(basename "$agent")$(dry_run_msg)"
            if [ "$DRY_RUN" = false ]; then
                cp "$agent" "$PI_AGENTS_DIR"/ || error "Failed to install $agent"
            fi
        fi
    done
    
    if [ "$DRY_RUN" = false ]; then
        log "Guild agents installed successfully!"
        log "Restart Pi to see the changes."
    else
        log "Dry run completed. No changes were made."
    fi
    
    # Post-installation notes
    if ! verify_flint_installed; then
        log "\n--- NOTE ---"
        log "Flint is recommended for full functionality of Guild agents."
        log "Without Flint, the following agents will have limited capabilities:"
        log "  - guild-init: Cannot persist plan metadata."
        log "  - guild-reviewer: Cannot detect spec drift."
        log "  - guild-archivist: Cannot archive results."
        log "Install Flint: https://github.com/opencode-ai/flint"
    fi
    
    if [ "$DRY_RUN" = false ]; then
        log "\n--- Next Steps ---"
        log "1. Restart Pi: systemctl --user restart pi-agent"
        log "2. Verify agents: pi agent list"
        log "3. Run a test workflow: { agent: 'guild-scout', task: 'Map the auth module' }"
    fi
}

uninstall_agents() {
    log "Uninstalling Guild agents from $PI_AGENTS_DIR$(dry_run_msg)"
    
    # Remove all guild-* agents
    for agent in "$PI_AGENTS_DIR"/guild-*.md; do
        if [ -f "$agent" ]; then
            log "Removing $(basename "$agent")$(dry_run_msg)"
            if [ "$DRY_RUN" = false ]; then
                rm "$agent" || error "Failed to remove $agent"
            fi
        fi
    done
    
    if [ "$DRY_RUN" = false ]; then
        log "Guild agents uninstalled successfully!"
        log "Restart Pi to see the changes."
    else
        log "Dry run completed. No changes were made."
    fi
    
    # Post-uninstallation notes
    log "\n--- NOTE ---"
    log "Flint is no longer required for Guild agents, but it is still recommended for:"
    log "  - Persisting SDD plans and results."
    log "  - Detecting spec drift during reviews."
    log "  - Archiving completed changes."
    log "Install Flint: https://github.com/opencode-ai/flint"
}

restore_backup() {
    if [ -d "$BACKUP_DIR" ]; then
        log "Restoring backup from $BACKUP_DIR$(dry_run_msg)"
        if [ "$DRY_RUN" = false ]; then
            cp -r "$BACKUP_DIR"/* "$PI_AGENTS_DIR"/ || error "Failed to restore backup"
            rm -rf "$BACKUP_DIR"
        fi
        log "Backup restored successfully!"
    fi
}

# --- Main ---
if [ "${1:-}" = "--uninstall" ]; then
    verify_pi_installed
    uninstall_agents
    if [ "$DRY_RUN" = false ]; then
        restore_backup
    fi
else
    verify_pi_installed
    if [ "$DRY_RUN" = false ]; then
        backup_existing_agents
    fi
    install_agents
fi