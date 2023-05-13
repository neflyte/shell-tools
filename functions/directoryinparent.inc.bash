#!/usr/bin/env bash
#
# directoryinparent.inc.bash -- Check if the specified directory exists in the parent hierarchy
#
directoryinparent() {
    # shellcheck source=../bootstrap/bootstrap.bash
    [[ ${__BOOTSTRAPPED:-0} -eq 1 ]] || { . "${TOOLS_HOME}/bootstrap/bootstrap.bash" || exit 1; }
    [[ -z "${1}" ]] && {
      logger_error "desired directory must be specified"
      return 1
    }
    local directory="${1}"
    local startingPath="${PWD}"
    local currentDir="${startingPath}"
    while [[ "${currentDir}" != "/" ]] && [[ "${currentDir}" != "" ]]; do
      if [[ -d "${currentDir}/${directory}" ]]; then
        return 0
      fi
      currentDir=$(dir_name "${currentDir}")
    done
    return 1
}
