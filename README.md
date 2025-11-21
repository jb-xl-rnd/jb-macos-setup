# MacOS Setup Scripts

A comprehensive collection of scripts and configurations for setting up a new macOS machine with developer tools, applications, and local LLM capabilities. These scripts automate the installation process and support both interactive and fully headless deployments.

## Overview

This project provides multiple installation approaches for setting up a macOS machine:

- **Interactive Setup**: Menu-driven installation with `install.sh`
- **Headless Setup**: Fully automated installation for remote deployment
- **Ansible-based**: Comprehensive, idempotent configuration management
- **Direct Scripts**: Targeted installations for specific components
- **LLM Integration**: Local AI/LLM capabilities with llama.cpp

## Quick Start

### 🌐 Web Installation (Recommended)
```bash
# Complete setup on fresh macOS machine
curl -fsSL jonathanbeer.me/macos | bash

# With specific options
curl -fsSL jonathanbeer.me/macos | bash -s -- --llm
curl -fsSL jonathanbeer.me/macos | bash -s -- --help
```

### Interactive Installation (Local Development)
```bash
./install.sh
```

### Headless Installation (For Remote/Automated Setup)
```bash
# Complete setup without GUI interactions
./installers/headless/install_headless.sh --all

# Just install LLM components
./installers/headless/install_headless.sh --llm

# Run with sleep prevention
./installers/headless/install_nosleep.sh
```

### Direct LLM Installation
```bash
# Quick LLM setup bypassing ansible
./installers/llm/direct_llm_install.sh
```

## Directory Structure

```
MacOS/
├── README.md                # Main documentation
├── install.sh               # Interactive setup menu
├── CLAUDE.md               # AI assistant instructions
├── ansible/                 # Ansible playbooks and templates
│   ├── macos_setup.yml     # Main playbook
│   ├── tasks/              # Individual task modules
│   └── templates/          # Jinja2 templates
├── config/                  # Configuration files
│   ├── packages.json       # Package definitions
│   ├── shell_config.json  # Shell configurations
│   ├── config.json        # Feature flags
│   └── llm_config.json    # LLM settings
├── installers/              # Installation scripts
│   ├── headless/           # Automated installation
│   │   ├── install_headless.sh
│   │   ├── install_fully_headless.sh
│   │   └── install_nosleep.sh
│   ├── llm/                # LLM-specific installers
│   │   ├── direct_llm_install.sh
│   │   ├── install_llama.sh
│   │   ├── setup_llama_mini.sh
│   │   └── test_llm_setup.sh
│   └── specialized/        # Specialized installers
│       ├── install_server.sh
│       └── install_with_sudo.sh
├── scripts/                 # Utility scripts
│   ├── llm/                # LLM management
│   │   ├── llm_manager.sh  # LLM server management
│   │   └── manage_models.sh # Model download/management
│   ├── system/             # System configuration
│   │   ├── setupInitialMacOS.sh # Initial environment
│   │   ├── prevent_sleep.sh    # Sleep prevention
│   │   └── setup_permissions.sh # Permissions
│   ├── tools/              # Tool installation
│   │   └── installDutis.sh # Default app manager
│   └── testing/            # Setup verification
│       ├── setupAnsible.sh # Ansible installation
│       └── test-ansible.sh # Ansible testing
├── build/                   # Generated files (gitignored)
│   ├── llm                 # LLM wrapper script
│   ├── llm_client.py      # Python LLM client
│   └── com.llama.server.plist # LaunchAgent plist
└── docs/                    # Documentation
    ├── AEROSPACE_CHEATSHEET.md
    ├── LLM_INTEGRATION_PLAN.md
    ├── PintaInstallationWorkaround.md
    └── SetupNTFSSupportMacOS.md
```

## Installation Methods

### 1. Server Mode Installation (Mac Mini)

For dedicated Mac Mini servers that should never sleep:

```bash
./installers/specialized/install_server.sh
```

This configures:
- **Permanent wake state** - System never sleeps
- **LLM server** - Accessible from network (0.0.0.0:8080)
- **Auto-restart** - On power failure
- **Wake on network** - Remote access enabled
- **Persistent caffeinate** - LaunchDaemon ensures system stays awake

