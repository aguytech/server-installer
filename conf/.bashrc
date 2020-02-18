#!/bin/bash

# Source global definitions
[ -f /etc/bashrc ] && . /etc/bashrc

# enable bash completion in interactive shells
if ! shopt -oq posix; then
  if [ -f /usr/share/bash-completion/bash_completion ]; then
    . /usr/share/bash-completion/bash_completion
  elif [ -f /etc/bash_completion ]; then
    . /etc/bash_completion
  fi
fi

# PS1
[ "$PS1" ] && PS1="${debian_chroot:+($debian_chroot)}\[\e[1;91m\]\u\[\e[1;37m\]@\[\e[1;32m\]\h\[\e[1;37m\]:\W\[\e[1;32m\]$\[\e[0;0m\]"

# source global variables
[ -f /etc/server/env.conf ] && . /etc/server/env.conf

# aliases
[ -f ~/.bash_aliases ] && . ~/.bash_aliases

# functions
[ -f ~/.bash_functions ] && . ~/.bash_functions
