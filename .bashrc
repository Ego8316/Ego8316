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
# Readline markers for non-printing ANSI escapes emitted via command substitution.
RL_BLACK=$'\001\033[38;5;16m\002'
RL_RED=$'\001\033[38;5;196m\002'
RL_GIT_RED=$'\001\033[38;5;160m\002'

git_info() {
    local branch dirty
    branch="$(git branch --show-current 2>/dev/null)"
    dirty="$([[ -n "$(git status --porcelain 2>/dev/null)" ]] && echo "*")"

    if [ -n "$branch" ]; then
        printf "%s─[%s %s%s%s]" "$RL_BLACK" "$RL_GIT_RED" \
            "$branch" "$dirty" "$RL_BLACK"
    fi
}

LAST_EXIT_CODE=0
save_last_exit() {
    LAST_EXIT_CODE=$?
}
PROMPT_COMMAND="save_last_exit"
last_exit() {
    if [ "$LAST_EXIT_CODE" -ne 0 ]; then
        printf "%s─[%sexit: %s%s]" "$RL_BLACK" "$RL_RED" \
            "$LAST_EXIT_CODE" "$RL_BLACK"
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
alias chrome="chromium"
alias gtree="__gtree_branch=\$(git branch --show-current 2>/dev/null); __gtree_cols=\${COLUMNS:-\$(tput cols 2>/dev/null || echo 120)}; \
  git -c color.ui=always -c log.graphColors='16,16,16,16,16,16' \
  log --graph --decorate=short \
  --pretty=format:'%C(always,#af5f00)%h%C(reset)%C(always,#d70000)%d%C(reset)%x1f%s%x1f%C(always,#d70000)(%cr)%C(reset)' \
  --all | awk -F \$'\\x1f' -v cols=\"\$__gtree_cols\" -v branch=\"\$__gtree_branch\" \
  -v red=\"\$(printf '\\033[38;5;160m')\" \
  -v blk=\"\$(printf '\\033[38;5;16m')\" \
  'function vislen(s, t){ t=s; gsub(/\\033\\[[0-9;]*m/, \"\", t); return length(t) } \
   function first_graph_pos(graph,   i, c){ \
     for (i=1; i<=length(graph); i++) { c=substr(graph, i, 1); if (c ~ /[|\\\\/*]/) return i; } \
     return 0; \
   } \
   function nearest_graph_pos(graph, guess,   d, p, c){ \
     if (guess < 1) guess = 1; \
     for (d=0; d<=4; d++) { \
       p=guess-d; if (p>=1) { c=substr(graph, p, 1); if (c ~ /[|\\\\/*]/) return p; } \
       if (d==0) continue; \
       p=guess+d; if (p<=length(graph)) { c=substr(graph, p, 1); if (c ~ /[|\\\\/*]/) return p; } \
     } \
     return 0; \
   } \
   function color_graph(prefix,   orange, first, graph, rest, pos, chr, hpos){ \
     orange=sprintf(\"%c[38;2;175;95;0m\", 27); \
     first=index(prefix, orange); \
     if (first>0) { graph=substr(prefix, 1, first-1); rest=substr(prefix, first); } else { graph=prefix; rest=\"\"; } \
     gsub(/\\033\\[[0-9;]*m/, \"\", graph); \
     if (!anchored) { \
       if (branch != \"\" && index(rest, \"HEAD -> \" branch) > 0) { \
         pos=index(graph, \"*\"); \
         if (pos < 1) pos=first_graph_pos(graph); \
         target_col=pos; \
         anchored=1; \
       } else if (branch == \"\") { \
         pos=first_graph_pos(graph); \
         target_col=pos; \
         anchored=1; \
       } else { \
         graph=blk graph; \
         return graph rest; \
       } \
     } else { \
       pos=nearest_graph_pos(graph, target_col); \
       if (pos < 1) pos=first_graph_pos(graph); \
     } \
     if (pos > 0) { \
       chr=substr(graph, pos, 1); \
       graph=blk substr(graph, 1, pos-1) red chr blk substr(graph, pos+1); \
       if (chr==\"*\") { \
         hpos=index(rest, orange); \
         if (hpos>0) rest=substr(rest, 1, hpos-1) red substr(rest, hpos+length(orange)); \
       } \
       if (chr==\"\\\\\") target_col=pos+1; \
       else if (chr==\"/\") target_col=pos-1; \
       else target_col=pos; \
       if (target_col < 1) target_col = 1; \
     } else { \
       graph=blk graph; \
     } \
     return graph rest; \
   } \
   { prefix=\$1; subj=(NF>1 ? \$2 : \"\"); ts=(NF>2 ? \$3 : \"\"); \
     prefix=color_graph(prefix); \
     avail=cols-vislen(prefix)-1-vislen(ts); if (avail<0) avail=0; \
     if (length(subj)>avail) { cut=avail-4; if (cut<0) cut=0; if (avail>=4) subj=substr(subj,1,cut) \"...\"; else subj=\"\" } \
     pad=cols-vislen(prefix)-1-length(subj)-vislen(ts); if (pad<1) pad=1; \
     printf \"%s %s%*s%s\\n\", prefix, subj, pad, \"\", ts }' | less -R"

# Fly CLI

export FLYCTL_INSTALL="/home/ego/.fly"
export PATH="$FLYCTL_INSTALL:$PATH"
alias fly='/home/ego/.fly/bin/flyctl'

# Flutter
export ANDROID_HOME="$HOME/Android"
export CHROME_EXECUTABLE="chromium"
export PATH="$PATH:$HOME/flutter/bin:$ANDROID_HOME/cmdline-tools/latest/bin:$ANDROID_HOME/platform-tools:/mnt/c/Users/fuusu/AppData/Local/Android/Sdk/platform-tools"
