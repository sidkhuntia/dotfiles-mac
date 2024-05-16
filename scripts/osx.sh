setup_osx() {
	info "Configuring MacOS default settings"

	# Disable prompting to use new exteral drives as Time Machine volume
	defaults write com.apple.TimeMachine DoNotOfferNewDisksForBackup -bool true

	# Hide external hard drives on desktop
	defaults write com.apple.finder ShowExternalHardDrivesOnDesktop -bool false #false

	# Hide hard drives on desktop
	defaults write com.apple.finder ShowHardDrivesOnDesktop -bool false #false

	# Hide removable media hard drives on desktop
	defaults write com.apple.finder ShowRemovableMediaOnDesktop -bool false #false

	# Hide mounted servers on desktop
	defaults write com.apple.finder ShowMountedServersOnDesktop -bool false

	# Hide icons on desktop
	defaults write com.apple.finder CreateDesktop -bool false

	# Avoid creating .DS_Store files on network volumes
	defaults write com.apple.desktopservices DSDontWriteNetworkStores -bool true

	# Show path bar
	defaults write com.apple.finder ShowPathbar -bool true #true

	# Show hidden files inside the finder
	defaults write com.apple.finder "AppleShowAllFiles" -bool true #true

	# Show Status Bar
	defaults write com.apple.finder "ShowStatusBar" -bool true #true

	# Do not show warning when changing the file extension
	defaults write com.apple.finder FXEnableExtensionChangeWarning -bool false

	# Set search scope to current folder
	defaults write com.apple.finder FXDefaultSearchScope -string "SCcf" # SCcf

	# Save screenshots in PNG format (other options: BMP, GIF, JPG, PDF, TIFF)
	defaults write com.apple.screencapture type -string "png" #jpg

	# Set weekly software update checks
	defaults write com.apple.SoftwareUpdate ScheduleFrequency -int 7

	# Set Desktop as the default location for new Finder windows
	# For other paths, use `PfLo` and `file:///full/path/here/`
	defaults write com.apple.finder NewWindowTarget -string "PfHm" # PfLo
	defaults write com.apple.finder NewWindowTargetPath -string "file:///${HOME}/"  # file:///Users/sidkhuntia/Downloads/

	# Enable the Develop menu and the Web Inspector in Safari
	defaults write com.apple.Safari IncludeDevelopMenu -bool true
	defaults write com.apple.Safari WebKitDeveloperExtrasEnabledPreferenceKey -bool true
	defaults write com.apple.Safari com.apple.Safari.ContentPageGroupIdentifier.WebKit2DeveloperExtrasEnabled -bool true

	# Add a context menu item for showing the Web Inspector in web views
	defaults write NSGlobalDomain WebKitDeveloperExtras -bool true

	# Have the Dock show only active apps
	defaults write com.apple.dock static-only -bool true

	# Set Dock autohide
	defaults write com.apple.dock autohide -bool true #true
	defaults write com.apple.dock largesize -float 128 #16
	defaults write com.apple.dock "minimize-to-application" -bool true #true
	defaults write com.apple.dock tilesize -float 32 #16

	# Secondary click in external mouse
	defaults write com.apple.AppleMultitouchMouse MouseButtonMode -string "TwoButton"

	# Disable startup sound
	sudo nvram SystemAudioVolume=%01

  # Enable ssh agent on start up
  info "Enabling ssh agent on start up with launchctl"
  cp "$HOME/.dotfiles/macos/com.openssh.ssh-agent.plist" "$HOME/Library/LaunchAgents/"
  launchctl load "$HOME/Library/LaunchAgents/com.openssh.ssh-agent.plist"
  launchctl enable "$HOME/Library/LaunchAgents/com.openssh.ssh-agent.plist"
}
