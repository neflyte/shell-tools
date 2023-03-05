#!/usr/bin/env bash
#
# findport.inc.bash -- FreeBSD port locator
#
findport() {
  [[ $OSTYPE =~ freebsd.* ]] || { echo "*  findport() only runs on FreeBSD"; return 1; }
  # shellcheck source=../bootstrap/bootstrap.bash
  [[ "${__BOOTSTRAPPED:-0}" == "1" ]] || { . "${TOOLS_HOME}/bootstrap/bootstrap.bash" || return 1; }
  [[ -z "${1}" ]] && {
    logger_info "usage: findport <glob>"
    return 0
  }
  [[ -n "${1}" ]] && find /usr/ports -maxdepth 3 -type d -name "${1}" -print
}
