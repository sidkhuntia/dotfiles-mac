#!/usr/bin/env bash

# Dotfiles Rollback and Recovery Script
# This script helps recover from failed installations or revert changes

set -o errexit
set -o nounset 
set -o pipefail

# Configuration
BACKUP_BASE_DIR="$HOME/.dotfiles-backup"
LOG_FILE="$HOME/dotfiles-rollback.log"
STARTTIME=$(date +%s)

# Color output functions
reset_color=$(tput sgr 0)

info() {
	printf "%s[*] %s%s\n" "$(tput setaf 4)" "$1" "$reset_color"
	echo "[$(date '+%Y-%m-%d %H:%M:%S')] [INFO] $1" >> "$LOG_FILE"
}

success() {
	printf "%s[*] %s%s\n" "$(tput setaf 2)" "$1" "$reset_color"
	echo "[$(date '+%Y-%m-%d %H:%M:%S')] [SUCCESS] $1" >> "$LOG_FILE"
}

err() {
	printf "%s[*] %s%s\n" "$(tput setaf 1)" "$1" "$reset_color"
	echo "[$(date '+%Y-%m-%d %H:%M:%S')] [ERROR] $1" >> "$LOG_FILE"
}

warn() {
	printf "%s[*] %s%s\n" "$(tput setaf 3)" "$1" "$reset_color"
	echo "[$(date '+%Y-%m-%d %H:%M:%S')] [WARN] $1" >> "$LOG_FILE"
}

cleanup() {
	local exit_code=$?
	local end_time=$(date +%s)
	local duration=$((end_time - STARTTIME))
	
	if [ $exit_code -ne 0 ]; then
		err "Rollback failed with exit code: $exit_code"
		err "Check log file: $LOG_FILE"
	else
		success "Rollback completed in ${duration} seconds"
	fi
	
	exit $exit_code
}

trap cleanup EXIT

