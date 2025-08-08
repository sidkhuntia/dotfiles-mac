#!/usr/bin/env bash

# Improved error handling and debugging
set -o errexit   # Exit on any error
set -o nounset   # Exit on undefined variable  
set -o pipefail  # Exit on pipe failures

# Configuration
REPO_URL=https://github.com/sidkhuntia/dotfiles-mac.git
REPO_PATH="$HOME/Developer/personal/dotfiles-mac"
LOG_FILE="$HOME/dotfiles-install.log"
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
	if ! curl -fsSL "$installer_url" | head -1 | grep -q "^#!/bin/bash"; then
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

info "################################################################################"
info "macOS Dotfiles Installation"
info "Version: 2.0 | Log: $LOG_FILE"
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
read -r -p "Continue with installation? (y/N): " confirm
if [[ ! "$confirm" =~ ^[Yy]$ ]]; then
	info "Installation cancelled by user"
	exit 0
fi

# Main installation function
main() {
	# Initialize log file
	echo "macOS Dotfiles Installation Log - $(date)" > "$LOG_FILE"
	echo "========================================" >> "$LOG_FILE"
	
	# Run pre-flight checks
	precheck || return 1
	
	# Get administrative privileges
	get_privileges || return 1
	
	# Install system dependencies
	install_xcode || return 1
	install_homebrew || return 1

    # Git is provided by Xcode Command Line Tools; Ansible will be installed via Brewfile
	
	info "################################################################################"
	info "Creating development directories"
	info "################################################################################"
	if ! mkdir -p ~/Developer/personal; then
		err "Failed to create development directories"
		return 1
	fi
	success "Development directories created"
	
	info "################################################################################"
	info "Cloning dotfiles repository"
	info "################################################################################"
	info "Source: $REPO_URL"
	info "Target: $REPO_PATH"
	
	if ! git clone "$REPO_URL" "$REPO_PATH"; then
		err "Failed to clone repository"
		err "Please check your internet connection and repository access"
		return 1
	fi
	success "Repository cloned successfully"
	
	info "################################################################################"
	info "Changing to repository directory"
	info "################################################################################"
	if ! cd "$REPO_PATH"; then
		err "Failed to change to repository directory: $REPO_PATH"
		return 1
	fi
	info "Current directory: $(pwd)"
	
	info "################################################################################"
	info "Installing applications and tools"
	info "################################################################################"
	info "This may take several minutes..."
	
	if [[ ! -f "Brewfile" ]]; then
		err "Brewfile not found in repository"
		return 1
	fi
	
	if ! brew bundle install --no-lock; then
		err "Failed to install Brewfile packages"
		err "Some packages may have failed - check the output above"
		warn "You can retry with: cd $REPO_PATH && brew bundle install"
		return 1
	fi
	success "Applications and tools installed successfully"
	
	# Run ansible tasks
	info "################################################################################"
	info "Configuring development environment"
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
	
	info "################################################################################"
	info "Applying macOS system settings"
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
	
	# Installation completed
	local end_time
	end_time=$(date +%s)
	local duration=$((end_time - STARTTIME))
	
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
