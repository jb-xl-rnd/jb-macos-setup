#!/bin/bash
# Headless/automated installation script for MacOS Setup

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

# Display usage
show_usage() {
    echo "Usage: $0 [OPTIONS]"
    echo ""
    echo "Options:"
    echo "  --all              Run complete setup (initial + ansible)"
    echo "  --initial          Run initial setup only (Homebrew, shell)"
    echo "  --ansible          Run ansible playbook only"
    echo "  --ansible-install  Install ansible only"
    echo "  --llm              Run LLM setup only"
    echo "  --test             Test the installation"
    echo "  --help             Show this help message"
    echo ""
    echo "Examples:"
    echo "  $0 --all           # Complete installation"
    echo "  $0 --initial --ansible  # Initial setup then ansible"
    echo "  $0 --llm           # Just install LLM components"
}

# Check prerequisites
check_prerequisites() {
    print_style "Checking prerequisites..." "info"
    
    # Check if running on macOS
    if [[ "$OSTYPE" != "darwin"* ]]; then
        print_style "This script is for macOS only!" "error"
        exit 1
    fi
    
    # Check if script directory exists
    if [ ! -d "./scripts" ]; then
        print_style "Scripts directory not found!" "error"
        print_style "Please run from the MacOS setup directory" "warning"
        exit 1
    fi
    
    # Make scripts executable
    chmod +x ./scripts/*.sh 2>/dev/null || true
    
    print_style "Prerequisites check passed" "success"
}

# Run initial setup
run_initial_setup() {
    print_style "=== Running Initial Setup ===" "info"
    
    # Check if Homebrew is installed
    if ! command -v brew &> /dev/null; then
        print_style "Installing Homebrew..." "info"
        NONINTERACTIVE=1 /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"
        
        # Add Homebrew to PATH
        if [[ -f "/opt/homebrew/bin/brew" ]]; then
            eval "$(/opt/homebrew/bin/brew shellenv)"
            echo 'eval "$(/opt/homebrew/bin/brew shellenv)"' >> ~/.zprofile
        elif [[ -f "/usr/local/bin/brew" ]]; then
            eval "$(/usr/local/bin/brew shellenv)"
            echo 'eval "$(/usr/local/bin/brew shellenv)"' >> ~/.zprofile
        fi
    else
        print_style "Homebrew already installed" "success"
    fi
    
    # Update Homebrew
    print_style "Updating Homebrew..." "info"
    brew update || true
    
    # Install essential tools
    print_style "Installing essential tools..." "info"
    brew install git curl wget || true
    
    print_style "Initial setup completed" "success"
}

# Install Ansible
install_ansible() {
    print_style "=== Installing Ansible ===" "info"
    
    # Ensure Homebrew is available
    if ! command -v brew &> /dev/null; then
        run_initial_setup
    fi
    
    # Install Python and Ansible
    print_style "Installing Python and Ansible..." "info"
    brew install python@3.12 ansible || true
    
    # Install ansible collections
    print_style "Installing Ansible collections..." "info"
    ansible-galaxy collection install community.general || true
    
    print_style "Ansible installation completed" "success"
}

# Run Ansible playbook
run_ansible_playbook() {
    print_style "=== Running Ansible Playbook ===" "info"
    
    # Check if Ansible is installed
    if ! command -v ansible-playbook &> /dev/null; then
        print_style "Ansible not found. Installing first..." "warning"
        install_ansible
    fi
    
    # Check for config files
    if [ ! -d "./config" ]; then
        print_style "Configuration files not found!" "error"
        exit 1
    fi
    
    # Run the playbook
    print_style "Running Ansible playbook..." "info"
    
    if [ "$1" == "llm" ]; then
        # Run only LLM tasks
        ansible-playbook ./ansible/macos_setup.yml --tags llm -v
    else
        # Run complete playbook
        ansible-playbook ./ansible/macos_setup.yml -v
    fi
    
    print_style "Ansible playbook completed" "success"
}

# Test installation
test_installation() {
    print_style "=== Testing Installation ===" "info"
    
    # Test Homebrew
    if command -v brew &> /dev/null; then
        print_style "✅ Homebrew installed" "success"
    else
        print_style "❌ Homebrew not found" "error"
    fi
    
    # Test Ansible
    if command -v ansible &> /dev/null; then
        print_style "✅ Ansible installed" "success"
    else
        print_style "❌ Ansible not found" "error"
    fi
    
    # Test LLM setup if test script exists
    if [ -f "./test_llm_setup.sh" ]; then
        print_style "Running LLM setup test..." "info"
        chmod +x ./test_llm_setup.sh
        ./test_llm_setup.sh
    fi
    
    print_style "Testing completed" "success"
}

# Run complete setup
run_complete_setup() {
    print_style "=== Running Complete Setup ===" "info"
    check_prerequisites
    run_initial_setup
    install_ansible
    run_ansible_playbook
    test_installation
    print_style "=== Complete Setup Finished ===" "success"
}

# Main execution
main() {
    # Check if no arguments provided
    if [ $# -eq 0 ]; then
        show_usage
        exit 0
    fi
    
    # Parse arguments
    while [[ $# -gt 0 ]]; do
        case $1 in
            --all)
                run_complete_setup
                shift
                ;;
            --initial)
                check_prerequisites
                run_initial_setup
                shift
                ;;
            --ansible)
                check_prerequisites
                run_ansible_playbook
                shift
                ;;
            --ansible-install)
                check_prerequisites
                install_ansible
                shift
                ;;
            --llm)
                check_prerequisites
                install_ansible
                run_ansible_playbook "llm"
                shift
                ;;
            --test)
                test_installation
                shift
                ;;
            --help|-h)
                show_usage
                exit 0
                ;;
            *)
                print_style "Unknown option: $1" "error"
                show_usage
                exit 1
                ;;
        esac
    done
}

# Run main function
main "$@"