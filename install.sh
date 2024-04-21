#!/usr/bin/env bash

set -o errexit

REPO_URL=https://github.com/sidkhuntia/mac-setup.git
REPO_PATH="$HOME/Developer/personal/mac-setup"

reset_color=$(tput sgr 0)

info() {
	printf "%s[*] %s%s\n" "$(tput setaf 4)" "$1" "$reset_color"
}

success() {
	printf "%s[*] %s%s\n" "$(tput setaf 2)" "$1" "$reset_color"
}

err() {
	printf "%s[*] %s%s\n" "$(tput setaf 1)" "$1" "$reset_color"
}

warn() {
	printf "%s[*] %s%s\n" "$(tput setaf 3)" "$1" "$reset_color"
}

install_xcode() {
	if xcode-select -p >/dev/null; then
		warn "xCode Command Line Tools already installed"
	else
		info "Installing xCode Command Line Tools..."
		xcode-select --install
		sudo xcodebuild -license accept
	fi
}

install_homebrew() {
	export HOMEBREW_CASK_OPTS="--appdir=/Applications"
	if hash brew &>/dev/null; then
		warn "Homebrew already installed"
	else
		info "Installing homebrew..."
		sudo --validate # reset `sudo` timeout to use Homebrew install in noninteractive mode
		NONINTERACTIVE=1 /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/master/install.sh)"
	fi
}

get_privileges() {
	info "Prompting for sudo password..."
	if sudo -v; then
		# Keep-alive: update existing `sudo` time stamp until `setup.sh` has finished
		while true; do sudo -n true; sleep 60; kill -0 "$$" || exit; done 2>/dev/null &
		success "Sudo credentials updated."
	else
		error "Failed to obtain sudo credentials."
	fi
}


info "################################################################################"
info "Bootstraping"
info "################################################################################"
read -r -p "Press enter to start:"
info "Bootstraping..."

get_privileges
install_xcode
install_homebrew

info "################################################################################"
info "Installing Git"
info "################################################################################"
brew install git
success "Git installed"

info "################################################################################"
info "Installing Ansible"
info "################################################################################"
brew install ansible
success "Ansible installed"

info "################################################################################"
info "Cloning .dotfiles repo from $REPO_URL into $REPO_PATH"
info "################################################################################"
git clone "$REPO_URL" "$REPO_PATH"

info "################################################################################"
info "Change path to $REPO_PATH"
info "################################################################################"
cd "$REPO_PATH" >/dev/null


info "################################################################################"
info "Installing Brewfile"
info "################################################################################"
brew bundle install
success "Brewfile installed"

# Run ansible tasks
info "################################################################################"
info "Running ansible playbook"
info "################################################################################"
ansible-playbook ansible/playbook.yml

success "Ansible playbook executed"


info "################################################################################"
info "Running setup.sh"
info "################################################################################"
./setup.sh
success "setup.sh executed"
