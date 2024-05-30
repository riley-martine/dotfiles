#!/usr/bin/env bash
set -euo pipefail
IFS=$'\n\t'

# This wraps brew install calls in a bundle command, so we don't get error messages
# about the program already being installed, and don't have to do extra typing to write
# the brewfiles ourselves.
# https://github.com/Homebrew/brew/issues/2491
brew-get() {
    local PREFIX="brew"
    local ARGS=""
    for arg in "$@"; do
        case "$arg" in
            --cask)
                PREFIX="cask"
                shift
                ;;
            --HEAD)
                # https://github.com/Homebrew/homebrew-bundle/issues/1042
                ARGS=', args: ["head"]'
                shift
                ;;
            *) ;;

        esac
    done

    for arg in "$@"; do echo "${PREFIX} \"${arg}\"${ARGS}"; done | brew bundle --file=-
}
