# Dotfiles

Contains system and tool configuration. This README intentionally left bare,
for now.

See `diff.sh` for path conversion to system paths.

See `setup.sh` for an in-progress, very thorough, MacOS setup script.

See `bin/` for small useful programs I wrote.

See each tool directory for tool configuration.

## Shared agent instructions

`agents/` mirrors the public files in `~/.agents/`. The private
`agents-shared.extra.md` and generated `AGENTS.md` stay on each machine.
Create an empty `~/.agents/agents-shared.extra.md` if the machine has no extra
instructions, then run `make -C ~/.agents` to generate `AGENTS.md`.

With `vim-localvimrc`, saving either source or the Makefile rebuilds `AGENTS.md`,
including when Vim's working directory is elsewhere. Approve loading `.lvimrc`
and running it outside the sandbox when prompted; the existing
`g:localvimrc_persistent=2` setting remembers both approvals until `.lvimrc`
changes. The global sandbox setting remains enabled.

[tern]: https://stackoverflow.com/questions/41371789/figuring-out-javascript-libraries-for-vim-autocompletion-with-ternjs-in-tern-pr/41377689#41377689
