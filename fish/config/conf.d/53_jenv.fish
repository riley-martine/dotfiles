# see here:
# https://github.com/jenv/jenv/issues/148#issuecomment-1416570999

if ! type --no-functions -q jenv
    exit 0
end

if status --is-login
    set -ga fish_function_path "$HOME/.local/share/jenv_shim_shims"

    # See ~/.config/fish/functions/jenv.fish for rehashing.
    # Rehashing is done manually to save cycles.
    begin; fish -c "jenv rehash" &; end
end


# Getting completions out of jenv init is slow. This gets called by rehash.
# Rehash should be called manually.
function __make_jenv_completions
    function __fish_jenv_needs_command
      set cmd (commandline -opc)
      if [ (count $cmd) -eq 1 -a $cmd[1] = 'jenv' ]
        return 0
      end
      return 1
    end

    function __fish_jenv_using_command
      set cmd (commandline -opc)
      if [ (count $cmd) -gt 1 ]
        if [ $argv[1] = $cmd[2] ]
          return 0
        end
      end
      return 1
    end

    set -l commands (jenv commands | string join ' ')

    functions __fish_jenv_needs_command
    functions __fish_jenv_using_command
    echo 'complete -f -c jenv -n \'__fish_jenv_needs_command\' -a "'$commands'"'
    echo 'complete -f -c jenv -n \'__fish_jenv_using_command help\' -a "'$commands'"'
    for cmd in (string split ' ' -- "$commands")
        # these two are broken
        if not contains -- $cmd disable-plugin doctor
            set -l completions (string join ' ' -- (jenv completions $cmd))
            if ! test -z $completions
                string join '' -- 'complete -f -c jenv -n "__fish_jenv_using_command '$cmd'" -a "' $completions '"'
            end
        end
    end
end
