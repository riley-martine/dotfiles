#!/usr/bin/env bash
set -euo pipefail

# Update pip itself
brew list |
    sed -rn 's/python@(.+)/\1/p' |
    parallel --lb '/opt/homebrew/bin/python{} -m pip install --upgrade pip'

tmp_dir="$(mktemp -d)"
trap 'rm -rf "$tmp_dir"' EXIT
export tmp_dir

# Get packages installed by pip
brew list |
    sed -rn 's/python@(.+)/\1/p' |
    parallel --lb "/opt/homebrew/bin/pip{} list --format=freeze |
        grep -v \"^\-e\" |
        cut -d = -f 1 > \"$tmp_dir/{}-packages.txt\""

# Update packages installed by pip
brew list |
    sed -rn 's/python@(.+)/\1/p' |
    parallel -k --lb "/opt/homebrew/bin/pip{} install --upgrade -r \"$tmp_dir/{}-packages.txt\""
