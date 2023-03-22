#!/usr/bin/env bash
set -euo pipefail

pyenv install --skip-existing \
    "$(pyenv install --list | sed 's/ //g' | ggrep -P '^[\d\.]+$' | tail -n 1)"
pyenv global "$(pyenv latest 3)"

pyenv update

pyenv versions --bare |
    gxargs -d $'\n' bash -c 'eval "$(pyenv init -)";
    for arg; do
        pyenv shell $arg
        python --version
        python -m pip install --upgrade pip
        pip list --format=freeze |
            grep -v "^\-e" |
            cut -d = -f 1 |
            xargs -n1 pip install -U
    done' _

pip install -r ~/.config/python/global-requirements.txt
