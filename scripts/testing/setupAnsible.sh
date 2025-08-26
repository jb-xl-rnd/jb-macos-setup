#!/bin/bash
# setupAnsible.sh
#
# Description: Installs Ansible using Homebrew and required collections
# - Installs Homebrew if not present
# - Installs Ansible directly through Homebrew
# - Installs required Ansible collections
# - Creates Ansible config directory

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

# Install Homebrew if not installed
if ! command -v brew &> /dev/null; then
    print_style "Installing Homebrew..." "info"
    /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"
fi

# Install Ansible directly via Homebrew
print_style "Installing Ansible via Homebrew..." "info"
brew install ansible

# Create Ansible config directory
print_style "Creating Ansible config directory..." "info"
mkdir -p ~/.ansible/roles

# Install community.general collection
print_style "Installing required Ansible collections..." "info"
ansible-galaxy collection install community.general

print_style "Ansible installation complete!" "success"
print_style "Testing homebrew module..." "info"

# Create a test playbook to verify the homebrew module
cat > /tmp/test_homebrew.yml << 'EOF'
---
- name: Test Homebrew Module
  hosts: localhost
  become: false
  tasks:
    - name: Get list of installed packages
      community.general.homebrew_info:
        name: git
      register: brew_info
    
    - name: Display installed package info
      debug:
        var: brew_info
EOF

# Run the test playbook
print_style "Running test playbook to verify the homebrew module..." "info"
ansible-playbook /tmp/test_homebrew.yml

print_style "Setup complete. You can now run the main playbook." "success"