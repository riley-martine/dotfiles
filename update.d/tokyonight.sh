#!/usr/bin/env bash

set -euo pipefail

wget 'https://raw.githubusercontent.com/folke/tokyonight.nvim/main/extras/iterm/tokyonight_day.itermcolors' --output-document ~/.config/iterm2/tokyonight_day.itermcolors
wget 'https://raw.githubusercontent.com/folke/tokyonight.nvim/main/extras/fzf/tokyonight_day.sh' --output-document ~/.config/fish/conf.d/51_fzf_theme.fish
wget 'https://raw.githubusercontent.com/folke/tokyonight.nvim/main/extras/tmux/tokyonight_day.tmux' --output-document  ~/.config/tmux/tokyonight_day.tmux
wget 'https://raw.githubusercontent.com/folke/tokyonight.nvim/main/extras/delta/tokyonight_day.gitconfig' --output-document ~/.config/git/tokyonight_day.gitconfig
wget 'https://raw.githubusercontent.com/folke/tokyonight.nvim/main/extras/fish/tokyonight_day.fish' --output-document  ~/.config/fish/themes/tokyonight_day.fish
wget 'https://raw.githubusercontent.com/folke/tokyonight.nvim/main/extras/eza/tokyonight_day.yml' --output-document "$HOME/Library/Application Support/eza/theme.yml"
wget 'https://raw.githubusercontent.com/folke/tokyonight.nvim/main/extras/sublime/tokyonight_day.tmTheme' --output-document ~/.config/bat/themes/tokyonight_day.tmTheme
bat cache --build
