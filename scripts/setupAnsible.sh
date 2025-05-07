#!/bin/bash
# setupAnsible.sh
#
# Description: Installs Ansible using Homebrew to bypass Python environment restrictions
# - Installs Homebrew if not present
# - Installs Ansible directly through Homebrew
# - Creates Ansible config directory

# Install Homebrew if not installed
if ! command -v brew &> /dev/null; then
    /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"
fi

# Install Ansible directly via Homebrew
brew install ansible

# Create Ansible config directory
mkdir -p ~/.ansible/roles

echo "Ansible installation complete. You can now run the playbook."