### 2. Standard Ansible-based Setup

```bash
# Install Ansible
./scripts/testing/setupAnsible.sh

# Run complete setup
ansible-playbook ./ansible/macos_setup.yml

# Run specific components with tags
ansible-playbook ./ansible/macos_setup.yml --tags packages
ansible-playbook ./ansible/macos_setup.yml --tags llm
ansible-playbook ./ansible/macos_setup.yml --tags shell
```

### 2. Headless Deployment

Perfect for remote machines or CI/CD:

```bash
# Full headless installation with all components
./installers/headless/install_headless.sh --all

# Individual components
./installers/headless/install_headless.sh --initial      # Homebrew and basics
./installers/headless/install_headless.sh --ansible      # Run ansible playbook
./installers/headless/install_headless.sh --llm          # LLM setup only
./installers/headless/install_headless.sh --test         # Test installation
```

### 3. Direct Component Installation

For when you need specific functionality without the full setup:

```bash
# Direct LLM installation (fastest)
./installers/llm/direct_llm_install.sh

# Sleep prevention during long operations
./scripts/system/prevent_sleep.sh start
# ... run your installation ...
./scripts/system/prevent_sleep.sh stop
```

## Features

### Server Mode (Mac Mini)
When `enable_server_mode` is true:
- **Never Sleep**: System stays awake 24/7
- **Network Wake**: Wake on LAN enabled
- **Auto-restart**: Automatic restart after power failure
- **Persistent Caffeinate**: LaunchDaemon keeps system awake
- **LLM Server**: Accessible from network (not just localhost)
- **No Hibernation**: Disabled to prevent sleep
- **App Nap Disabled**: Applications stay responsive

To disable server mode:
```bash
~/disable_sleep_uninstall.sh
```

### Core Development Environment
- **Homebrew**: Package manager with 200+ pre-configured packages
- **Development Tools**: git, neovim (LazyVim), VS Code, tmux
- **Languages**: Python 3.12+, Node.js, Go, Deno
- **Build Tools**: cmake, gcc, autoconf, automake
- **Cloud Tools**: AWS CLI, Docker alternatives (OrbStack)

### Shell Environment
- **Custom Prompt**: Git-aware, minimalist design
- **Aliases**: Linux compatibility commands, productivity shortcuts
- **UV Package Manager**: Modern Python package management
- **Pyenv**: Python version management

### Local LLM Capabilities (New!)
- **llama.cpp**: High-performance LLM inference
- **Metal Acceleration**: Optimized for Apple Silicon
- **Model Management**: Easy model downloading and switching
- **API Server**: OpenAI-compatible API endpoint
- **Client Tools**: Python client and CLI utilities

### Default Application Management
- **dutis**: Command-line tool for file associations
- **Automated Configuration**: Set default apps for file types

## LLM Setup

The LLM integration provides local AI capabilities:

### Components Installed
- llama.cpp with Metal GPU acceleration
- TinyLlama 1.1B model (default, 637MB)
- HTTP API server (OpenAI-compatible)
- Python client library
- Management scripts

### Usage
```bash
# Start LLM server
~/llm-workspace/start_server.sh

# Test the setup
~/llm-workspace/test_llm.sh

# Use the API
curl -X POST http://localhost:8080/v1/chat/completions \
  -H "Content-Type: application/json" \
  -d '{"messages":[{"role":"user","content":"Hello!"}]}'

# Interactive CLI
llm --interactive
llm --prompt "Your question here"
```

### Available Models
Configure additional models in `config/llm_config.json`:
- TinyLlama 1.1B (default)
- Phi-3 Mini 4K
- Custom GGUF models

## Configuration

### Package Configuration (`config/packages.json`)
Define which packages to install:
```json
{
  "brew_packages": [...],
  "brew_cask_apps": [...],
  "mas_apps": [...]
}
```

### AeroSpace Tiling Window Manager Setup
After installation, AeroSpace requires additional configuration:

```bash
# Copy the template configuration
cp config/.aerospace.toml ~/.aerospace.toml

# Start AeroSpace manually (first time)
open /Applications/AeroSpace.app

# Enable window management
aerospace enable on
```

