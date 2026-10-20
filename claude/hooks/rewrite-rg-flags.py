#!/usr/bin/env python3
"""PreToolUse hook: strip a bundled -r from rg invocations.

In ripgrep -r is --replace, not --recursive, and it takes a value. So `rg -rn
foo .` replaces every match with the literal text "n" -- output that looks like
real results and is silently wrong. A bundled -r is never what anyone meant:
whichever letters follow it in the cluster get eaten as the replacement string.

Only clusters are rewritten (-rn -> -n, -nri -> -ni). A standalone `-r` is left
alone, since that is how --replace is actually spelled.
"""
import json
import re
import sys

# `rg` as a command word, bare or path-qualified, but not the tail of a longer
# word like `myrg`.
RG = re.compile(r"(?<![\w-])rg(?=\s)")
# Shell tokens that end rg's argument list.
BREAK = re.compile(r"[|;&\n)]|\$\(")
# A short-flag cluster containing r alongside at least one other letter.
CLUSTER = re.compile(r"(?<!\S)-(?=[A-Za-z]*r)(?=[A-Za-z]{2,}(?!\S))([A-Za-z]+)(?!\S)")


def fix(command):
    out = []
    pos = 0
    for m in RG.finditer(command):
        end = BREAK.search(command, m.end())
        end = end.start() if end else len(command)
        out.append(command[pos:m.end()])
        out.append(CLUSTER.sub(lambda c: "-" + c.group(1).replace("r", ""),
                               command[m.end():end]))
        pos = end
    out.append(command[pos:])
    return "".join(out)


def main():
    try:
        payload = json.load(sys.stdin)
    except (json.JSONDecodeError, UnicodeDecodeError):
        return
    tool_input = payload.get("tool_input") or {}
    command = tool_input.get("command")
    if not isinstance(command, str) or "rg" not in command:
        return

    fixed = fix(command)
    if fixed == command:
        return

    json.dump({
        "systemMessage": f"rewrote bundled `rg -r` (it is --replace): {fixed}",
        "hookSpecificOutput": {
            "hookEventName": "PreToolUse",
            "updatedInput": {**tool_input, "command": fixed},
        },
    }, sys.stdout)


main()
