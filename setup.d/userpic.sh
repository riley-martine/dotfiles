#!/usr/bin/env bash
set -euo pipefail
IFS=$'\n\t'

echo "Setting user picture..."
# From: https://maybelsart.tumblr.com/post/729375923885965312/be-not-afraid
USER_PIC="flow.jpg"
if [ -f "$USER_PIC" ]; then
    sudo cp "$USER_PIC" "/Library/User Pictures/"
    if pic="$(dscl . -read "/Users/$USER" Picture | tail -1 | sed 's/^ //')"; then
        sudo dscl . -change "/Users/$USER" Picture "$pic" "/Library/User Pictures/$USER_PIC"
    else
        sudo dscl . -append "/Users/$USER" Picture "$pic" "/Library/User Pictures/$USER_PIC"
    fi

    dscl . delete /Users/"$USER" JPEGPhoto

    # https://gist.github.com/palmerc/5e8dfb37ed46b01c9a6f56ecd58727a7
    declare -x USERPIC="/Library/User Pictures/$USER_PIC"

    declare -r MAPPINGS='0x0A 0x5C 0x3A 0x2C'
    declare -r ATTRS='dsRecTypeStandard:Users 2 dsAttrTypeStandard:RecordName externalbinary:dsAttrTypeStandard:JPEGPhoto'

    PICIMPORT="$(mktemp "/tmp/${USER}_dsimport.XXXXXX")"
    readonly PICIMPORT

    printf "%s %s \n%s:%s" "${MAPPINGS}" "${ATTRS}" "${USER}" "${USERPIC}" >"${PICIMPORT}"
    dsimport "${PICIMPORT}" /Local/Default M &&
        echo "Successfully imported ${USERPIC} for ${USER}."

    rm "${PICIMPORT}"
    echo "Set user picture."
else
    echo "Unable to locate user picture" >&2
fi
