#!/usr/bin/env bash
set -euo pipefail

if [[ -n "${IS_WORK:-}" ]]; then
  echo "Skip softwareupdate"
  exit 0
fi

softwareupdate -i -a
