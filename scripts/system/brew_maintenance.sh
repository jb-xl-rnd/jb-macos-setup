#!/bin/bash
# Homebrew Maintenance Script
# Run regular maintenance checks and cleanup for Homebrew

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# Print with color
print_color() {
    local color=$1
    shift
    echo -e "${color}$@${NC}"
}

print_header() {
    echo ""
    print_color "$BLUE" "============================================"
    print_color "$BLUE" "$1"
    print_color "$BLUE" "============================================"
}

print_success() {
    print_color "$GREEN" "✓ $1"
}

print_warning() {
    print_color "$YELLOW" "⚠ $1"
}

print_error() {
    print_color "$RED" "✗ $1"
}

# Check if Homebrew is installed
if ! command -v brew &> /dev/null; then
    print_error "Homebrew is not installed!"
    exit 1
fi

# Parse command line arguments
QUICK_MODE=false
VERBOSE=false

while [[ $# -gt 0 ]]; do
    case $1 in
        -q|--quick)
            QUICK_MODE=true
            shift
            ;;
        -v|--verbose)
            VERBOSE=true
            shift
            ;;
        -h|--help)
            echo "Usage: $0 [OPTIONS]"
            echo ""
            echo "Options:"
            echo "  -q, --quick     Quick check (skip updates)"
            echo "  -v, --verbose   Show detailed output"
            echo "  -h, --help      Show this help message"
            echo ""
            echo "This script performs regular Homebrew maintenance:"
            echo "  1. Updates package lists"
            echo "  2. Checks for deprecated packages"
            echo "  3. Upgrades installed packages"
            echo "  4. Cleans up old versions"
            echo "  5. Removes orphaned dependencies"
            exit 0
            ;;
        *)
            print_error "Unknown option: $1"
            echo "Use -h or --help for usage information"
            exit 1
            ;;
    esac
done

print_header "Homebrew Maintenance"
echo "Started: $(date)"
echo ""

# Step 1: Update package lists
if [ "$QUICK_MODE" = false ]; then
    print_header "Step 1: Updating Package Lists"
    if brew update; then
        print_success "Package lists updated"
    else
        print_error "Failed to update package lists"
        exit 1
    fi
else
    print_warning "Skipping update (quick mode)"
fi

# Step 2: Check for deprecated packages
print_header "Step 2: Checking for Deprecated Packages"
DEPRECATED=$(brew info --json=v2 --installed 2>/dev/null | jq -r '.formulae[] | select(.deprecated == true or .disabled == true) | .name' 2>/dev/null)

if [ -z "$DEPRECATED" ]; then
    print_success "No deprecated formulae found"
else
    print_warning "Found deprecated formulae:"
    echo "$DEPRECATED" | while read -r pkg; do
        echo "  - $pkg"
    done
    echo ""
    print_warning "Consider removing these packages and finding replacements"
fi

# Check for deprecated casks
DEPRECATED_CASKS=$(brew doctor 2>&1 | grep -A 50 "deprecated or disabled" | grep -E "^\s+[a-z]" | sed 's/^[[:space:]]*//' || true)
if [ -n "$DEPRECATED_CASKS" ]; then
    print_warning "Found deprecated casks:"
    echo "$DEPRECATED_CASKS" | while read -r pkg; do
        echo "  - $pkg"
    done
    echo ""
fi

# Step 3: Check for outdated packages
print_header "Step 3: Checking for Outdated Packages"
OUTDATED=$(brew outdated)

if [ -z "$OUTDATED" ]; then
    print_success "All packages are up to date"
else
    print_warning "Outdated packages found:"
    echo "$OUTDATED"
    echo ""

    if [ "$QUICK_MODE" = false ]; then
        read -p "Would you like to upgrade all packages? (y/N) " -n 1 -r
        echo ""
        if [[ $REPLY =~ ^[Yy]$ ]]; then
            print_header "Step 4: Upgrading Packages"
            if brew upgrade; then
                print_success "Packages upgraded successfully"
            else
                print_error "Some packages failed to upgrade"
            fi
        else
            print_warning "Skipping package upgrades"
        fi
    else
        print_warning "Skipping upgrade (quick mode)"
    fi
fi

# Step 5: Cleanup
print_header "Step 5: Cleaning Up"
if brew cleanup -s 2>&1 | tee /tmp/brew_cleanup.log; then
    CLEANED_SIZE=$(grep "freed approximately" /tmp/brew_cleanup.log | sed 's/.*freed approximately //' || echo "unknown amount of space")
    print_success "Cleanup complete - freed $CLEANED_SIZE"
else
    print_warning "Cleanup completed with warnings (check output above)"
fi

# Step 6: Remove orphaned dependencies
print_header "Step 6: Removing Orphaned Dependencies"
AUTOREMOVE_OUTPUT=$(brew autoremove 2>&1)
if echo "$AUTOREMOVE_OUTPUT" | grep -q "Nothing to autoremove"; then
    print_success "No orphaned dependencies found"
else
    echo "$AUTOREMOVE_OUTPUT"
    print_success "Orphaned dependencies removed"
fi

# Step 7: System health check
print_header "Step 7: System Health Check"
DOCTOR_OUTPUT=$(brew doctor 2>&1)

if echo "$DOCTOR_OUTPUT" | grep -q "Your system is ready to brew"; then
    print_success "Your system is ready to brew"
else
    print_warning "Brew doctor found some issues:"
    echo ""
    echo "$DOCTOR_OUTPUT"
    echo ""
fi

# Summary
print_header "Maintenance Summary"
TOTAL_PACKAGES=$(brew list --formula | wc -l | xargs)
TOTAL_CASKS=$(brew list --cask 2>/dev/null | wc -l | xargs)

echo "Total formulae installed: $TOTAL_PACKAGES"
echo "Total casks installed: $TOTAL_CASKS"
echo ""

if [ -n "$DEPRECATED" ] || [ -n "$DEPRECATED_CASKS" ]; then
    print_warning "Action required: Remove deprecated packages"
    echo "  Run: brew uninstall <package-name>"
    echo "  Update: config/packages.json in your setup repository"
else
    print_success "No deprecated packages found"
fi

echo ""
echo "Completed: $(date)"
print_success "Maintenance complete!"
