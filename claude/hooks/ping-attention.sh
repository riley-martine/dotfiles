#!/bin/bash
# Audible + visual ping when Claude Code is blocked waiting on you.
#
# Bound to Notification (filtered by notification_type in settings.json) and
# TeammateIdle -- events that mean Claude cannot proceed without you.
#
# Deliberately NOT bound to Stop. Stop fires at every turn boundary, not at the
# end of the work: with a Monitor running or queued input pending, the loop
# continues straight through it, so a Stop-triggered ping rings mid-turn. The
# "turn finished and you walked away" case is covered by upstream's idle_prompt
# notification instead, which fires 60s after the last message -- gated on
# isLoading and on pending /loop wakeups, and on nothing else.
#
# Pings are suppressed while you're demonstrably watching this pane (see
# `watching`), and idle_prompt is suppressed while background work is still
# running (see `pending_background_work`), so a ping always means your
# attention is somewhere else and something is actually waiting on it.
set -u

IDLE_SECONDS=30

# How long a background task's output file may go unwritten before it stops
# counting as live. Agents append on every tool result, so a gap this long means
# the task has finished, wedged, or was orphaned by a killed session.
TASK_QUIET_SECONDS=300

# The hook payload. Notification carries notification_type and transcript_path;
# TeammateIdle carries neither, and falls through to a ping. Not read when stdin
# is a tty, so the script can still be run by hand to test the ping itself.
HOOK_INPUT=''
[ -t 0 ] || HOOK_INPUT=$(cat)

hook_field() {
  [ -n "$HOOK_INPUT" ] || return 0
  printf '%s' "$HOOK_INPUT" | jq -r "$1 // empty" 2>/dev/null
}

# BEL sets tmux's bell flag for the window, which iTerm2 turns into a tab
# highlight -- the pane that needs you is identifiable even with audio muted.
# Written to our own pane's tty, not stdout, which the hook runner captures.
bell() {
  local tty
  tty=$(tmux display-message -p -t "${TMUX_PANE:-}" '#{pane_tty}' 2>/dev/null)
  printf '\a' >"${tty:-/dev/tty}" 2>/dev/null || true
}

# The bell flag is per-window, so with several Claude panes in one window it
# can't say *which* one wants you. `window-style` can: set per-pane it tints
# only that pane's background, and unlike anything keyed to pane_active it
# stays put while you look around.
#
# pane-border-style is not an option here -- borders are drawn between panes,
# so `set -p` on it silently falls back to window scope and tints all of them.
#
# Cleared by the hooks installed below, since a ping means you're away and the
# mark has to survive until you actually arrive.
#
# tokyonight-day amber, chosen against the theme's own #e1e2e7 background: dE76
# ~30 so it reads at a glance, while every palette colour stays >=3:1 on it and
# the #3760bf foreground keeps 4.7:1 (AA). Amber rather than red/green because
# blue-vs-amber is the axis that survives colour-vision deficiency.
HIGHLIGHT='bg=#ffe3b3'

# Clearing needs two hooks, because "I arrived at this pane" has two distinct
# shapes and neither one covers the other:
#
#   after-select-pane  you moved to the pane from within tmux. Also fires when
#                      re-selecting the pane that is already active, which is
#                      what the default MouseDown1Pane binding (`select-pane
#                      -t =`) does -- so a click lands here too.
#   pane-focus-in      the pane gained focus without any tmux navigation, e.g.
#                      switching iTerm tabs or refocusing the window while
#                      already sitting on the right pane. Requires
#                      focus-events, which is on.
#
# Both run the same guarded clear, so whichever fires first wins and the second
# is a no-op.
CLEAR_MARK='if -F "#{@attn_marked}" "set -pu window-style ; set -pu @attn_marked"'

highlight_pane() {
  [ -n "${TMUX_PANE:-}" ] || return 0

  # Idempotent, and only ever touches panes this script marked: the hooks key
  # off @attn_marked rather than clearing window-style unconditionally, so a
  # pane-scoped window-style set for any other reason is left alone.
  tmux set -p -t "$TMUX_PANE" window-style "$HIGHLIGHT" 2>/dev/null || return 0
  tmux set -p -t "$TMUX_PANE" @attn_marked 1 2>/dev/null

  tmux set-hook -g after-select-pane "$CLEAR_MARK" 2>/dev/null
  tmux set-hook -g pane-focus-in "$CLEAR_MARK" 2>/dev/null
}

sound() { afplay "/System/Library/Sounds/$1.aiff" >/dev/null 2>&1 & }

# Nanoseconds since the last system-wide keyboard/mouse event. No entitlement or
# accessibility consent needed, unlike the osascript route.
hid_idle_seconds() {
  ioreg -c IOHIDSystem 2>/dev/null |
    awk -F' = ' '/HIDIdleTime/ {print int($2 / 1000000000); exit}'
}

