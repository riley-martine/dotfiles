#!/usr/bin/env bash
set -euo pipefail

ssh nextcloud -t 'update-system; exit'
