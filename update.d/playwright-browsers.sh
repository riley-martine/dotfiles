#!/usr/bin/env bash
set -euo pipefail

# Browser builds are pinned to the playwright version, so this must run after
# js-global-deps.sh has upgraded playwright itself (it sorts earlier).
playwright install --no-progress
