#!/usr/bin/env bash

# Improved error handling and debugging
set -o errexit   # Exit on any error
set -o nounset   # Exit on undefined variable  
set -o pipefail  # Exit on pipe failures

# Configuration
REPO_URL=https://github.com/sidkhuntia/dotfiles-mac.git
REPO_PATH="$HOME/Developer/personal/dotfiles-mac"
LOG_FILE="$HOME/dotfiles-install.log"
STATE_FILE="$HOME/.dotfiles-install-state"
STARTTIME=$(date +%s)

reset_color=$(tput sgr 0)

# Enhanced logging functions
log_with_timestamp() {
	local level="$1"
	local message="$2"
	local timestamp
	timestamp=$(date '+%Y-%m-%d %H:%M:%S')
	echo "[$timestamp] [$level] $message" >> "$LOG_FILE"
}

info() {
	printf "%s[*] %s%s\n" "$(tput setaf 4)" "$1" "$reset_color"
	log_with_timestamp "INFO" "$1"
}

success() {
	printf "%s[*] %s%s\n" "$(tput setaf 2)" "$1" "$reset_color"
	log_with_timestamp "SUCCESS" "$1"
}

err() {
	printf "%s[*] %s%s\n" "$(tput setaf 1)" "$1" "$reset_color"
	log_with_timestamp "ERROR" "$1"
}

warn() {
	printf "%s[*] %s%s\n" "$(tput setaf 3)" "$1" "$reset_color"
	log_with_timestamp "WARN" "$1"
}

# Cleanup function for error handling
cleanup() {
	local exit_code=$?
	if [ $exit_code -ne 0 ]; then
		err "Installation failed with exit code: $exit_code"
		err "Check log file: $LOG_FILE"
		err "You can re-run this script after fixing any issues"
	fi
	info "Total installation time: $(($(date +%s) - STARTTIME)) seconds"
	exit $exit_code
}

trap cleanup EXIT

# State management functions
save_state() {
	local step="$1"
	echo "$step" >> "$STATE_FILE"
	info "Progress saved: $step completed"
}

check_state() {
	local step="$1"
	if [[ -f "$STATE_FILE" ]]; then
		if grep -q "^$step$" "$STATE_FILE"; then
			return 0  # Step already completed
		fi
	fi
	return 1  # Step not completed
}

clear_state() {
	if [[ -f "$STATE_FILE" ]]; then
		rm -f "$STATE_FILE"
		info "Previous installation state cleared"
	fi
}

show_resume_menu() {
	info "Previous installation detected. Select where to resume:"
	info "1) Start fresh (clear previous state)"
	info "2) Resume from last successful step"
	info "3) Choose specific step to resume from"
	info "4) Exit"
	
	read -r -p "Enter choice (1-4): " choice
	
	case $choice in
		1)
			clear_state
			return 0
			;;
		2)
			info "Resuming from last successful step..."
			return 0
			;;
		3)
			show_step_menu
			return 0
			;;
		4)
			info "Installation cancelled"
			exit 0
			;;
		*)
			err "Invalid choice"
			show_resume_menu
			;;
	esac
}

show_step_menu() {
	info "Select step to resume from:"
	info "1) Pre-flight checks"
	info "2) Sudo privileges"
	info "3) Xcode Command Line Tools"
	info "4) Homebrew"
	info "5) Development directories"
	info "6) Clone repository"
	info "7) Install applications (brew bundle)"
	info "8) Configure environment (Ansible)"
	info "9) Install NearDrop"
	info "10) Apply macOS settings"
	
	read -r -p "Enter step number (1-10): " step_num
	
	# Clear state and add all steps up to selected one
	clear_state
	case $step_num in
		1) ;;  # Start from beginning
		2) save_state "precheck" ;;
		3) save_state "precheck"; save_state "privileges" ;;
		4) save_state "precheck"; save_state "privileges"; save_state "xcode" ;;
		5) save_state "precheck"; save_state "privileges"; save_state "xcode"; save_state "homebrew" ;;
		6) save_state "precheck"; save_state "privileges"; save_state "xcode"; save_state "homebrew"; save_state "directories" ;;
		7) save_state "precheck"; save_state "privileges"; save_state "xcode"; save_state "homebrew"; save_state "directories"; save_state "clone" ;;
		8) save_state "precheck"; save_state "privileges"; save_state "xcode"; save_state "homebrew"; save_state "directories"; save_state "clone"; save_state "brew_bundle" ;;
		9) save_state "precheck"; save_state "privileges"; save_state "xcode"; save_state "homebrew"; save_state "directories"; save_state "clone"; save_state "brew_bundle"; save_state "ansible" ;;
		10) save_state "precheck"; save_state "privileges"; save_state "xcode"; save_state "homebrew"; save_state "directories"; save_state "clone"; save_state "brew_bundle"; save_state "ansible"; save_state "neardrop" ;;
		*)
			err "Invalid step number"
			show_step_menu
			;;
	esac
}

