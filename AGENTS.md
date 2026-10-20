# AGENTS.md

Guidance for AI agents working in this repository.

## What this repo is

A git-versioned **mirror** of system and tool configuration. The files here are
copies, not symlinks: nothing on this machine reads them. `~/.vim/vimrc` is what
vim loads; `vim/vimrc` here is a snapshot of it that other machines get.

`diff.sh` holds the mapping table from repo path to system path, and is the
authoritative list of which files are mirrored.

## Never edit mirrored files directly

Edit the live file at its system path. Do not touch its counterpart here.

**Why:** the two sides drift on purpose. A change made on this machine may be
machine-specific, half-finished, or need fixing up before other machines should
receive it. Importing happens later, deliberately, one file at a time — the repo
is the thing that propagates, so nothing lands in it unreviewed.

**How to apply:** look the file up in `diff.sh`'s `dotfiles` table and edit the
`$HOME` side. Then say which live file changed, and stop. Do not sync it here,
and do not run the `cp` commands `diff.sh` suggests.

Files not in that table — `README.md`, `setup.sh`, `diff.sh`, `setup.d/`, this
file — live here canonically. Edit those in place as normal.

## Importing changes

Periodically, run `./diff.sh` and walk the divergences by hand, importing or
discarding each. That pass is a human decision; an agent should only run
`./diff.sh` to *report* what differs.

`~/.claude/settings.json` is deliberately not in the table, because it mixes
global with machine-specific settings and can't be compared whole.
`claude/settings-check.sh` handles it.

## Two CLAUDE.md files

`claude/CLAUDE.md` is the mirror of `~/.claude/CLAUDE.md`, the user's global
instructions for every project — mirrored, so the rule above applies. The
`CLAUDE.md` at this repo's root is repo-scoped and imports this file.
