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

2. **Install Ansible** (if you want to use the Ansible playbook)
   ```bash
   ./scripts/setupAnsible.sh
   ```

3. **Run the Ansible Playbook** (recommended approach)
   ```bash
   ansible-playbook ./ansible/macos_setup.yml
   ```

   OR

   **Install Additional Software** using the bash script
   ```bash
   ./scripts/setupMacOs.sh
   ```

## Features

- **Homebrew Setup**: Automatic installation and configuration of Homebrew
- **Developer Tools**: Installation of common development tools (neovim, git, etc.)
- **Applications**: Installation of essential applications (browsers, productivity tools, etc.)
- **Python Environment**: Configuration of a Python development environment with pyenv
- **LaTeX Setup**: Installation of LaTeX tools and packages
- **Custom Shell Configuration**: Configuration of zsh with useful aliases and functions

## Customization

You can customize the installations by editing:

- `macos_setup.yml`: Add or remove packages from the various lists
- `setupMacOs.sh`: Edit the script to add or remove Homebrew packages or casks

## Additional Resources

- [NTFS Support](./SetupNTFSSupportMacOS.md): Instructions for enabling NTFS support on macOS

## Requirements

- macOS (tested on recent versions including Apple Silicon)
- Administrative privileges

## License

This project is available for personal use.