# Find available backups
list_backups() {
	info "Available system backups:"
	
	if [[ ! -d "$BACKUP_BASE_DIR" ]]; then
		warn "No backup directory found at $BACKUP_BASE_DIR"
		return 1
	fi
	
	local backups=($(find "$BACKUP_BASE_DIR" -maxdepth 1 -type d -name "*.dotfiles-backup-*" 2>/dev/null | sort -r))
	
	if [[ ${#backups[@]} -eq 0 ]]; then
		warn "No backups found"
		return 1
	fi
	
	local i=1
	for backup in "${backups[@]}"; do
		local backup_name=$(basename "$backup")
		local backup_date=$(echo "$backup_name" | sed 's/.*-\([0-9]\{8\}-[0-9]\{6\}\).*/\1/')
		info "$i) $backup_name (created: $backup_date)"
		((i++))
	done
	
	return 0
}

# Restore system settings from backup
restore_system_settings() {
	local backup_dir="$1"
	
	info "Restoring system settings from: $backup_dir"
	
	# Restore Finder settings
	if [[ -f "$backup_dir/finder-settings.plist" ]]; then
		info "Restoring Finder settings..."
		if defaults import com.apple.finder "$backup_dir/finder-settings.plist" 2>/dev/null; then
			success "Finder settings restored"
		else
			warn "Failed to restore Finder settings"
		fi
	fi
	
	# Restore Dock settings
	if [[ -f "$backup_dir/dock-settings.plist" ]]; then
		info "Restoring Dock settings..."
		if defaults import com.apple.dock "$backup_dir/dock-settings.plist" 2>/dev/null; then
			success "Dock settings restored"
			# Restart Dock to apply changes
			killall Dock 2>/dev/null || true
		else
			warn "Failed to restore Dock settings"
		fi
	fi
	
	# Restore screenshot settings
	if [[ -f "$backup_dir/screencapture-settings.plist" ]]; then
		info "Restoring screenshot settings..."
		if defaults import com.apple.screencapture "$backup_dir/screencapture-settings.plist" 2>/dev/null; then
			success "Screenshot settings restored"
		else
			warn "Failed to restore screenshot settings"
		fi
	fi
}

# Remove installed applications
remove_applications() {
	info "Removing applications installed by dotfiles..."
	
	local brewfile_path="$HOME/Developer/personal/dotfiles-mac/Brewfile"
	if [[ ! -f "$brewfile_path" ]]; then
		warn "Brewfile not found, skipping application removal"
		return 0
	fi
	
	read -r -p "This will remove ALL applications from Brewfile. Continue? (y/N): " confirm
	if [[ ! "$confirm" =~ ^[Yy]$ ]]; then
		info "Skipping application removal"
		return 0
	fi
	
	if command -v brew >/dev/null 2>&1; then
		info "Uninstalling Brewfile applications..."
		cd "$HOME/Developer/personal/dotfiles-mac"
		if brew bundle cleanup --force; then
			success "Applications removed"
		else
			warn "Some applications may not have been removed"
		fi
	else
		warn "Homebrew not found, cannot remove applications"
	fi
}

# Remove dotfiles symlinks
remove_dotfiles() {
	info "Removing dotfile symlinks..."
	
	local dotfiles_dir="$HOME/Developer/personal/dotfiles-mac/ansible/dotfiles"
	if [[ ! -d "$dotfiles_dir" ]]; then
		warn "Dotfiles directory not found"
		return 0
	fi
	
	# Find and remove symlinks that point to our dotfiles
	find "$HOME" -maxdepth 1 -type l | while read -r symlink; do
		local target=$(readlink "$symlink" 2>/dev/null || echo "")
		if [[ "$target" == "$dotfiles_dir"* ]]; then
			info "Removing symlink: $(basename "$symlink")"
			rm "$symlink"
		fi
	done
	
	success "Dotfile symlinks removed"
}

# Clean up development directories (with confirmation)
cleanup_dev_dirs() {
	info "Development directory cleanup options:"
	
	local dirs=(
		"$HOME/Developer/personal/dotfiles-mac"
		"$HOME/.oh-my-zsh"
		"$HOME/.dotfiles"
	)
	
	for dir in "${dirs[@]}"; do
		if [[ -d "$dir" ]]; then
			read -r -p "Remove directory $dir? (y/N): " confirm
			if [[ "$confirm" =~ ^[Yy]$ ]]; then
				rm -rf "$dir"
				success "Removed: $dir"
			else
				info "Keeping: $dir"
			fi
		fi
	done
}

# Full system reset
full_reset() {
	warn "FULL SYSTEM RESET - This will remove all dotfiles changes"
	warn "This action cannot be undone!"
	
	read -r -p "Are you absolutely sure? Type 'RESET' to confirm: " confirm
	if [[ "$confirm" != "RESET" ]]; then
		info "Reset cancelled"
		return 0
	fi
	
	info "Performing full system reset..."
	
	# 1. Restore system settings if backup exists
	local latest_backup=$(find "$BACKUP_BASE_DIR" -maxdepth 1 -type d -name "*dotfiles-backup-*" 2>/dev/null | sort -r | head -n1)
	if [[ -n "$latest_backup" ]]; then
		restore_system_settings "$latest_backup"
	fi
	
	# 2. Remove applications
	remove_applications
	
	# 3. Remove dotfile symlinks
	remove_dotfiles
	
	# 4. Clean up directories
	cleanup_dev_dirs
	
	# 5. Reset shell to default
	if [[ "$SHELL" == *"zsh"* ]]; then
		read -r -p "Reset shell to bash? (y/N): " shell_reset
		if [[ "$shell_reset" =~ ^[Yy]$ ]]; then
			chsh -s /bin/bash
			success "Shell reset to bash"
		fi
	fi
	
	success "Full system reset completed"
	warn "Please restart your system to ensure all changes take effect"
}

# Interactive menu
show_menu() {
	clear
	cat << "EOF"
╔══════════════════════════════════════════════════════════════════════════════╗
║                         DOTFILES ROLLBACK & RECOVERY                        ║
╚══════════════════════════════════════════════════════════════════════════════╝

Choose an option:

1) List available backups
2) Restore system settings from backup  
3) Remove installed applications
4) Remove dotfile symlinks
5) Clean up development directories
6) Full system reset (removes everything)
7) View rollback log
8) Exit

EOF
	
	read -r -p "Enter your choice (1-8): " choice
	
	case $choice in
		1) list_backups ;;
		2) 
			if list_backups; then
				read -r -p "Enter backup number to restore: " backup_num
				local backups=($(find "$BACKUP_BASE_DIR" -maxdepth 1 -type d -name "*dotfiles-backup-*" 2>/dev/null | sort -r))
				if [[ $backup_num -gt 0 && $backup_num -le ${#backups[@]} ]]; then
					restore_system_settings "${backups[$((backup_num-1))]}"
				else
					err "Invalid backup number"
				fi
			fi
			;;
		3) remove_applications ;;
		4) remove_dotfiles ;;
		5) cleanup_dev_dirs ;;
		6) full_reset ;;
		7) 
			if [[ -f "$LOG_FILE" ]]; then
				less "$LOG_FILE"
			else
				warn "No log file found at $LOG_FILE"
			fi
			;;
		8) 
			info "Exiting rollback utility"
			exit 0
			;;
		*) 
			err "Invalid choice"
			;;
	esac
	
	echo ""
	read -r -p "Press Enter to continue..."
}

# Main execution
main() {
	echo "Dotfiles Rollback and Recovery Log - $(date)" > "$LOG_FILE"
	echo "=============================================" >> "$LOG_FILE"
	
	info "Starting dotfiles rollback utility..."
	
	while true; do
		show_menu
	done
}

# Check if script is being sourced or executed
if [[ "${BASH_SOURCE[0]}" == "${0}" ]]; then
	main "$@"
fi