# for things not checked into git..
if test -e "$HOME/.extra.fish";
    source ~/.extra.fish
end

if status --is-login
and not set -q TMUX
    # tmux has-session 2> /dev/null; and tmux attach; or tmux
    tmux
end

# no indent to make this easier
# only do any of this on login to make faster
# if status --is-login
# Language Default
set -x LC_ALL en_US.UTF-8
set -x LC_CTYPE en_US.UTF-8

set -x EDITOR vim
set -x VISUAL $EDITOR

function fish_right_prompt_loading_indicator -a last_prompt
    echo -n "$last_prompt" | sed -r 's/\x1B\[[0-9;]*[JKmsu]//g' | read -zl uncolored_last_prompt
    echo -n (set_color brblack)"$uncolored_last_prompt"(set_color normal)
end

function last_history_item; echo $history[1]; end
abbr -a !! --position anywhere --function last_history_item

# Paste a git URL in the prompt, hit enter, and it'll clone it and CD in.
function git_clone_into
    [ -d $(basename $argv[1] .git) ]
    or git clone $argv[1]
    cd $(basename $argv[1] .git)
end
abbr -a auto_clone_cd --position command --regex ".+\.git" --function git_clone_into
abbr -a auto_clone_cd_p --position command --regex "^git@.+" --function git_clone_into
abbr -a auto_clone_cd_h --position command --regex "^https://github\.com.+" --function git_clone_into

abbr -a --position anywhere -- "--help" "--help 2>&1 | bat --plain --language=help --wrap=character"

function popup-help
  # handle piped input
  if test -z "$argv"
    set argv (cat)
  end
  tmux popup -E -w 80% -h 80% "$argv --help | bat --plain --language=help --wrap=character"
end
abbr -a ph popup-help

set -x GIT_CONFIG_COUNT 1
set -x GIT_CONFIG_KEY_0 core.hooksPath
set -x GIT_CONFIG_VALUE_0 ~/.config/git/hooks

function vim_edit
    echo vim $argv
end
abbr -a vim_edit_texts --position command --regex "^[^.].+\.(txt|java|py|ts|tsx)" --function vim_edit

# Read: xargs multiple
# https://stackoverflow.com/questions/6958689/running-multiple-commands-with-xargs
abbr -a XM --position anywhere --set-cursor '| gxargs -d \'\n\' bash -c \'for arg do % "$arg"; done\' _'

# Configuration for tools
# LESS with colors
# from http://blog.0x1fff.com/2009/11/linux-tip-color-enabled-pager-less.html
# https://unix.stackexchange.com/questions/329093/how-to-use-less-f-without-x-but-still-display-output-if-only-one-page
set -x LESS "-iRSM~gIsw"
set -x PAGER 'less -F'
set -x MANPAGER 'less +Gg' # Goes to end and then start of file; this gives a percentage complete.

set -x FZF_DEFAULT_COMMAND "fd --type f --hidden -E '.git/'"
set -x FZF_DEFAULT_OPTS "--bind=ctrl-c:abort,'ctrl-o:execute(vim {})+abort'"
set -x GPG_TTY (tty)

set -x pact_do_not_track "true"

function confirm -a 'prompt' -d "Confirm whether or not to do something"
    if test -z "$prompt"
        set prompt 'Are you sure?'
    end

    read -f -p "set_color green; echo \"$prompt [y/N]\"; set_color normal" response
    switch "$response"
        case y Y
            true
        case '*'
            false
    end
end

function dockerbash -d "Bash into docker container, if only one running."
    set ids (docker ps --filter status=running --format "{{.ID}}")
    if [ (count $ids) != 1 ]
        echo "Docker container count" (count $ids) "!= 1"
        return
    end
    docker exec -it $ids[1] /bin/bash
end


# Alii and functions that are basically alii

abbr -a k 'kubectl'
abbr -a kl 'kubectl logs'

abbr -a kg 'kubectl get'
abbr -a kgd 'kubectl get deploy'

abbr -a kd 'kubectl describe'
abbr -a kdd 'kubectl describe deploy'

function knamespace -a 'ns' -d "Set kubernetes namespace context."
    kubectl config set-context --current --namespace=$ns
end


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

function pickone -d "Prints a random argument. Cleanses own call from history. Hail Chaos!"
    echo $argv[(random 1 (count $argv))]
    history delete --exact --case-sensitive "pickone $argv"
end


# I'm not sold on eza but I'll try it
if type -q eza
    abbr -a l eza
    abbr -a ll 'eza --long --all --group --header --git'
    abbr -a lt 'eza --long --all --group --header --tree --level'
    abbr -a tree 'eza --tree --git-ignore'
end


if status --is-interactive
    if type -q bat
        alias cat 'bat --paging=never'
    end
end

set -x RIPGREP_CONFIG_PATH ~/.config/ripgreprc
alias rg 'rg --ignore-case'
abbr -a frg 'rg --fixed-strings' # fgrep
function rge -d "Ripgrep but exclude"
    rg '^((?!'$argv[1]').)*$' --pcre2
end
abbr -a --set-cursor find-strings 'rg --hidden --no-filename --no-line-number --no-heading "%" | sort | uniq'

abbr -a agar 'sudo apt autoremove'
abbr -a agi 'sudo apt install'
abbr -a agr 'sudo apt remove'
abbr -a agu 'sudo apt update'
abbr -a agud 'sudo apt update && sudo apt dist-upgrade'

