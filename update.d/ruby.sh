#!/usr/bin/env bash
set -euo pipefail

eval "$(rbenv init - bash)"
gem update --system && gem update
