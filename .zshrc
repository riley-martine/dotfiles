USER="riley"
# Path to your oh-my-zsh installation.
  export ZSH=/home/$USER/.oh-my-zsh

# Set name of the theme to load.
# Look in ~/.oh-my-zsh/themes/
# Optionally, if you set this to "random", it'll load a random theme each
# time that oh-my-zsh is loaded.
ZSH_THEME="robbyrussell"

# Uncomment the following line to use case-sensitive completion.
# CASE_SENSITIVE="true"

# Uncomment the following line to use hyphen-insensitive completion. Case
# sensitive completion must be off. _ and - will be interchangeable.
# HYPHEN_INSENSITIVE="true"

# Uncomment the following line to disable bi-weekly auto-update checks.
# DISABLE_AUTO_UPDATE="true"

# Uncomment the following line to change how often to auto-update (in days).
# export UPDATE_ZSH_DAYS=13

# Uncomment the following line to disable colors in ls.
# DISABLE_LS_COLORS="true"

# Uncomment the following line to disable auto-setting terminal title.
# DISABLE_AUTO_TITLE="true"

# Uncomment the following line to enable command auto-correction.
# ENABLE_CORRECTION="true"

# Uncomment the following line to display red dots whilst waiting for completion.
# COMPLETION_WAITING_DOTS="true"

# Uncomment the following line if you want to disable marking untracked files
# under VCS as dirty. This makes repository status check for large repositories
# much, much faster.
# DISABLE_UNTRACKED_FILES_DIRTY="true"

# Uncomment the following line if you want to change the command execution time
# stamp shown in the history command output.
# The optional three formats: "mm/dd/yyyy"|"dd.mm.yyyy"|"yyyy-mm-dd"
# HIST_STAMPS="mm/dd/yyyy"

# Would you like to use another custom folder than $ZSH/custom?
# ZSH_CUSTOM=/path/to/new-custom-folder

# Which plugins would you like to load? (plugins can be found in ~/.oh-my-zsh/plugins/*)
# Custom plugins may be added to ~/.oh-my-zsh/custom/plugins/
# Example format: plugins=(rails git textmate ruby lighthouse)
# Add wisely, as too many plugins slow down shell startup.
plugins=(zsh-autosuggestions zsh-completions git github sudo cp ubuntu alias-tips command-not-found pip python common-aliases zsh-syntax-highlighting)

# User configuration

export PATH="/home/$USER/bin:/usr/bin:/bin:/usr/sbin:/sbin:$PATH:$HOME/Projects/tools"
export LD_LIBRARY_PATH="/lib:/usr/local/lib:$LD_LIBRARY_PATH"
# export MANPATH="/usr/local/man:$MANPATH"

source $ZSH/oh-my-zsh.sh

# You may need to manually set your language environment
# export LANG=en_US.UTF-8

# Preferred editor for local and remote sessions
# if [[ -n $SSH_CONNECTION ]]; then
#   export EDITOR='vim'
# else
#   export EDITOR='mvim'
# fi

# Compilation flags
# export ARCHFLAGS="-arch x86_64"

# ssh
# export SSH_KEY_PATH="~/.ssh/dsa_id"

# Set personal aliases, overriding those provided by oh-my-zsh libs,
# plugins, and themes. Aliases can be placed here, though oh-my-zsh
# users are encouraged to define aliases within the ZSH_CUSTOM folder.
# For a full list of active aliases, run `alias`.
#
# Example aliases
# alias zshconfig="mate ~/.zshrc"
# alias ohmyzsh="mate ~/.oh-my-zsh"


# Load xdebug Zend extension with php command
#alias php='php -dzend_extension=xdebug.so'
# PHPUnit needs xdebug for coverage. In this case, just make an alias with php command prefix.
alias phpunit='php $(which phpunit)'
alias python='python3.6'
alias pip='pip3.6'
alias virtualenv='virtualenv --python=/usr/bin/python3'
alias lua='lua5.3'
alias cl='clear'

export GOPATH='~/gocode/'

