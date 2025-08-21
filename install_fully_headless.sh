#!/bin/bash
# Fully headless installation script with permission handling

set -e

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

print_style "=== Starting Fully Headless Installation ===" "info"

# Use caffeinate to prevent sleep during entire process
caffeinate -dims bash << 'INSTALL_SCRIPT'

cd ~/macos-setup

# Set up environment
export PATH="/opt/homebrew/bin:/usr/local/bin:/usr/bin:/bin:/usr/sbin:/sbin"
export NONINTERACTIVE=1
export CI=1
export HOMEBREW_NO_AUTO_UPDATE=1
export HOMEBREW_NO_INSTALL_CLEANUP=1
export HOMEBREW_NO_ENV_HINTS=1

# Disable analytics
export HOMEBREW_NO_ANALYTICS=1
export HOMEBREW_NO_GITHUB_API=1

# Setup sudo password helper
echo '#!/bin/bash' > /tmp/sudo_pass.sh
echo 'echo "pass"' >> /tmp/sudo_pass.sh
chmod +x /tmp/sudo_pass.sh
export SUDO_ASKPASS=/tmp/sudo_pass.sh

echo "=== Step 1: Configuring System Permissions ==="

# Disable Gatekeeper and quarantine temporarily
echo "pass" | sudo -S spctl --master-disable 2>/dev/null || true
echo "pass" | sudo -S defaults write com.apple.LaunchServices LSQuarantine -bool false 2>/dev/null || true

# Configure firewall to allow Python and tools
echo "pass" | sudo -S /usr/libexec/ApplicationFirewall/socketfilterfw --setglobalstate off 2>/dev/null || true

echo "=== Step 2: Installing Homebrew ==="
if ! command -v brew &> /dev/null; then
    echo "pass" | /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"
    eval "$(/opt/homebrew/bin/brew shellenv)"
else
    echo "Homebrew already installed"
    eval "$(/opt/homebrew/bin/brew shellenv)" 2>/dev/null || true
fi

echo "=== Step 3: Installing Core Dependencies ==="
brew install cmake git wget python@3.12 ansible uv || true

echo "=== Step 4: Setting up Python environment ==="
# Create venv for ansible to avoid permission issues
python3 -m venv ~/ansible-venv || true
source ~/ansible-venv/bin/activate || true
pip install --upgrade pip ansible || true

echo "=== Step 5: Installing Ansible Collections ==="
ansible-galaxy collection install community.general || true

echo "=== Step 6: Running Ansible Playbook (LLM only) ==="
cd ~/macos-setup

# Create ansible.cfg to avoid warnings and issues
cat > ansible.cfg << 'EOF'
[defaults]
host_key_checking = False
gathering = smart
fact_caching = jsonfile
fact_caching_connection = /tmp/ansible_cache
fact_caching_timeout = 3600
stdout_callback = yaml
callback_whitelist = profile_tasks
interpreter_python = auto_silent
ansible_python_interpreter = auto_silent
[ssh_connection]
pipelining = True
EOF

# Run playbook with LLM tags only
ANSIBLE_LOCALHOST_WARNING=False \
ANSIBLE_INVENTORY_UNPARSED_WARNING=False \
ANSIBLE_DEPRECATION_WARNINGS=False \
ANSIBLE_COMMAND_WARNINGS=False \
PYTHONWARNINGS="ignore" \
ansible-playbook ./ansible/macos_setup.yml --tags llm -v \
    --connection=local \
    --inventory localhost, \
    -e ansible_python_interpreter=/opt/homebrew/bin/python3

# Clean up
rm -f /tmp/sudo_pass.sh
rm -f ansible.cfg

echo "=== Step 7: Restoring Security Settings ==="
echo "pass" | sudo -S spctl --master-enable 2>/dev/null || true
echo "pass" | sudo -S defaults write com.apple.LaunchServices LSQuarantine -bool true 2>/dev/null || true
echo "pass" | sudo -S /usr/libexec/ApplicationFirewall/socketfilterfw --setglobalstate on 2>/dev/null || true

echo "=== Installation Complete ==="

INSTALL_SCRIPT

print_style "=== Testing LLM Setup ===" "info"
if [ -f "./test_llm_setup.sh" ]; then
    ./test_llm_setup.sh
fi

print_style "=== Fully Headless Installation Complete ===" "success"