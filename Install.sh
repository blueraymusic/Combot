#!/bin/bash

# Install the required Python packages
if ! command -v pip3 &>/dev/null; then
    echo "Error: pip3 not found. Please install Python3 and pip3 first."
    exit 1
fi

pip3 install -r requirements.txt

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
    fi
else
    echo "Skipping OpenSSL upgrade."
fi

pip3 install --upgrade anaconda-cloud-auth
pip3 install pydantic==1.8.2
pip3 install -U pydantic-settings
pip3 install urllib3 == 1.26.6

echo "Hello. Installing computer..."
echo "- Cloning the repository..."
git clone https://github.com/blueraymusic/Combot.git combot
cd combot || exit

TARGET_DIR=~/combot
TARGET_FULLPATH=$TARGET_DIR/computer.py

# Check if the target directory already exists
if [ -d "$TARGET_DIR" ]; then
    echo "Error: Target directory $TARGET_DIR already exists. Aborting."
    exit 1
fi

# Copying files
echo "- Copying files..."
cp computer.py prompt.txt computer.yaml "$TARGET_DIR"
chmod +x "$TARGET_FULLPATH"

# Add aliases to the user's shell configuration file
echo "- Adding aliases to the shell configuration file..."

# Determine the shell configuration file
if [[ -f ~/.bashrc ]]; then
    SHELL_CONFIG_FILE=~/.bashrc
elif [[ -f ~/.bash_profile ]]; then
    SHELL_CONFIG_FILE=~/.bash_profile
elif [[ -f ~/.zshrc ]]; then
    SHELL_CONFIG_FILE=~/.zshrc
else
    echo "Error: Unable to determine the shell configuration file. Please manually add the aliases to your shell configuration."
    exit 1
fi

# Append aliases to the shell configuration file
echo "alias computer=$TARGET_FULLPATH" >> "$SHELL_CONFIG_FILE"
echo "alias bot=$TARGET_FULLPATH" >> "$SHELL_CONFIG_FILE"

# Reload the shell configuration
echo "- Reloading the shell configuration..."
source "$SHELL_CONFIG_FILE"

# Verify if aliases are set correctly
if ! alias computer &>/dev/null; then
    echo "Error: Alias 'computer' was not set correctly."
    echo "Please manually add the following line to your shell configuration file:"
    echo "alias computer=$TARGET_FULLPATH"
    exit 1
fi

if ! alias bot &>/dev/null; then
    echo "Error: Alias 'bot' was not set correctly."
    echo "Please manually add the following line to your shell configuration file:"
    echo "alias bot=$TARGET_FULLPATH"
    exit 1
fi

# 
echo
echo "Done."
echo
echo "Make sure you have the OpenAI API key set via one of these options:" 
echo "  - environment variable"
echo "  - .env or an ~/.openai.apikey file or in"
echo "  - computer.yaml"
echo
echo "Have fun!"
