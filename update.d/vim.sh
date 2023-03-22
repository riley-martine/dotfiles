#!/usr/bin/env bash
set -euo pipefail

vim +PlugUpgrade +PlugInstall +PlugUpdate +qall
