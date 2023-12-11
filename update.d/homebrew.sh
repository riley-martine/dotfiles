#!/usr/bin/env bash
set -euo pipefail

trap 'brew unlink openssh' EXIT
# We need to move the fzf fish file so it doesn't override atuin's binds
trap '$HOME/.local/share/update.d/fzf.sh' EXIT
brew update
brew upgrade
brew upgrade --cask --greedy
brew cleanup
