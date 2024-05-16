fonts=(
	font-fira-code
	font-meslo-lg-nerd-fontK
)

install_fonts() {
	info "Installing fonts..."
	brew tap homebrew/cask-fonts
	install_brew_casks "${fonts[@]}"
}
