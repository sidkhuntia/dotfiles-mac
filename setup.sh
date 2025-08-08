#!/usr/bin/env bash

# Enhanced error handling
set -o errexit   # Exit on any error
set -o nounset   # Exit on undefined variable
set -o pipefail  # Exit on pipe failures

# Configuration
LOG_FILE="$HOME/dotfiles-setup.log"
STARTTIME=$(date +%s)

# Source utility scripts with validation
if [[ ! -f "scripts/utils.sh" ]]; then
	echo "ERROR: scripts/utils.sh not found" >&2
	exit 1
fi
. scripts/utils.sh

if [[ ! -f "scripts/osx.sh" ]]; then
	err "scripts/osx.sh not found"
	exit 1
fi
. scripts/osx.sh

# Enhanced cleanup function
cleanup() {
	local exit_code=$?
	local end_time=$(date +%s)
	local duration=$((end_time - STARTTIME))
	
	if [ $exit_code -ne 0 ]; then
		err "macOS configuration failed with exit code: $exit_code"
		err "Check log file: $LOG_FILE"
		err "Some settings may have been partially applied"
	else
		success "macOS configuration completed in ${duration} seconds"
	fi
	
	exit $exit_code
}

# Enhanced logging with timestamps (consistent with install.sh)
log_with_timestamp() {
	local level="$1"
	local message="$2"
	local timestamp=$(date '+%Y-%m-%d %H:%M:%S')
	echo "[$timestamp] [$level] $message" >> "$LOG_FILE"
}

# Backup current settings
backup_settings() {
	info "Creating backup of current system settings..."
	local backup_dir="$HOME/.dotfiles-backup-$(date +%Y%m%d-%H%M%S)"
	mkdir -p "$backup_dir"
	
	# Backup key preferences
	defaults read com.apple.finder > "$backup_dir/finder-settings.plist" 2>/dev/null || true
	defaults read com.apple.dock > "$backup_dir/dock-settings.plist" 2>/dev/null || true
	defaults read com.apple.screencapture > "$backup_dir/screencapture-settings.plist" 2>/dev/null || true
	
	info "Settings backed up to: $backup_dir"
	log_with_timestamp "INFO" "Settings backed up to: $backup_dir"
}

# Validate system compatibility
validate_system() {
	info "Validating system compatibility..."
	
	# Check if we're running on macOS
	if [[ "$(uname)" != "Darwin" ]]; then
		err "This script is designed for macOS only"
		return 1
	fi
	
	# Check if we have necessary permissions
	if ! sudo -n true 2>/dev/null; then
		err "Sudo access required for system configuration"
		return 1
	fi
	
	success "System validation passed"
}

main() {
	# Initialize logging
	echo "macOS System Configuration Log - $(date)" > "$LOG_FILE"
	echo "=========================================" >> "$LOG_FILE"
	
	info "################################################################################"
	info "macOS System Configuration"
	info "Version: 2.0 | Log: $LOG_FILE"
	info "################################################################################"
	
	# Validate system before making changes
	validate_system || return 1
	
	# Create backup of current settings
	backup_settings
	
	info "################################################################################"
	info "Applying macOS Configuration"
	info "################################################################################"
	info "This will modify system preferences for:"
	info "• Finder settings (hidden files, path bar, etc.)"
	info "• Dock configuration (autohide, size, etc.)"
	info "• Screenshot settings and Time Machine"
	info "• System audio and power management"
	info ""
	warn "These changes will affect your current desktop environment"
	read -r -p "Continue with configuration? (y/N): " confirm
	if [[ ! "$confirm" =~ ^[Yy]$ ]]; then
		info "Configuration cancelled by user"
		return 0
	fi
	
	# Apply macOS settings
	if ! setup_osx; then
		err "Failed to apply macOS settings"
		return 1
	fi
	
	success "macOS configuration applied successfully"
	success "NOTE: A system restart is required for all changes to take effect"
	
	info "################################################################################"
	info "Restart Options"
	info "################################################################################"
	info "Your system needs to restart to apply all configuration changes."
	info "You can:"
	info "1. Restart now (recommended)"
	info "2. Restart later manually"
	info ""
	read -r -p "Restart now? (y/N): " restart_choice
	
	if [[ "$restart_choice" =~ ^[Yy]$ ]]; then
		info "Restarting system in 5 seconds..."
		info "Press Ctrl+C to cancel"
		sleep 5
		sudo shutdown -r now
	else
		info "Please restart your system manually when convenient"
		info "Run 'sudo shutdown -r now' to restart from terminal"
	fi
}

trap cleanup SIGINT SIGTERM ERR EXIT

main
