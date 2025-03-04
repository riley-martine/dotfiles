#!/usr/bin/env fish
# see here:
# https://github.com/jenv/jenv/issues/148#issuecomment-1416570999

# if ! type -fq pyenv
#     exit 0
# end

# if status --is-login
#     set -x PYTHON_CONFIGURE_OPTS "--enable-framework"
#     set -ga fish_function_path "$HOME/.local/share/pyenv_shim_shims"

#     # See ~/.config/fish/functions/pyenv.fish for rehashing.
#     # Rehashing is done manually to save cycles.
# end

# function __make_pyenv_completions
#     function __fish_pyenv_needs_command
#       set cmd (commandline -opc)
#       if [ (count $cmd) -eq 1 -a $cmd[1] = 'pyenv' ]
#         return 0
#       end
#       return 1
#     end

#     function __fish_pyenv_using_command
#       set cmd (commandline -opc)
#       if [ (count $cmd) -gt 1 ]
#         if [ $argv[1] = $cmd[2] ]
#           return 0
#         end
#       end
#       return 1
#     end

#     set -l commands (pyenv commands | string join ' ')

#     functions __fish_pyenv_needs_command
#     functions __fish_pyenv_using_command
#     echo 'complete -f -c pyenv -n \'__fish_pyenv_needs_command\' -a "'$commands'"'
#     for cmd in (string split ' ' -- "$commands")
#         set -l completions (string join ' ' -- (pyenv completions $cmd))
#         if ! test -z $completions
#             string join '' -- 'complete -f -c pyenv -n "__fish_pyenv_using_command '$cmd'" -a "' $completions '"'
#         end
#     end
# end