function calibreupdate {
	sudo -v && wget -nv -O- https://download.calibre-ebook.com/linux-installer.py | sudo python -c "import sys; main=lambda:sys.stderr.write('Download failed\n'); exec(sys.stdin.read()); main()"
}

function mp3 {
	youtube-dl --audio-format mp3 -x "$1"
}

alias netflix='google-chrome --app=https://www.netflix.com/browse --kiosk'
alias spotify='google-chrome --app=https://open.spotify.com/browse --kiosk'

python ~/Projects/pyfortune/pyfortune.py
alias cls='printf "\033c"'

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
	pyst workspace $1
	exit
}

alias caps='xdotool key Caps_Lock'
alias CAPS='xdotool key Caps_Lock' # for when caps lock is on

alias pi='sudo -H pip3 install'
alias xt='xfce4-terminal'
alias male='make'
alias dg='python -m dg'
alias :q='exit'
alias list='ls'
alias nicechromium='ps -C chromium-browser -o "pid=" | while read in; do renice -n 10 -p "$in"; done'

function addfortune {
  echo "%" >> ~/Projects/pyfortune/myfortunes.txt
  echo "$1" >> ~/Projects/pyfortune/myfortunes.txt
}
function pushfortunes {
	cd ~/Projects/pyfortune
	git add myfortunes.txt
	git commit -m "Add fortunes"
	git push
	cd -
}

# Create template C directory
function ds {
	mkdir $1
	cd $1
	sed "s/NAME/$1/g" ~/Templates/MakefileCustom > ./Makefile
	cp ~/Templates/template.c ./$1.c
	pwd
	ls
}

function grepfortunes {
    grep $1 ~/Projects/pyfortune/myfortunes.txt
}
#alias coinflip='python -c "import random; print([\"Heads\",\"Tails\"][random.randint(0,1)]);"'
alias weather='curl wttr.in/durham'

#export PATH="/home/riley/.pyenv/bin:$PATH"
#eval "$(pyenv init -)"
#eval "$(pyenv virtualenv-init -)"
export PATH=$PATH:/usr/local/go/bin

export GOPATH=$HOME/gopath
export PATH=$GOPATH:$GOPATH/bin:$PATH:/home/riley/Projects/tools/biotext

PATH="/home/$USER/perl5/bin${PATH:+:${PATH}}"; export PATH;
PERL5LIB="/home/$USER/perl5/lib/perl5${PERL5LIB:+:${PERL5LIB}}"; export PERL5LIB;
PERL_LOCAL_LIB_ROOT="/home/$USER/perl5${PERL_LOCAL_LIB_ROOT:+:${PERL_LOCAL_LIB_ROOT}}"; export PERL_LOCAL_LIB_ROOT;
PERL_MB_OPT="--install_base \"/home/$USER/perl5\""; export PERL_MB_OPT;
PERL_MM_OPT="INSTALL_BASE=/home/$USER/perl5"; export PERL_MM_OPT;

export NVM_DIR="/home/$USER/.nvm"
[ -s "$NVM_DIR/nvm.sh" ] && . "$NVM_DIR/nvm.sh"  # This loads nvm


hlalib=/usr/hla/hlalib 
export hlalib

hlainc=/usr/hla/include
export hlainc

alias work='encfs ~/.encrypted ~/work_files; cd ~/work_files && unset HISTFILE'
alias unwork='cd && fusermount -u ~/work_files && HISTFILE=/home/riley/.zsh_history'
alias deexif='exiftool -all= *.jpg *.jpeg *.png'

alias con='windscribe connect'
alias dis='windscribe disconnect'
alias ..='cd ..'
alias ,,='cd ..'
function loss {
    echo "l  |  ll"
    echo "--------"
    echo "11 |  l_"
}
function mkcd {
    mkdir $1
    cd $1
}
function foldersize {
    if [ ! -z $1 ]
    then
        du -sb $1/* | sort -n -r | numfmt --to=iec
    else
        du -sb * | sort -n -r | numfmt --to=iec
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


source /etc/zsh_command_not_found  

SSH_ENV=$HOME/.ssh/environment

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
