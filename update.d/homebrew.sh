#!/usr/bin/env bash
set -euo pipefail

brew update
brew upgrade
brew upgrade --cask --greedy
brew unlink openssh
brew cleanup
