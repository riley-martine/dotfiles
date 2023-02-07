# see problems with this approach here:
# https://github.com/jenv/jenv/issues/148#issuecomment-1416570999

if ! type -fq pyenv
    exit 0
end
if ! status --is-login
    exit 0
end

set -x PYTHON_CONFIGURE_OPTS "--enable-framework"

function pyenv --wraps=pyenv
    functions --erase pyenv
    functions --erase python
    functions --erase python3
    functions --erase pip
    functions --erase pip3

    pyenv init - | source
    set -gx PATH "$(pyenv root)/shims" $PATH
    pyenv $argv
end

function python --wraps=python
    functions --erase pyenv
    functions --erase python
    functions --erase python3
    functions --erase pip
    functions --erase pip3

    pyenv init - | source
    set -gx PATH "$(pyenv root)/shims" $PATH
    python $argv
end

function pip --wraps=pip
    functions --erase pyenv
    functions --erase python
    functions --erase python3
    functions --erase pip
    functions --erase pip3
    pyenv init - | source
    set -gx PATH "$(pyenv root)/shims" $PATH
    pip $argv
end

function python3 --wraps=python3
    functions --erase pyenv
    functions --erase python
    functions --erase python3
    functions --erase pip
    functions --erase pip3
    pyenv init - | source
    set -gx PATH "$(pyenv root)/shims" $PATH
    python3 $argv
end

function pip3 --wraps=pip3
    functions --erase pyenv
    functions --erase python
    functions --erase python3
    functions --erase pip
    functions --erase pip3
    pyenv init - | source
    set -gx PATH "$(pyenv root)/shims" $PATH
    pip3 $argv
end
