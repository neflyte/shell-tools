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
alias sst="svn status"
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
alias ytdump="yt-dlp --no-playlist --embed-metadata --embed-thumbnail --write-thumbnail --all-formats --add-metadata --no-overwrites -o '%(id)s_%(format)s.%(ext)s'"
alias yta="yt-dlp --embed-thumbnail --format 'ba[ext=wav]/ba[ext=m4a]/ba[ext=mp4]/ba[ext=mp3]/ba' -o '%(title)s.%(ext)s'"
alias ytapl="yt-dlp --yes-playlist --embed-thumbnail --format 'ba[ext=wav]/ba[ext=m4a]/ba[ext=mp4]/ba[ext=mp3]/ba' -o '%(playlist_index)s_%(track_number)s_%(title)s.%(ext)s'"
alias ytv="yt-dlp --embed-metadata --embed-thumbnail --format 'bv+ba/b' -o '%(title)s.%(ext)s'"
#
# Wine
alias w32="export WINEARCH=win32 && export WINEPREFIX=\${HOME}/.wine32"
alias w64="export WINEARCH=win64 && export WINEPREFIX=\${HOME}/.wine"
alias cdwine="cd \${WINEPREFIX}/drive_c"
#
# Misc
# shellcheck disable=SC2139
alias e="\${EDITOR:-vi}"
# shellcheck disable=SC2139
alias g="\${VISUAL:-vim}"
alias z="7z a -mx9"  # 7-zip with high compression
alias t="tmux attach || tmux"  # tmux: attach to existing session or start a new one
alias nuget="mono \${HOME}/bin/nuget.exe"
#
# OS-specific aliases
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
