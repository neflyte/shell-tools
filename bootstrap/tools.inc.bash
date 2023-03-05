#!/usr/bin/env bash
#
# tools.inc.bash -- bootstrap dependent tools
#
[ "${__BOOTSTRAPPED:-0}" -eq 1 ] || { . "${TOOLS_HOME}/bootstrap/bootstrap.bash" || exit 1; }
#
# look for configs in tool directory; create the config directory if it does not exist
[ -d "${TOOLCONFIG_PATH}" ] || {
  mkdir -p "${TOOLCONFIG_PATH}" || {
    logger_error "could not create tool config directory '${TOOLCONFIG_PATH}'"
    exit 1
  }
}

#
# find one of cURL or wget
declare -i __HAS_CURL=0
tools_inPath curl && __HAS_CURL=1 && logger_debug "found cURL"
declare -i __HAS_WGET=0
tools_inPath wget && __HAS_WGET=1 && logger_debug "found wget"
[ ${__HAS_CURL} -eq 0 ] && [ ${__HAS_WGET} -eq 0 ] && {
  logger_error "could not find a tool to download with; looking for cURL or wget"
  exit 1
}
