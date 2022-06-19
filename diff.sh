#!/bin/bash
set -uo pipefail

declare -A dotfiles=(
    ["$HOME/.tmux.conf"]="tmux/.tmux.conf"
    ["$HOME/.tmuxline"]="tmux/.tmuxline"
    ["$HOME/.vim/vimrc"]="vim/vimrc"
    ["$HOME/.config/starship.toml"]="starship/starship.toml"
    ["$HOME/.gitconfig"]="git/.gitconfig"
    ["$HOME/.gitmessage"]="git/.gitmessage"
    ["$__fish_config_dir/fish_plugins"]="fish/fish_plugins"
    ["$__fish_config_dir/config.fish"]="fish/config.fish"
)

for i in "${!dotfiles[@]}"; do
    diff "$i" "${dotfiles[$i]}"
done

fish installed.fish
