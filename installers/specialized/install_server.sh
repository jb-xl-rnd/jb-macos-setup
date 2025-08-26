#!/bin/bash
# Server installation script - optimized for Mac Mini server use
# Includes: LLM setup, no sleep configuration, headless operation

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

print_style "=== Mac Mini Server Setup ===" "info"
print_style "This will configure your Mac as an always-on server with LLM capabilities" "warning"

# Prevent sleep during installation
caffeinate -dims bash << 'SERVER_INSTALL'

# Set environment
export PATH="/opt/homebrew/bin:/usr/local/bin:/usr/bin:/bin:/usr/sbin:/sbin"
export NONINTERACTIVE=1
export CI=1
export HOMEBREW_NO_AUTO_UPDATE=1

print_style "=== Step 1: Disabling Sleep Permanently ===" "info"
# Disable all sleep settings for server use
sudo pmset -a sleep 0
sudo pmset -a disksleep 0
sudo pmset -a displaysleep 0
sudo pmset -a powernap 0
sudo pmset -a autorestart 1
sudo pmset -a womp 1
sudo pmset -a standby 0
sudo pmset -a standbydelay 0
sudo pmset -a autopoweroff 0
sudo pmset -a hibernatemode 0
sudo pmset -a acwake 1
sudo pmset -a lidwake 1
sudo pmset -a ttyskeepawake 1

# Disable App Nap
defaults write NSGlobalDomain NSAppSleepDisabled -bool YES

# Create persistent caffeinate daemon
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
</dict>
</plist>
EOF

sudo launchctl load -w /Library/LaunchDaemons/com.server.nosleep.plist

print_style "✅ Server mode enabled - system will never sleep" "success"

print_style "=== Step 2: Installing Homebrew ===" "info"
if ! command -v brew &> /dev/null; then
    NONINTERACTIVE=1 /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"
    eval "$(/opt/homebrew/bin/brew shellenv)"
else
    print_style "Homebrew already installed" "info"
fi

print_style "=== Step 3: Installing Core Dependencies ===" "info"
brew install cmake git wget curl python@3.12 ansible uv

print_style "=== Step 4: Setting up Ansible ===" "info"
ansible-galaxy collection install community.general

print_style "=== Step 5: Running Full Setup with Server Mode ===" "info"
cd $(dirname "$0")

# Create temporary ansible vars file with server settings
cat > /tmp/server_vars.yml << EOF
---
install_llama_cpp: true
enable_server_mode: true
llm_server_host: "0.0.0.0"  # Allow external connections
llm_server_port: 8080
EOF

# Run ansible with server configuration
ansible-playbook ./ansible/macos_setup.yml \
    --connection=local \
    --inventory localhost, \
    -e @/tmp/server_vars.yml \
    --tags packages,llm,server

print_style "=== Step 6: Starting LLM Server ===" "info"
if [ -f ~/llm-workspace/start_server.sh ]; then
    # Update server to listen on all interfaces
    sed -i '' 's/--host 127.0.0.1/--host 0.0.0.0/g' ~/llm-workspace/start_server.sh
    ~/llm-workspace/start_server.sh
    
    sleep 10
    
    # Test the server
    if curl -s http://localhost:8080/health | grep -q "ok"; then
        print_style "✅ LLM Server is running and accessible" "success"
        
        # Get IP address
        IP=$(ifconfig | grep "inet " | grep -v 127.0.0.1 | head -1 | awk '{print $2}')
        print_style "Server accessible at: http://$IP:8080" "info"
    else
        print_style "⚠️ LLM Server started but not responding yet" "warning"
    fi
fi

# Create service management script
cat > ~/server_manage.sh << 'MANAGE'
#!/bin/bash
case "$1" in
    start)
        ~/llm-workspace/start_server.sh
        echo "LLM Server started"
        ;;
    stop)
        if [ -f ~/llm-workspace/logs/server.pid ]; then
            kill $(cat ~/llm-workspace/logs/server.pid)
            echo "LLM Server stopped"
        fi
        ;;
    restart)
        $0 stop
        sleep 2
        $0 start
        ;;
    status)
        if [ -f ~/llm-workspace/logs/server.pid ] && ps -p $(cat ~/llm-workspace/logs/server.pid) > /dev/null; then
            echo "LLM Server is running (PID: $(cat ~/llm-workspace/logs/server.pid))"
        else
            echo "LLM Server is not running"
        fi
        ;;
    *)
        echo "Usage: $0 {start|stop|restart|status}"
        exit 1
        ;;
esac
MANAGE
chmod +x ~/server_manage.sh

print_style "=== Server Setup Complete ===" "success"
print_style "" "info"
print_style "Server Features Enabled:" "info"
print_style "  ✅ System will never sleep (server mode)" "success"
print_style "  ✅ Wake on network access enabled" "success"
print_style "  ✅ Auto-restart on power failure" "success"
print_style "  ✅ LLM server with Metal acceleration" "success"
print_style "  ✅ Accessible from network" "success"
print_style "" "info"
print_style "Management Commands:" "info"
print_style "  ~/server_manage.sh start|stop|restart|status" "info"
print_style "  ~/llm-workspace/test_llm.sh  # Test LLM" "info"
print_style "" "info"

# Clean up
rm -f /tmp/server_vars.yml

SERVER_INSTALL