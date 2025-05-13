# MacOS Setup Scripts

A collection of scripts and configurations for setting up a new macOS machine. These scripts automate the installation of various developer tools, applications, and system configurations to get a new Mac up and running quickly.

## Overview

This project contains several scripts that help with different aspects of setting up a macOS machine:

- `scripts/setupInitialMacOS.sh`: Sets up the initial environment with Homebrew, iTerm2, and shell configurations
- `scripts/setupAnsible.sh`: Installs Ansible for configuration management
- `scripts/setupMacOs.sh`: Installs various packages, applications, and configurations using Homebrew
- `ansible/macos_setup.yml`: Ansible playbook for more comprehensive system setup
- `docs/SetupNTFSSupportMacOS.md`: Instructions for enabling NTFS support on macOS

## Directory Structure

- `scripts/`: Contains all bash scripts for setup
- `ansible/`: Contains Ansible playbooks and configurations
- `docs/`: Contains documentation for specific tasks

## Quick Start

For a fresh macOS installation, use the interactive installer:

```bash
./install.sh
```

Or you can run individual scripts:

1. **Initial Setup**: Run the initial setup script to install essential tools
   ```bash
   ./scripts/setupInitialMacOS.sh
   ```

2. **Setup with Ansible (Comprehensive, Idempotent):**
   
   First install Ansible:
   ```bash
   ./scripts/setupAnsible.sh
   ```
   
   Then run the playbook:
   ```bash
   ansible-playbook ./ansible/macos_setup.yml
   ```

## Configuration Options

The project now uses configuration files to manage which packages and settings are installed:

- **config/packages.json**: Contains lists of all packages to install
- **config/shell_config.json**: Contains shell configurations and useful aliases
- **config/config.json**: Controls feature flags and minimal mode packages

You can customize these files to tailor the installation to your needs.

## Features

- **Homebrew Setup**: Automatic installation and configuration of Homebrew
- **Developer Tools**: Installation of common development tools (neovim, git, etc.)
- **Applications**: Installation of essential applications (browsers, productivity tools, etc.)
- **Python Environment**: Configuration of a Python development environment with pyenv
- **UV Package Manager**: Support for the modern UV Python package manager with isolated virtual environments
- **Custom Shell Configuration**: Configuration of zsh with useful aliases and functions
- **Linux Compatibility Aliases**: Aliases for Linux commands like `lsblk` that map to macOS equivalents

## Detailed Feature Documentation

### Developer Toolchain

This setup installs a comprehensive developer environment with tools for:

- **Text Editing**: neovim, Visual Studio Code, Sublime Text
- **Version Control**: git with enhanced prompt
- **Command Line**: iterm2, tmux, tree, jq, coreutils
- **Languages**: Python, Node.js, Go, Deno
- **Build Tools**: cmake, gcc
- **Cloud**: awscli

### Python Configuration

The Python environment is carefully structured to avoid common pitfalls:

1. **pyenv**: Manages Python versions to isolate from system Python
2. **UV**: Modern, fast replacement for pip (up to 10-100x faster)
3. **Isolated Environments**: All packages install in a dedicated virtual environment
4. **Activation Script**: Auto-generated script to easily activate the environment

### macOS-Specific Enhancements

These scripts include macOS-specific improvements:

- **Homebrew**: The missing package manager for macOS
- **Default Apps**: Uses `dutis` to set file associations (unlike Linux's simpler approach)
- **System Monitoring**: Tools like `asitop` for Apple Silicon metrics
- **Window Management**: Rectangle for keyboard-based window positioning

## Operation Modes

### Ansible Playbook (macos_setup.yml)

The Ansible approach offers:
- **Idempotent** operation (can be run multiple times safely)
- **Declarative configuration** of the entire system
- **Feature toggles** for enabling/disabling components
- Better for managing multiple machines or team setups

#### Ansible Requirements

Unlike the bash script, Ansible has prerequisites:
- Python must be installed first (the setupAnsible.sh script handles this)
- Proper permissions for running Ansible tasks
- Some familiarity with Ansible concepts (playbooks, tasks, etc.)

#### Execution Details

The Ansible playbook:
1. Loads variables from all JSON config files
2. Executes tasks based on enabled feature flags
3. Skips tasks that have already been completed
4. Provides detailed output of what changed
5. Can be safely re-run multiple times

## Python Environment Management

This project uses UV, a modern Python package manager that's much faster than pip, to manage Python packages.
Instead of installing packages globally, our setup uses isolated virtual environments:

- All Python packages are installed in `~/.venvs/macos-setup`
- An activation script is created at `~/activate-macos-setup.sh`
- To use these packages, simply run: `source ~/activate-macos-setup.sh`

This approach prevents conflicts and keeps your global Python environment clean.

## Customization

You can customize the installations by editing the configuration files:

- `config/packages.json`: Add or remove packages from the various package lists
- `config/shell_config.json`: Modify shell configurations and aliases
- `config/config.json`: Toggle features and set which packages are included in minimal mode

### Adding a New Package

To add a new package to install:

1. Add it to the appropriate list in `config/packages.json`
2. If it should be included in minimal installations, also add it to the `core_packages` list in `config/config.json`

### Adding a New Shell Configuration

To add a new shell function or alias:

1. Add a new entry to the `zsh_additions` array in `config/shell_config.json`
2. Ensure it has a unique name, description, and content
3. Add a corresponding feature flag in `config/config.json` if needed

## Additional Resources

- [NTFS Support](./docs/SetupNTFSSupportMacOS.md): Instructions for enabling NTFS support on macOS

## Requirements

- macOS (tested on recent versions including Apple Silicon)
- Administrative privileges

## Troubleshooting

### Common Issues

1. **Homebrew installation fails**
   - Check your internet connection
   - Try running the command manually: `/bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"`
   - Ensure you have the Xcode Command Line Tools: `xcode-select --install`

2. **Mac App Store (mas) installations fail**
   - Ensure you're signed into the App Store application
   - Some apps may require manual installation if they're region-restricted
   - Check if the App Store is experiencing issues

3. **Python package installations fail**
   - Make sure your UV installation is working: `uv --version`
   - Check for permissions issues in the ~/.venvs directory
   - Try running with sudo if needed for certain packages

4. **Shell configurations not applied**
   - Run `source ~/.zshrc` to apply changes immediately
   - Restart your terminal application
   - Check for syntax errors in the zsh configuration

### Reset and Retry

If you encounter persistent issues, you can try a fresh start:

```bash
# Remove Python virtual environments
rm -rf ~/.venvs

# Reset shell configurations (backup first!)
cp ~/.zshrc ~/.zshrc.backup
grep -v "ANSIBLE MANAGED BLOCK\|macchina\|neofetch\|lsblk\|UV_VIRTUALENV\|PYENV_ROOT\|precmd_functions" ~/.zshrc.backup > ~/.zshrc

# Try installation again
./scripts/setupInitialMacOS.sh
./scripts/setupMacOs.sh
```

## License

This project is available for personal use.