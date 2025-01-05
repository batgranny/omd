#!/bin/bash

# Exit immediately if a command exits with a non-zero status
set -e
echo "Installing componants..."

#fix for https://github.com/pimoroni/pirate-audio/issues/104
sudo apt remove -y python3-numpy 
sudo apt install -y libopenblas-dev
sudo apt-get install -y python3-rpi.gpio python3-spidev python3-pip python3-pil git
sudo pip3 install numpy --break-system-packages

#fix for RuntimeError: Failed to add edge detection issue - didn't fix it though
echo "Installing st7789-python..."
git clone https://github.com/pimoroni/st7789-python.git
cd st7789-python/
git checkout feature/floyd-made-me-do-it
git pull
pip3 install ./ --break-system-packages

echo "Installing pirate-audio and mopidy..."
git clone https://github.com/pimoroni/pirate-audio
cd pirate-audio/
cd ./mopidy/

# fix for https://github.com/pimoroni/pirate-audio/issues/98
echo "Modifying the install.sh script to use --break-system-packages..."
sed -i 's|\$PIP_BIN install --upgrade|\$PIP_BIN install --break-system-packages --upgrade|g' install.sh

echo "Running the install.sh script..."
sudo ./install.sh

echo "Setup complete! rebooting..."
sudo reboot now

#THIS IS THE ERROR AFTER THE SCRIPT COMPLETES
# Jan 05 16:16:56 raspberrypi mopidy[821]:   File "/usr/lib/python3/dist-packages/mopidy/commands.py", line 445, in start_frontends
# Jan 05 16:16:56 raspberrypi mopidy[821]:     frontend_class.start(config=config, core=core)
# Jan 05 16:16:56 raspberrypi mopidy[821]:   File "/usr/lib/python3/dist-packages/pykka/_actor.py", line 86, in start
# Jan 05 16:16:56 raspberrypi mopidy[821]:     obj = cls(*args, **kwargs)
# Jan 05 16:16:56 raspberrypi mopidy[821]:           ^^^^^^^^^^^^^^^^^^^^
# Jan 05 16:16:56 raspberrypi mopidy[821]:   File "/usr/local/lib/python3.11/dist-packages/mopidy_raspberry_gpio/frontend.py", line 52, in __init__
# Jan 05 16:16:56 raspberrypi mopidy[821]:     GPIO.add_event_detect(
# Jan 05 16:16:56 raspberrypi mopidy[821]: RuntimeError: Failed to add edge detection
# Jan 05 16:16:56 raspberrypi mopidy[821]: INFO     [HttpFrontend-9 (_actor_loop)] mopidy.http.actor HTTP server running at [::ffff:0.0.0.0]:6680
# Jan 05 16:16:56 raspberrypi mopidy[821]: INFO     [MainThread] mopidy.commands Starting GLib mainloop