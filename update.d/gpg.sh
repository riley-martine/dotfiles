#!/usr/bin/env bash
set -euo pipefail

if [[ -n "${IS_WORK:-}" ]]; then
  echo "Skip GPG update due to firewall blocking hkps"
  exit 0
fi


gpg --refresh-keys
