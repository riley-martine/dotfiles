#!/usr/bin/env bash
set -euo pipefail

/opt/homebrew/opt/fzf/install --all
FISH="$HOME/.config/fish/conf.d/fzf.fish"
if [ -f "$FISH" ]; then
    mv "$FISH" "$HOME/.config/fish/conf.d/50_fzf.fish"
fi
