#!/bin/bash

export USER=$(whoami)

# --- Discover WinGet Binaries ---
export PATH="$PATH:/c/Users/$USER/AppData/Local/Microsoft/WinGet/Links"
export PATH="$PATH:/c/Program Files/WinGet/Links"
export PATH="$PATH:/c/Users/$USER/AppData/Local/Microsoft/WindowsApps"

# --- Neovim ---
alias vim='nvim'

# --- Navigation ---
alias ..='cd ..'
alias ...='cd ../..'
alias ....='cd ../../..'
alias ~='cd ~'

# --- Directory listing ---
alias ls='ls --color=auto'
alias ll='ls -lh'
alias la='ls -lAh'
alias l='ls -CF'

# --- Safety nets ---
alias cp='cp -i'
alias mv='mv -i'
alias rm='rm -i'
alias mkdir='mkdir -p'

# --- Search ---
alias grep='grep --color=auto'
alias fgrep='fgrep --color=auto'
alias egrep='egrep --color=auto'

# --- Git shortcuts ---
alias g='git'
alias gs='git status'
alias ga='git add'
alias gaa='git add --all'
alias gc='git commit'
alias gcm='git commit -m'
alias gca='git commit --amend'
alias gco='git checkout'
alias gb='git branch'
alias gd='git diff'
alias gds='git diff --staged'
alias gl='git log --oneline --graph --decorate'
alias gla='git log --oneline --graph --decorate --all'
alias gp='git push'
alias gpf='git push --force-with-lease'
alias gpl='git pull'
alias gst='git stash'
alias gstp='git stash pop'
alias grb='git rebase'
alias grs='git restore'
alias grss='git restore --staged'

# --- Misc ---
alias h='history'
alias c='clear'
alias which='type -a'
alias path='echo -e "${PATH//:/\\n}"'
alias reload='source ~/.bashrc'
