#!/bin/bash
# setupAnsible.sh
#
# Description: Installs Ansible and its prerequisites
# - Installs Homebrew if not present
# - Installs Python if not present
# - Installs pip if not present
# - Installs Ansible via pip
# - Creates Ansible config directory

# Install Homebrew if not installed
if ! command -v brew &> /dev/null; then
    /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"
fi

# Install Python if not present
brew install python

# Install pip if not present
if ! command -v pip3 &> /dev/null; then
    curl https://bootstrap.pypa.io/get-pip.py -o get-pip.py
    python3 get-pip.py
    rm get-pip.py
fi

# Install Ansible
pip3 install ansible

# Create Ansible config directory
mkdir -p ~/.ansible/roles

echo "Ansible installation complete. You can now run the playbook."