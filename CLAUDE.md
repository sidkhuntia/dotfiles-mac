# macOS Dotfiles - Claude Setup Instructions

## Overview
This repository provides automated macOS setup using Ansible for development environment configuration. It's a complete solution for setting up a new Mac with preferred tools, applications, and system settings.

## Key Components

### Primary Scripts
- `install.sh` - Main entry point, handles initial setup and dependencies
- `setup.sh` - Applies macOS system configuration and restarts system
- `ansible/playbook.yml` - Orchestrates all configuration roles

### What Gets Installed
- **Package Manager**: Homebrew with 25+ CLI tools and 20+ GUI applications
- **Shell Environment**: Zsh with Oh My Zsh, Powerlevel10k theme, custom plugins
- **Development Tools**: VSCode, Git, Node.js (NVM), Go, Docker, Python
- **Applications**: Chrome, Firefox, Discord, Spotify, Raycast, Rectangle, Obsidian
- **Configuration**: Dotfiles symlinked via GNU Stow, SSH keys, AWS credentials

## Setup Process

### Single Command Execution
```bash
bash <(curl -sL https://raw.githubusercontent.com/sidkhuntia/dotfiles-mac/main/install.sh)
```

### Process Flow
1. **Bootstrap Phase** (install.sh):
   - Requests sudo password (keeps alive throughout)
   - Installs Xcode CLI Tools
   - Installs Homebrew
   - Installs Git and Ansible
   - Creates directory structure (`~/Developer/personal`, `~/Developer/lohum`)
   - Clones repository to `~/Developer/personal/dotfiles-mac`

2. **Package Installation**:
   - Runs `brew bundle install` using Brewfile
   - Installs all CLI tools and GUI applications

3. **Configuration Phase** (Ansible):
   - **REQUIRES ANSIBLE VAULT PASSWORD** - prompts for decryption key
   - Configures Zsh with Oh My Zsh and plugins
   - Sets up Git with multiple profiles (personal/work)
   - Installs Node.js via NVM and Go
   - Creates symlinks for all dotfiles using Stow
   - Deploys SSH keys and AWS credentials with proper permissions

4. **System Configuration** (setup.sh):
   - Applies macOS defaults (Finder, Dock, screenshots, etc.)
   - Prompts for system restart

### Required Inputs
1. **Admin/Sudo Password**: For system modifications and package installations
2. **Ansible Vault Password**: To decrypt sensitive credentials and SSH keys
3. **Restart Confirmation**: Whether to restart system after configuration

## Key Features

### Security
- Ansible Vault encryption for sensitive data
- SSH keys deployed with correct permissions (600)
- Multiple Git profiles for work/personal separation
- 2FA backup codes securely stored

### Development Environment
- **Zsh Configuration**: Custom aliases, Powerlevel10k theme, syntax highlighting
- **Git Setup**: Work/personal profiles, SSH key authentication, commit signing
- **Node.js**: NVM with multiple versions capability
- **Go**: Latest version installation
- **Docker**: Full containerization setup

### Applications Installed
**Development**: VSCode, iTerm2, Git, Docker, various CLI tools
**Productivity**: Raycast, Rectangle (window manager), Obsidian, Bitwarden
**Communication**: Discord, Telegram, WhatsApp, Zoom
**Utilities**: Stats (system monitor), Lunar (display control), Caffeine

### macOS Customizations
- Finder: Show hidden files, path bar, status bar, disable desktop icons
- Dock: Autohide enabled, show only active apps, minimize to application
- Screenshots: JPG format, weekly update checks
- System: Disable startup sound, Time Machine preferences

## Post-Setup Actions

### Manual Configuration Required
1. **Raycast**: Import configuration from `~/Downloads/*.rayconfig`
2. **Applications**: Sign into Discord, Spotify, Bitwarden, etc.
3. **Development**: Install VSCode extensions, configure development tools

### Verification Commands
```bash
echo $SHELL          # Should show /bin/zsh
node --version       # Node.js version
go version          # Go version
git config --list   # Git configuration
```

## File Structure
```
~/Developer/personal/dotfiles-mac/
├── install.sh                    # Main installer
├── setup.sh                     # System configuration  
├── Brewfile                     # Package definitions
├── ansible/
│   ├── playbook.yml            # Main Ansible orchestration
│   ├── roles/                  # Configuration modules
│   ├── credentials/            # Encrypted sensitive data
│   └── dotfiles/              # Configuration files to symlink
```

## Troubleshooting

### Common Issues
- **Sudo timeout**: Script maintains sudo access automatically
- **Network issues**: Ensure stable internet for Homebrew downloads
- **Vault password**: Must have correct Ansible Vault password
- **Permissions**: SSH keys automatically set to proper permissions

### Re-running Setup
```bash
cd ~/Developer/personal/dotfiles-mac
git pull
ansible-playbook --ask-vault-pass ansible/playbook.yml
```

## Customization Notes
- Modify `Brewfile` to add/remove applications
- Update `ansible/roles/` for configuration changes  
- Replace credentials in `ansible/credentials/` for personal use
- Adjust `scripts/osx.sh` for different macOS preferences

This setup provides a complete, reproducible development environment for macOS with one-command installation.