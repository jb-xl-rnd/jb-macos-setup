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
   
   Test the setup (recommended):
   ```bash
   ./scripts/test-ansible.sh
   ```
   
   Then run the playbook:
   ```bash
   ansible-playbook ./ansible/macos_setup.yml
   ```

## Configuration Options

The project now uses configuration files to manage which packages and settings are installed:

- **config/packages.json**: Contains lists of all packages to install
- **config/shell_config.json**: Contains shell configurations and useful aliases
- **config/config.json**: Controls feature flags and configuration options

### Feature Flags

The `config.json` file contains feature flags that control various aspects of the setup:

- **use_pyenv**: Enable Python version management with pyenv
- **use_uv_package_manager**: Use the modern UV package manager for Python
- **custom_shell_prompt**: Configure a custom shell prompt
- **alias_compatibility**: Add Linux compatibility aliases for macOS
- **install_dutis**: Install the dutis utility for managing default applications
- **dutis_auto_configure**: Automatically configure default applications without user interaction

You can customize these files to tailor the installation to your needs.

## Features

- **Homebrew Setup**: Automatic installation and configuration of Homebrew
- **Developer Tools**: Installation of common development tools (neovim, git, etc.)
- **Applications**: Installation of essential applications (browsers, productivity tools, etc.)
- **Default App Manager**: Integration of dutis for managing file associations and default applications
- **Python Environment**: Configuration of a Python development environment with pyenv
- **UV Package Manager**: Support for the modern UV Python package manager with isolated virtual environments
- **Custom Shell Configuration**: Configuration of zsh with useful aliases and functions
- **Linux Compatibility Aliases**: Aliases for Linux commands like `lsblk` that map to macOS equivalents
- **LazyVim**: Pre-configured Neovim with LazyVim starter configuration

## Detailed Feature Documentation

### Developer Toolchain

This setup installs a comprehensive developer environment with tools for:

- **Text Editing**: neovim with LazyVim configuration, Visual Studio Code, Sublime Text
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
  - Allows setting default applications for specific file extensions (e.g., `sudo dutis mp4`)
  - Supports file type groups for bulk assignment (e.g., `sudo dutis --group video`)
  - Integrates with macOS UTI (Uniform Type Identifier) system
- **System Monitoring**: Tools like `asitop` for Apple Silicon metrics
- **Window Management**: Rectangle for keyboard-based window positioning

### LazyVim Configuration

LazyVim is a Neovim configuration that transforms Neovim into a modern IDE-like experience. Our setup automatically installs and configures LazyVim with:

#### What LazyVim Provides
- **Plugin Management**: Lazy.nvim for fast, lazy-loaded plugins
- **LSP Integration**: Built-in Language Server Protocol support for intelligent code features
- **Syntax Highlighting**: TreeSitter-based syntax highlighting for 100+ languages
- **File Explorer**: Neo-tree for project navigation
- **Fuzzy Finding**: Telescope for file/text search
- **Git Integration**: Built-in git signs and LazyGit integration
- **Modern UI**: Beautiful, informative status line and notifications

#### Prerequisites Installed
Our setup automatically installs all LazyVim prerequisites:
- **fzf**: Fuzzy finder for file searching
- **ripgrep**: Fast text searching across files
- **fd**: Fast file finder
- **lazygit**: Terminal UI for git operations
- **curl**: HTTP client for plugin downloads

#### Installation Process
The LazyVim installation:
1. **Backs up existing Neovim configuration** (if any) to `.bak` extensions
2. **Clones LazyVim starter** repository to `~/.config/nvim`
3. **Removes git history** for clean customization
4. **Preserves your ability to customize** the configuration

#### Using LazyVim
After installation:
```bash
# Start Neovim - LazyVim will auto-install plugins on first run
nvim

# In Neovim, check plugin health
:LazyHealth

# View plugin manager
:Lazy

# Access LazyVim documentation
:help LazyVim
```

#### Key Features for Developers
- **Zero-config LSP**: Language servers auto-install for most languages
- **Code completion**: Intelligent autocompletion with snippets
- **File navigation**: Quick file switching with `<leader>ff`
- **Text search**: Project-wide search with `<leader>sg`
- **Git integration**: View changes, blame, and stage hunks
- **Terminal integration**: Built-in terminal with `<leader>ft`

LazyVim can be run independently with:
```bash
ansible-playbook ansible/macos_setup.yml --tags lazyvim
```

