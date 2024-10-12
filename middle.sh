#!/bin/bash

# Trap to handle Ctrl+C
trap 'printf "\nExiting...\n"; exit 1' SIGINT

# Suppress Homebrew warnings and environment hints
export HOMEBREW_NO_INSTALL_CLEANUP=1
export HOMEBREW_NO_ENV_HINTS=1

# Detect the appropriate package manager
get_package_manager() {
    if command -v apt-get &>/dev/null; then
        echo "apt-get"
    elif command -v yum &>/dev/null; then
        echo "yum"
    elif command -v apk &>/dev/null; then
        echo "apk"
    elif command -v brew &>/dev/null; then
        echo "brew"
    else
        printf "No supported package manager found! Exiting...\n"
        exit 1
    fi
}

PACKAGE_MANAGER=$(get_package_manager)

# Function to install dependencies
dependencies() {
    check_dependency() {
        if ! command -v "$1" &>/dev/null; then
            echo "$1 is not installed! Installing $1..."

            if [ "$PACKAGE_MANAGER" == "brew" ]; then
                if [ "$(id -u)" -eq 0 ]; then
                    echo "Error: Do not run this script as root with Homebrew!"
                    exit 1
                fi
                brew install "$1" || {
                    echo "Error: Failed to install $1 with Homebrew!"
                    exit 1
                }
            else
                sudo "$PACKAGE_MANAGER" install -y "$1" || {
                    echo "Error: Failed to install $1 with $PACKAGE_MANAGER!"
                    exit 1
                }
            fi
        fi
    }

    for dep in php curl openssh unzip; do
        check_dependency "$dep"
    done
}

# Loading animation
loading() {
    clear
    printf "\e[1;92m"
    for i in $(seq 1 10); do
        printf "\n%s Loading ...\n" "$(printf '▓%.0s' $(seq 1 $i))"
        sleep 0.1
        clear
    done
}

# Display banner
banner() {
    printf " \e[36;1m.:. Choose One .:.\e[0m\n\n"
}

# Menu logic
menu() {
    banner
    printf " \e[1;31m[\e[0m\e[1;77m01\e[0m\e[1;31m]\e[0m\e[1;93m ShellFish\n"
    printf " \e[1;31m[\e[0m\e[1;77mST\e[0m\e[1;31m]\e[0m\e[1;93m Termux Setup\n"
    printf " \e[1;31m[\e[0m\e[1;77mSL\e[0m\e[1;31m]\e[0m\e[1;93m Linux Setup\n"
    printf " \e[1;31m[\e[0m\e[1;77mEX\e[0m\e[1;31m]\e[0m\e[1;93m Exit\n\n"

    printf " \e[1;31m[\e[0m\e[1;77m~\e[0m\e[1;31m] Select an option: \e[0m\e[1;96m"
    read -rp "" option

    option=$(echo "$option" | xargs)  # Trim whitespace

    case "$option" in
        1|01) ShellP ;;
        ST|st) termux_setup ;;
        SL|sl) linux_setup ;;
        EX|ex) exit 0 ;;
        *)
            printf " \e[1;91mInvalid option! Please try again.\e[0m\n"
            sleep 1
            menu  # Reload menu on invalid input
            ;;
    esac
}

# ShellFish execution function
run_shellfish() {
    local script_dir
    script_dir=$(dirname "${BASH_SOURCE[0]}")
    local shellfish_script="Shellfish/ShellPhish/shellphish.sh"

    if [ -f "$script_dir/$shellfish_script" ]; then
        bash "$script_dir/$shellfish_script"
    else
        printf " \e[1;91mFile not found: %s\e[0m\n" "$shellfish_script"
    fi
}

# Wrapper for ShellFish
ShellP() {
    run_shellfish
}

# Termux setup function
termux_setup() {
    clear
    printf "\n\e[1;92mRunning Termux Setup...\n"
    apt update && apt upgrade -y
    pkg install -y wget curl php unzip openssh git
    printf "\n\e[1;92mTermux Setup Done...\e[0m\n"
    sleep 1
    menu
}

# Linux setup function
linux_setup() {
    clear
    printf "\n\e[1;92mRunning Linux Setup...\n"
    sudo "$PACKAGE_MANAGER" install -y wget curl php unzip dos2unix ssh git
    printf "\n\e[1;92mLinux Setup Done...\e[0m\n"
    sleep 1
    menu
}

# Main execution
clear
loading
dependencies
menu
