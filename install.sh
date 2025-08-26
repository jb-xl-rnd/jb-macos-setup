#!/bin/bash
# Main installation script for MacOS Setup

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

# Display menu
show_menu() {
    echo ""
    print_style "===== MacOS Setup Menu =====" "info"
    print_style "1) Initial Setup (Homebrew, iTerm2, Shell)" "info"
    echo ""
    print_style "ANSIBLE SETUP (comprehensive):" "warning"
    print_style "2) Install Ansible" "info"
    print_style "3) Run Ansible Playbook" "info"
    echo ""
    print_style "OTHER OPTIONS:" "warning"
    print_style "4) Edit Configuration Files" "info"
    print_style "5) View Documentation" "info"
    print_style "q) Quit" "info"
    echo ""
}

# Execute selected option
execute_option() {
    case $1 in
        1)
            print_style "Running Initial Setup..." "info"
            ./scripts/system/setupInitialMacOS.sh
            ;;
        2)
            print_style "Installing Ansible..." "info"
            ./scripts/testing/setupAnsible.sh
            ;;
        3)
            print_style "Running Ansible Playbook..." "info"
            if ! command -v ansible-playbook &> /dev/null; then
                print_style "Ansible not found. Installing first..." "warning"
                ./scripts/testing/setupAnsible.sh
            fi
            ansible-playbook ./ansible/macos_setup.yml
            ;;
        4)
            print_style "Edit Configuration Files:" "info"
            echo "1) Edit Package List (packages.json)"
            echo "2) Edit Shell Configurations (shell_config.json)"
            echo "3) Edit Feature Flags (config.json)"
            echo "b) Back to main menu"
            read -p "Choose an option: " config_choice
            case $config_choice in
                1)
                    ${EDITOR:-nano} ./config/packages.json
                    ;;
                2)
                    ${EDITOR:-nano} ./config/shell_config.json
                    ;;
                3)
                    ${EDITOR:-nano} ./config/config.json
                    ;;
                b)
                    return
                    ;;
                *)
                    print_style "Invalid option" "error"
                    ;;
            esac
            ;;
        5)
            print_style "Documentation:" "info"
            echo "1) Main README"
            echo "2) NTFS Support Instructions"
            echo "b) Back to main menu"
            read -p "Choose an option: " doc_choice
            case $doc_choice in
                1)
                    less README.md
                    ;;
                2)
                    less docs/SetupNTFSSupportMacOS.md
                    ;;
                b)
                    return
                    ;;
                *)
                    print_style "Invalid option" "error"
                    ;;
            esac
            ;;
        q)
            print_style "Goodbye!" "success"
            exit 0
            ;;
        *)
            print_style "Invalid option" "error"
            ;;
    esac
}

# Make scripts executable
chmod +x ./scripts/*/*.sh

# Create config dir if it doesn't exist
if [ ! -d "./config" ]; then
    print_style "Configuration directory not found. Creating..." "warning"
    mkdir -p ./config
    
    # Check if we can download the default config files
    if command -v curl &> /dev/null; then
        print_style "Downloading default configuration files..." "info"
        curl -s https://raw.githubusercontent.com/user/macos-setup/main/config/packages.json > ./config/packages.json 2>/dev/null || echo '{"brew_packages":[], "brew_cask_apps":[], "mas_apps":[], "pip_packages":[]}' > ./config/packages.json
        curl -s https://raw.githubusercontent.com/user/macos-setup/main/config/shell_config.json > ./config/shell_config.json 2>/dev/null || echo '{"zsh_additions":[]}' > ./config/shell_config.json
        curl -s https://raw.githubusercontent.com/user/macos-setup/main/config/config.json > ./config/config.json 2>/dev/null || echo '{"bash_setup":{"core_packages":[],"core_cask_apps":[]},"feature_flags":{}}' > ./config/config.json
    else
        # Create empty config files
        echo '{"brew_packages":[], "brew_cask_apps":[], "mas_apps":[], "pip_packages":[]}' > ./config/packages.json
        echo '{"zsh_additions":[]}' > ./config/shell_config.json
        echo '{"bash_setup":{"core_packages":[],"core_cask_apps":[]},"feature_flags":{}}' > ./config/config.json
    fi
fi

# Main loop
while true; do
    show_menu
    read -p "Choose an option: " choice
    execute_option $choice
    echo ""
    read -p "Press Enter to continue..."
done