#!/bin/bash
# installDutis.sh
#
# Description: Installs dutis (Default UTI Setter) for managing default applications on macOS
# GitHub: https://github.com/tsonglew/dutis
# Requirements: Rust/cargo must be installed

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

# Check for Rust installation
if ! command -v cargo &> /dev/null; then
    print_style "Rust is required but not installed. Installing Rust..." "warning"
    curl --proto '=https' --tlsv1.2 -sSf https://sh.rustup.rs | sh -s -- -y
    source "$HOME/.cargo/env"
fi

# Create a temporary directory
TEMP_DIR=$(mktemp -d)
print_style "Created temporary directory: $TEMP_DIR" "info"

# Clone the repository
print_style "Cloning the dutis repository..." "info"
git clone https://github.com/tsonglew/dutis.git "$TEMP_DIR/dutis"
cd "$TEMP_DIR/dutis" || {
    print_style "Failed to navigate to cloned repository" "error"
    exit 1
}

# Build the binary
print_style "Building dutis..." "info"
cargo build --release

# Create local bin directory if it doesn't exist
print_style "Creating ~/.local/bin directory..." "info"
mkdir -p "$HOME/.local/bin"

# Install the binary
print_style "Installing dutis to ~/.local/bin/" "info"
cp target/release/dutis "$HOME/.local/bin/"

# Add to PATH if not already there
if ! grep -q 'PATH="$HOME/.local/bin:$PATH"' "$HOME/.zshrc" &>/dev/null; then
    print_style "Adding ~/.local/bin to PATH in .zshrc" "info"
    echo '# Add ~/.local/bin to PATH if it does not exist' >> "$HOME/.zshrc"
    echo 'if [[ ":$PATH:" != *":$HOME/.local/bin:"* ]]; then' >> "$HOME/.zshrc"
    echo '  export PATH="$HOME/.local/bin:$PATH"' >> "$HOME/.zshrc"
    echo 'fi' >> "$HOME/.zshrc"
    
    # Source the updated PATH
    export PATH="$HOME/.local/bin:$PATH"
fi

# Verify installation
if [ -x "$HOME/.local/bin/dutis" ]; then
    print_style "dutis installed successfully!" "success"
    print_style "Usage examples:" "info"
    print_style "  $HOME/.local/bin/dutis mp4           # Set default app for .mp4 files" "info"
    print_style "  $HOME/.local/bin/dutis --group video # Set default app for all video files" "info"
    print_style "Note: You may need to restart your terminal or run 'source ~/.zshrc' to update your PATH" "warning"
else
    print_style "dutis installation failed" "error"
fi

# Clean up
print_style "Cleaning up..." "info"
cd - > /dev/null || true
rm -rf "$TEMP_DIR"