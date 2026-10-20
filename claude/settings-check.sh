#!/usr/bin/env bash
# Compare ~/.claude/settings.json against the tracked subset of it.
#
# settings.json can't be copied wholesale like the other dotfiles: it mixes
# settings that belong on every machine (hooks, theme, plugins) with ones that
# are specific to this one (an employer's gateway, a secret token). So the repo
# tracks a *subset* -- claude/settings.tracked.json -- and this script asks two
# questions about the live file:
#
#   1. Is the live file a superset of the tracked subset, with matching values?
#      A tracked setting that drifted or vanished locally is a real difference.
#
#   2. Is every untracked leaf accounted for? Anything present locally that is
#      neither tracked nor listed in settings.untracked.json is reported as
#      UNDECIDED -- it might be a new setting that ought to be tracked, or local
#      noise to add to the ignore list. Silence would let it be neither.
#
# settings.untracked.json is gitignored, since it names machine-specific keys.
# Its shape is {"_reasons": {"dotted.path": "why it isn't tracked"}}; a path
# covers its whole subtree. Without the file, every untracked leaf is UNDECIDED.
#
# Only leaf paths are compared, so `hooks.PostToolUse[0].hooks[0].timeout` is
# checked independently of its siblings. Called without arguments.
#
# Exit 0 when clean, 1 when anything is reported.
set -euo pipefail

here=$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd)
live=${CLAUDE_SETTINGS:-$HOME/.claude/settings.json}

if [ ! -f "$live" ]; then
    echo "no settings file at $live" >&2
    exit 1
fi

python3 - "$live" "$here/settings.tracked.json" "$here/settings.untracked.json" <<'PY'
import json, sys

live_path, tracked_path, untracked_path = sys.argv[1:4]


def load(p):
    with open(p) as f:
        return json.load(f)


def leaves(obj, prefix=""):
    """Flatten to {dotted.path: value}. Lists are indexed, so list order and
    length are both significant -- reordering hooks is a real difference."""
    if isinstance(obj, dict):
        out = {}
        for k, v in obj.items():
            out.update(leaves(v, f"{prefix}.{k}" if prefix else str(k)))
        return out
    if isinstance(obj, list):
        if not obj:
            return {prefix: []}
        out = {}
        for i, v in enumerate(obj):
            out.update(leaves(v, f"{prefix}[{i}]"))
        return out
    return {prefix: obj}


live = leaves(load(live_path))
tracked = leaves(load(tracked_path))

try:
    ignored = set(load(untracked_path)["_reasons"])
except FileNotFoundError:
    ignored = set()

missing, drifted, undecided = [], [], []

for path, want in tracked.items():
    if path not in live:
        missing.append((path, want))
    elif live[path] != want:
        drifted.append((path, want, live[path]))

for path in live:
    if path in tracked:
        continue
    # An ignore entry covers the subtree beneath it, so listing
    # `extraKnownMarketplaces.foo` need not enumerate every leaf under it.
    if any(path == ig or path.startswith(ig + ".") or path.startswith(ig + "[")
           for ig in ignored):
        continue
    undecided.append(path)


def show(v):
    return json.dumps(v)


if missing:
    print("MISSING locally -- tracked, but not in your settings.json:")
    for path, want in missing:
        print(f"  {path} = {show(want)}")
    print()

if drifted:
    print("DRIFTED -- tracked value differs from local:")
    for path, want, got in drifted:
        print(f"  {path}")
        print(f"    tracked: {show(want)}")
        print(f"    local:   {show(got)}")
    print()

if undecided:
    print("UNDECIDED -- present locally, neither tracked nor ignored.")
    print("Decide each one: add it to settings.tracked.json, or add it to")
    print("settings.untracked.json's _reasons with a note saying why not.")
    for path in undecided:
        print(f"  {path} = {show(live[path])}")
    print()

if not (missing or drifted or undecided):
    print(f"settings.json: {len(tracked)} tracked leaves match, "
          f"{len(live) - len(tracked)} accounted for as untracked.")
    sys.exit(0)

sys.exit(1)
PY
