#!/usr/bin/env bash
set -euo pipefail
IFS=$'\n\t'

# Converts the latest screen recording to a gif using Gifski
# Requires Gifski GUI to be installed:
#   https://github.com/sindresorhus/Gifski
# Requires Gnu find to be installed:
#   brew install findutils
# Usage: screen2gif.sh
#
# TODO: Add in some applescript to fully automate this

# We use Gifski GUI because I'm tired of struggling with ffmpeg to get the
# colors right when converting from apple's mov format, and gifski Just
# Works™ (though I've also struggled getting the cli version's colors right)

folder="$(defaults read com.apple.screencapture location)"
screencap="$(gfind "$folder"/*.mov -printf "%T@\0%p\n" | sort -n | tail -1 | cut -d '' -f2)"
open -a Gifski "$screencap"
