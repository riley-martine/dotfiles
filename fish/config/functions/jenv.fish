function jenv --wraps jenv
    if [ (count $argv) -gt 0 ] && [ $argv[1] = rehash ]
        command jenv rehash

        fish -c "__make_jenv_completions > ~/.config/fish/completions/jenv.fish" &

        # set to value of $(jenv root)/shims
        set -l jenv_shims "$HOME/.jenv/shims"
        set -l shim_shims "$HOME/.local/share/jenv_shim_shims"
        if [ ! -d $shim_shims ] || [ (ls $jenv_shims | wc -l) != (ls $shim_shims | wc -l) ]
            mkdir -p $shim_shims

            for file in $jenv_shims/*
                set shim $(basename $file)
                echo "\
#!/usr/bin/env fish
function $shim
    # Erase second-layer shims from path
    set index (contains -i \"$shim_shims\" \$fish_function_path)
    and set -ge fish_function_path[\$index]

    # Start jenv and set path to include first-layer shims
    jenv init - --no-rehash | source
    set -gxp PATH \"$jenv_shims\"

    # Call original function
    $shim \$argv
end\
" > $shim_shims/$shim.fish

            end
        end
    else if [ (count $argv) -gt 0 ] && [ $argv[1] = add ]
        command jenv $argv
        and jenv rehash
    else
        command jenv $argv
    end
end
