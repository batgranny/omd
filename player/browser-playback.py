import os
import RPi.GPIO as GPIO
import time
from PIL import Image, ImageDraw, ImageFont
from st7789 import ST7789
import pygame
from mutagen.mp3 import MP3
from mutagen.easyid3 import EasyID3

# Constants
MUSIC_DIR = "/home/pi/Music"
BUTTONS = {
    "up": 24,            # Volume Up button
    "down": 6,           # Volume Down button
    "select": 16,        # Play/Pause button
    "back": 5            # Back button
}
SPI_SPEED_MHZ = 80

# State variables
current_dir = MUSIC_DIR
current_index = 0
playing = False  # Track whether music is playing
browsing = True  # Track whether the user is browsing
paused = False   # Track whether playback is paused
scroll_offset = 0

# Set up GPIO
GPIO.setmode(GPIO.BCM)
for button in BUTTONS.values():
    GPIO.setup(button, GPIO.IN, pull_up_down=GPIO.PUD_UP)

# Initialize pygame mixer
pygame.mixer.init()
pygame.mixer.music.set_volume(0.5)  # Set initial volume to 50%

# Set up the ST7789 display
st7789 = ST7789(
    rotation=90,
    port=0,
    cs=1,
    dc=9,
    backlight=13,
    spi_speed_hz=SPI_SPEED_MHZ * 1000 * 1000
)

# Load fonts
try:
    large_font = ImageFont.truetype("/usr/share/fonts/truetype/dejavu/DejaVuSans-Bold.ttf", 24)
    medium_font = ImageFont.truetype("/usr/share/fonts/truetype/dejavu/DejaVuSans-Bold.ttf", 18)
    small_font = ImageFont.truetype("/usr/share/fonts/truetype/dejavu/DejaVuSans-Bold.ttf", 14)
except IOError:
    large_font = medium_font = small_font = ImageFont.load_default()

def list_directory(directory):
    """List all non-hidden files and directories in the given directory."""
    try:
        items = os.listdir(directory)
        return sorted([item for item in items if not item.startswith('.')])
    except PermissionError:
        return []

def display_browsing(current_dir, current_index, items):
    """Display the current directory and its contents on the screen."""
    image = Image.new("RGB", (240, 240), (0, 0, 0))
    draw = ImageDraw.Draw(image)

    # Draw header
    draw.rectangle((0, 0, 240, 20), fill=(0, 128, 128))
    draw.text((5, 2), f"Dir: {os.path.basename(current_dir)}", fill=(255, 255, 255), font=small_font)

    # Display items
    for i, item in enumerate(items[:10]):  # Show up to 10 items
        y_position = 30 + i * 20
        color = (255, 255, 255) if i != current_index else (255, 0, 0)
        draw.text((10, y_position), item, fill=color, font=medium_font)

    st7789.display(image)

def display_playing(track, artist, album):
    """Display the track name, artist, and album while playing an MP3."""
    global scroll_offset
    image = Image.new("RGB", (240, 240), (0, 0, 0))
    draw = ImageDraw.Draw(image)

    # Title scrolling
    title_bbox = draw.textbbox((0, 0), track, font=large_font)
    title_width = title_bbox[2] - title_bbox[0]
    if title_width > 240:
        scroll_offset = (scroll_offset + 2) % (title_width + 240)
        draw.text((-scroll_offset, 20), track, fill=(255, 255, 255), font=large_font)
    else:
        scroll_offset = 0
        draw.text((10, 20), track, fill=(255, 255, 255), font=large_font)

    # Artist and album
    draw.text((10, 70), f"Artist: {artist}", fill=(200, 200, 200), font=medium_font)
    draw.text((10, 100), f"Album: {album}", fill=(200, 200, 200), font=small_font)

    st7789.display(image)

def play_mp3(file_path):
    """Play or pause the selected MP3 file and display metadata."""
    global playing, paused, browsing

    if playing and paused:
        # Resume playback
        pygame.mixer.music.unpause()
        paused = False
    elif playing:
        # Pause playback
        pygame.mixer.music.pause()
        paused = True
    else:
        # Start playing a new file
        pygame.mixer.music.load(file_path)
        pygame.mixer.music.play()
        playing = True
        paused = False
        browsing = False

        # Extract metadata
        audio = MP3(file_path, ID3=EasyID3)
        track = audio.get("title", ["Unknown Title"])[0]
        artist = audio.get("artist", ["Unknown Artist"])[0]
        album = audio.get("album", ["Unknown Album"])[0]

        # Display playing screen
        display_playing(track, artist, album)

def button_pressed(channel):
    """Handle button presses."""
    global current_dir, current_index, playing, paused, browsing
    items = list_directory(current_dir)

    if browsing:
        # Reverse behavior for browsing
        if channel == BUTTONS["up"]:
            current_index = (current_index + 1) % len(items)
        elif channel == BUTTONS["down"]:
            current_index = (current_index - 1) % len(items)
    else:
        # Volume controls in playing mode
        if channel == BUTTONS["up"]:
            volume = min(pygame.mixer.music.get_volume() + 0.1, 1.0)
            pygame.mixer.music.set_volume(volume)
        elif channel == BUTTONS["down"]:
            volume = max(pygame.mixer.music.get_volume() - 0.1, 0.0)
            pygame.mixer.music.set_volume(volume)

    if channel == BUTTONS["select"]:
        if not browsing:
            play_mp3("")
        else:
            selected_item = items[current_index]
            selected_path = os.path.join(current_dir, selected_item)
            if os.path.isfile(selected_path) and selected_path.endswith('.mp3'):
                play_mp3(selected_path)
            elif os.path.isdir(selected_path):
                current_dir = selected_path
                current_index = 0
    elif channel == BUTTONS["back"]:
        if playing:
            pygame.mixer.music.stop()
            playing = False
            paused = False
            browsing = True
        else:
            current_dir = os.path.dirname(current_dir)
            current_index = 0

    # Refresh display
    if browsing:
        display_browsing(current_dir, current_index, list_directory(current_dir))

# Attach button callbacks
for button_name, pin in BUTTONS.items():
    GPIO.add_event_detect(pin, GPIO.FALLING, callback=button_pressed, bouncetime=300)

try:
    # Initial display
    items = list_directory(current_dir)
    display_browsing(current_dir, current_index, items)

    while True:
        time.sleep(0.1)
except KeyboardInterrupt:
    print("\nExiting...")
finally:
    pygame.mixer.music.stop()
    GPIO.cleanup()