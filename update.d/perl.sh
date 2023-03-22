#!/usr/bin/env bash
set -euo pipefail

cpanm --self-upgrade || perlbrew install-cpanm --yes

cpan-outdated -p | cpanm
