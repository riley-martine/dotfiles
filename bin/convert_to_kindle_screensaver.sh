#!/usr/bin/env bash

# Convert PNG image to kindle pw3 image
# Dimensions from https://www.mobileread.com/forums/showthread.php?t=195474
# And original script from there as well
# Mine adds borders though, and assumes image has a white background

convert "$1" \
    -filter LanczosSharp \
    -bordercolor white -border 8%x8% \
    -resize 1072x1448 -background white -gravity center -extent '1072x1448!' \
    -colorspace Gray -dither Riemersma -remap kindle_colors.gif \
    -quality 75 -define png:color-type=0 -define png:bit-depth=8 +repage \
    "$(basename "$1")_out.png"
