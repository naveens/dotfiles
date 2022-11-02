# ~/.bashrc: executed by bash(1) for non-login shells.
# see /usr/share/doc/bash/examples/startup-files (in the package bash-doc)
# for examples

# If not running interactively, don't do anything
[ -z "$PS1" ] && return

# don't put duplicate lines in the history. See bash(1) for more options
# ... or force ignoredups and ignorespace
HISTCONTROL=ignoredups:ignorespace

# append to the history file, don't overwrite it
shopt -s histappend

# for setting history length see HISTSIZE and HISTFILESIZE in bash(1)
HISTSIZE=100000
HISTFILESIZE=200000

# check the window size after each command and, if necessary,
# update the values of LINES and COLUMNS.
shopt -s checkwinsize

# make less more friendly for non-text input files, see lesspipe(1)
[ -x /usr/bin/lesspipe ] && eval "$(SHELL=/bin/sh lesspipe)"

parse_kubeconfig() {
    basename "${KUBECONFIG:-}"
}

# source git-prompt.sh to get git status in PS1
test -f ~/.local/share/git-core/contrib/completion/git-prompt.sh && source ~/.local/share/git-core/contrib/completion/git-prompt.sh
export GIT_PS1_SHOWCOLORHINTS=1
export GIT_PS1_SHOWDIRTYSTATE=1
export GIT_PS1_SHOWSTASHSTATE=1
export GIT_PS1_SHOWUNTRACKEDFILES=1
export GIT_PS1_SHOWUPSTREAM="auto"

# Some useful information on trace output
PS4='+ ${BASH_SOURCE:-}:${FUNCNAME[0]:-}:L${LINENO:-}:   '

# enable color support of ls and also add handy aliases
if [ -x /usr/bin/dircolors ]; then
    test -r ~/.dircolors && eval "$(dircolors -b ~/.dircolors)" || eval "$(dircolors -b)"
    alias ls='ls --color=auto'
    alias grep='grep --color=auto'
    alias fgrep='fgrep --color=auto'
    alias egrep='egrep --color=auto'
fi

# some more ls aliases
alias ll='ls -alF'
alias la='ls -A'
alias l='ls -CF'
alias llt='ls -ltr'

pathadd () {
    if [ -d "$1" ] && [[ ":$PATH:" != *":$1:"* ]]; then
        PATH="$PATH:$1"
    fi
}

set_bash_prompt () {

    EXIT=$?

    # Set window title
    echo -ne "\033]0;${USER}@${HOSTNAME}: ${PWD}\007"

    # set a fancy prompt (non-color, unless we know we "want" color)
    case "$TERM" in
        xterm-color) color_prompt=yes;;
        xterm-256color) color_prompt=yes;;
        screen*) color_prompt=yes;;
        alacritty*) color_prompt=yes;;
    esac

    PS1=""

    # Add exit code of last command if it's non-zero
    test $EXIT -ne 0 && PS1="$PS1[$EXIT]"

    # Add virtualenv if inside one
    test ! -z $VIRTUAL_ENV && PS1="$PS1(`basename \"$VIRTUAL_ENV\"`)"

    if [ "$color_prompt" = yes ] ; then
        # Enclose the ANSI escape codes in \[ and \] so bash knows they are non-printable
        PS1="$PS1\[\e[1;32m\]\u\[\e[0m\]@\[\e[1;33m\]\h\[\e[0m\] \[\e[1;34m\]\w\[\e[0m\]"
    else
        PS1="$PS1\u@\h \w"
    fi

    # Add git status
    if type __git_ps1 &> /dev/null; then
        PS1="$PS1$(__git_ps1)\n; "
    fi

    # before setting command prompt, append last command to history file and load
    # commands from history file (including history from other shells) in to the
    # current shell history list.
    history -a && history -n

    unset color_prompt
}

PROMPT_COMMAND=set_bash_prompt

pathadd $HOME/.local/bin

test -f ~/.pythonrc && export PYTHONSTARTUP=~/.pythonrc

export GOPATH=~/go
pathadd $GOPATH/bin

# Enable completions for bash, git, kubectl etc
test -f /usr/share/bash-completion/bash_completion && source /usr/share/bash-completion/bash_completion
if type kubectl &> /dev/null; then
    source <(kubectl completion bash)
fi

if type rg &> /dev/null; then
    export FZF_DEFAULT_COMMAND='rg --files' # integrate with ripgrep
    export FZF_DEFAULT_OPTS='-m --height 50% --border'
fi

# Local customized path and environment settings, etc.
if [ -f ~/.bashrc_local ]; then
    . ~/.bashrc_local
fi

if [ -f ~/.bash_aliases ]; then
    . ~/.bash_aliases
fi
# vim: set expandtab:autoindent:tabstop=4:shiftwidth=4
