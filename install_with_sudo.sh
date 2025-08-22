#!/bin/bash
# Wrapper script to run installation with sudo password

cd ~/macos-setup

# Export password for sudo
export SUDO_ASKPASS=/tmp/sudo_pass.sh
echo '#!/bin/bash' > /tmp/sudo_pass.sh
echo 'echo "pass"' >> /tmp/sudo_pass.sh
chmod +x /tmp/sudo_pass.sh

# Install Homebrew with password
echo "pass" | /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"

# Add Homebrew to PATH
if [[ -f "/opt/homebrew/bin/brew" ]]; then
    eval "$(/opt/homebrew/bin/brew shellenv)"
    echo 'eval "$(/opt/homebrew/bin/brew shellenv)"' >> ~/.zprofile
fi

# Now run the rest of the setup
/opt/homebrew/bin/brew install python@3.12 ansible
/opt/homebrew/bin/ansible-galaxy collection install community.general
cd ~/macos-setup
/opt/homebrew/bin/ansible-playbook ./ansible/macos_setup.yml -v

# Clean up
rm -f /tmp/sudo_pass.sh