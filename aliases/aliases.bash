#!/usr/bin/env bash
#
# aliases.bash -- Command Aliases
#
# git
alias gp="git pull"
alias gb="git branch"
alias gt="git tag"
alias gs="git status"
alias gfo="git fetch origin"
#
# Subversion
alias sco="svn co"
alias si="svn info"
alias scl="svn cleanup"
alias sup="svn update"
alias ss="svn status"
#
# Kubernetes
alias kc="kubectl"
alias mk="minikube"
alias pods="kubectl get pods"
alias podsw="kubectl get pods -o wide"
alias wpods="watch kubectl get pods"
alias wpodsw="watch kubectl get pods -o wide"
#
# Helm
alias hdp="helm delete --purge"
#
# Docker
alias dkr="docker"
alias dkc="docker-compose"
alias dsp="docker system prune -f --volumes"
alias dspa="docker system prune -a -f --volumes"
#
# NodeJS
alias jt="npx jest --clearCache && npx jest -i"
alias ni="npm i"
alias nci="npm ci"
#
# yt-dlp
alias ytdump="yt-dlp --no-playlist --embed-thumbnail --write-thumbnail --all-formats --add-metadata --no-overwrites -o '%(id)s_%(format)s.%(ext)s'"
alias yta="yt-dlp --embed-thumbnail --format 'bestaudio[ext=wav]/bestaudio[ext=m4a]/bestaudio[ext=mp4]/bestaudio[ext=mp3]/bestaudio' -o '%(title)s.%(ext)s'"
alias ytv="yt-dlp --format 'bestvideo+bestaudio/best' -o '%(title)s.%(ext)s'"
#
# Wine
alias w32="export WINEARCH=win32 && export WINEPREFIX=\${HOME}/.wine32"
alias w64="export WINEARCH=win64 && export WINEPREFIX=\${HOME}/.wine"
alias cdwine="cd \${WINEPREFIX}/drive_c"
#
# Misc
# shellcheck disable=SC2139
alias nuget="mono ${HOME}/bin/nuget.exe"
# shellcheck disable=SC2139
alias e="${EDITOR:-vi}"
# shellcheck disable=SC2139
alias g="${VISUAL:-vi}"
alias z="7z a -mx9"  # 7-zip with high compression
alias t="tmux attach || tmux"  # tmux: attach to existing session or start a new one
case ${OSTYPE} in
  linux*|freebsd*)
    alias ls="ls -aFh --color=auto"
    alias ll="ls -aFhl --color=auto"
    ;;
  darwin*)
    alias ls="ls -aFGh"
    alias ll="ls -aFGhl"
    ;;
esac
