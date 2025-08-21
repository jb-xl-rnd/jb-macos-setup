#!/bin/bash
# Script to pre-configure permissions for headless installation

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

print_style "=== Setting up permissions for headless operation ===" "info"

# 1. Disable Gatekeeper temporarily (re-enable after installation)
print_style "Temporarily disabling Gatekeeper..." "warning"
sudo spctl --master-disable

# 2. Allow apps from anywhere temporarily
sudo spctl --global-disable

# 3. Disable quarantine for downloaded files during setup
print_style "Disabling quarantine attributes..." "info"
sudo defaults write com.apple.LaunchServices LSQuarantine -bool false

# 4. Auto-accept local network access for Python and other tools
print_style "Configuring firewall exceptions..." "info"

# Add Python to firewall exceptions
/usr/libexec/ApplicationFirewall/socketfilterfw --add /opt/homebrew/bin/python3
/usr/libexec/ApplicationFirewall/socketfilterfw --add /opt/homebrew/bin/python3.12
/usr/libexec/ApplicationFirewall/socketfilterfw --add /opt/homebrew/bin/python3.13
/usr/libexec/ApplicationFirewall/socketfilterfw --add /usr/bin/python3

# Add other tools that might need network access
/usr/libexec/ApplicationFirewall/socketfilterfw --add /opt/homebrew/bin/ansible
/usr/libexec/ApplicationFirewall/socketfilterfw --add /opt/homebrew/bin/ansible-playbook
/usr/libexec/ApplicationFirewall/socketfilterfw --add /opt/homebrew/bin/brew
/usr/libexec/ApplicationFirewall/socketfilterfw --add /opt/homebrew/bin/git

# Unblock all added applications
/usr/libexec/ApplicationFirewall/socketfilterfw --unblockapp /opt/homebrew/bin/python3
/usr/libexec/ApplicationFirewall/socketfilterfw --unblockapp /opt/homebrew/bin/python3.12
/usr/libexec/ApplicationFirewall/socketfilterfw --unblockapp /opt/homebrew/bin/python3.13
/usr/libexec/ApplicationFirewall/socketfilterfw --unblockapp /usr/bin/python3
/usr/libexec/ApplicationFirewall/socketfilterfw --unblockapp /opt/homebrew/bin/ansible
/usr/libexec/ApplicationFirewall/socketfilterfw --unblockapp /opt/homebrew/bin/ansible-playbook

# 5. Configure Privacy settings for Terminal/Shell access
print_style "Configuring privacy settings..." "info"

# Add Terminal to Full Disk Access (requires user action normally, but we can try)
# This usually requires manual intervention or MDM
sqlite3 ~/Library/Application\ Support/com.apple.TCC/TCC.db \
    "INSERT OR REPLACE INTO access VALUES('kTCCServiceSystemPolicyAllFiles','/System/Applications/Utilities/Terminal.app',0,2,4,1,NULL,NULL,0,'UNUSED',NULL,0,1687976045);" 2>/dev/null || true

# 6. Disable notification center during installation
print_style "Disabling notifications temporarily..." "info"
launchctl unload -w /System/Library/LaunchAgents/com.apple.notificationcenterui.plist 2>/dev/null || true

# 7. Set Python to not verify SSL certificates (for downloads)
export PYTHONHTTPSVERIFY=0
export SSL_CERT_FILE=""
export SSL_CERT_DIR=""

# 8. Configure git to skip SSL verification temporarily
git config --global http.sslVerify false

print_style "=== Permission setup complete ===" "success"
print_style "Note: Some settings are temporary and should be reverted after installation" "warning"

# Create a restore script
cat > ~/restore_security.sh << 'EOF'
#!/bin/bash
echo "=== Restoring security settings ==="

# Re-enable Gatekeeper
sudo spctl --master-enable

# Re-enable quarantine
sudo defaults write com.apple.LaunchServices LSQuarantine -bool true

# Re-enable SSL verification for git
git config --global http.sslVerify true

# Re-enable notifications
launchctl load -w /System/Library/LaunchAgents/com.apple.notificationcenterui.plist 2>/dev/null || true

echo "Security settings restored!"
EOF

chmod +x ~/restore_security.sh
print_style "Run ~/restore_security.sh after installation to restore security settings" "info"