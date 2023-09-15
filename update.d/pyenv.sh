#!/usr/bin/env bash
set -euo pipefail

# TODO uninstall old versions of python
# and move over packages?

latest_python="$(pyenv install --list | sed 's/ //g' | ggrep -P '^[\d\.]+$' | tail -n 1)"
pyenv install --skip-existing "$latest_python"

latest="$(pyenv latest 3)"
pyenv global "$latest"

pyenv update

tmp_dir="$(mktemp -d)"
trap 'rm -rf "$tmp_dir"' EXIT
export tmp_dir

update_python () {
    set -euo pipefail
    version="$1"

    export PYENV_ROOT="$HOME/.pyenv"
    command -v pyenv >/dev/null || export PATH="$PYENV_ROOT/bin:$PATH"
    init_pyenv="$(pyenv init -)"
    eval "$init_pyenv"

    pyenv shell "$version"
    python --version
    python -m pip install --quiet --upgrade pip
    pip list --format=freeze |
        grep -v "^\-e" |
        cut -d = -f 1 > "$tmp_dir/$version-packages.txt"

    python -m pip install --quiet --upgrade -r "$tmp_dir/$version-packages.txt"
}
export -f update_python

pyenv versions --bare | parallel --lb -k update_python

pip install -r ~/.config/python/global-requirements.txt
