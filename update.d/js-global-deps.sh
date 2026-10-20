#!/usr/bin/env bash
set -euo pipefail
IFS=$'\n\t'

DEPS_FILE="$HOME/.config/js-global-deps.txt"
# js globals are machine-level, not per-node-version; they live in Homebrew's
# node prefix even when the calling shell has an nvm node active.
NPM="/opt/homebrew/bin/npm"

if [ -e "$DEPS_FILE" ]; then
  cat "$DEPS_FILE" | xargs "$NPM" install -g
fi