function tzconv -a "from" -a "to" -a "time" -d "Convert a time between timezones"
    echo (TZ="$from" gdate --date $time +"%r %a %b %d") in (string split '/' -f2 $from) is:
    echo (TZ="$to" gdate --date='TZ="'$from'" '$time +"%r %a %b %d") in (string split '/' -f2 $to)
end

function ny_to_denver -a "time" -d "Convert NY time to Denver"
    tzconv "America/New_York" "America/Denver" $time
end

function denver_to_ny -a "time" -d "Convert Denver time to NY"
    tzconv "America/Denver" "America/New_York" $time
end

function time_ny -d "Current time in NY"
    denver_to_ny (gdate)
end

function sco -d "shellcheck open"
    open https://www.shellcheck.net/wiki/$argv[1]
end

abbr -a cl 'clear'


# Git shortcuts
abbr -a g 'git'

abbr -a ga 'git add'
abbr -a gco 'git checkout'
abbr -a gst 'git status'
abbr -a gl 'git pull'
abbr -a gd 'git diff'
abbr -a gppr 'git ppr'

abbr -a gs 'git stash' # Sorry ghostscript
abbr -a --set-cursor gsm 'git stash push -m "%"'
abbr -a --set-cursor gsam 'git stash apply stash^{/%}'

abbr -a gp 'git push'
abbr -a gpf 'git push --force-with-lease'

abbr -a gc 'git commit'
abbr -a --set-cursor gcmsg 'git commit -m "%"'
abbr -a gca 'git commit --amend -C HEAD'

abbr -a grb 'git rebase'
abbr -a grbc 'git rebase --continue'
abbr -a grba 'git rebase --abort'
abbr -a grbi 'git rebase -i (git merge-base HEAD (git default-branch))'
abbr -a grbm 'git rebase-master && git push --force-with-lease'

# Git root
alias gr 'cd (git rev-parse --show-toplevel)'

# Git main|master
alias gm 'git checkout $(git default-branch) && git pull'

alias gaa 'git status; confirm "Add all?"; and git add -A'
alias gcapf 'git status; confirm "Amend + Push Force?"; and git commit --amend -C HEAD && git push --force-with-lease'
alias gcap 'git status; confirm "Amend + Push Force?"; and git commit --amend -C HEAD && git push'
alias gitgud 'gaa; and gcapf' # Add all with confirmation after git status, commit amend, push force

function gap -d "Git add one file, or prompt for all"
    if [ (git status --porcelain | wc -l) = 1 ]
        git add -v -A # -v prints added file
    else
        # can we prompt one by one, but better than git add --interactive?
       git status; confirm "Add all?"; and git add -A
    end
end

abbr -a vimrc 'vim ~/.vim/vimrc'
abbr -a vimfish 'vim ~/.config/fish/config.fish'
abbr -a refish 'source ~/.config/fish/config.fish'
abbr -a newfish 'exec fish -l'

# iterm2's semantic history is better actually ;.;
# unless I can figure out how to make it open OSC 8 hyperlinks in vim
# mayyybe auto-adding a #0 to them? https://iterm2.com/documentation-escape-codes.html
# alias ls 'gls --color=always --hyperlink=always'
abbr -a lsa 'ls -lah'

# https://unix.stackexchange.com/questions/631733/how-to-write-a-command-to-history-in-fish-shell
function add_history_entry
  begin
    flock 1
    and echo -- '- cmd:' (
      string replace -- \n \\n (string join ' ' $argv) | string replace \\ \\\\
    )
    and date +'  when: %s'
  end >> $__fish_user_data_dir/fish_history
  and history merge
end

# https://github.com/atuinsh/atuin/issues/1188
function run_and_record_in_atuin
    set -f id "$(atuin history start $argv)"
    $argv
    set -f cmd_status $status
    atuin history end --exit $cmd_status "$id"
    return $cmd_status
end


# Function instead of alias, so we can exit on ctrl-c
function p
    set file (fzf --preview 'bat --color "always" {}' --bind='ctrl-o:accept')
    if string length -q $file
        # This way you can arrow up->enter to re-open
        add_history_entry "vim '$file'"
        run_and_record_in_atuin vim "$file"
    end
end

# Preview-all (includes hidden files)
function pa
    set -fa FZF_DEFAULT_COMMAND "--no-ignore" # assumes fd base command
    set file (fzf --preview 'bat --color "always" {}' --bind='ctrl-o:accept')
    if string length -q $file
        # This way you can arrow up->enter to re-open
        add_history_entry "vim '$file'"
        run_and_record_in_atuin vim "$file"
    end
end

bind \cp 'p'
bind \cx edit_command_buffer
# Lets us Ctrl-Z to both background and foreground
bind \cz 'fg 2>/dev/null; commandline -f repaint'
# Ctrl-C clears the screen on an empty command line
bind \cc 'if test -z (commandline); clear; commandline -f repaint; else; __fish_cancel_commandline; end'
bind \cd 'if test -z (commandline); exit; else; __fish_cancel_commandline; end'

alias rm 'rm -i'
alias cp 'cp -i'
alias mv 'mv -i'

abbr -a hm 'history merge'

# Appearance
set fish_greeting
source ~/.config/fish/themes/tokyonight_day.fish
set -x BAT_THEME 'tokyonight_day'
set -x --path --append TERMINFO_DIRS $HOME/.local/share/terminfo
# end
