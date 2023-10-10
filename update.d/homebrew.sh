#!/usr/bin/env bash
set -euo pipefail

trap 'brew unlink openssh' EXIT
brew update
brew upgrade
brew upgrade --cask --greedy
brew cleanup
