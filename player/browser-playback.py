import os
import RPi.GPIO as GPIO
import time
from PIL import Image, ImageDraw, ImageFont
from ST7789 import ST7789
import pygame  # Import pygame for MP3 playback
from mutagen.easyid3 import EasyID3  # For reading MP3 metadata

# Constants
MUSIC_DIR = "/home/pi/Music"
BUTTONS = {
    "up": 24,            # Volume Up button
    "down": 6,           # Volume Down button
    "select": 16,        # Play/Pause button
    "back": 5            # Back/Stop button
}
SPI_SPEED_MHZ = 80

# State variables
current_dir = MUSIC_DIR
current_index = 0
playing = False  # Track whether music is playing
current_volume = 0.5  # Initial volume set to 50%
current_track = ""  # Track name for display
current_artist = ""  # Artist name for display
current_album = ""  # Album name for display
scroll_offset = 0  # For scrolling text

# Set up GPIO
GPIO.setmode(GPIO.BCM)
for button in BUTTONS.values():
    GPIO.setup(button, GPIO.IN, pull_up_down=GPIO.PUD_UP)

# Initialize pygame mixer
pygame.mixer.init()
pygame.mixer.music.set_volume(current_volume)

# Set up the ST7789 display
st7789 = ST7789(
    rotation=90,  # Needed to display the right way up on Pirate Audio
    port=0,       # SPI port
    cs=1,         # SPI port Chip-select channel
    dc=9,         # BCM pin used for data/command
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

def display_playing(track, artist, album):
    """Display the track name, artist, and album while playing an MP3."""
    global scroll_offset
    image = Image.new("RGB", (240, 240), (0, 0, 0))
    draw = ImageDraw.Draw(image)

    # Draw title with scrolling if needed
    title_bbox = draw.textbbox((0, 0), track, font=large_font)
    title_width = title_bbox[2] - title_bbox[0]
    if title_width > 240:
        scroll_offset = (scroll_offset + 2) % (title_width + 240)
        draw.text((-scroll_offset, 20), track, fill=(255, 255, 255), font=large_font)
    else:
        scroll_offset = 0
        draw.text((10, 20), track, fill=(255, 255, 255), font=large_font)

    # Draw artist and album below the title
    draw.text((10, 70), f"Artist: {artist}", fill=(200, 200, 200), font=medium_font)
    draw.text((10, 100), f"Album: {album}", fill=(200, 200, 200), font=small_font)

    st7789.display(image)

def display_tree(current_dir, current_index, items):
    """Display the current directory and its contents on the screen."""
    image = Image.new("RGB", (240, 240), (0, 0, 0))
    draw = ImageDraw.Draw(image)

    # Header: Display current directory
    draw.rectangle((0, 0, 240, 20), fill=(0, 128, 128))  # Header background
    draw.text((5, 2), f"Dir: {os.path.basename(current_dir)}", fill=(255, 255, 255), font=small_font)

    # Display the items in the directory
    for i, item in enumerate(items[:8]):  # Display up to 8 items
        y_position = 30 + i * 20
        color = (255, 255, 255) if i != current_index else (255, 0, 0)  # Highlight selected
        draw.text((10, y_position), item, fill=color, font=medium_font)

    st7789.display(image)

def play_mp3(file_path):
    """Play the selected MP3 file and display metadata."""
    global playing, current_track, current_artist, current_album

    # Stop any currently playing track
    if playing:
        pygame.mixer.music.stop()
        playing = False

    # Extract metadata using mutagen
    try:
        audio = EasyID3(file_path)
        current_track = audio.get("title", ["Unknown Track"])[0]
        current_artist = audio.get("artist", ["Unknown Artist"])[0]
        current_album = audio.get("album", ["Unknown Album"])[0]
    except Exception:
        current_track = "Unknown Track"
        current_artist = "Unknown Artist"
        current_album = "Unknown Album"

    # Load and play the MP3 file
    pygame.mixer.music.load(file_path)
    pygame.mixer.music.play()
    playing = True

def button_pressed(channel):
    """Handle button presses."""
    global current_dir, current_index, playing, current_volume, scroll_offset
    items = list_directory(current_dir)

    if playing:
        # Volume control when music is playing
        if channel == BUTTONS["up"]:
            current_volume = min(current_volume + 0.1, 1.0)  # Increase volume
            pygame.mixer.music.set_volume(current_volume)
        elif channel == BUTTONS["down"]:
            current_volume = max(current_volume - 0.1, 0.0)  # Decrease volume
            pygame.mixer.music.set_volume(current_volume)
        elif channel == BUTTONS["back"]:
            pygame.mixer.music.stop()
            playing = False
            scroll_offset = 0  # Reset scroll offset
            display_tree(current_dir, current_index, items)  # Return to browser
    else:
        # File navigation when no music is playing
        if channel == BUTTONS["up"]:
            current_index = (current_index - 1) % len(items)  # Browse up
        elif channel == BUTTONS["down"]:
            current_index = (current_index + 1) % len(items)  # Browse down

        if channel == BUTTONS["select"]:
            selected_item = items[current_index]
            selected_path = os.path.join(current_dir, selected_item)
            if os.path.isfile(selected_path) and selected_path.endswith('.mp3'):
                play_mp3(selected_path)
            elif os.path.isdir(selected_path):
                current_dir = selected_path
                current_index = 0

    # Refresh display based on state
    if playing:
        display_playing(current_track, current_artist, current_album)
    else:
        display_tree(current_dir, current_index, list_directory(current_dir))

# Attach event detection for buttons
for button_name, pin in BUTTONS.items():
    GPIO.add_event_detect(pin, GPIO.FALLING, callback=button_pressed, bouncetime=300)

try:
    # Initial Display
    items = list_directory(current_dir)
    display_tree(current_dir, current_index, items)

    # Keep the script running
    while True:
        if playing:
            display_playing(current_track, current_artist, current_album)  # Refresh display for scrolling
        time.sleep(0.1)
except KeyboardInterrupt:
    print("\nExiting...")
finally:
    pygame.mixer.music.stop()  # Stop playback on exit
    GPIO.cleanup()