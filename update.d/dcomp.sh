#!/usr/bin/env bash

set -euo pipefail

wget "https://raw.githubusercontent.com/docker/cli/master/contrib/completion/fish/docker.fish" --output-document ~/.config/fish/completions/docker.fish
