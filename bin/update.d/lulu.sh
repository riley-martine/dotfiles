#!/usr/bin/env bash

set -euo pipefail

# Update LuLu blocklist from little snitch blocklist and suggested.
# https://github.com/fabston/little-snitch-blocklist
# https://ceadd.ca/blockyouxlist.txt

mkdir -p ~/.local/share/lulu/files

cd ~/.local/share/lulu

before="$(wc -l files/blocklist-merged.txt 2> /dev/null || echo 0)"

curl --silent https://raw.githubusercontent.com/fabston/little-snitch-blocklist/main/blocklist.txt |
    perl -pe 'BEGIN{undef $/;} s/",\s+]/"\n    ]/gm' |
    jq -r '.["denied-remote-domains"][]' > files/littlesnitch.txt

curl --silent https://ceadd.ca/blockyouxlist.txt |
    gsed '/^#/d' > files/blockyoulist.txt

cat files/littlesnitch.txt files/blockyoulist.txt |
    sort | uniq > files/blocklist-merged.txt

date > files/updated_at

after="$(wc -l files/blocklist-merged.txt)"
echo "Updated LuLu blocklist.
    ${before} ->
    ${after}"
