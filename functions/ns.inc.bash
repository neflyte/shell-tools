#!/usr/bin/env bash
#
# ns.inc.bash -- Switch Kubernetes namespace
#
ns() {
  # shellcheck source=../bootstrap/bootstrap.bash
  [[ "${__BOOTSTRAPPED:-0}" -eq 1 ]] || { . "${TOOLS_HOME}/bootstrap/bootstrap.bash" || return 1; }
  tools_inPath kubectl || return 1
  tools_inPath jq || return 1
  local CURRENT_CTX
  CURRENT_CTX="$(kubectl config view -o json | jq -Mr '."current-context"')" || {
    logger_error "error getting current kubernetes context"
    return 1
  }
  [[ -z "${1}" ]] && {
    kubectl config view -o json | jq -Mr ".contexts[] | select(.name == \"${CURRENT_CTX}\") | .context.namespace"
    return ${?}
  }
  [[ "${1}" == "." ]] && {
    kubectl get ns -o wide
    return $?
  }
  kubectl config set-context --current --namespace "${1}"
}
