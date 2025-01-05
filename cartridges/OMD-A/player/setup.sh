#!/bin/bash

# Exit immediately if a command exits with a non-zero status
set -e

echo "Removing system-installed numpy..."
sudo apt remove -y python3-numpy

echo "Installing libopenblas-dev..."
sudo apt install -y libopenblas-dev

echo "Installing required Python packages and Git..."
sudo apt-get install -y python3-rpi.gpio python3-spidev python3-pip python3-pil git

echo "Installing numpy with pip..."
sudo pip3 install numpy --break-system-packages

echo "Cloning the st7789-python repository..."
git clone https://github.com/pimoroni/st7789-python.git
cd st7789-python/

echo "Switching to the feature/floyd-made-me-do-it branch..."
git checkout feature/floyd-made-me-do-it

echo "Pulling the latest updates..."
git pull

echo "Installing st7789-python..."
pip3 install ./ --break-system-packages

echo "Navigating back to the parent directory..."
cd ../

echo "Cloning the pirate-audio repository..."
git clone https://github.com/pimoroni/pirate-audio
cd pirate-audio/

echo "Navigating to the mopidy directory..."
cd ./mopidy/

echo "Modifying the install.sh script to use --break-system-packages..."
sed -i 's|\$PIP_BIN install --upgrade|\$PIP_BIN install --break-system-packages --upgrade|g' install.sh

echo "Running the install.sh script..."
sudo ./install.sh

echo "Setup complete!"