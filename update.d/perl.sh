#!/usr/bin/env bash
set -euo pipefail

cpanm --self-upgrade

cpan-outdated -p | cpanm