# Count of background tasks this session launched that are still running.
#
# Upstream fires idle_prompt 60s after the last message
# (messageIdleNotifThresholdMs), gated on isLoading and on pending /loop
# wakeups but not on pending background work. So a `/panel` run pings once per
# reviewer that reports back, while the REPL reads "Waiting for 2 background
# agents to finish" or "1 shell still running" and nothing is blocked on you.
#
# The transcript is the only place that state is visible from outside the
# process. A launch lands as a tool_result naming the task and the file its
# output goes to -- "Async agent launched successfully" with an agentId and
# output_file for an agent, "Command running in background with ID" for a shell
# -- and each stop lands as a <task-notification> naming that same id.
#
# An id can also stay unmatched forever: a session killed mid-task leaves the
# launch in the transcript with no notification ever appended. So unmatched ids
# are confirmed live by their output file's mtime rather than trusted. That is
# also what keeps a long-lived `yarn start` in a background shell from
# suppressing every ping for the rest of the session -- once it stops logging it
# stops counting.
#
# The output file is only stat'd, never read: for an agent it is the subagent's
# full JSONL transcript.
#
# Monitors are not counted. They notify per event rather than once at the end,
# so a notification does not mean a monitor is finished, and they have no output
# file to fall back on.
pending_background_work() {
  local transcript now out mtime n=0
  transcript=$(hook_field .transcript_path)

  if [ -n "$transcript" ] && [ -r "$transcript" ]; then
    now=$(date +%s)
    # grep first: it cuts a multi-megabyte transcript down to the handful of
    # lines jq has to parse, which keeps this inside the hook's 5s timeout.
    while IFS= read -r out; do
      mtime=$(stat -f %m "$out" 2>/dev/null) || continue
      [ $((now - mtime)) -lt "$TASK_QUIET_SECONDS" ] && n=$((n + 1))
    done < <(
      grep -F \
        -e 'Async agent launched successfully' \
        -e 'Command running in background with ID' \
        -e '<task-notification>' \
        "$transcript" |
        jq -r '
          select(.type == "user")
          | .message.content
          | if type == "array" then .[] else {type: "text", text: .} end
          | if .type == "tool_result" then
              (if (.content | type) == "array"
               then ([.content[].text? // ""] | join(" "))
               else (.content // "") end)
            elif .type == "text" then .text
            else empty end
          | gsub("\n"; " ")
        ' 2>/dev/null |
        awk '
          # The value after the last ": " of the matched fragment, minus the
          # sentence-ending period the shell launch line puts after its path.
          function after_colon(re,   s) {
            if (!match($0, re)) return ""
            s = substr($0, RSTART, RLENGTH)
            sub(/^.*: /, "", s)
            sub(/\.$/, "", s)
            return s
          }
          function remember(id, path) {
            if (id != "" && path != "") launched[id] = path
          }
          /Async agent launched successfully/ {
            remember(after_colon("agentId: [0-9a-f]+"),
                     after_colon("output_file: [^ ]+"))
          }
          /Command running in background with ID/ {
            remember(after_colon("ID: [0-9a-z]+"),
                     after_colon("Output is being written to: [^ ]+"))
          }
          /<task-notification>/ {
            if (match($0, /<task-id>[^<]+<\/task-id>/))
              done[substr($0, RSTART + 9, RLENGTH - 19)] = 1
          }
          END { for (id in launched) if (!(id in done)) print launched[id] }
        '
    )
  fi

  # Always an integer, and zero on anything unresolvable -- a missing jq, an
  # unreadable transcript, a payload without one. A spurious ping costs less
  # than a missed one.
  printf '%s\n' "$n"
}

# True when all three hold: the terminal is frontmost, this pane is the focused
# one, and input landed recently. Any single failure means attention is
# elsewhere, so we ping. TMUX_PANE comes from the environment Claude inherited
# at launch -- it identifies *our* pane, not whichever pane is focused now.
watching() {
  [ "$(lsappinfo info -only name "$(lsappinfo front 2>/dev/null)" 2>/dev/null)" \
    = '"LSDisplayName"="iTerm2"' ] || return 1

  [ -n "${TMUX_PANE:-}" ] || return 1
  # A detached session can still report pane_active=1, hence session_attached.
  [ "$(tmux display-message -p -t "$TMUX_PANE" \
       '#{pane_active}#{session_attached}' 2>/dev/null)" = '11' ] || return 1

  local idle
  idle=$(hid_idle_seconds)
  [ -n "$idle" ] && [ "$idle" -lt "$IDLE_SECONDS" ]
}

# Only idle_prompt is gated on this. A permission prompt or an agent asking for
# input wants you regardless of what else is still running.
if [ "$(hook_field .notification_type)" = idle_prompt ] &&
   [ "$(pending_background_work)" -gt 0 ]; then
  exit 0
fi

if ! watching; then
  highlight_pane
  bell
  sound Funk
fi

exit 0
