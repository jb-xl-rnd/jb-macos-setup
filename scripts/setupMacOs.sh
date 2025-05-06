#!/bin/bash
# setupMacOS.sh
#
# Description: Comprehensive setup script for macOS applications and configurations
# - Updates macOS built-in software
# - Installs various command line utilities via Homebrew
# - Installs GUI applications via Homebrew Cask
# - Installs applications from the Mac App Store
# - Sets up Python development environment
# - Configures shell with useful functions and aliases

# Color output
print_style() {
    if [ "$2" == "info" ] ; then
        COLOR="96m"
    elif [ "$2" == "success" ] ; then
        COLOR="92m"
    elif [ "$2" == "warning" ] ; then
        COLOR="93m"
    elif [ "$2" == "error" ] ; then
        COLOR="91m"
    else
        COLOR="0m"
    fi
    echo -e "\033[${COLOR}$1\033[0m"
}

# Load configuration from JSON
CONFIG_DIR="$(dirname "$(dirname "$0")")/config"
PACKAGES_FILE="$CONFIG_DIR/packages.json"
SHELL_CONFIG_FILE="$CONFIG_DIR/shell_config.json"
CONFIG_FILE="$CONFIG_DIR/config.json"

# Check for jq
if ! command -v jq &> /dev/null; then
    print_style "Installing jq..." "info"
    brew install jq
fi

# Check if running in minimal mode
MINIMAL=false
if [ "$1" == "--minimal" ]; then
    MINIMAL=true
    print_style "Running in minimal mode - installing only core packages" "warning"
fi

# Update Built-in Software
print_style "Updating macOS built-in software..." "info"
softwareupdate --install -a

# Install Homebrew packages
print_style "Installing Homebrew packages..." "info"

if [ "$MINIMAL" = true ]; then
    # Install core packages only
    PACKAGES=$(jq -r '.bash_setup.core_packages[]' "$CONFIG_FILE")
    for pkg in $PACKAGES; do
        print_style "Installing $pkg..." "info"
        brew install "$pkg"
    done
    
    # Install core cask apps only
    CASK_APPS=$(jq -r '.bash_setup.core_cask_apps[]' "$CONFIG_FILE")
    for app in $CASK_APPS; do
        print_style "Installing $app..." "info"
        brew install --cask "$app"
    done
else
    # Install all packages
    PACKAGES=$(jq -r '.brew_packages[]' "$PACKAGES_FILE")
    for pkg in $PACKAGES; do
        print_style "Installing $pkg..." "info"
        brew install "$pkg"
    done
    
    # Install all cask apps
    CASK_APPS=$(jq -r '.brew_cask_apps[]' "$PACKAGES_FILE")
    for app in $CASK_APPS; do
        print_style "Installing $app..." "info"
        brew install --cask "$app"
    done
    
    # Install Mac App Store apps
    print_style "Installing Mac App Store apps..." "info"
    MAS_APPS=$(jq -c '.mas_apps[]' "$PACKAGES_FILE")
    for app in $MAS_APPS; do
        id=$(echo "$app" | jq -r '.id')
        name=$(echo "$app" | jq -r '.name')
        print_style "Installing $name..." "info"
        mas install "$id"
    done
    
    # Install Python packages if not in minimal mode
    if [ "$(jq -r '.feature_flags.use_uv_package_manager' "$CONFIG_FILE")" = "true" ]; then
        print_style "Installing Python packages with UV..." "info"
        mkdir -p "$HOME/.venvs"  # Create the directory for virtual environments
        
        PIP_PACKAGES=$(jq -r '.pip_packages[]' "$PACKAGES_FILE")
        for pkg in $PIP_PACKAGES; do
            print_style "Installing $pkg..." "info"
            uv pip install "$pkg"
        done
    else
        print_style "Installing Python packages with pip..." "info"
        PIP_PACKAGES=$(jq -r '.pip_packages[]' "$PACKAGES_FILE")
        for pkg in $PIP_PACKAGES; do
            print_style "Installing $pkg..." "info"
            pip3 install "$pkg"
        done
    fi
fi

# Configure shell
ZSHRC="$HOME/.zshrc"
print_style "Configuring shell..." "info"

# Process each zsh addition
if [ -f "$SHELL_CONFIG_FILE" ]; then
    USE_PYENV=$(jq -r '.feature_flags.use_pyenv // false' "$CONFIG_FILE")
    USE_CUSTOM_PROMPT=$(jq -r '.feature_flags.custom_shell_prompt // false' "$CONFIG_FILE")
    USE_ALIAS_COMPAT=$(jq -r '.feature_flags.alias_compatibility // false' "$CONFIG_FILE")
    USE_UV=$(jq -r '.feature_flags.use_uv_package_manager // false' "$CONFIG_FILE")
    
    # Add pyenv config if enabled
    if [ "$USE_PYENV" = "true" ]; then
        PYENV_CONFIG=$(jq -r '.zsh_additions[] | select(.name=="pyenv_config") | .content' "$SHELL_CONFIG_FILE")
        if ! grep -q 'export PYENV_ROOT=' "$ZSHRC"; then
            print_style "Adding pyenv configuration to .zshrc..." "info"
            echo -e "\n# Pyenv configuration" >> "$ZSHRC"
            echo "$PYENV_CONFIG" >> "$ZSHRC"
        fi
    fi
    
    # Add UV config if enabled
    if [ "$USE_UV" = "true" ]; then
        UV_CONFIG=$(jq -r '.zsh_additions[] | select(.name=="uv_config") | .content' "$SHELL_CONFIG_FILE")
        if ! grep -q 'UV_VIRTUALENV_ROOT' "$ZSHRC"; then
            print_style "Adding UV configuration to .zshrc..." "info"
            echo -e "\n# UV package manager configuration" >> "$ZSHRC"
            echo "$UV_CONFIG" >> "$ZSHRC"
        fi
    fi
    
    # Add custom prompt if enabled
    if [ "$USE_CUSTOM_PROMPT" = "true" ]; then
        CUSTOM_PROMPT=$(jq -r '.zsh_additions[] | select(.name=="custom_prompt") | .content' "$SHELL_CONFIG_FILE")
        if ! grep -q 'set_prompt()' "$ZSHRC"; then
            print_style "Adding custom prompt to .zshrc..." "info"
            echo -e "\n# Custom prompt" >> "$ZSHRC"
            echo "$CUSTOM_PROMPT" >> "$ZSHRC"
        fi
    fi
    
    # Add compatibility aliases if enabled
    if [ "$USE_ALIAS_COMPAT" = "true" ]; then
        # Neofetch alias
        NEOFETCH_ALIAS=$(jq -r '.zsh_additions[] | select(.name=="neofetch_alias") | .content' "$SHELL_CONFIG_FILE")
        if ! grep -q 'alias neofetch=' "$ZSHRC"; then
            print_style "Adding neofetch alias to .zshrc..." "info"
            echo -e "\n# Compatibility aliases" >> "$ZSHRC"
            echo "$NEOFETCH_ALIAS" >> "$ZSHRC"
        fi
        
        # lsblk alias
        LSBLK_ALIAS=$(jq -r '.zsh_additions[] | select(.name=="lsblk_alias") | .content' "$SHELL_CONFIG_FILE")
        if ! grep -q 'alias lsblk=' "$ZSHRC"; then
            print_style "Adding lsblk alias to .zshrc..." "info"
            echo "$LSBLK_ALIAS" >> "$ZSHRC"
        fi
    fi
fi

print_style "Setup complete!" "success"
print_style "Please restart your terminal or run 'source ~/.zshrc' to apply changes." "info"