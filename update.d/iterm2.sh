#!/usr/bin/env bash
set -euo pipefail

curl -L --no-progress-bar https://iterm2.com/shell_integration/fish \
    -o ~/.config/fish/conf.d/90_iterm2_shell_integration.fish