install_xcode() {
	info "Checking Xcode Command Line Tools..."
	if xcode-select -p >/dev/null 2>&1; then
		warn "xCode Command Line Tools already installed"
		return 0
	fi
	
	info "Installing xCode Command Line Tools..."
	# Check if tools are available for installation
	if ! xcode-select --install 2>/dev/null; then
		err "Failed to trigger Xcode Command Line Tools installation"
		err "Please install manually from App Store or Developer Portal"
		return 1
	fi
	
	# Wait for installation to complete
	info "Waiting for Xcode Command Line Tools installation..."
	while ! xcode-select -p >/dev/null 2>&1; do
		printf "."
		sleep 5
	done
	printf "\n"
	
	info "Accepting Xcode license..."
	if ! sudo xcodebuild -license accept 2>/dev/null; then
		warn "Failed to accept license automatically - you may need to run 'sudo xcodebuild -license' manually"
	fi
	success "Xcode Command Line Tools installed successfully"
}

install_homebrew() {
	export HOMEBREW_CASK_OPTS="--appdir=/Applications"
	info "Checking Homebrew installation..."
	
	if command -v brew >/dev/null 2>&1; then
		warn "Homebrew already installed at $(which brew)"
		# Verify Homebrew is working
		if ! brew --version >/dev/null 2>&1; then
			err "Homebrew installation appears corrupted"
			return 1
		fi
		return 0
	fi
	
	info "Installing Homebrew..."
	sudo --validate # reset `sudo` timeout
	
	# Download and verify installer
	local installer_url="https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh"
	if ! /bin/bash -c "curl -fsSL '$installer_url' | head -1 | grep -q '^#!/bin/bash'"; then
		err "Failed to download or verify Homebrew installer"
		return 1
	fi
	
	# Install Homebrew
	if ! NONINTERACTIVE=1 /bin/bash -c "$(curl -fsSL $installer_url)"; then
		err "Homebrew installation failed"
		return 1
	fi
	
	# Add Homebrew to PATH for current session
	if [[ -d "/opt/homebrew/bin" ]]; then
		export PATH="/opt/homebrew/bin:$PATH"
	elif [[ -d "/usr/local/bin" ]]; then
		export PATH="/usr/local/bin:$PATH"
	fi
	
	# Verify installation
	if ! command -v brew >/dev/null 2>&1; then
		err "Homebrew installation verification failed"
		return 1
	fi
	
	success "Homebrew installed successfully"
}

get_privileges() {
	info "Checking sudo access..."
	
	# Check if we already have sudo access
	if sudo -n true 2>/dev/null; then
		info "Sudo access already active"
	else
		info "Prompting for sudo password..."
		if ! sudo -v; then
			err "Failed to obtain sudo credentials"
			err "This script requires administrative privileges"
			return 1
		fi
	fi
	
	# Keep-alive: update existing `sudo` time stamp until script finishes
	while true; do 
		sudo -n true 2>/dev/null
		sleep 60
		kill -0 "$$" 2>/dev/null || exit
	done 2>/dev/null &
	
	success "Sudo credentials configured with keep-alive"
}


# Pre-flight checks
precheck() {
	info "Running pre-flight checks..."
	
	# Check OS
	if [[ "$(uname)" != "Darwin" ]]; then
		err "This script is designed for macOS only"
		return 1
	fi
	
	# Check macOS version (require 10.15+)
	local macos_version
	macos_version=$(sw_vers -productVersion)
	if [[ "$(echo "$macos_version" | cut -d. -f1)" -lt 10 ]] || 
	   [[ "$(echo "$macos_version" | cut -d. -f1)" -eq 10 && "$(echo "$macos_version" | cut -d. -f2)" -lt 15 ]]; then
		err "macOS 10.15 (Catalina) or later required. Current version: $macos_version"
		return 1
	fi
	
	# Check internet connectivity
	info "Checking internet connectivity..."
	if ! curl -Is --connect-timeout 10 https://github.com >/dev/null 2>&1; then
		err "No internet connection available"
		err "Please check your network connection and try again"
		return 1
	fi
	
	# Check disk space (require at least 2GB free)
	local free_space
	free_space=$(df -g "$HOME" | awk 'NR==2 {print $4}')
	if [[ "$free_space" -lt 2 ]]; then
		err "Insufficient disk space. At least 2GB required, found ${free_space}GB"
		return 1
	fi
	
	# Check if repo directory already exists
	if [[ -d "$REPO_PATH" ]]; then
		warn "Repository directory already exists: $REPO_PATH"
		read -r -p "Remove existing directory and continue? (y/N): " response
		if [[ "$response" =~ ^[Yy]$ ]]; then
			info "Removing existing directory..."
			rm -rf "$REPO_PATH"
		else
			err "Installation cancelled by user"
			return 1
		fi
	fi
	
	success "All pre-flight checks passed"
}

