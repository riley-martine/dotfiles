#!/bin/bash
set -euo pipefail
IFS=$'\n\t'

SCRIPT_PATH="$(readlink -f "$0")"
SCRIPT_DIR=$( dirname "$SCRIPT_PATH" )
export PATH="$SCRIPT_DIR/../bin:$PATH"
source "$SCRIPT_DIR/utils.sh"

# Could've sworn I heard about this in this talk, but can't find it:
# https://xeiaso.net/talks/rustconf-2022-sheer-terror-pam
echo "Enabling touch-id for sudo..."

if ! grep -qe "pam_tid.so" /etc/pam.d/sudo; then
    sudo sed -i '' '2i\
auth       sufficient     pam_tid.so
' /etc/pam.d/sudo
fi

# https://birkhoff.me/make-sudo-authenticate-with-touch-id-in-a-tmux/
brew-get pam-reattach # This is so we can use it in tmux sessions
if ! grep -qe "pam_reattach.so" /etc/pam.d/sudo; then
    sudo sed -i '' '2i\
auth       optional       /opt/homebrew/lib/pam/pam_reattach.so
' /etc/pam.d/sudo
fi

echo "Done enabling touch-id for sudo"
