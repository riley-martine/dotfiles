# Path to your oh-my-zsh installation.
export ZSH=$HOME/.oh-my-zsh

ZSH_THEME="agnoster"

# _ and - will be interchangeable.
HYPHEN_INSENSITIVE="true"

# Enable command auto-correction.
ENABLE_CORRECTION="true"

# Display red dots whilst waiting for completion.
COMPLETION_WAITING_DOTS="true"


ZSH_TMUX_AUTOSTART="false"
ZSH_TMUX_AUTOCONNECT="false"

# Example format: plugins=(rails git textmate ruby lighthouse)
plugins=(tmux dircycle gitfast git-extras web-search wd alias-history zsh-autosuggestions zsh-completions git github sudo cp alias-tips command-not-found pip python common-aliases zsh-syntax-highlighting)

source "$ZSH"/oh-my-zsh.sh

export LANG=en_US.UTF-8
export TERM="xterm-256color"

export VISUAL=vim
export EDITOR="$VISUAL"

# Aliases to specify version/flags
alias python='python3'
alias pip='pip3'
alias virtualenv='virtualenv --python=/usr/bin/python3'
alias grep='grep --color=always'
alias less='less -R'

# Aliases to rename commands
alias cl='clear'
alias ..='cd ..'
alias ,,='cd ..'
alias xt='xfce4-terminal'
alias please='fuck'
alias :partyparrot:='curl parrot.live'

alias male='make'
alias :q='exit'
alias list='ls'

alias caps='xdotool key Caps_Lock'
alias CAPS='xdotool key Caps_Lock' # for when caps lock is on

alias weather='curl wttr.in/durham'
alias deexif='exiftool -all= *.jpg *.jpeg *.png'

alias con='windscribe connect'
alias dis='windscribe disconnect'

# Aliases that do something complicated
alias nicechromium='ps -C chromium-browser -o "pid=" | while read in; do renice -n 10 -p "$in"; done'
alias coinflip='python -c "import random; print([\"Heads\",\"Tails\"][random.randint(0,1)]);"'
alias netflix='google-chrome --app=https://www.netflix.com/browse --kiosk'
alias spotify='google-chrome --app=https://open.spotify.com/browse --kiosk'
alias work='encfs "$HOME/.encrypted" "$HOME/work_files"; cd "$HOME/work_files" && unset HISTFILE'
alias unwork='cd && fusermount -u "$HOME/work_files" && HISTFILE="$HOME/.zsh_history"'

# Pystiler aliases
alias l='pyst move left'
alias r='pyst move right' # override r builtin
alias tl='pyst move top_left'
alias tr='pyst move top_right' # override tr builtin
alias bl='pyst move bottom_left'
alias br='pyst move bottom_right'
alias m='pyst move maximize'
alias t='pyst move top'
alias b='pyst move bottom'
alias ws='pyst workspace'
function wso {
	pyst workspace "$1"
	exit
}

# Pyfortune functions
FORTUNES_DIR="$HOME/Projects/pyfortune"
FORTUNES="$FORTUNES_DIR/myfortunes.txt"
function addfortune { echo "%\\n$1" >> "$FORTUNES"; }
function grepfortunes { grep "$1" "$FORTUNES"; }
function catfortunes { cat "$FORTUNES"; }
function pushfortunes {
    cd "$FORTUNES_DIR" || exit
    git add myfortunes.txt
    git commit -m "Add fortunes"
    git push
    cd - || exit
}

# Create template C directory
function ds {
    mkdir "$1" && cd "$1" || exit
    sed "s/NAME/$1/g" "$HOME/Templates/MakefileCustom" > ./Makefile
    cp "$HOME/Templates/template.c" "./$1.c"
    pwd && ls
}

function calibreupdate {
    sudo -v && wget -nv -O- https://download.calibre-ebook.com/linux-installer.py | sudo python -c "import sys; main=lambda:sys.stderr.write('Download failed\\n'); exec(sys.stdin.read()); main()"
}

function foldersize {
    if [ ! -z "$1" ]
    then
        du -sb "$1/*" | sort -n -r | numfmt --to=iec
    else
        du -sb -- * | sort -n -r | numfmt --to=iec
    fi
}

function extract {
  for name in "$@"; do
    if [ -f "$name" ] ; then
      case "$name" in
        *.tar.bz2)   tar xvjf "$name"    ;;
        *.tar.xz)    tar xf "$name"      ;;
        *.tar.gz)    tar xvzf "$name"    ;;
        *.bz2)       bunzip2 "$name"     ;;
        *.rar)       unrar x "$name"     ;;
        *.gz)        gunzip "$name"      ;;
        *.tar)       tar xvf "$name"     ;;
        *.tbz2)      tar xvjf "$name"    ;;
        *.tgz)       tar xvzf "$name"    ;;
        *.zip)       unzip "$name"       ;;
        *.Z)         uncompress "$name"  ;;
        *.7z)        7z x "$name"        ;;
        *)           echo "Don't know how to extract '$name'..." ;;
      esac
      echo "'$name' was extracted."
    else
      echo "'$name' is not a valid file!"
    fi
  done
}

function mp3 { youtube-dl --audio-format mp3 -x "$1"; }
function loss { echo "l  |  ll\\n--------\\n11 |  l_"; }
function mkcd { mkdir "$1" && cd "$1" || exit; }
function gorep { find . -type f -name "*.go" -print0 | xargs -0 grep "$1"; }
function mdr { pandoc "$1" | lynx -stdin; }
function pprint_json { sed "s/'/\"/g" | python -m json.tool | pygmentize -l javascript; }

export GOPATH="$HOME/gopath:$HOME/gocode/"

PATH="$PATH:/usr/local/go/bin"
PATH="$GOPATH:$GOPATH/bin:$PATH:/home/riley/Projects/tools/biotext"
PATH="/home/$USER/bin:/usr/bin:/bin:/usr/sbin:/sbin:$PATH:$HOME/Projects/tools"
PATH="/home/$USER/perl5/bin${PATH:+:${PATH}}"
export PATH

export LD_LIBRARY_PATH="/lib:/usr/local/lib:$LD_LIBRARY_PATH"

export NVM_DIR="/home/$USER/.nvm"
[ -s "$NVM_DIR/nvm.sh" ] && . "$NVM_DIR/nvm.sh"  # This loads nvm

source /etc/zsh_command_not_found  

SSH_ENV="$HOME/.ssh/environment"

# start the ssh-agent
function start_agent {
    echo "Initializing new SSH agent..."
    # spawn ssh-agent
    /usr/bin/ssh-agent | sed 's/^echo/#echo/' > "${SSH_ENV}"
    echo succeeded
    chmod 600 "${SSH_ENV}"
    . "${SSH_ENV}" > /dev/null
    /usr/bin/ssh-add
}

if [ -f "${SSH_ENV}" ]; then
     . "${SSH_ENV}" > /dev/null
     ps -ef | grep ${SSH_AGENT_PID} | grep ssh-agent$ > /dev/null || {
        start_agent;
    }
else
    start_agent;
fi

source ~/.bin/tmuxinator.zsh
eval "$(pipenv --completion)"
eval "$(thefuck --alias)"
python "$HOME/Projects/pyfortune/pyfortune.py"

if [ -z "$TMUX" ]; then
  mux start default -n "$(random-words 2)"
fi
