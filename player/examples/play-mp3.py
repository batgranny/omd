
import pygame
import time

# Initialize pygame mixer
pygame.mixer.init()

# Set the volume to 50%
pygame.mixer.music.set_volume(0.5)  # Volume range: 0.0 (mute) to 1.0 (full volume)

# Load the MP3 file
mp3_file = "/home/pi/Music/Nirvana/Nevermind/Something In The Way.mp3"
pygame.mixer.music.load(mp3_file)

# Play the MP3 file
pygame.mixer.music.play()

# Wait while the music plays
while pygame.mixer.music.get_busy():
    time.sleep(1)