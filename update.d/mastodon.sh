#!/usr/bin/env bash
set -euxo pipefail

if [[ -n "${IS_WORK:-}" ]]; then
  echo "Skip mastodon archiving"
  exit 0
fi

mkdir -p ~/Nextcloud/Mastodon/
cd ~/Nextcloud/Mastodon/

ACCOUNT="$(fish -l -c "echo \$MASTODON_PROFILE")"
readonly ACCOUNT
if [ -z "$ACCOUNT" ]; then
    echo "No account found, is \$MASTODON_PROFILE set?" >&2
    exit 1
fi

if ! command -v mastodon-archive; then
    pipx install mastodon-archive
fi

mastodon-archive archive --with-followers --with-following "$ACCOUNT"

# mastodon-archive media --collection favourites "$ACCOUNT"
# mastodon-archive media --collection bookmarks "$ACCOUNT"

mastodon-archive text --collection statuses "$ACCOUNT" > statuses.txt
mastodon-archive text --collection favourites "$ACCOUNT" > favourites.txt
mastodon-archive text --collection bookmarks "$ACCOUNT" > bookmarks.txt

mastodon-archive html --collection statuses "$ACCOUNT"
mastodon-archive html --collection favourites "$ACCOUNT"
mastodon-archive html --collection bookmarks "$ACCOUNT"
