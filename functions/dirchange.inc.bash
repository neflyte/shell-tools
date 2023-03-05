#!/usr/bin/env bash
#
# dirchange.inc.bash -- Directory change utility
#
dirchange() {
  # shellcheck source=../bootstrap/bootstrap.bash
  [[ "${__BOOTSTRAPPED:-0}" == "1" ]] || { . "${TOOLS_HOME}/bootstrap/bootstrap.bash" || return 1; }
  [[ -z "${1}" ]] && {
    logger_error "root directory must be specified"
    return 1
  }
  local ROOTDIR="${1}"
  local SUBDIR="${2}"
  [[ -z "${SUBDIR}" ]] && {
    cd "${ROOTDIR}" || return 1
    return 0
  }
  [[ ! -d "${ROOTDIR}/${SUBDIR}" ]] && {
    logger_warn "subdirectory ${SUBDIR} of ${ROOTDIR} does not exist"
    cd "${ROOTDIR}" || return 1
    return 0
  }
  cd "${ROOTDIR}/${SUBDIR}" || return 1
}
