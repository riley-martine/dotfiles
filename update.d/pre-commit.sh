#!/usr/bin/env bash

set -euo pipefail

# prek refuses to update any config unless you're currently in a repo
TMP_DIR="$(mktemp -d)"
trap 'rm -rf $TMP_DIR' EXIT
cd "$TMP_DIR"
git init

prek cache gc
for conf in ~/.config/pre-commit/*.yaml; do
    echo "Updating $conf"
    prek update --config "$conf"
    prek prepare-hooks --config "$conf"
done
