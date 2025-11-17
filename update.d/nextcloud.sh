#!/usr/bin/env bash
set -euo pipefail

if [[ -n "${IS_WORK:-}" ]]; then
  echo "Skip nextcloud updates"
  exit 0
fi

ssh nextcloud -C "export TERM=\"$TERM\"; update-system; exit"
