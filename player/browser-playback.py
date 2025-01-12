import os
import RPi.GPIO as GPIO
import time
from PIL import Image, ImageDraw, ImageFont
from ST7789 import ST7789
import pygame  # Import pygame for MP3 playback

# Constants
MUSIC_DIR = "/home/pi/Music"
BUTTONS = {
    "up": 24,            # Volume Up button
    "down": 6,           # Volume Down button
    "select": 16,        # Play/Pause button
    "back": 5            # Next button
}
SPI_SPEED_MHZ = 80

# State variables
current_dir = MUSIC_DIR
current_index = 0
playing = False  # Track whether music is playing
current_volume = 0.5  # Initial volume set to 50%

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

# Load a font (use the default if custom font is unavailable)
try:
    font = ImageFont.truetype("/usr/share/fonts/truetype/dejavu/DejaVuSans-Bold.ttf", 18)
except IOError:
    font = ImageFont.load_default()

def list_directory(directory):
    """List all non-hidden files and directories in the given directory."""
    try:
        items = os.listdir(directory)
        return sorted([item for item in items if not item.startswith('.')])
    except PermissionError:
        return []

def display_tree(current_dir, current_index, items, playing, volume):
    """Display the current directory and its contents on the screen."""
    # Create a new image with a black background
    image = Image.new("RGB", (240, 240), (0, 0, 0))
    draw = ImageDraw.Draw(image)

    # Draw the current directory name at the top
    draw.rectangle((0, 0, 240, 20), fill=(0, 128, 128))  # Header background
    status = f"Playing | Vol: {int(volume * 100)}%" if playing else "Stopped"
    draw.text((5, 2), f"Dir: {os.path.basename(current_dir)} | {status}", fill=(255, 255, 255), font=font)

    # Display the items in the directory
    for i, item in enumerate(items[:10]):  # Display up to 10 items
        y_position = 30 + i * 20
        color = (255, 255, 255) if i != current_index else (255, 0, 0)  # Highlight selected
        draw.text((10, y_position), item, fill=color, font=font)

    # Display the image on the screen
    st7789.display(image)

def play_mp3(file_path):
    """Play the selected MP3 file."""
    global playing
    if playing:
        pygame.mixer.music.stop()
        playing = False
    pygame.mixer.music.load(file_path)
    pygame.mixer.music.play()
    playing = True

def button_pressed(channel):
    """Handle button presses."""
    global current_dir, current_index, playing, current_volume
    items = list_directory(current_dir)

    if playing:
        # Volume control when music is playing
        if channel == BUTTONS["up"]:
            current_volume = min(current_volume + 0.1, 1.0)  # Increase volume
            pygame.mixer.music.set_volume(current_volume)
        elif channel == BUTTONS["down"]:
            current_volume = max(current_volume - 0.1, 0.0)  # Decrease volume
            pygame.mixer.music.set_volume(current_volume)
    else:
        # File navigation when no music is playing
        if channel == BUTTONS["up"]:
            current_index = (current_index + 1) % len(items)  # Browse down (reversed functionality)
        elif channel == BUTTONS["down"]:
            current_index = (current_index - 1) % len(items)  # Browse up (reversed functionality)

    if channel == BUTTONS["select"]:
        selected_item = items[current_index]
        selected_path = os.path.join(current_dir, selected_item)
        if os.path.isfile(selected_path) and selected_path.endswith('.mp3'):
            play_mp3(selected_path)
        elif os.path.isdir(selected_path):
            current_dir = selected_path
            current_index = 0
    elif channel == BUTTONS["back"]:
        pygame.mixer.music.stop()
        playing = False
        current_dir = os.path.dirname(current_dir)
        current_index = 0

    # Refresh display
    display_tree(current_dir, current_index, list_directory(current_dir), playing, current_volume)

# Attach event detection for buttons
for button_name, pin in BUTTONS.items():
    GPIO.add_event_detect(pin, GPIO.FALLING, callback=button_pressed, bouncetime=300)

try:
    # Initial Display
    items = list_directory(current_dir)
    display_tree(current_dir, current_index, items, playing, current_volume)

    # Keep the script running
    while True:
        time.sleep(0.1)
except KeyboardInterrupt:
    print("\nExiting...")
finally:
    pygame.mixer.music.stop()  # Stop playback on exit
    GPIO.cleanup()