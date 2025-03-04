direnv hook fish | source
if status --is-login
and test -z "$DIRENV_FILE"
and test -f .envrc
  direnv reload
end
