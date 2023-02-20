function pyenv --wraps pyenv
    if [ $argv[1] = rehash ]
        command pyenv rehash

        fish -c "__make_pyenv_completions > ~/.config/fish/completions/pyenv.fish" &

        # set to value of $(pyenv root)/shims
        set -l pyenv_shims "$HOME/.pyenv/shims"
        set -l shim_shims "$HOME/.local/share/pyenv_shim_shims"
        if [ ! -d $shim_shims ] || [ (ls $pyenv_shims | wc -l) != (ls $shim_shims | wc -l) ]
            mkdir -p $shim_shims

            for file in $pyenv_shims/*
                set shim $(basename $file)
                echo "\
#!/usr/bin/env fish
function $shim
    # Erase second-layer shims from path
    set index (contains -i \"$shim_shims\" \$fish_function_path)
    and set -ge fish_function_path[\$index]

    # Start pyenv and set path to include first-layer shims
    pyenv init - --no-rehash | source
    set -gxp PATH \"$pyenv_shims\"

    # Call original function
    $shim \$argv
end\
" > $shim_shims/$shim.fish

            end
        end
    # Getting commands is slow! Calling any actual pyenv command is slow!
    # And it happens during generating completions
    # This block saves ~20ms on shell startup
    else
        command pyenv $argv
    end
end