### Default Application Management with dutis

Dutis is a powerful command-line utility for managing file associations on macOS. Unlike the simple file association mechanisms in Linux, macOS uses a complex UTI (Uniform Type Identifier) system. Dutis simplifies this process.

#### How dutis Works

Dutis interacts with macOS's Launch Services database to manage file associations. It provides several ways to set default applications:

1. **Individual File Extensions**: Set a default app for a specific file extension
   ```bash
   # Interactive mode - shows a menu of available applications
   dutis mp4
   
   # Non-interactive mode with --write flag
   dutis mp4 --write "VLC"
   ```

2. **File Type Groups**: Efficiently set defaults for multiple related file types at once
   ```bash
   # Set default for all video formats
   dutis --group video --write "VLC"
   
   # Set default for all code files
   dutis --group code --write "Visual Studio Code"
   ```

3. **UTI (Uniform Type Identifier)**: For more advanced usage with macOS's type system
   ```bash
   # Set default for public.html UTI
   dutis --uti public.html --write "Firefox"
   ```

#### File Type Groups

One of dutis's most powerful features is its group system, which allows you to organize file extensions into logical groups and assign default applications to entire groups at once. 

Common file type groups include:
- `video` (mp4, mov, mkv, etc.)
- `audio` (mp3, flac, wav, etc.)
- `image` (jpg, png, webp, etc.)
- `code` (js, py, rs, etc.)
- `archive` (zip, tar, gz, etc.)

You can customize these groups by editing the `~/.config/dutis/groups.yaml` file after installation. Our setup automatically creates a comprehensive group configuration for you.

```bash
# List all defined groups and their extensions
dutis --list-groups

# Set default application for all files in a group
dutis --group video --write "VLC"
```

#### Default Application Configuration

Our setup includes a script for configuring default applications using dutis. This script sets appropriate default applications for common file types without requiring user interaction:

- Text/Code files (.md, .json, .py, etc.) → Visual Studio Code
- Media files (.mp4, .mkv, .mp3, etc.) → VLC
- Archive files (.zip, .rar, .7z, etc.) → The Unarchiver
- Images (.jpg, .png, .gif, etc.) → Preview
- PDFs → Preview

This feature can be controlled with the `dutis_auto_configure` feature flag in `config/config.json`. When enabled, a script is created at `~/.local/bin/set_default_apps.sh` which you can run after installation:

```bash
~/.local/bin/set_default_apps.sh
```

The script is designed to work without root privileges by installing dutis to `~/.local/bin` instead of system directories. Additionally, it uses the `--write` option for non-interactive operation, making it suitable for automation.

#### Implementation Details

Our implementation:
1. Installs dutis locally without requiring sudo privileges
2. Creates a comprehensive group configuration in `~/.config/dutis/groups.yaml`
3. Provides a script that uses the non-interactive `--write` option to set defaults
4. Uses group assignments when possible for efficiency
5. Includes timeout protection to prevent hanging during automated setup

## Operation Modes

### Ansible Playbook (macos_setup.yml)

The Ansible approach offers:
- **Idempotent** operation (can be run multiple times safely)
- **Declarative configuration** of the entire system
- **Feature toggles** for enabling/disabling components
- **Modular task files** for better organization and maintenance
- Better for managing multiple machines or team setups

The playbook is organized into separate task files for better maintainability:
- `tasks/packages.yml`: Installation of Homebrew packages and applications
- `tasks/python_env.yml`: Python environment setup with pyenv and UV
- `tasks/shell_config.yml`: Shell configuration for zsh
- `tasks/dutis.yml`: Installation and configuration of dutis for default applications
- `tasks/lazyvim.yml`: LazyVim installation and configuration

#### Ansible Requirements

Unlike the bash script, Ansible has prerequisites:
- Python must be installed first (the setupAnsible.sh script handles this)
- Ansible collections must be installed (automatically handled by the playbook)
- Proper permissions for running Ansible tasks
- Some familiarity with Ansible concepts (playbooks, tasks, etc.)

#### Ansible Improvements

Recent improvements to the Ansible setup include:
- **Auto-installation of collections**: The playbook automatically installs required Ansible collections
- **Requirements file**: `ansible/requirements.yml` specifies needed collections
- **Test script**: `scripts/test-ansible.sh` validates the setup before running
- **Better error handling**: Improved syntax and error detection

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