#
# sk.inc.bash -- Switch Kubernetes context
#
sk() {
  # shellcheck source=../bootstrap/bootstrap.bash
  [[ "${__BOOTSTRAPPED:-0}" -eq 1 ]] || { . "${TOOLS_HOME}/bootstrap/bootstrap.bash" || return 1; }
  tools_inPath kubectl || return 1
  [[ -z "${1}" ]] && {
    kubectl config current-context
    return 0
  }
  [[ "${1}" == "." ]] && {
    kubectl config get-contexts
    return 0
  }
  kubectl config use-context "${1}"
}
