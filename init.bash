#!/usr/bin/env bash
#
# init.bash -- Scripts/Tools Environment Init
#
[ -n "${1}" ] || { echo "*  this script should not be invoked manually"; return 1; }
[ -d "${1}" ] || { echo "*  invalid directory specified"; return 1; }
export TOOLS_HOME="${1}"
#
# Functions
[ -z "${TOOLS_FUNCTIONS_PATH}" ] && readonly TOOLS_FUNCTIONS_PATH="${TOOLS_HOME}/functions"
[ -d "${TOOLS_FUNCTIONS_PATH}" ] && {
  for FUNCTION_DEF in "${TOOLS_FUNCTIONS_PATH}"/*.inc.bash; do
    # shellcheck disable=SC1090
    [ -r "${FUNCTION_DEF}" ] && . "${FUNCTION_DEF}"
  done
}
#
# Aliases
[ -z "${TOOLS_ALIASES_FILE}" ] && readonly TOOLS_ALIASES_FILE="aliases.bash"
[ -z "${TOOLS_ALIASES_PATH}" ] && readonly TOOLS_ALIASES_PATH="${TOOLS_HOME}/aliases/${TOOLS_ALIASES_FILE}"
# shellcheck source=aliases/aliases.bash
[ -r "${TOOLS_ALIASES_PATH}" ] && { . "${TOOLS_ALIASES_PATH}"; }
#
# Scripts
[ -z "${TOOLS_SCRIPTS_PATH}" ] && readonly TOOLS_SCRIPTS_PATH="${TOOLS_HOME}/scripts"
[ -d "${TOOLS_SCRIPTS_PATH}" ] && {
  for SCRIPT in "${TOOLS_SCRIPTS_PATH}"/*.bash; do
    SCRIPT_NAME="$(basename "${SCRIPT}")"
    # shellcheck disable=SC2139
    builtin alias "${SCRIPT_NAME/.bash/}"="${SCRIPT}"
  done
}
#
# Completion
[ -z "${TOOLS_COMPLETION_PATH}" ] && readonly TOOLS_COMPLETION_PATH="${TOOLS_HOME}/completion"
[ -d "${TOOLS_COMPLETION_PATH}" ] && [ -r "${TOOLS_COMPLETION_PATH}/completion.bash" ] && {
  . "${TOOLS_COMPLETION_PATH}/completion.bash"
}
