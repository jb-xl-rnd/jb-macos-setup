#!/bin/bash
# Installation script with sleep prevention for MacOS Setup

set -e  # Exit on error

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

print_style "=== MacOS Automated Setup Starting ===" "info"
print_style "Preventing system sleep during installation..." "warning"

# Prevent sleep using caffeinate
# -d prevents display sleep
# -i prevents system idle sleep
# -m prevents disk idle sleep
# -s prevents system sleep when on AC power
caffeinate -dims bash <<'CAFFEINATE_SCRIPT'

cd ~/macos-setup

echo "=== System will stay awake during installation ==="
echo "Installation started at: $(date)"

# Export password for sudo
export SUDO_ASKPASS=/tmp/sudo_pass.sh
echo '#!/bin/bash' > /tmp/sudo_pass.sh
echo 'echo "pass"' >> /tmp/sudo_pass.sh
chmod +x /tmp/sudo_pass.sh

# Step 1: Install Homebrew
echo "=== Installing Homebrew ==="
if ! command -v brew &> /dev/null; then
    echo "pass" | /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"
    
    # Add Homebrew to PATH
    if [[ -f "/opt/homebrew/bin/brew" ]]; then
        eval "$(/opt/homebrew/bin/brew shellenv)"
        echo 'eval "$(/opt/homebrew/bin/brew shellenv)"' >> ~/.zprofile
        export PATH="/opt/homebrew/bin:$PATH"
    fi
else
    echo "Homebrew already installed"
    eval "$(/opt/homebrew/bin/brew shellenv)" 2>/dev/null || true
fi

# Step 2: Install core dependencies
echo "=== Installing Core Dependencies ==="
/opt/homebrew/bin/brew install python@3.12 ansible git cmake wget

# Step 3: Install Ansible collections
echo "=== Installing Ansible Collections ==="
/opt/homebrew/bin/ansible-galaxy collection install community.general

# Step 4: Install uv for Python package management
echo "=== Installing uv ==="
/opt/homebrew/bin/brew install uv
mkdir -p ~/.local/bin
ln -sf /opt/homebrew/bin/uv ~/.local/bin/uv 2>/dev/null || true

# Step 5: Run Ansible playbook
echo "=== Running Ansible Playbook ==="
cd ~/macos-setup
/opt/homebrew/bin/ansible-playbook ./ansible/macos_setup.yml -v

# Clean up
rm -f /tmp/sudo_pass.sh

echo "=== Installation Complete ==="
echo "Installation finished at: $(date)"

CAFFEINATE_SCRIPT

print_style "=== Installation Complete ===" "success"
print_style "System sleep prevention has been lifted" "info"

# Test the installation
if [ -f "./test_llm_setup.sh" ]; then
    print_style "Running installation tests..." "info"
    chmod +x ./test_llm_setup.sh
    ./test_llm_setup.sh
fi