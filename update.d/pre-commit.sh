#!/usr/bin/env bash

set -euo pipefail

# pre-commit refuses to update any config unless you're currently in a repo
TMP_DIR="$(mktemp -d)"
trap 'rm -rf $TMP_DIR' EXIT
cd "$TMP_DIR"
git init

pre-commit gc
for conf in ~/.config/pre-commit/*.yaml; do
    pre-commit autoupdate --config "$conf" --jobs 5
    pre-commit install-hooks --config "$conf"
done
