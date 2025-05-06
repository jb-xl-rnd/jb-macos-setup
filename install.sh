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
    echo "1) Initial Setup (Homebrew, iTerm2, Shell)"
    echo "2) Install Ansible"
    echo "3) Run Ansible Playbook (Recommended)"
    echo "4) Run Bash Setup Script"
    echo "5) View Documentation"
    echo "q) Quit"
    echo ""
}

# Execute selected option
execute_option() {
    case $1 in
        1)
            print_style "Running Initial Setup..." "info"
            ./scripts/setupInitialMacOS.sh
            ;;
        2)
            print_style "Installing Ansible..." "info"
            ./scripts/setupAnsible.sh
            ;;
        3)
            print_style "Running Ansible Playbook..." "info"
            if ! command -v ansible-playbook &> /dev/null; then
                print_style "Ansible not found. Installing first..." "warning"
                ./scripts/setupAnsible.sh
            fi
            ansible-playbook ./ansible/macos_setup.yml
            ;;
        4)
            print_style "Running Bash Setup Script..." "info"
            ./scripts/setupMacOs.sh
            ;;
        5)
            print_style "Documentation:" "info"
            echo "1) Main README"
            echo "2) NTFS Support Instructions"
            echo "b) Back to main menu"
            read -p "Choose an option: " doc_choice
            case $doc_choice in
                1)
                    cat README.md | less
                    ;;
                2)
                    cat docs/SetupNTFSSupportMacOS.md | less
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
chmod +x ./scripts/*.sh

# Main loop
while true; do
    show_menu
    read -p "Choose an option: " choice
    execute_option $choice
    echo ""
    read -p "Press Enter to continue..."
done