#!/bin/bash
set -euo pipefail

declare -A dotfiles=(
    ["$HOME/.tmux.conf"]="tmux/.tmux.conf"
    ["$HOME/.tmuxline"]="tmux/.tmuxline"
    ["$HOME/.vim/vimrc"]="vim/vimrc"
    ["$HOME/.config/starship.toml"]="starship/starship.toml"
    ["$HOME/.gitconfig"]="git/.gitconfig"
    ["$HOME/.gitmessage"]="git/.gitmessage"
)

for i in "${!dotfiles[@]}"; do
    echo "$i: ${dotfiles[$i]}"
    diff "$i" "${dotfiles[$i]}"
done
