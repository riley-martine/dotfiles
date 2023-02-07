# see problems with this approach here:
# https://github.com/jenv/jenv/issues/148#issuecomment-1416570999

if ! type -fq jenv
    exit 0
end
if ! status --is-login
    exit 0
end

set -a PATH "$HOME"/.jenv/bin

function jenv --wraps=jenv
    functions --erase jenv
    functions --erase java
    jenv init - | source
    jenv $argv
end

function java --wraps=java
    functions --erase java
    functions --erase jenv
    jenv init - | source
    java $argv
end
