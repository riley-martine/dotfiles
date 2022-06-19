if status --is-login
and not set -q TMUX
    # tmux has-session 2> /dev/null; and tmux attach; or tmux
    tmux
end

# for things not checked into git..
if test -e "$HOME/.extra.fish";
	source ~/.extra.fish
end

# Language Default
set -x LC_ALL en_US.UTF-8
set -x LC_CTYPE en_US.UTF-8

set -x EDITOR vim
set -x VISUAL $EDITOR

function fish_right_prompt_loading_indicator -a last_prompt
    echo -n "$last_prompt" | sed -r 's/\x1B\[[0-9;]*[JKmsu]//g' | read -zl uncolored_last_prompt
    echo -n (set_color brblack)"$uncolored_last_prompt"(set_color normal)
end


# Configuration for tools
# LESS with colors
# from http://blog.0x1fff.com/2009/11/linux-tip-color-enabled-pager-less.html
set -x LESS "-RSM~gIsw"
set -x BAT_THEME 'Nord'
set -x FZF_DEFAULT_COMMAND "fd --type f --hidden -E '.git/'"
set -x FZF_DEFAULT_OPTS "--bind='ctrl-o:execute(vim {})+abort'"
set -x GPG_TTY (tty)


# Functions
# https://github.com/ithinkihaveacat/dotfiles/blob/master/fish/functions/starship-install-latest.fish
function starship-install-latest -d "Install latest version of starship"
  curl -fsSL https://starship.rs/install.sh | sh /dev/stdin -y
end


# Alii and functions that are basically alii
function mkcd --wraps mkdir -d "Create a directory and cd into it"
  command mkdir -p $argv
  if test $status = 0
    switch $argv[(count $argv)]
      case '-*'
      case '*'
        cd $argv[(count $argv)]
        return
    end
  end
end

# I'm not sold on exa but I'll try it
if type -q exa
    alias l exa
    alias ll 'exa --long --all --group --header --git'
    alias lt 'exa --long --all --group --header --tree --level'
end


if type -q bat
    alias cat 'bat --paging=never'
end

alias rg 'rg --ignore-case'

alias agar 'sudo apt autoremove'
alias agi 'sudo apt install'
alias agr 'sudo apt remove'
alias agu 'sudo apt update'
alias agud 'sudo apt update && sudo apt dist-upgrade'

alias cl 'clear'

alias g 'git'
alias ga 'git add'
alias gcmsg 'git commit -m'
alias gp 'git push'
alias gpf 'git push --force-with-lease'
alias gco 'git checkout'
alias gst 'git status'
alias gl 'git pull'
alias gd 'git diff'
alias gc 'git commit'

alias vimrc 'vim ~/.vim/vimrc'

alias lsa 'ls -lah'

alias preview="fzf --preview 'bat --color \"always\" {}'"

alias rm 'rm -i'
alias cp 'cp -i'
alias mv 'mv -i'

# Appearance
set fish_greeting
fish_config theme choose Nord
starship init fish | source
