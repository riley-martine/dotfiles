# starship init fish | source
# must.. go... faster...
if status --is-interactive
    source (/opt/homebrew/bin/starship init fish --print-full-init | psub)
end
