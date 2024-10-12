#!/bin/bash

cd "$(pwd)"


# Install the required Python packages
if ! command -v pip3 &>/dev/null; then
    echo "Error: pip3 not found. Please install Python3 and pip3 first."
    exit 1
fi



# Check if requirements can be installed
if pip3 install -r requirements.txt; then
    echo "Requirements installed successfully."
else
    # If requirements installation fails, install packages manually
    echo "Installing packages manually..."
    pip3 install openai==0.27.0 python-dotenv distro PyYAML pyperclip termcolor colorama aiohttp keyring urllib3==1.26.6
fi


# Upgrade OpenSSL with user confirmation
read -p "Do you want to upgrade OpenSSL? (y/n): " upgrade_ssl
if [[ $upgrade_ssl == [yY] ]]; then
    pip3 install --upgrade urllib3
    if command -v brew &>/dev/null; then
        brew update
        brew install openssl
        brew upgrade openssl
        pip3 install --upgrade pyOpenSSL
    else
        echo "Error: Homebrew is required for upgrading OpenSSL. Please install Homebrew first."
        exit 1
    fi
else
    echo "Skipping OpenSSL upgrade."
fi


echo "Hello. Installing computer..."


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
printf "\n▓▓▓▓▓▓▓▓▒▒▒▒▒▒▒ Loading ...\n"
sleep 0.1
clear
printf "\n▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓ Loading ...\n"
sleep 0.1
}

loading

# Check if the target directory already exists
if [ -d "$TARGET_DIR" ]; then
    echo "Error: Target directory $TARGET_DIR already exists. Aborting. (Use or Remove)"
    exit 1
fi


echo "- Cloning the repository..."
TARGET_DIR="$HOME"

cd "$TARGET_DIR" || exit
git clone https://github.com/blueraymusic/Combot.git combot

cd combot || exit

TARGET_DIR=~/combot
TARGET_FULLPATH=$TARGET_DIR/computer.py


# Copying files
echo "- Copying files..."
cp computer.py prompt.txt computer.yaml "$TARGET_DIR"
chmod +x "$TARGET_FULLPATH"

# Add aliases to the user's shell configuration files
echo "- Adding aliases to the shell configuration files..."

if [[ -f ~/.bashrc ]]; then
    SHELL_CONFIG_FILE=~/.bashrc
    echo "alias computer=\"$TARGET_FULLPATH\"" >> "$SHELL_CONFIG_FILE"
    echo "alias bot=\"$TARGET_FULLPATH\"" >> "$SHELL_CONFIG_FILE"
fi

if [[ -f ~/.bash_profile ]]; then
    SHELL_CONFIG_FILE=~/.bash_profile
    echo "alias computer=\"$TARGET_FULLPATH\"" >> "$SHELL_CONFIG_FILE"
    echo "alias bot=\"$TARGET_FULLPATH\"" >> "$SHELL_CONFIG_FILE"
fi

if [[ -f ~/.zshrc ]]; then
    SHELL_CONFIG_FILE=~/.zshrc
    echo "alias computer=\"$TARGET_FULLPATH\"" >> "$SHELL_CONFIG_FILE"
    echo "alias bot=\"$TARGET_FULLPATH\"" >> "$SHELL_CONFIG_FILE"
fi

#seocnd time
chmod +x "$TARGET_FULLPATH"

# Reload the shell configuration
echo " "
echo "- Reloading the shell configuration..."
source ~/.bashrc || source ~/.bash_profile || source ~/.zshrc
echo " "

# Verify if aliases are set correctly
if ! alias computer &>/dev/null; then
    echo "Error: Alias 'computer' was not set correctly."
    echo "Please manually add the following line to your shell configuration file(s):"
    echo "alias computer=\"$TARGET_FULLPATH\""
    exit 1
fi

if ! alias bot &>/dev/null; then
    echo "Error: Alias 'bot' was not set correctly."
    echo "Please manually add the following line to your shell configuration file(s):"
    echo "alias bot=\"$TARGET_FULLPATH\""
    exit 1
fi

echo
echo "Done."
echo
echo "Make sure you have the OpenAI API key set via one of these options:" 
echo "  - environment variable"
echo "  - .env or an ~/.openai.apikey file or in"
echo "  - computer.yaml"
echo "  - type the command: 'computer --API : API_KEY' "

echo "For more information and commands, type in the following command:"
echo "  - type the command: 'computer -i' "

echo
echo "Have fun!"
