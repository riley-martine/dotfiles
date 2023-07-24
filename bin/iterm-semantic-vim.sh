#!/usr/bin/env bash

set -euo pipefail

# This is a script for iTerm2's semantic history feature.
# Right now, it sits at the nexus of that, OSC 8 hyperlinks,
# tmux, and git-delta. It lets you command-click file line
# numbers and open them in vim in another pane.
#
# When running "git diff", command click on the line number or file. If
# vim is open, the file will be opened to that line number. If not, vim will be
# opened to the right location. This works no matter which pane is focused, as
# long as either there is a vim or empty pane.
#
# This is a pile of horrible hacks.

# To use it, set iTerm2's "Semantic History" to Coprocess:
#   ~/bin/iterm-semantic-vim.sh "\1" "\2"
# Note that this must not be "Command".
#
# And in ~/.gitconfig:
#   [delta]
#       hyperlinks = true
#       hyperlinks-file-link-format = "file://{path}#{line}"
#
# This is important because iTerm2 will only open OSC 8 hyperlinks with a
# custom command (coprocess) if there is a line number. Otherwise, it defers
# to the system, which'll open it in VSCode or something.
#
# Tmux needs v3.4 (currently unreleased, so brew install --HEAD)
#
# In ~/.tmux.conf (replace fish with your shell):
#   bind-key V run-shell 'tmux select-pane -t $(tmux list-panes -F "##{pane_id}" -f "##{==:##{pane_current_command},vim}" | head -n1) || tmux select-pane -t $(tmux list-panes -F "##{pane_id}" -f "##{==:##{pane_current_command},fish}" | head -n1)'


FILE="$1"
LINE="$2"

set +e
pgrep -fx "git diff" > /dev/null
DIFF_RUNNING=$?
set -e

if [ $DIFF_RUNNING -eq 0 ]; then
    # Switch to Vim, or fish if can't find vim
    # This could probably be inlined.

    # We're spawning this shell, printing a literal <C-b> to activate tmux,
    # running another shell (bash) from inside tmux, running tmux in that to
    # control the calling tmux, and running a different tmux in a bash
    # sub-shell. I think I should be put down for this.

    printf $'\cb'
    printf 'V'

    printf '%b' '\e' # exit vim insert mode, if in
    if [ -z "$LINE" ]; then
        # Comment characters (") prevent rest from running in vim
        # This line is interpreted both by fish and vim as "open the file" >:)
        # This should be a quine and use the exact delete command.
        echo ":e $FILE \"\"; echo 'all' | history delete '^:e' >/dev/null; clear; vim $FILE"
    else
        echo ":e +$LINE $FILE \"\"; echo 'all' | history delete '^:e' >/dev/null; clear; vim +$LINE $FILE"
    fi
else
    if [ -z "$LINE" ]; then
    printf '%b' '\e' # exit vim insert mode, if in
        # echo "vim $FILE"
        echo ":e $FILE \"\"; echo 'all' | history delete '^:e' >/dev/null; clear; vim $FILE"
    else
        echo "vim +$LINE $FILE"
    fi
fi

# https://303net.net/posts/2020-07-28-iterm2-tmux-vim.html
# ~/posts/2020-07-28-iterm2-tmux-vim.html
# ~/bin/toc.pl
# /posts/2020-07-28-iterm2-tmux-vim.html
# posts/2020-07-28-iterm2-tmux-vim.html
