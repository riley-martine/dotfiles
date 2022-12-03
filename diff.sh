#!/usr/bin/env bash
set -uo pipefail

declare -A dotfiles
dotfiles=(
    ["$HOME/.tmux.conf"]="tmux/.tmux.conf"
    ["$HOME/.config/tmux/tokyonight_day.tmux"]="tmux/tokyonight_day.tmux"

    ["$HOME/.vim/vimrc"]="vim/vimrc"

    ["$HOME/.config/starship.toml"]="starship/starship.toml"

    ["$HOME/.gitconfig"]="git/.gitconfig"
    ["$HOME/.config/git/identity.gitconfig"]="git/identity.gitconfig"
    ["$HOME/.config/git/gitmessage"]="git/gitmessage"
    ["$HOME/.config/git/gitignore"]="git/gitignore"

    ["$__fish_config_dir/fish_plugins"]="fish/fish_plugins"
    ["$__fish_config_dir/config.fish"]="fish/config.fish"
)

for i in "${!dotfiles[@]}"; do
    PAGER='cat' delta "$i" "${dotfiles[$i]}"
done

fish installed.fish
