#!/usr/bin/env bash
#
# mkstart.inc.bash -- Minikube startup script
#
mkstart() {
  # shellcheck source=../bootstrap/bootstrap.bash
  [[ "${__BOOTSTRAPPED:-0}" == "1" ]] || { . "${TOOLS_HOME}/bootstrap/bootstrap.bash" || return 1; }
  tools_inPath minikube || return 1
  tools_inPath kubectl || return 1
  tools_inPath helm || return 1
  tools_inPath jq || return 1
  minikube status &>/dev/null && {
    logger_error "minikube is already running"
    return 1
  }
  # Get the current Minikube profile
  local MK_PROFILE
  MK_PROFILE=$(minikube profile) || MK_PROFILE=""
  local MK_START_ARGS
  [[ -n "${MK_PROFILE}" ]] && MK_START_ARGS="-p ${MK_PROFILE}"
  # Get the driver from the profile
  local MK_PROFILE_DRIVER
  MK_PROFILE_DRIVER="$(minikube profile list -o json | jq -Mr ".valid[]? | select(.Name == \"${MK_PROFILE}\") | .Config.Driver")" || MK_PROFILE_DRIVER=""
  [[ -n "${MK_PROFILE_DRIVER}" ]] && MK_START_ARGS+=" --driver=${MK_PROFILE_DRIVER}"
  logger_debug "MK_START_ARGS=${MK_START_ARGS}"
  # Start Minikube with optional arguments
  minikube start ${MK_START_ARGS} || {
    logger_error "could not start minikube"
    return 1
  }
  minikube status || {
    logger_error "minikube is not started; this is unexpected"
    return 1
  }
  tools_inPath updatekubehosts && updatekubehosts
  "${TOOLS_HOME}"/scripts/minikube-update-docker-context.bash || {
    logger_error "error updating docker context"
    return 1
  }
  local HELMVERSION
  HELMVERSION="$(helm version --short --client)" || HELMVERSION=""
  [[ $HELMVERSION =~ ^v3.*$ ]] || {
    helm init --upgrade || {
      logger_error "error initializing helm"
      return 1
    }
  }
  helm repo up || {
    logger_error "error updating helm repos"
    return 1
  }
  tools_inPath helm3 && {
    helm3 repo up || {
      logger_error "error updating helm3 repos"
      return 1
    }
  }
  logger_info "minikube started successfully"
}
