#!/usr/bin/env bash
#
# mkstop.inc.bash -- Minikube shutdown script
#
mkstop() {
  # shellcheck source=../bootstrap/bootstrap.bash
  [[ "${__BOOTSTRAPPED:-0}" == "1" ]] || { . "${TOOLS_HOME}/bootstrap/bootstrap.bash" || return 1; }
  tools_inPath minikube || return 1
  tools_inPath docker || return 1
  # Switch docker context back to default so there's no delays when minikube stops
  sd default
  # Stop Minikube
  minikube stop || {
    logger_error "error stopping minikube"
    return 1
  }
  logger_info "minikube stopped"
}
