#!/usr/bin/env bash

set -euo pipefail

pre-commit gc
for conf in ~/.config/pre-commit/*.yaml; do
    pre-commit autoupdate --config "$conf" --jobs 5
    pre-commit install-hooks --config "$conf"
done
