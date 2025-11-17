#!/usr/bin/env bash
set -euo pipefail
IFS=$'\n\t'

DEPS_FILE="$HOME/.config/js-global-deps.txt"

if [ -e "$DEPS_FILE" ]; then
  cat "$DEPS_FILE" | xargs npm install -g
fi
