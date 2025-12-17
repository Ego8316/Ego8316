# If not running interactively, don't do anything
case $- in
    *i*) ;;
      *) return;;
esac

# don't put duplicate lines or lines starting with space in the history.
# See bash(1) for more options
HISTCONTROL=ignoreboth

# append to the history file, don't overwrite it
shopt -s histappend

# for setting history length see HISTSIZE and HISTFILESIZE in bash(1)
HISTSIZE=1000
HISTFILESIZE=2000

# check the window size after each command and, if necessary,
# update the values of LINES and COLUMNS.
shopt -s checkwinsize

# make less more friendly for non-text input files, see lesspipe(1)
[ -x /usr/bin/lesspipe ] && eval "$(SHELL=/bin/sh lesspipe)"

# enable color support of ls and also add handy aliases
if [ -x /usr/bin/dircolors ]; then
    test -r ~/.dircolors && eval "$(dircolors -b ~/.dircolors)" || eval "$(dircolors -b)"
    alias ls='ls --color=auto'
    #alias dir='dir --color=auto'
    #alias vdir='vdir --color=auto'

    alias grep='grep --color=auto'
    alias fgrep='fgrep --color=auto'
    alias egrep='egrep --color=auto'
fi

# some more ls aliases
alias ll='ls -alF'
alias la='ls -A'
alias l='ls -CF'

# Alias definitions.
# You may want to put all your additions into a separate file like
# ~/.bash_aliases, instead of adding them here directly.
# See /usr/share/doc/bash-doc/examples in the bash-doc package.

if [ -f ~/.bash_aliases ]; then
    . ~/.bash_aliases
fi

# enable programmable completion features (you don't need to enable
# this, if it's already enabled in /etc/bash.bashrc and /etc/profile
# sources /etc/bash.bashrc).
if ! shopt -oq posix; then
  if [ -f /usr/share/bash-completion/bash_completion ]; then
    . /usr/share/bash-completion/bash_completion
  elif [ -f /etc/bash_completion ]; then
    . /etc/bash_completion
  fi
fi

# Custom prompt

RED="\[\033[38;5;196m\]"
BLACK="\[\033[38;5;16m\]"
DARK_ORANGE="\[\033[38;5;130m\]"
RESET="\[\033[0m\]"

git_info() {
    local branch dirty
    branch="$(git branch --show-current 2>/dev/null)"
    dirty="$([[ -n "$(git status --porcelain 2>/dev/null)" ]] && echo "*")"

    if [ -n "$branch" ]; then
        printf "\033[38;5;16m─[\033[38;5;160m %s%s\033[38;5;16m]" \
            "$branch" "$dirty"
    fi
}

LAST_EXIT_CODE=0
save_last_exit() {
    LAST_EXIT_CODE=$?
}
PROMPT_COMMAND="save_last_exit"
last_exit() {
    if [ "$LAST_EXIT_CODE" -ne 0 ]; then
        printf "\033[38;5;16m─[\033[38;5;196mexit: %s\033[38;5;16m]" "$LAST_EXIT_CODE"
    fi
}

PS1="${BLACK}┌─[${RED}\u${BLACK}@${RED}\h${BLACK}]\
─[${DARK_ORANGE}\w${BLACK}]\
─[${RED}\$(date +\"%I:%M %P\")${BLACK}]\
\$(git_info)${RESET}\
\n${BLACK}└\$(last_exit)─[${RED}\$${BLACK}]› ${RESET}"

# Custom aliases

alias c='clear'
alias gccw='gcc -Wall -Wextra -Werror'
alias gccf='gcc -Wall -Wextra -Werror -fsanitize=address'
alias norm='/home/ego/.local/bin/norminette'
alias gls='git ls-files'
alias gtree="git log --graph --pretty=format:'%C(yellow)%h%C(reset) %C(cyan)%d%C(reset) %s %C(blue)(%cr)%C(reset)' --all"
alias chrome="chromium"

# Fly CLI

export FLYCTL_INSTALL="/home/ego/.fly"
export PATH="$FLYCTL_INSTALL:$PATH"
alias fly='/home/ego/.fly/bin/flyctl'

# Flutter
export ANDROID_HOME="$HOME/Android"
export CHROME_EXECUTABLE="chromium"
export PATH="$PATH:$HOME/flutter/bin:$ANDROID_HOME/cmdline-tools/latest/bin:$ANDROID_HOME/platform-tools:/mnt/c/Users/fuusu/AppData/Local/Android/Sdk/platform-tools"
