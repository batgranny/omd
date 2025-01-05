### Similar projects
* [PiPod](https://hackaday.io/project/26157-pipod)
* [python project](https://www.youtube.com/watch?v=AzPH5V-sfsI&list=WL&ab_channel=RP2040Projects)
* [Reddit discussion](https://www.reddit.com/r/3Dprinting/comments/95e463/3d_printed_portable_music_player_with_raspberry/)

## Installation
1. install the 32-bit OS lite image
2. ``sudo apt update && sudo apt upgrade``
3. sudo raspi-config  - turn on spi and i2c
4. sudo nano /boot/firmware/config.txt, add
```
dtoverlay=hifiberry-dac
gpio=25=op,dh
```
5. sudo apt-get install python3-rpi.gpio python3-spidev python3-pip python3-pil python3-numpy
sudo pip3 install pidi-display-st7789  --break-system-packages
sudo pip3 install pyfluidsynth  --break-system-packages
6. ``sudo apt install libopenblas-dev``
7. i``sudo apt install git``
7. there is a dirty kludge fix for now on bookworm. edit 'install.sh' and locate the lines beginning with ' $PIP_BIN install --upgrade ' edit them like so ' $PIP_BIN install --break-system-packages --upgrade '
1. Install the Pirate radio HAT

## Attempt 2
3.  ``sudo raspi-config`` #turn on spi and i2c
5.  ``sudo apt install libopenblas-dev``
6.  ``sudo apt install git``
7.  ``git clone https://github.com/pimoroni/st7789-python.git``
8.  ``cd st7789-python/``
9.  ``git checkout feature/floyd-made-me-do-it``
10.  ``git pull``
11.  ``git checkout feature/floyd-made-me-do-it``
13.  ``sudo pip3 uninstall pidi-display-st7789  --break-system-packages``
15.  ``pip install ./`` 
17  ``cd ../``
18  ``git clone https://github.com/pimoroni/pirate-audio``
19  ``git checkout feature/pi5-mopidy``
20  ``cd pirate-audio/``
21  ``git checkout feature/pi5-mopidy``
22  ``cd ./mopidy/`` 
25  ``./install.sh`` 

## Attempt 3

1.  ``sudo raspi-config`` #turn on spi and i2c
2. ``sudo reboot now``
3.  ``sudo apt remove python3-numpy``
5.  ``sudo apt install libopenblas-dev``
6.  ``sudo apt-get install python3-rpi.gpio python3-spidev python3-pip python3-pil git -y`` 
6.   ``sudo pip install numpy --break-system-packages``
7.  ``git clone https://github.com/pimoroni/st7789-python.git``
8.  ``cd st7789-python/``
9.  ``git checkout feature/floyd-made-me-do-it``
10.  ``git pull``
15.  ``pip install ./ --break-system-packages`` 
17  ``cd ../``
18  ``git clone https://github.com/pimoroni/pirate-audio``
20  ``cd pirate-audio/``
22  ``cd ./mopidy/`` 
23  ``sed -i 's|\$PIP_BIN install --upgrade|\$PIP_BIN install --break-system-packages --upgrade|g' install.sh``
25  ``./install.sh`` 
