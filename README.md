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

2. **Choose Your Setup Method:**

   ### Option A: Minimal Bash Setup (Faster, No Dependencies)
   
   For a lightweight setup with just the essential tools:
   ```bash
   ./scripts/setupMacOs.sh --minimal
   ```
   
   For the full bash-based setup:
   ```bash
   ./scripts/setupMacOs.sh
   ```

   ### Option B: Comprehensive Ansible Setup (Complete, Idempotent)
   
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

## Operation Modes

### Bash Script (setupMacOs.sh)

The bash script approach offers:
- **No dependencies** (except Homebrew)
- **Minimal mode** option for essential tools only
- **Configuration via JSON** files
- Perfect for initial setup or single-machine use

### Ansible Playbook (macos_setup.yml)

The Ansible approach offers:
- **Idempotent** operation (can be run multiple times safely)
- **Declarative configuration** of the entire system
- **Feature toggles** for enabling/disabling components
- Better for managing multiple machines or team setups

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

## License

This project is available for personal use.