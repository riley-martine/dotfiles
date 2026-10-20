# Opus 5 gets a short system prompt that drops the anti-verbosity rules Sonnet's
# keeps, including the one-line-max comment rule. 0 forces the long preset.
# Verified on claude-code 2.1.224: unset, `claude -p` reports no docstring or
# unsolicited-markdown rule; set to 0, it quotes both.
set -x CLAUDE_CODE_SIMPLE_SYSTEM_PROMPT 0
