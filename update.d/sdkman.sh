#!/usr/bin/env bash

set -euo pipefail

# shellcheck source=../../../.sdkman/bin/sdkman-init.sh
if [ -f ~/.sdkman/bin/sdkman-init.sh ]; then
    set +u
    source ~/.sdkman/bin/sdkman-init.sh
    sdk update
    set -u
fi
