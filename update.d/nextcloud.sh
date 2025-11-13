#!/usr/bin/env bash
set -euo pipefail

ssh nextcloud -C "export TERM=\"$TERM\"; update-system; exit"
