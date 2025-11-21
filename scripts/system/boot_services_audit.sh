#!/bin/bash

#######################################################################
# macOS Boot Services and Background Process Audit Script
#
# This script audits all services, agents, and processes that run at
# boot time or in the background on macOS.
#
# Usage:
#   ./boot_services_audit.sh [--verbose] [--output FILE]
#
# Options:
#   --verbose    Show detailed information
#   --output     Save report to file
#######################################################################

set -e

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

VERBOSE=false
OUTPUT_FILE=""

# Parse arguments
while [[ $# -gt 0 ]]; do
    case $1 in
        --verbose)
            VERBOSE=true
            shift
            ;;
        --output)
            OUTPUT_FILE="$2"
            shift 2
            ;;
        *)
            echo "Unknown option: $1"
            exit 1
            ;;
    esac
done

# Print header
print_header() {
    echo -e "${BLUE}======================================${NC}"
    echo -e "${BLUE}$1${NC}"
    echo -e "${BLUE}======================================${NC}"
    echo
}

print_section() {
    echo -e "${GREEN}$1${NC}"
    echo "--------------------------------------"
}

# Start audit
{
    echo "macOS Boot Services & Background Process Audit"
    echo "Generated: $(date)"
    echo "Hostname: $(hostname)"
    echo "macOS Version: $(sw_vers -productVersion)"
    echo

    # ============================================
    # 1. SYSTEM-LEVEL LAUNCHDAEMONS
    # ============================================
    print_header "1. SYSTEM-LEVEL LAUNCHDAEMONS (Boot-time services)"

    print_section "Third-party LaunchDaemons (/Library/LaunchDaemons)"
    if [ -d "/Library/LaunchDaemons" ]; then
        ls -lh /Library/LaunchDaemons/ | tail -n +2 | awk '{print $9, "(" $5 ")"}'
        echo

        if [ "$VERBOSE" = true ]; then
            echo "Details:"
            for file in /Library/LaunchDaemons/*.plist; do
                if [ -f "$file" ]; then
                    label=$(defaults read "$file" Label 2>/dev/null || echo "Unknown")
                    program=$(defaults read "$file" Program 2>/dev/null || echo "Unknown")
                    echo "  - $(basename "$file")"
                    echo "    Label: $label"
                    echo "    Program: $program"
                    echo
                fi
            done
        fi
    fi

    print_section "System LaunchDaemons (count only)"
    echo "Total system daemons: $(ls /System/Library/LaunchDaemons/*.plist 2>/dev/null | wc -l | tr -d ' ')"
    echo "(These are built-in macOS services)"
    echo

    # ============================================
    # 2. USER-LEVEL LAUNCHAGENTS
    # ============================================
    print_header "2. USER-LEVEL LAUNCHAGENTS (Login-time services)"

    print_section "User-specific LaunchAgents (~/Library/LaunchAgents)"
    if [ -d "$HOME/Library/LaunchAgents" ]; then
        ls -lh ~/Library/LaunchAgents/ | tail -n +2 | awk '{print $9, "(" $5 ")"}'
        echo

        if [ "$VERBOSE" = true ]; then
            echo "Details:"
            for file in ~/Library/LaunchAgents/*.plist; do
                if [ -f "$file" ] && [ ! -L "$file" ]; then
                    label=$(defaults read "$file" Label 2>/dev/null || echo "Unknown")
                    program=$(defaults read "$file" ProgramArguments 2>/dev/null | head -1 | sed 's/[()]//g' | xargs || echo "Unknown")
                    echo "  - $(basename "$file")"
                    echo "    Label: $label"
                    echo "    Program: $program"
                    echo
                elif [ -L "$file" ]; then
                    echo "  - $(basename "$file") -> $(readlink "$file")"
                    echo
                fi
            done
        fi
    fi

    print_section "Third-party LaunchAgents (/Library/LaunchAgents)"
    if [ -d "/Library/LaunchAgents" ]; then
        ls -lh /Library/LaunchAgents/ | tail -n +2 | awk '{print $9, "(" $5 ")"}'
        echo
    fi

    print_section "System LaunchAgents (count only)"
    echo "Total system agents: $(ls /System/Library/LaunchAgents/*.plist 2>/dev/null | wc -l | tr -d ' ')"
    echo "(These are built-in macOS services)"
    echo

    # ============================================
    # 3. RUNNING LAUNCHD SERVICES
    # ============================================
    print_header "3. CURRENTLY RUNNING NON-APPLE SERVICES"

    print_section "Active third-party launchd services"
    launchctl list | grep -v "com.apple" | head -30
    echo

    # ============================================
    # 4. LOGIN ITEMS
    # ============================================
    print_header "4. LOGIN ITEMS (Apps starting at login)"

    print_section "User Login Items"
    osascript -e 'tell application "System Events" to get the name of every login item' 2>/dev/null || echo "Unable to retrieve login items"
    echo

    # ============================================
    # 5. BACKGROUND PROCESSES
    # ============================================
    print_header "5. BACKGROUND PROCESSES"

    print_section "Non-Apple running processes (top 30)"
    ps aux | grep -Ev "com\.apple\.|/System/|/usr/libexec" | grep -v "grep" | head -30 | awk '{print $1, $2, $11}'
    echo

    if [ "$VERBOSE" = true ]; then
        print_section "Process summary by executable"
        ps aux | grep -v "grep" | awk '{print $11}' | sort | uniq -c | sort -rn | head -20
        echo
    fi

    # ============================================
    # 6. SYSTEM EXTENSIONS
    # ============================================
    print_header "6. SYSTEM EXTENSIONS & KERNEL EXTENSIONS"

    print_section "System Extensions"
    systemextensionsctl list 2>/dev/null || echo "No system extensions or unable to list"
    echo

    print_section "Non-Apple Kernel Extensions"
    kextstat 2>/dev/null | grep -v "com.apple" || echo "No non-Apple kernel extensions found"
    echo

    # ============================================
    # 7. STARTUP AGENTS SUMMARY
    # ============================================
    print_header "7. SUMMARY"

    echo "LaunchDaemons:"
    echo "  - Third-party: $(ls /Library/LaunchDaemons/*.plist 2>/dev/null | wc -l | tr -d ' ')"
    echo "  - System: $(ls /System/Library/LaunchDaemons/*.plist 2>/dev/null | wc -l | tr -d ' ')"
    echo
    echo "LaunchAgents:"
    echo "  - User: $(ls ~/Library/LaunchAgents/*.plist 2>/dev/null | wc -l | tr -d ' ')"
    echo "  - Third-party: $(ls /Library/LaunchAgents/*.plist 2>/dev/null | wc -l | tr -d ' ')"
    echo "  - System: $(ls /System/Library/LaunchAgents/*.plist 2>/dev/null | wc -l | tr -d ' ')"
    echo
    echo "Login Items: $(osascript -e 'tell application "System Events" to get the name of every login item' 2>/dev/null | tr ',' '\n' | wc -l | tr -d ' ')"
    echo
    echo "Running Services: $(launchctl list | grep -v "com.apple" | wc -l | tr -d ' ') non-Apple services"
    echo

    # ============================================
    # 8. THIRD-PARTY SERVICE IDENTIFICATION
    # ============================================
    print_header "8. THIRD-PARTY SERVICES IDENTIFICATION"

    echo "The following third-party services were identified:"
    echo

    for file in /Library/LaunchDaemons/*.plist; do
        if [ -f "$file" ]; then
            basename "$file" .plist
        fi
    done

    for file in ~/Library/LaunchAgents/*.plist; do
        if [ -f "$file" ] && [ ! -L "$file" ]; then
            basename "$file" .plist
        fi
    done

    echo
    echo "Audit complete."

} | if [ -n "$OUTPUT_FILE" ]; then
    tee "$OUTPUT_FILE"
else
    cat
fi
