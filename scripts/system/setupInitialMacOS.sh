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

# Install Raycast and disable Spotlight
if ! brew list --cask raycast &> /dev/null; then
    print_style "Installing Raycast..." "info"
    brew install --cask raycast
    print_style "Raycast installed successfully" "success"
else
    print_style "Raycast already installed" "success"
fi

# Disable Spotlight keyboard shortcut (Cmd+Space) so Raycast can use it
print_style "Disabling Spotlight shortcut (Cmd+Space) for Raycast..." "info"
# Disable Spotlight shortcut via defaults
defaults write com.apple.symbolichotkeys AppleSymbolicHotKeys -dict-add 64 '{ enabled = 0; value = { parameters = (65535, 49, 1048576); type = standard; }; }'
# Restart the hotkey daemon to apply
/System/Library/PrivateFrameworks/SystemAdministration.framework/Resources/activateSettings -u 2>/dev/null || true
print_style "Spotlight shortcut disabled — set Raycast hotkey to Cmd+Space in Raycast preferences" "success"

# Install oh-my-zsh if using zsh and not already installed
if [ "$CURRENT_SHELL" = "zsh" ] && [ ! -d "$HOME/.oh-my-zsh" ]; then
    print_style "Installing oh-my-zsh..." "info"
    # KEEP_ZSHRC prevents oh-my-zsh from clobbering existing .zshrc
    KEEP_ZSHRC=yes sh -c "$(curl -fsSL https://raw.githubusercontent.com/ohmyzsh/ohmyzsh/master/tools/install.sh)" "" --unattended
    # Add oh-my-zsh source line to existing .zshrc if not present
    if ! grep -q 'source.*oh-my-zsh.sh' "$SHELL_CONFIG_FILE" 2>/dev/null; then
        # Prepend oh-my-zsh config to top of .zshrc
        TEMP_ZSHRC=$(mktemp)
        cat > "$TEMP_ZSHRC" << 'OMZRC'
# oh-my-zsh configuration
export ZSH="$HOME/.oh-my-zsh"
ZSH_THEME="robbyrussell"
plugins=(git)
source $ZSH/oh-my-zsh.sh

OMZRC
        cat "$SHELL_CONFIG_FILE" >> "$TEMP_ZSHRC"
        mv "$TEMP_ZSHRC" "$SHELL_CONFIG_FILE"
    fi
    print_style "oh-my-zsh installed successfully (existing .zshrc preserved)" "success"
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
print_style "3. Open Raycast, set its hotkey to Cmd+Space in Raycast preferences" "warning"
if [ "$CURRENT_SHELL" = "zsh" ]; then
    print_style "4. oh-my-zsh has been installed. Customize your theme in $SHELL_CONFIG_FILE" "warning"
fi