#!/bin/bash
# Python Package Maintenance Script
# Audit and maintain Python packages across different installations

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

# Parse command line arguments
QUICK_MODE=false
UPGRADE_ALL=false

while [[ $# -gt 0 ]]; do
    case $1 in
        -q|--quick)
            QUICK_MODE=true
            shift
            ;;
        -u|--upgrade)
            UPGRADE_ALL=true
            shift
            ;;
        -h|--help)
            echo "Usage: $0 [OPTIONS]"
            echo ""
            echo "Options:"
            echo "  -q, --quick     Quick check (skip upgrades)"
            echo "  -u, --upgrade   Upgrade all packages automatically"
            echo "  -h, --help      Show this help message"
            echo ""
            echo "This script audits Python installations and packages:"
            echo "  1. Lists all Python installations"
            echo "  2. Checks system packages (Homebrew Python)"
            echo "  3. Checks user-local packages"
            echo "  4. Checks uv tools"
            echo "  5. Identifies outdated packages"
            echo "  6. Optionally upgrades packages"
            exit 0
            ;;
        *)
            print_error "Unknown option: $1"
            echo "Use -h or --help for usage information"
            exit 1
            ;;
    esac
done

print_header "Python Package Audit"
echo "Started: $(date)"
echo ""

# Step 1: Identify Python installations
print_header "Step 1: Python Installations"

if command -v python3 &> /dev/null; then
    DEFAULT_PYTHON=$(python3 --version 2>&1)
    print_success "Default Python: $DEFAULT_PYTHON"
    echo "  Location: $(which python3)"
fi

# Check Homebrew Python versions
BREW_PYTHONS=$(ls /opt/homebrew/bin/python3.* 2>/dev/null | grep -E "python3\.(11|12|13|14)$" | wc -l | xargs)
if [ "$BREW_PYTHONS" -gt 0 ]; then
    print_success "Homebrew Python versions: $BREW_PYTHONS"
    ls /opt/homebrew/bin/python3.* 2>/dev/null | grep -E "python3\.(11|12|13|14)$" | while read pypath; do
        VERSION=$($pypath --version 2>&1 | awk '{print $2}')
        echo "  - $(basename $pypath): $VERSION"
    done
fi

# Check pyenv
if command -v pyenv &> /dev/null; then
    PYENV_VERSIONS=$(pyenv versions 2>/dev/null | grep -v "system" | wc -l | xargs)
    if [ "$PYENV_VERSIONS" -gt 0 ]; then
        print_success "Pyenv versions: $PYENV_VERSIONS"
        pyenv versions 2>/dev/null | grep -v "system" | sed 's/^/  /'
    fi
fi

# Step 2: System packages audit
print_header "Step 2: System Packages (Homebrew Python)"

if command -v python3 &> /dev/null; then
    SYSTEM_PACKAGES=$(python3 -m pip list --format=freeze 2>/dev/null | wc -l)
    print_success "System packages installed: $SYSTEM_PACKAGES"

    if [ "$SYSTEM_PACKAGES" -gt 0 ]; then
        echo ""
        python3 -m pip list --format=columns 2>/dev/null | head -20
    fi

    # Check for outdated system packages
    OUTDATED=$(python3 -m pip list --outdated 2>/dev/null)
    if [ -z "$OUTDATED" ]; then
        print_success "All system packages are up-to-date"
    else
        print_warning "Outdated system packages found:"
        echo "$OUTDATED" | head -15

        if [ "$UPGRADE_ALL" = true ]; then
            print_warning "Upgrading system packages..."
            python3 -m pip install --upgrade $(python3 -m pip list --outdated --format=freeze 2>/dev/null | cut -d= -f1) 2>&1
        fi
    fi
fi

# Step 3: User-local packages
print_header "Step 3: User-Local Packages"

if [ -d "$HOME/.local/lib" ]; then
    USER_PACKAGES=$(find "$HOME/.local/lib" -name "*.dist-info" 2>/dev/null | wc -l | xargs)
    if [ "$USER_PACKAGES" -gt 0 ]; then
        print_warning "User-local packages found: $USER_PACKAGES"
        echo "Location: ~/.local/lib/"

        # List unique package names
        find "$HOME/.local/lib" -name "*.dist-info" -type d 2>/dev/null | \
            xargs -I {} basename {} | \
            sed 's/-[0-9].*//' | \
            sort -u | \
            sed 's/^/  - /'
    else
        print_success "No user-local packages found"
    fi