**Key Features:**
- **Workspace switching**: `⌘ + 1-9` (fixed to avoid macOS conflicts)
- **Window movement**: `⌥ + H/J/K/L` (focus), `⌥ + Shift + H/J/K/L` (move)
- **Toggle**: `⌥ + Shift + Ctrl + E` or `~/SHORTHAND-COMMANDS/TOGGLE_AEROSPACE`
- **Auto-start**: Configured with `start-at-login = true` in template

See `docs/AEROSPACE_CHEATSHEET.md` for complete keybinding reference.

### Feature Flags (`config/config.json`)
Control installation behavior:
```json
{
  "feature_flags": {
    "use_pyenv": true,
    "use_uv_package_manager": true,
    "custom_shell_prompt": true,
    "install_dutis": true,
    "enable_server_mode": true
  }
}
```

### LLM Configuration (`config/llm_config.json`)
Configure LLM settings:
```json
{
  "llm_settings": {
    "server_port": 8080,
    "default_model": "tinyllama",
    "metal_acceleration": true
  }
}
```

## Headless Installation Notes

For completely unattended installation:

1. **Prevent Sleep**: Scripts use `caffeinate` to prevent system sleep
2. **Handle Permissions**: Automated firewall and security configuration
3. **Skip GUI Prompts**: Pre-configured to avoid permission dialogs
4. **Remote Access**: SSH-friendly with no interactive prompts

Example for remote deployment:
```bash
ssh user@mac-mini 'cd ~/macos-setup && ./installers/headless/install_headless.sh --all'
```

## Security Considerations

The headless scripts temporarily relax some security settings during installation:
- Gatekeeper is temporarily disabled
- Firewall exceptions are added for development tools
- These are automatically restored after installation

To manually restore security settings:
```bash
~/restore_security.sh  # Created during headless setup
```

## Troubleshooting

### Installation Takes Too Long
- Use `install_nosleep.sh` to prevent sleep
- Check network connectivity for package downloads
- Consider using `--tags` to install specific components

### Permission Popups During Installation
- Use `install_fully_headless.sh` for unattended setup
- Run `scripts/system/setup_permissions.sh` before installation

### LLM Server Not Accessible
- Check firewall settings
- Ensure server is bound to correct interface (0.0.0.0 for external)
- Verify model file exists in `~/llm-workspace/models/`

## Testing

Verify your installation:
```bash
# Test everything
./installers/llm/test_llm_setup.sh

# Test specific components
ansible-playbook ansible/macos_setup.yml --check
llm --mode health
```

## Maintenance

### Automated Maintenance Script

Use the included maintenance script for comprehensive system checks:

```bash
# Run full maintenance (interactive)
./scripts/system/brew_maintenance.sh

# Quick check without upgrades
./scripts/system/brew_maintenance.sh --quick

# Verbose output
./scripts/system/brew_maintenance.sh --verbose

# Help
./scripts/system/brew_maintenance.sh --help
```

The maintenance script performs:
1. Updates package lists
2. Checks for deprecated packages
3. Identifies outdated packages
4. Offers to upgrade packages
5. Cleans up old versions
6. Removes orphaned dependencies
7. Runs system health check

### Manual Maintenance Commands

Alternatively, run these commands individually:

```bash
# Update all packages
brew update
brew upgrade

# Check for deprecated/disabled packages
brew doctor

# Clean up old versions and cache
brew cleanup
brew autoremove

# Audit installed packages for security issues
brew audit --installed
```

### Boot Services & Background Process Audit

Audit all services, agents, and processes running at boot or in the background:

```bash
# Run full boot services audit
./scripts/system/boot_services_audit.sh

# Detailed audit with verbose output
./scripts/system/boot_services_audit.sh --verbose

# Save audit report to file
./scripts/system/boot_services_audit.sh --output ~/Desktop/boot_audit_$(date +%Y%m%d).txt
```

The boot services audit identifies:
1. System-level LaunchDaemons (boot-time services)
2. User-level LaunchAgents (login-time services)
3. Login Items (GUI apps at login)
4. Running background processes
5. System extensions and kernel extensions
6. Third-party vs built-in macOS services

