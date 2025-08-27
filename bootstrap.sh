#!/bin/bash
# Bootstrap script for macOS Setup
# This script downloads and runs the full setup from GitHub
# Usage: curl -fsSL jonathanbeer.me/macos | bash
# Usage with options: curl -fsSL jonathanbeer.me/macos | bash -s -- --llm

set -e  # Exit on any error

REPO_URL="https://github.com/jb-xl-rnd/jb-macos-setup"
REPO_NAME="jb-macos-setup-main"
TEMP_DIR=""

# Colors for output
RED='\033[91m'
GREEN='\033[92m'
YELLOW='\033[93m'
BLUE='\033[96m'
NC='\033[0m' # No Color

# Print colorized output
print_style() {
    if [ "$2" == "info" ]; then
        echo -e "${BLUE}$1${NC}"
    elif [ "$2" == "success" ]; then
        echo -e "${GREEN}$1${NC}"
    elif [ "$2" == "warning" ]; then
        echo -e "${YELLOW}$1${NC}"
    elif [ "$2" == "error" ]; then
        echo -e "${RED}$1${NC}"
    else
        echo -e "$1"
    fi
}

# Cleanup function
cleanup() {
    if [ -n "$TEMP_DIR" ] && [ -d "$TEMP_DIR" ]; then
        print_style "Cleaning up temporary files..." "info"
        rm -rf "$TEMP_DIR"
    fi
}

# Set up trap for cleanup on exit
trap cleanup EXIT

# Check if running on macOS
check_macos() {
    if [[ "$OSTYPE" != "darwin"* ]]; then
        print_style "❌ This script is for macOS only!" "error"
        print_style "Detected OS: $OSTYPE" "error"
        exit 1
    fi
    
    # Get macOS version
    MACOS_VERSION=$(sw_vers -productVersion)
    print_style "✅ Running on macOS $MACOS_VERSION" "success"
}

# Check prerequisites
check_prerequisites() {
    print_style "🔍 Checking prerequisites..." "info"
    
    # Check for curl
    if ! command -v curl &> /dev/null; then
        print_style "❌ curl is required but not installed" "error"
        exit 1
    fi
    
    # Check for tar
    if ! command -v tar &> /dev/null; then
        print_style "❌ tar is required but not installed" "error"
        exit 1
    fi
    
    print_style "✅ Prerequisites check passed" "success"
}

# Download and extract repository
download_repo() {
    print_style "📥 Downloading macOS setup repository..." "info"
    
    # Create temporary directory
    TEMP_DIR=$(mktemp -d)
    cd "$TEMP_DIR"
    
    # Download the repository tarball
    if ! curl -fsSL "${REPO_URL}/archive/main.tar.gz" | tar -xz; then
        print_style "❌ Failed to download repository" "error"
        exit 1
    fi
    
    # Verify extraction
    if [ ! -d "$REPO_NAME" ]; then
        print_style "❌ Failed to extract repository" "error"
        exit 1
    fi
    
    print_style "✅ Repository downloaded and extracted" "success"
}

# Run the installer
run_installer() {
    print_style "🚀 Starting macOS setup installation..." "info"
    
    cd "$TEMP_DIR/$REPO_NAME"
    
    # Make scripts executable
    chmod +x ./installers/headless/install_headless.sh
    chmod +x ./scripts/*/*.sh 2>/dev/null || true
    
    # Parse arguments passed to this script
    if [ $# -eq 0 ]; then
        # Default: run complete setup
        print_style "Running complete setup (use --help for options)" "info"
        ./installers/headless/install_headless.sh --all
    else
        # Pass all arguments to the installer
        print_style "Running with options: $*" "info"
        ./installers/headless/install_headless.sh "$@"
    fi
}

# Show usage information
show_usage() {
    echo ""
    print_style "📋 macOS Setup Bootstrap" "info"
    echo ""
    echo "Usage examples:"
    echo "  curl -fsSL jonathanbeer.me/macos | bash"
    echo "  curl -fsSL jonathanbeer.me/macos | bash -s -- --help"
    echo "  curl -fsSL jonathanbeer.me/macos | bash -s -- --llm"
    echo "  curl -fsSL jonathanbeer.me/macos | bash -s -- --initial"
    echo ""
    echo "Available options:"
    echo "  --all              Complete setup (default)"
    echo "  --initial          Initial setup only (Homebrew, shell)"
    echo "  --ansible          Run ansible playbook only"
    echo "  --llm              LLM setup only"
    echo "  --test             Test installation"
    echo "  --help             Show detailed help"
    echo ""
    echo "Repository: $REPO_URL"
}

# Main execution
main() {
    print_style "🍎 macOS Setup Bootstrap Script" "info"
    print_style "================================" "info"
    
    # Handle help request
    if [[ "$*" == *"--help"* ]] || [[ "$*" == *"-h"* ]]; then
        show_usage
        return 0
    fi
    
    # Run setup steps
    check_macos
    check_prerequisites
    download_repo
    run_installer "$@"
    
    print_style "🎉 macOS setup completed successfully!" "success"
    print_style "Repository source: $REPO_URL" "info"
}

# Execute main function with all arguments
main "$@"