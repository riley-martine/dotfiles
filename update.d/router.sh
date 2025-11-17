#!/usr/bin/env bash
set -euo pipefail

if [[ -n "${IS_WORK:-}" ]]; then
  echo "Skip router updates"
  exit 0
fi

# Update the update script
UPDATE_SCRIPT="$(command -v update-system)"
echo "put $UPDATE_SCRIPT /usr/local/bin" | sftp router

ssh -y router -C "setenv TERM xterm-256color; update-system; exit"