See `docs/BOOT_SERVICES_AUDIT.md` for detailed documentation of all boot services.

**Recommended Schedule:** Run monthly to track new services and identify undocumented utilities.

### Scheduling Automated Maintenance

Create a weekly maintenance schedule with launchd:

```bash
# Run maintenance script weekly (recommended)
# Add to your crontab or create a LaunchAgent
# Example LaunchAgent: ~/Library/LaunchAgents/com.user.brew-maintenance.plist
```

### Checking for Deprecated Packages

Deprecated packages should be removed and replaced with alternatives:

```bash
# Show deprecated packages
brew info --json=v2 --installed | jq -r '.formulae[] | select(.deprecated == true or .disabled == true) | .name'

# Show deprecated casks
brew doctor | grep -A 10 "deprecated or disabled"
```

### Handling Deprecated Packages

When `brew doctor` reports deprecated packages:

1. **Research replacement**: Check Homebrew's deprecation message for suggested alternatives
2. **Update packages.json**: Remove deprecated entries from `config/packages.json`
3. **Uninstall deprecated**: Run `brew uninstall <package-name>` or `brew uninstall --cask <cask-name>`
4. **Install replacement**: If available, install the suggested replacement
5. **Run cleanup**: `brew cleanup && brew autoremove` to remove orphaned dependencies

Example deprecation handling:
```bash
# Check for issues
brew doctor

# Remove deprecated package
brew uninstall pyside@2

# Cleanup dependencies
brew autoremove
brew cleanup
```

### Keeping packages.json in Sync

After making manual changes to installed packages, update the configuration:

```bash
# Export currently installed packages
brew list --formula > /tmp/current_formulae.txt
brew list --cask > /tmp/current_casks.txt

# Compare with config/packages.json and update accordingly
# This ensures future installations match your current setup
```

### Security Best Practices

1. **Regular updates**: Run `brew upgrade` at least monthly
2. **Audit packages**: Use `brew audit --installed` to check for known issues
3. **Remove unused packages**: Use `brew autoremove` to clean up orphaned dependencies
4. **Check for vulnerabilities**: Monitor Homebrew announcements for security advisories
5. **Avoid deprecated packages**: Replace them promptly when notified

### Python Package Maintenance

Python packages require separate maintenance from Homebrew:

```bash
# Run Python package audit
./scripts/system/python_maintenance.sh

# Quick check without prompts
./scripts/system/python_maintenance.sh --quick

# Upgrade all packages automatically
./scripts/system/python_maintenance.sh --upgrade
```

The Python maintenance script audits:
1. All Python installations (Homebrew, pyenv)
2. System packages (minimal is best)
3. User-local packages (~/.local/lib)
4. UV tools (recommended package manager)
5. Virtual environments
6. Python version recommendations

**Python Package Best Practices:**
- Keep system Python packages minimal (6 core packages is ideal)
- Use `uv` for tool installations instead of `pip install --global`
- Use virtual environments for project dependencies
- Update UV tools monthly: `uv tool upgrade --all`
- Avoid `pip install --user` (pollutes user site-packages)

**UV Tools Management:**
```bash
# List installed tools
uv tool list

# Upgrade all tools
uv tool upgrade --all

# Install a new tool
uv tool install <package-name>

# Uninstall a tool
uv tool uninstall <package-name>
```

## Requirements

### For Web Installation
- Fresh macOS machine (any recent version)
- Internet connection
- Terminal access

### For Local Development
- macOS 14.0 or later (tested on Sequoia 15.5)
- Admin (sudo) access
- Internet connection for package downloads
- ~50GB free disk space for full installation
- Apple Silicon recommended for LLM features

## Contributing

Contributions are welcome! Please:
1. Test changes on a fresh macOS installation
2. Update documentation for new features
3. Follow existing naming conventions
4. Add feature flags for optional components

## License

MIT - See LICENSE file for details

## Acknowledgments

- Built with Ansible for idempotent configuration
- Uses llama.cpp for efficient LLM inference
- Inspired by various dotfiles projects
- Community contributions and feedback

---

**Note**: This setup is optimized for developer machines and includes many development tools. Review `config/packages.json` to customize for your needs.