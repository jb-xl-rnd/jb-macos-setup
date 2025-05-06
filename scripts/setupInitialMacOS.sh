#!/bin/bash
# setupInitialMacOS.sh
#
# Description: Initial setup script for a new macOS installation
# - Installs Homebrew (Apple's unofficial package manager)
# - Configures shell environment for Homebrew
# - Installs iTerm2 (improved terminal)
# - Sets up oh-my-zsh (if using zsh shell)

# Print colorized output
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

# Check if Homebrew is installed
if ! command -v brew &> /dev/null; then
    print_style "Installing Homebrew..." "info"
    /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"
else
    print_style "Homebrew already installed" "success"
fi

# Detect shell and configure Homebrew
CURRENT_SHELL=$(echo $SHELL | awk -F/ '{print $NF}')
SHELL_CONFIG_FILE=""
BREW_PATH='eval "$(/opt/homebrew/bin/brew shellenv)"'

if [ "$CURRENT_SHELL" = "zsh" ]; then
    SHELL_CONFIG_FILE="$HOME/.zshrc"
elif [ "$CURRENT_SHELL" = "bash" ]; then
    SHELL_CONFIG_FILE="$HOME/.bashrc"
else
    print_style "Unsupported shell: $CURRENT_SHELL" "error"
    exit 1
fi

# Add Homebrew to path if not already present
if ! grep -q "$BREW_PATH" "$SHELL_CONFIG_FILE" 2>/dev/null; then
    print_style "Adding Homebrew to $SHELL_CONFIG_FILE..." "info"
    echo "$BREW_PATH" >> "$SHELL_CONFIG_FILE"
    # Also add to .zprofile for zsh
    if [ "$CURRENT_SHELL" = "zsh" ]; then
        echo "$BREW_PATH" >> "$HOME/.zprofile"
    fi
    print_style "Homebrew path configured" "success"
else
    print_style "Homebrew path already configured" "success"
fi

# Source the updated configuration
source "$SHELL_CONFIG_FILE" 2>/dev/null || true

# Verify Homebrew installation
if ! brew --version &> /dev/null; then
    print_style "ERROR: Homebrew installation failed or path not properly set" "error"
    exit 1
fi

# Install iTerm2 if not already installed
if ! brew list --cask iterm2 &> /dev/null; then
    print_style "Installing iTerm2..." "info"
    brew install --cask iterm2
    print_style "iTerm2 installed successfully" "success"
else
    print_style "iTerm2 already installed" "success"
fi

# Install oh-my-zsh if using zsh and not already installed
if [ "$CURRENT_SHELL" = "zsh" ] && [ ! -d "$HOME/.oh-my-zsh" ]; then
    print_style "Installing oh-my-zsh..." "info"
    sh -c "$(curl -fsSL https://raw.githubusercontent.com/ohmyzsh/ohmyzsh/master/tools/install.sh)" "" --unattended
    print_style "oh-my-zsh installed successfully" "success"
elif [ "$CURRENT_SHELL" = "zsh" ]; then
    print_style "oh-my-zsh already installed" "success"
fi

# Final verification and instructions
print_style "\nVerification:" "info"
print_style "Current Shell: $CURRENT_SHELL" "info"
print_style "Homebrew Version: $(brew --version | head -n 1)" "info"

print_style "\nNext Steps:" "warning"
print_style "1. iTerm2 has been installed. Please launch it from your Applications folder" "warning"
print_style "2. Restart your terminal or run: source $SHELL_CONFIG_FILE" "warning"
if [ "$CURRENT_SHELL" = "zsh" ]; then
    print_style "3. oh-my-zsh has been installed. Customize your theme in $SHELL_CONFIG_FILE" "warning"
fi