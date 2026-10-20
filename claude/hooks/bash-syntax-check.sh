#!/opt/homebrew/bin/bash
# PostToolUse hook: parse-check edited shell scripts.
#
# /bin/bash on macOS is 3.2.57 and rejects modern syntax these scripts use, so
# this deliberately runs homebrew bash. Exits 2 on a parse error, which feeds
# stderr back to the model.
set -uo pipefail

BASH=/opt/homebrew/bin/bash
[[ -x $BASH ]] || exit 0

f=$(jq -r '.tool_response.filePath // .tool_input.file_path // empty')
[[ -n $f && $f == *.sh && -f $f ]] || exit 0

# Only bash/sh. A .sh with a python or fish shebang is not ours to parse.
read -r shebang < "$f" || exit 0
case $shebang in
  '#!'*bash* | '#!'*/sh | '#!'*'env sh') ;;
  '#!'*) exit 0 ;;
esac

err=$("$BASH" -n "$f" 2>&1) && exit 0

printf 'bash -n failed on %s:\n%s\n' "$f" "$err" >&2
exit 2
