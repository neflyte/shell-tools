#
# sd.inc.bash -- Switch Docker context
#
sd() {
  # shellcheck source=../bootstrap/bootstrap.bash
  [[ "${__BOOTSTRAPPED:-0}" == "1" ]] || { . "${TOOLS_HOME}/bootstrap/bootstrap.bash" || return 1; }
  tools_inPath docker || return 1
  local __DOCKER_ENV="${1}"
  [[ -z "${__DOCKER_ENV}" ]] && {
    local CURRENT_DOCKER_CONTEXT
    local CTX_COUNT
    CTX_COUNT=$(docker context list -q | wc -l | tr -d ' ') || CTX_COUNT=0
    [[ ${CTX_COUNT} -eq 0 ]] && {
      logger_error "no docker contexts are configured"
      return 1
    }
    CURRENT_DOCKER_CONTEXT="$(docker context list --format "{{json .}}" | jq -Mr "select(.Current == true) | .Name")" || {
      logger_error "[${?}] error reading current docker context"
      return 1
    }
    echo "${CURRENT_DOCKER_CONTEXT}"
    return 0
  }
  [[ "${1}" == "." ]] && {
    docker context list
    return 0
  }
  docker context use "${__DOCKER_ENV}"
}