# Parse command line arguments
RESUME_MODE=false
CLEAR_STATE=false

while [[ $# -gt 0 ]]; do
	case $1 in
		--resume|-r)
			RESUME_MODE=true
			shift
			;;
		--clear|-c)
			CLEAR_STATE=true
			shift
			;;
		--help|-h)
			info "Usage: $0 [OPTIONS]"
			info "Options:"
			info "  --resume, -r    Resume installation from last successful step"
			info "  --clear, -c     Clear previous installation state and start fresh"
			info "  --help, -h      Show this help message"
			exit 0
			;;
		*)
			err "Unknown option: $1"
			info "Use --help for usage information"
			exit 1
			;;
	esac
done

# Handle clear state flag
if [[ "$CLEAR_STATE" == true ]]; then
	clear_state
fi

# Check for existing installation state
if [[ -f "$STATE_FILE" ]] && [[ "$RESUME_MODE" == false ]] && [[ "$CLEAR_STATE" == false ]]; then
	show_resume_menu
elif [[ "$RESUME_MODE" == true ]] && [[ ! -f "$STATE_FILE" ]]; then
	warn "No previous installation state found. Starting fresh..."
	RESUME_MODE=false
fi

info "################################################################################"
info "macOS Dotfiles Installation"
info "Version: 2.0 | Log: $LOG_FILE"
if [[ "$RESUME_MODE" == true ]]; then
	info "Mode: RESUME from previous state"
fi
info "################################################################################"
info "This will install and configure:"
info "• Xcode Command Line Tools"
info "• Homebrew package manager"
info "• 25+ CLI tools and 20+ applications"
info "• Development environment (Git, Node.js, Go, etc.)"
info "• Shell configuration (Zsh + Oh My Zsh)"
info "• Personal dotfiles and system preferences"
info ""
warn "This process may take 15-30 minutes depending on your internet speed"
info ""

if [[ "$RESUME_MODE" == false ]] && [[ ! -f "$STATE_FILE" ]]; then
	read -r -p "Continue with installation? (y/N): " confirm
	if [[ ! "$confirm" =~ ^[Yy]$ ]]; then
		info "Installation cancelled by user"
		exit 0
	fi
fi

