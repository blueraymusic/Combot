#!/bin/bash

# Try to clone the repository
if git clone https://github.com/blueraymusic/Combot; then
    echo "Repository cloned successfully"
else
    # If cloning fails, install git
    echo "Cloning failed. Installing git first..."
    sudo apt-get install git  # Assuming you are using a Debian-based system
fi

# Change directory to combot
cd Combot

#python
pip install -U pip
python -m venv venv
source venv/bin/activate

# Install the required Python packages
pip3 install -r requirements.txt

# Upgrade OpenSSL
pip3 install --upgrade urllib3
brew update
brew install openssl
brew upgrade openssl
pip3 install --upgrade pyOpenSSL
pip3 install --upgrade anaconda-cloud-auth
pip3 install pydantic==1.8.2
pip3 install -U pydantic-settings


# Make the script executable
chmod +x computer.py

# Add alias to ~/.bashrc
echo "alias computer=\"$(pwd)/computer.py\"" >> ~/.bashrc_profile

# Reload the bash profile
source ~/.bashrc_profile

# Provide a message indicating successful installation
echo "Combot has been installed successfully. You can now use the 'computer' command."
