#!/bin/bash
# setupAnsible.sh
#
# Description: Forces Ansible installation in the global environment
# - Installs Homebrew if not present
# - Installs Python if not present
# - Forces Ansible installation with --ignore-installed flag
# - Creates Ansible config directory

# Install Homebrew if not installed
if ! command -v brew &> /dev/null; then
    /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"
fi

# Install Python if not present
brew install python

# Force install Ansible with --ignore-installed to override any conflicts
pip3 install --ignore-installed ansible

# Create Ansible config directory
mkdir -p ~/.ansible/roles

echo "Ansible installation complete. You can now run the playbook."