#!/usr/bin/env bash
set -euo pipefail

# Update pip itself
brew list |
    sed -rn 's/python@(.+)/\1/p' |
    xargs -I{} bash -c '/opt/homebrew/bin/"python{}" -m pip install --upgrade pip'

# Update packages installed by pip
brew list |
    sed -rn 's/python@(.+)/\1/p' |
    xargs -I{} bash -c '/opt/homebrew/bin/"pip{}" list --format=freeze |
        grep -v "^\-e" |
        cut -d = -f 1 |
        xargs -n1 pip{} install -U'
