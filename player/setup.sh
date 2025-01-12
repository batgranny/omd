#source /home/pi/.virtualenvs/mopidy/bin/activate to enter venv
#deactivate to deactivate

#systemctl --user status mopidy
#journalctl --user -u mopidy


# Variables
# MOUNT_POINT="/home/pi/Music"
# FSTAB_ENTRY="/dev/sda1  /home/pi/Music  vfat  defaults  0  2"
# FSTAB_FILE="/etc/fstab"

# # Check if the mount point directory exists
# if [ ! -d "$MOUNT_POINT" ]; then
#     mkdir -p "$MOUNT_POINT"
#     echo "Directory $MOUNT_POINT created."
# fi

# # Check if the fstab entry does not exist
# if ! grep -qF "$FSTAB_ENTRY" "$FSTAB_FILE"; then
#     echo "$FSTAB_ENTRY" | sudo tee -a "$FSTAB_FILE" > /dev/null
#     echo "Fstab entry added."

#     #mount the USB drive
#     sudo mount -a
#     if ! mountpoint -q "$MOUNT_POINT"; then
#         echo "Failed to mount the drive. Please check your fstab or drive settings."
#     fi
# fi

set -e
sudo sed -i 's/^dtparam=audio=on$/dtparam=audio=off/' /boot/firmware/config.txt
sudo apt install -y libopenblas-dev git
git clone https://github.com/pimoroni/pirate-audio
cd pirate-audio/
git checkout feature/pi5-mopidy
cd ./mopidy/

# need to modify this so we use our own install .sh that doesn't install mopidy and installs:
pip3 install mutagen

./install.sh
sudo apt install -y python3-pygame
cd ~/
git clone https://github.com/batgranny/omd.git
cd omd
git checkout pirate-audio
sudo cp ~/omd/player/mp3/01.\ I\ Knew.mp3  ~/Music/

echo "Setup complete! rebooting..."
sudo reboot now

# # Exit immediately if a command exits with a non-zero status
# set -e
# echo "Installing componants..."

# #fix for https://github.com/pimoroni/pirate-audio/issues/104
# sudo apt remove -y python3-numpy 
# sudo apt install -y libopenblas-dev
# sudo apt-get install -y python3-rpi.gpio python3-spidev python3-pip python3-pil git
# sudo pip3 install numpy --break-system-packages

# #fix for RuntimeError: Failed to add edge detection issue - didn't fix it though
# echo "Installing st7789-python..."
# git clone https://github.com/pimoroni/st7789-python.git
# cd st7789-python/
# git checkout feature/floyd-made-me-do-it
# git pull
# pip3 install ./ --break-system-packages

# echo "Installing pirate-audio and mopidy..."
# git clone https://github.com/pimoroni/pirate-audio
# cd pirate-audio/
# cd ./mopidy/

# # fix for https://github.com/pimoroni/pirate-audio/issues/98
# echo "Modifying the install.sh script to use --break-system-packages..."
# sed -i 's|\$PIP_BIN install --upgrade|\$PIP_BIN install --break-system-packages --upgrade|g' install.sh

# echo "Running the install.sh script..."
# sudo ./install.sh

# echo "Setup complete! rebooting..."
# sudo reboot now
