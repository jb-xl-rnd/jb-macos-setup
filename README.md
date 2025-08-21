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

### Interactive Installation (Recommended for Desktop)
```bash
./install.sh
```

### Headless Installation (For Remote/Automated Setup)
```bash
# Complete setup without GUI interactions
./install_headless.sh --all

# Just install LLM components
./install_headless.sh --llm

# Run with sleep prevention
./install_nosleep.sh
```

### Direct LLM Installation
```bash
# Quick LLM setup bypassing ansible
./direct_llm_install.sh
```

## Directory Structure

```
MacOS/
├── ansible/                  # Ansible playbooks and templates
│   ├── macos_setup.yml      # Main playbook
│   ├── tasks/               # Individual task modules
│   └── templates/           # Jinja2 templates
├── config/                  # Configuration files
│   ├── packages.json        # Package definitions
│   ├── shell_config.json   # Shell configurations
│   ├── config.json         # Feature flags
│   └── llm_config.json     # LLM settings
├── scripts/                 # Setup scripts
│   ├── setupInitialMacOS.sh # Initial environment setup
│   ├── setupAnsible.sh      # Ansible installation
│   ├── prevent_sleep.sh    # Sleep prevention utility
│   └── setup_permissions.sh # Permission configuration
├── docs/                    # Documentation
└── install*.sh             # Various installers
```

## Installation Methods

### 1. Standard Ansible-based Setup

```bash
# Install Ansible
./scripts/setupAnsible.sh

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
./install_headless.sh --all

# Individual components
./install_headless.sh --initial      # Homebrew and basics
./install_headless.sh --ansible      # Run ansible playbook
./install_headless.sh --llm          # LLM setup only
./install_headless.sh --test         # Test installation
```

### 3. Direct Component Installation

For when you need specific functionality without the full setup:

```bash
# Direct LLM installation (fastest)
./direct_llm_install.sh

# Sleep prevention during long operations
./scripts/prevent_sleep.sh start
# ... run your installation ...
./scripts/prevent_sleep.sh stop
```

## Features

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

### Feature Flags (`config/config.json`)
Control installation behavior:
```json
{
  "feature_flags": {
    "use_pyenv": true,
    "use_uv_package_manager": true,
    "custom_shell_prompt": true,
    "install_dutis": true
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
ssh user@mac-mini 'cd ~/macos-setup && ./install_headless.sh --all'
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
- Run `scripts/setup_permissions.sh` before installation

### LLM Server Not Accessible
- Check firewall settings
- Ensure server is bound to correct interface (0.0.0.0 for external)
- Verify model file exists in `~/llm-workspace/models/`

## Testing

Verify your installation:
```bash
# Test everything
./test_llm_setup.sh

# Test specific components
ansible-playbook ansible/macos_setup.yml --check
llm --mode health
```

## Requirements

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