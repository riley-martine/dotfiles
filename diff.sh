#!/usr/bin/env bash
set -euo pipefail

# This script detects differences between git-versioned config and the local system.
# It offers options for what to do about them.
# It is called without arguments.

# TODO allowed patch for e.g. work starship.toml
# TODO something about WIZARD and other symlinks
# TODO why are things printed three times oops
# TODO merge tomls for work starship

declare -A dotfiles
dotfiles=(
    ["$HOME/.tmux.conf"]="tmux/.tmux.conf"
    ["$HOME/.config/tmux/"]="tmux/config"

    ["$HOME/.vim/vimrc"]="vim/vimrc"
    ["$HOME/.vim/syntax/"]="vim/syntax"

    ["$HOME/.vale.ini"]="vale/.vale.ini"

    ["$HOME/.config/starship.toml"]="starship/starship.toml"

    ["$HOME/.gitconfig"]="git/.gitconfig"
    ["$HOME/.config/git/gitignore"]="git/config/gitignore"
    ["$HOME/.config/git/tokyonight_day.gitconfig"]="git/config/tokyonight_day.gitconfig"
    ["$HOME/.config/git/gitmessage"]="git/config/gitmessage"

    ["$HOME/.config/iterm2/tokyonight_day.itermcolors"]="iterm2/tokyonight_day.itermcolors"
    ["$HOME/.config/iterm2/com.googlecode.iterm2.plist"]="iterm2/com.googlecode.iterm2.plist"

    ["$HOME/.config/bat/"]="bat/config/"

    ["$HOME/.config/fish/fish_plugins"]="fish/config/fish_plugins"
    ["$HOME/.config/fish/config.fish"]="fish/config/config.fish"
    ["$HOME/.config/fish/themes/"]="fish/config/themes"
    ["$HOME/.config/fish/functions/__ssh_agent_is_started.fish"]="fish/config/functions/__ssh_agent_is_started.fish"
    ["$HOME/.config/fish/functions/__ssh_agent_start.fish"]="fish/config/functions/__ssh_agent_start.fish"

    ["$HOME/Library/Application Support/ruff/pyproject.toml"]="ruff/pyproject.toml"

    ["$HOME/Documents/Tokyonight Day.terminal"]="terminal.app/Tokyonight Day.terminal"

    ["$HOME/bin/"]="bin"

    ["$HOME/.local/share/update.d/"]="update.d"
)

# Compare two files to see if they match
function compare_file {
    local LOCAL="$1"
    local GIT="$2"

    if ! [ -f "$LOCAL" ]; then
        echo "=================================================================================="
        echo "Local dotfile does not exist: $LOCAL" >&2
        return 1
    fi

    if ! [ -f "$GIT" ]; then
        echo "=================================================================================="
        echo "$GIT does not exist. Run:" >&2
        echo " cp $LOCAL $GIT"
        return 0
    fi

    if PAGER='cat' delta --width "$(tput cols)" "$(realpath "$LOCAL")" "$GIT"; then
        # echo "EQUAL: $LOCAL $GIT"
        return 0
    fi

    echo "=================================================================================="
    echo "edit files:"
    echo "  vim $LOCAL $GIT +vsplit  -c ':1' -c ':wincmd l' -c ':bnext' -c ':1'"
    echo "clobber local:"
    echo " command cp $GIT $LOCAL"
    echo "clobber remote:"
    echo " command cp $LOCAL $GIT"
}

# Recurse
function compare_maybe_dir {
    local LOCAL GIT
    LOCAL="$(echo "$1" | tr -s /)"
    GIT="$(echo "$2" | tr -s /)"

    if ! [ -e "$LOCAL" ]; then
        echo "=================================================================================="
        echo "Expected dotfile does not exist: $LOCAL" >&2
        echo "add to local:"
        echo " command cp $GIT $LOCAL"
        return
    fi

    if [ -f "$LOCAL" ]; then
        compare_file "$LOCAL" "$GIT"
        return
    fi

    if [ -d "$LOCAL" ]; then
        for local_maybe_dir in "$LOCAL"/*; do
            local final
            final="$(basename "$local_maybe_dir")"
            compare_maybe_dir "$local_maybe_dir" "${GIT}/${final}"
        done
        # TODO remove dupes, add copy cmd
        for git_maybe_dir in "$GIT"/*; do
            local final
            final="$(basename "$git_maybe_dir")"
            compare_maybe_dir "${LOCAL}/${final}" "$git_maybe_dir"
        done
        return
    fi

    echo "This should never happen" >&2
    return 1
}



for local in "${!dotfiles[@]}"; do
    compare_maybe_dir "$(echo "$local" | tr -s /)" "${dotfiles[$local]}"
done

# All my fish configs are in the form 30_pyenv.fish
# So we can exclude the ones created by fish_plugins
for config in "$HOME/.config/fish/conf.d"/*; do
    if basename "$config" | grep -qE '^\d\d' ; then
        gitconfig=fish/config/conf.d/"$(basename "$config")"
        compare_file "$config" "$gitconfig"
    fi
done

fish installed.fish

# TODO add "--install" flag
