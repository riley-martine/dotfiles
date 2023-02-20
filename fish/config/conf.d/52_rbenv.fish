# see problems with this approach here:
# https://github.com/jenv/jenv/issues/148#issuecomment-1416570999

if ! type -fq rbenv
    exit 0
end
if ! status --is-login
    exit 0
end

function rbenv --wraps=rbenv
    functions --erase rbenv
    functions --erase ruby
    functions --erase gem
    rbenv init - | source
    rbenv $argv
end

function ruby --wraps=ruby
    functions --erase rbenv
    functions --erase ruby
    functions --erase gem
    rbenv init - | source
    ruby $argv
end

function gem --wraps=gem
    functions --erase rbenv
    functions --erase ruby
    functions --erase gem
    rbenv init - | source
    gem $argv
end
