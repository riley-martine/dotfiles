#!/usr/bin/env bash
set -euo pipefail

cpan-outdated -p | cpanm
