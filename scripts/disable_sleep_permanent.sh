#!/bin/bash
# Script to permanently disable sleep on macOS for server use

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

print_style "=== Configuring Mac for Server Mode (No Sleep) ===" "info"

# 1. Disable all sleep settings
print_style "Disabling system sleep..." "info"
sudo pmset -a sleep 0
sudo pmset -a disksleep 0
sudo pmset -a displaysleep 0
sudo pmset -a powernap 0
sudo pmset -a autorestart 1
sudo pmset -a womp 1

# 2. Disable app nap system-wide
print_style "Disabling App Nap..." "info"
defaults write NSGlobalDomain NSAppSleepDisabled -bool YES

# 3. Keep the system awake indefinitely
print_style "Setting system to never sleep..." "info"
sudo systemsetup -setcomputersleep Never
sudo systemsetup -setdisplaysleep Never
sudo systemsetup -setharddisksleep Never

# 4. Disable standby mode
print_style "Disabling standby mode..." "info"
sudo pmset -a standby 0
sudo pmset -a standbydelay 0
sudo pmset -a autopoweroff 0

# 5. Disable hibernation
print_style "Disabling hibernation..." "info"
sudo pmset -a hibernatemode 0

# 6. Remove sleep image to save disk space
print_style "Removing sleep image file..." "info"
sudo rm -f /var/vm/sleepimage
sudo mkdir /var/vm/sleepimage

# 7. Enable wake on network access
print_style "Enabling wake on network access..." "info"
sudo pmset -a womp 1
sudo pmset -a ttyskeepawake 1

# 8. Prevent idle system sleep
print_style "Preventing idle sleep..." "info"
sudo pmset -a acwake 1
sudo pmset -a lidwake 1

# 9. Create a LaunchDaemon to keep the system awake
print_style "Creating LaunchDaemon for persistent wake..." "info"
sudo tee /Library/LaunchDaemons/com.server.nosleep.plist > /dev/null << EOF
<?xml version="1.0" encoding="UTF-8"?>
<!DOCTYPE plist PUBLIC "-//Apple//DTD PLIST 1.0//EN" "http://www.apple.com/DTDs/PropertyList-1.0.dtd">
<plist version="1.0">
<dict>
    <key>Label</key>
    <string>com.server.nosleep</string>
    <key>ProgramArguments</key>
    <array>
        <string>/usr/bin/caffeinate</string>
        <string>-dims</string>
    </array>
    <key>RunAtLoad</key>
    <true/>
    <key>KeepAlive</key>
    <true/>
    <key>StandardErrorPath</key>
    <string>/var/log/nosleep.err</string>
    <key>StandardOutPath</key>
    <string>/var/log/nosleep.out</string>
</dict>
</plist>
EOF

# 10. Load the LaunchDaemon
print_style "Loading LaunchDaemon..." "info"
sudo launchctl load -w /Library/LaunchDaemons/com.server.nosleep.plist

# 11. Show current power settings
print_style "=== Current Power Settings ===" "success"
pmset -g

# 12. Create uninstall script
cat > ~/disable_sleep_uninstall.sh << 'UNINSTALL'
#!/bin/bash
echo "=== Restoring Default Sleep Settings ==="

# Unload LaunchDaemon
sudo launchctl unload -w /Library/LaunchDaemons/com.server.nosleep.plist
sudo rm -f /Library/LaunchDaemons/com.server.nosleep.plist

# Restore default sleep settings
sudo pmset -a sleep 10
sudo pmset -a disksleep 10
sudo pmset -a displaysleep 10
sudo pmset -a powernap 1
sudo pmset -a autorestart 0
sudo pmset -a womp 1
sudo pmset -a standby 1
sudo pmset -a autopoweroff 1
sudo pmset -a hibernatemode 3

# Re-enable App Nap
defaults write NSGlobalDomain NSAppSleepDisabled -bool NO

echo "Default sleep settings restored!"
pmset -g
UNINSTALL

chmod +x ~/disable_sleep_uninstall.sh

print_style "=== Server Mode Configuration Complete ===" "success"
print_style "The system will now stay awake indefinitely." "info"
print_style "To restore default settings, run: ~/disable_sleep_uninstall.sh" "info"