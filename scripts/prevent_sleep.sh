#!/bin/bash
# Helper script to prevent Mac from sleeping during long operations

# Function to start caffeinate in background
start_caffeinate() {
    # Kill any existing caffeinate processes
    pkill caffeinate 2>/dev/null || true
    
    # Start caffeinate in background
    # -d prevents display sleep
    # -i prevents system idle sleep  
    # -m prevents disk idle sleep
    # -s prevents sleep when on AC power
    caffeinate -dims &
    CAFFEINATE_PID=$!
    
    # Save PID for later cleanup
    echo $CAFFEINATE_PID > /tmp/caffeinate.pid
    
    echo "☕ Caffeinate started (PID: $CAFFEINATE_PID) - System will stay awake"
    echo "To stop manually: kill $CAFFEINATE_PID"
}

# Function to stop caffeinate
stop_caffeinate() {
    if [ -f /tmp/caffeinate.pid ]; then
        CAFFEINATE_PID=$(cat /tmp/caffeinate.pid)
        if ps -p $CAFFEINATE_PID > /dev/null 2>&1; then
            kill $CAFFEINATE_PID 2>/dev/null || true
            echo "☕ Caffeinate stopped - System can sleep normally"
        fi
        rm -f /tmp/caffeinate.pid
    else
        # Try to kill any caffeinate process
        pkill caffeinate 2>/dev/null || true
    fi
}

# Trap to ensure caffeinate is stopped on script exit
trap stop_caffeinate EXIT INT TERM

# Handle arguments
case "${1:-start}" in
    start)
        start_caffeinate
        ;;
    stop)
        stop_caffeinate
        ;;
    status)
        if [ -f /tmp/caffeinate.pid ]; then
            CAFFEINATE_PID=$(cat /tmp/caffeinate.pid)
            if ps -p $CAFFEINATE_PID > /dev/null 2>&1; then
                echo "☕ Caffeinate is running (PID: $CAFFEINATE_PID)"
            else
                echo "☕ Caffeinate PID file exists but process not running"
            fi
        else
            echo "☕ Caffeinate is not running"
        fi
        ;;
    *)
        echo "Usage: $0 {start|stop|status}"
        echo "  start  - Prevent system from sleeping"
        echo "  stop   - Allow system to sleep normally"
        echo "  status - Check if caffeinate is running"
        exit 1
        ;;
esac