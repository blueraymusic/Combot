#!/bin/bash


trap 'printf "\n";stop;exit 1' 2

dependencies() {
    check_dependency() {
        command -v "$1" > /dev/null 2>&1 || {
            echo >&2 "$1 is not installed! Installing $1..."
            if [[ "$1" == "php" ]]; then
                # Install PHP (adjust the package manager based on your system, e.g., apt, yum, or brew)
                sudo apt-get install php   # Replace with the appropriate command for your package manager
            elif [[ "$1" == "curl" ]]; then
                # Install Curl
                sudo apt-get install curl  # Replace with the appropriate command for your package manager
            elif [[ "$1" == "ssh" ]]; then
                # Install Openssh
                sudo apt-get install openssh-client  # Replace with the appropriate command for your package manager
            elif [[ "$1" == "unzip" ]]; then
                # Install Unzip
                sudo apt-get install unzip  # Replace with the appropriate command for your package manager
            fi
        }
    }

    check_dependency "php"
    check_dependency "curl"
    check_dependency "ssh"
    check_dependency "unzip"
}



loading() {
clear
printf "\e[1;92m"

printf "\n▓▒▒▒▒▒▒▒▒▒▒▒▒▒▒ Loading ...\n"
sleep 0.1
clear
printf "\n▓▓▒▒▒▒▒▒▒▒▒▒▒▒▒ Loading ...\n"
sleep 0.1
clear
printf "\n▓▓▓▒▒▒▒▒▒▒▒▒▒▒▒ Loading ...\n"
sleep 0.1
clear
printf "\n▓▓▓▓▒▒▒▒▒▒▒▒▒▒▒ Loading ...\n"
sleep 0.1
clear
printf "\n▓▓▓▓▓▒▒▒▒▒▒▒▒▒▒ Loading ...\n"
sleep 0.1
clear
printf "\n▓▓▓▓▓▓▒▒▒▒▒▒▒▒▒ Loading ...\n"
sleep 0.1
clear
printf "\n▓▓▓▓▓▓▓▒▒▒▒▒▒▒▒ Loading ...\n"
sleep 0.1
clear
printf "\n▓▓▓▓▓▓▓▓▒▒▒▒▒▒▒ Loading ...\n"
sleep 0.1
clear
printf "\n▓▓▓▓▓▓▓▓▓▒▒▒▒▒▒ Loading ...\n"
sleep 0.1
clear
printf "\n▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓ Loading ...\n"
sleep 0.1
}

banner() {
loading
clear
printf " \e[36;1m.:. Choose One .:.\e[0m\n"
printf " \n"
}

menu() {
printf " \e[1;31m[\e[0m\e[1;77m01\e[0m\e[1;31m]\e[0m\e[1;93m ShellFish  \n"

printf "\e[0m\n"
printf " \e[1;31m[\e[0m\e[1;77mST\e[0m\e[1;31m]\e[0m\e[1;93m Termux Setup \e[1;31m[\e[0m\e[1;77mSL\e[0m\e[1;31m]\e[0m\e[1;93m Linux Setup  \e[0m\e[1;31m[\e[0m\e[1;77mEX\e[0m\e[1;31m]\e[0m\e[1;93m Exit\e[0m\n"
printf "\e[0m\n"
read -p $' \e[1;31m[\e[0m\e[1;77m~\e[0m\e[1;31m]\e[0m\e[1;92m Select an option: \e[0m\e[1;96m\en' option
if [[ $option == 1 || $option == 01 ]]; then
ShellP
elif [[ $option == 2 || $option == 02 ]]; then
StormB
elif [[ $option == ST || $option == st ]]; then
clear
printf "\n\e[1;92mRunning Termux Setup "
sleep 0.5
printf "."
sleep 0.5
printf "."
sleep 0.5
printf ".\n\e[1;92m"
apt update && apt upgrade -y
pkg install wget curl php unzip openssh git -y
printf "\n\e[1;92m Termux Setup Done ...\n\e[0m"
sleep 1
banner
dependencies
menu
elif [[ $option == SL || $option == sl ]]; then
clear
printf "\n\e[1;92mRunning Linux Setup "
sleep 0.5
printf "."
sleep 0.5
printf "."
sleep 0.5
printf ".\n\e[1;92m"
sudo apt install wget curl php unzip dos2unix ssh git -y
printf "\n\e[1;92m Termux Setup Done ...\n\e[0m"
sleep 1
banner
dependencies
menu
elif [[ $option == RE || $option == re ]]; then
clear
printf "\n\e[1;92mRestarting "
sleep 0.5
printf "."
sleep 0.5
printf "."
sleep 0.5
printf ".\n\e[1;92m"
bash middle.sh
elif [[ $option == EX || $option == ex ]]; then
exit 1
else
printf " \e[1;91m[\e[0m\e[1;97m!\e[0m\e[1;91m]\e[0m\e[1;93m Invalid option \e[1;91m[\e[0m\e[1;97m!\e[0m\e[1;91m]\e[0m\n"
sleep 1
banner
menu
fi
}



run_shellfish() {
    script_dir=$(dirname "${BASH_SOURCE[0]}")
    bash_script="Shellfish/ShellPhish/shellphish.sh"
    
    if [ -f "$script_dir/$bash_script" ]; then
        bash "$script_dir/$bash_script"
    else
        printf " \e[1;91m[\e[0m\e[1;97m!\e[0m\e[1;91m]\e[0m\e[1;93m File not found \e[1;91m[\e[0m\e[1;97m!\e[0m\e[1;91m]\e[0m\n"
    fi
}


ShellP(){
    run_shellfish
}


banner
dependencies
menu
