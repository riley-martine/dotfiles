#!/usr/bin/env bash
set -euo pipefail
IFS=$'\n\t'

cat ~/.config/python/global-requirements.txt | xargs -n 1 uv tool install
