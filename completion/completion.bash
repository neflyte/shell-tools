#!/usr/bin/env bash
#
# completion.bash -- Bash Completion initialization + aliasing
#
# Kubernetes CLI (kubectl); alias kubectl -> kc
declare -fp __start_kubectl &>/dev/null && {
  if [[ $(type -t compopt) = "builtin" ]]; then
    complete -o default -F __start_kubectl kc
  else
    complete -o default -o nospace -F __start_kubectl kc
  fi
}
#
# Git-related
# alias gco -> git checkout
declare -fp __git_complete &>/dev/null && {
  __git_complete gco _git_checkout
}
