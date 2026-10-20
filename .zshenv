[[ -f "$HOME/.cargo/env" ]] && . "$HOME/.cargo/env"

# uv
export PATH="$HOME/.local/bin:$PATH"

# direnv's zsh hook returns early in non-interactive shells, which Claude Code uses.
if command -v direnv >/dev/null && [[ -n "$CLAUDECODE" ]]; then
  _claude_direnv() { eval "$(DIRENV_LOG_FORMAT= direnv export zsh)"; }
  chpwd_functions+=(_claude_direnv)
  _claude_direnv
fi
