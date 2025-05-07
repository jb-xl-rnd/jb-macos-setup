#!/bin/bash
# setupAnsible.sh
#
# Description: Installs Ansible in a user environment to bypass external management restrictions
# - Installs Homebrew if not present
# - Installs Python if not present
# - Installs Ansible with --user flag to bypass externally managed environment
# - Creates Ansible config directory

# Install Homebrew if not installed
if ! command -v brew &> /dev/null; then
    /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"
fi

# Install Python if not present
brew install python

# Install Ansible with --user flag to bypass "externally managed environment" error
pip3 install --user ansible

# Add ~/.local/bin to PATH if not already there
if [[ ":$PATH:" != *":$HOME/.local/bin:"* ]]; then
    echo 'export PATH="$HOME/.local/bin:$PATH"' >> ~/.zshrc
    export PATH="$HOME/.local/bin:$PATH"
fi

# Create Ansible config directory
mkdir -p ~/.ansible/roles

echo "Ansible installation complete. You can now run the playbook."
echo "Note: If you're opening a new terminal, you may need to source your .zshrc first."