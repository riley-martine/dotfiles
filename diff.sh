#!/bin/bash
set -euo pipefail

declare -A dotfiles=(
    ["$HOME/.tmux.conf"]="tmux/.tmux.conf"
    ["$HOME/.tmuxline"]="tmux/.tmuxline"
    ["$HOME/.vim/vimrc"]="vim/vimrc"
)

for i in "${!dotfiles[@]}"; do
    echo "$i: ${dotfiles[$i]}"
    diff "$i" "${dotfiles[$i]}"
done
