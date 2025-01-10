import time
from PIL import Image, ImageDraw, ImageFont
from ST7789 import ST7789


print("""test_message.py - Display a test message on the Pirate Audio LCD

This example should demonstrate how to:
1. set up the Pirate Audio LCD,
2. create a PIL image to use as a buffer,
3. draw something into that image,
4. and display it on the display

You should see the text "This is a test" on the screen.

Press Ctrl+C to exit!

""")

SPI_SPEED_MHZ = 80

# Create a new PIL image with black background
image = Image.new("RGB", (240, 240), (0, 0, 0))
draw = ImageDraw.Draw(image)

# Set up the ST7789 display
st7789 = ST7789(
    rotation=90,  # Needed to display the right way up on Pirate Audio
    port=0,       # SPI port
    cs=1,         # SPI port Chip-select channel
    dc=9,         # BCM pin used for data/command
    backlight=13,
    spi_speed_hz=SPI_SPEED_MHZ * 1000 * 1000
)

# Load a font (default PIL font will be used if no custom font is available)
try:
    font = ImageFont.truetype("/usr/share/fonts/truetype/dejavu/DejaVuSans-Bold.ttf", 24)
except IOError:
    font = ImageFont.load_default()

# Clear the screen by filling it with black
draw.rectangle((0, 0, 240, 240), (0, 0, 0))

# Draw the text in white at the center of the screen
message = "This is a test"
text_width, text_height = draw.textsize(message, font=font)
text_x = (240 - text_width) // 2
text_y = (240 - text_height) // 2
draw.text((text_x, text_y), message, fill=(255, 255, 255), font=font)

# Display the image on the screen
st7789.display(image)

print("Message displayed. Press Ctrl+C to exit.")

# Keep the message displayed indefinitely
while True:
    time.sleep(1)