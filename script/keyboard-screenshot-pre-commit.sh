#!/bin/sh

# Create a screenshot of keyboard.html
/Applications/Google\ Chrome.app/Contents/MacOS/Google\ Chrome --headless --force-device-scale-factor=1 --disable-gpu --screenshot=keyboard.png --window-size=2200,1032 keyboard.html
convert -units PixelsPerInch keyboard.png -density 144 keyboard.png