# Main installation function
main() {
	# Initialize log file
	echo "macOS Dotfiles Installation Log - $(date)" > "$LOG_FILE"
	echo "========================================" >> "$LOG_FILE"
	
	# Step 1: Run pre-flight checks
	if ! check_state "precheck"; then
		info "################################################################################"
		info "Step 1: Running pre-flight checks"
		info "################################################################################"
		precheck || return 1
		save_state "precheck"
	else
		info "Skipping pre-flight checks (already completed)"
	fi
	
	# Step 2: Get administrative privileges
	if ! check_state "privileges"; then
		info "################################################################################"
		info "Step 2: Getting administrative privileges"
		info "################################################################################"
		get_privileges || return 1
		save_state "privileges"
	else
		info "Skipping sudo privileges (already completed)"
		# Still need to setup keep-alive for this session
		get_privileges || return 1
	fi
	
	# Step 3: Install Xcode Command Line Tools
	if ! check_state "xcode"; then
		info "################################################################################"
		info "Step 3: Installing Xcode Command Line Tools"
		info "################################################################################"
		install_xcode || return 1
		save_state "xcode"
	else
		info "Skipping Xcode installation (already completed)"
	fi
	
	# Step 4: Install Homebrew
	if ! check_state "homebrew"; then
		info "################################################################################"
		info "Step 4: Installing Homebrew"
		info "################################################################################"
		install_homebrew || return 1
		save_state "homebrew"
	else
		info "Skipping Homebrew installation (already completed)"
		# Ensure Homebrew is in PATH for this session
		if [[ -d "/opt/homebrew/bin" ]]; then
			export PATH="/opt/homebrew/bin:$PATH"
		elif [[ -d "/usr/local/bin" ]]; then
			export PATH="/usr/local/bin:$PATH"
		fi
	fi
	
	# Step 5: Create development directories
	if ! check_state "directories"; then
		info "################################################################################"
		info "Step 5: Creating development directories"
		info "################################################################################"
		if ! mkdir -p ~/Developer/personal ~/Developer/lohum; then
			err "Failed to create development directories"
			return 1
		fi
		success "Development directories created"
		save_state "directories"
	else
		info "Skipping directory creation (already completed)"
	fi
	
	# Step 6: Clone dotfiles repository
	if ! check_state "clone"; then
		info "################################################################################"
		info "Step 6: Cloning dotfiles repository"
		info "################################################################################"
		info "Source: $REPO_URL"
		info "Target: $REPO_PATH"
		
		# Remove existing directory if it exists (for fresh clone)
		if [[ -d "$REPO_PATH" ]]; then
			warn "Removing existing repository directory for fresh clone..."
			rm -rf "$REPO_PATH"
		fi
		
		if ! git clone "$REPO_URL" "$REPO_PATH"; then
			err "Failed to clone repository"
			err "Please check your internet connection and repository access"
			return 1
		fi
		success "Repository cloned successfully"
		save_state "clone"
	else
		info "Skipping repository clone (already completed)"
	fi
	
	# Change to repository directory
	info "################################################################################"
	info "Changing to repository directory"
	info "################################################################################"
	if ! cd "$REPO_PATH"; then
		err "Failed to change to repository directory: $REPO_PATH"
		return 1
	fi
	info "Current directory: $(pwd)"
	
	# Step 7: Install applications and tools
	if ! check_state "brew_bundle"; then
		info "################################################################################"
		info "Step 7: Installing applications and tools"
		info "################################################################################"
		info "This may take several minutes..."
		
		if [[ ! -f "Brewfile" ]]; then
			err "Brewfile not found in repository"
			return 1
		fi
		
		if ! brew bundle install; then
			err "Failed to install Brewfile packages"
			err "Some packages may have failed - check the output above"
			warn "You can retry with: cd $REPO_PATH && brew bundle install"
			return 1
		fi
		success "Applications and tools installed successfully"
		save_state "brew_bundle"
	else
		info "Skipping brew bundle install (already completed)"
	fi
	
	# Step 8: Run ansible tasks
	if ! check_state "ansible"; then
		info "################################################################################"
		info "Step 8: Configuring development environment with Ansible"
		info "################################################################################"
		info "You will be prompted for the Ansible Vault password to decrypt sensitive data"
		info "(SSH keys, AWS credentials, etc.)"
		info ""
		
		if [[ ! -f "ansible/playbook.yml" ]]; then
			err "Ansible playbook not found"
			return 1
		fi
		
		# Verify Ansible inventory
		if ! ansible-inventory --list >/dev/null 2>&1; then
			err "Ansible inventory validation failed"
			return 1
		fi
		
		if ! ansible-playbook --ask-vault-pass ansible/playbook.yml; then
			err "Ansible playbook execution failed"
			err "You can retry with: cd $REPO_PATH && ansible-playbook --ask-vault-pass ansible/playbook.yml"
			return 1
		fi
		
		success "Development environment configured successfully"
		save_state "ansible"
	else
		info "Skipping Ansible configuration (already completed)"
	fi
	
	# Step 9: Post-install extras that require special flags
	if ! check_state "neardrop"; then
		info "################################################################################"
		info "Step 9: Installing NearDrop"
		info "################################################################################"
		info "Installing NearDrop with no-quarantine flag"
		if ! brew list --cask neardrop >/dev/null 2>&1; then
			# ensure tap exists before install
			brew tap grishka/grishka >/dev/null 2>&1 || true
			if ! brew install --cask --no-quarantine grishka/grishka/neardrop; then
				warn "NearDrop installation failed. You can manually run: brew install --cask --no-quarantine grishka/grishka/neardrop"
			else
				success "NearDrop installed"
			fi
		else
			warn "NearDrop already installed"
		fi
		save_state "neardrop"
	else
		info "Skipping NearDrop installation (already completed)"
	fi
	
	# Step 10: Apply macOS system settings
	if ! check_state "macos_settings"; then
		info "################################################################################"
		info "Step 10: Applying macOS system settings"
		info "################################################################################"
		
		if [[ ! -f "setup.sh" ]]; then
			err "setup.sh not found"
			return 1
		fi
		
		if [[ ! -x "setup.sh" ]]; then
			info "Making setup.sh executable..."
			chmod +x setup.sh
		fi
		
		if ! ./setup.sh; then
			err "Failed to apply macOS settings"
			warn "You can retry with: cd $REPO_PATH && ./setup.sh"
			return 1
		fi
		
		success "macOS system settings applied successfully"
		save_state "macos_settings"
	else
		info "Skipping macOS settings (already completed)"
	fi
	
	# Installation completed
	local end_time
	end_time=$(date +%s)
	local duration=$((end_time - STARTTIME))
	
	# Clear state file on successful completion
	clear_state
	
	info "################################################################################"
	success "Installation completed successfully!"
	info "Total time: ${duration} seconds"
	info "Log file: $LOG_FILE"
	info ""
	info "Next steps:"
	info "• Your system will restart to apply all settings"
	info "• After restart, import Raycast config from ~/Downloads"
	info "• Sign into your applications (Discord, Spotify, etc.)"
	info "• Configure development tools and extensions"
	info "################################################################################"
}

# Execute main function
main "$@"