else
    print_success "No user-local packages directory"
fi

# Step 4: UV tools audit
print_header "Step 4: UV Tools"

if command -v uv &> /dev/null; then
    print_success "UV package manager found"

    UV_TOOLS=$(uv tool list 2>&1 | grep -E "^[a-z]" | wc -l | xargs)
    if [ "$UV_TOOLS" -gt 0 ]; then
        echo ""
        echo "Installed UV tools: $UV_TOOLS"
        echo ""
        uv tool list 2>&1 | grep -E "^[a-z]|^-" | head -20
        echo ""

        if [ "$QUICK_MODE" = false ]; then
            if [ "$UPGRADE_ALL" = true ]; then
                print_warning "Upgrading all UV tools..."
                uv tool upgrade --all 2>&1 | grep -E "Updated|Modified|Reinstalled" || print_success "All UV tools already up-to-date"
            else
                read -p "Would you like to check for UV tool updates? (y/N) " -n 1 -r
                echo ""
                if [[ $REPLY =~ ^[Yy]$ ]]; then
                    print_warning "Checking for UV tool updates..."
                    uv tool upgrade --all 2>&1 | grep -E "Updated|Modified|Reinstalled" || print_success "All UV tools already up-to-date"
                fi
            fi
        fi
    else
        print_success "No UV tools installed"
    fi
else
    print_warning "UV package manager not found"
    echo "  Install with: brew install uv"
fi

# Step 5: Check for virtual environments
print_header "Step 5: Virtual Environments"

VENVS_FOUND=0

# Check common venv locations
if [ -d "$HOME/venv" ]; then
    VENVS=$(find "$HOME/venv" -maxdepth 2 -name "pyvenv.cfg" 2>/dev/null | wc -l | xargs)
    if [ "$VENVS" -gt 0 ]; then
        print_warning "Virtual environments in ~/venv: $VENVS"
        VENVS_FOUND=$((VENVS_FOUND + VENVS))
    fi
fi

if [ -d "$HOME/.virtualenvs" ]; then
    VENVS=$(find "$HOME/.virtualenvs" -maxdepth 2 -name "pyvenv.cfg" 2>/dev/null | wc -l | xargs)
    if [ "$VENVS" -gt 0 ]; then
        print_warning "Virtual environments in ~/.virtualenvs: $VENVS"
        VENVS_FOUND=$((VENVS_FOUND + VENVS))
    fi
fi

if [ "$VENVS_FOUND" -eq 0 ]; then
    print_success "No virtual environments in common locations"
fi

# Step 6: Python version recommendations
print_header "Step 6: Python Version Analysis"

if [ "$BREW_PYTHONS" -gt 2 ]; then
    print_warning "Multiple Python versions detected: $BREW_PYTHONS"
    echo ""
    echo "Recommendations:"
    echo "  - Keep Python 3.12 (stable, LTS)"
    echo "  - Keep Python 3.14 (latest)"
    echo "  - Consider removing Python 3.11, 3.13 if not needed"
    echo ""
    echo "To remove a Python version:"
    echo "  brew uninstall python@3.11"
fi

# Summary
print_header "Maintenance Summary"

echo "Python Installations:"
echo "  - Homebrew Python versions: $BREW_PYTHONS"
echo "  - System packages: $SYSTEM_PACKAGES"
echo "  - User-local packages: $USER_PACKAGES"
echo "  - UV tools: $UV_TOOLS"
echo "  - Virtual environments: $VENVS_FOUND"
echo ""

print_success "Audit complete!"

# Recommendations
echo ""
print_header "Recommendations"
echo "1. Keep system Python packages minimal (current: $SYSTEM_PACKAGES - GOOD)"
echo "2. Use 'uv' for tool installations (recommended over pip)"
echo "3. Use virtual environments for project dependencies"
echo "4. Run 'uv tool upgrade --all' monthly to keep tools updated"
echo "5. Avoid installing packages with 'pip install --user'"
echo ""
echo "Next audit: $(date -v+1m '+%Y-%m-%d')"
echo ""
echo "Completed: $(date)"
