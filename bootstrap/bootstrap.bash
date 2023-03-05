#!/usr/bin/env bash
#
# bootstrap.bash -- Scripts/Tools Bootstrap Script
#
[[ -d "${TOOLS_HOME}" ]] || { echo "*  \$TOOLS_HOME not defined; cannot bootstrap"; exit 1; }
# CONSTANTS
[[ -z "${BOOTSTRAP_PATH}" ]] && readonly BOOTSTRAP_PATH="bootstrap"
[[ -z "${CONSTANTS_FILE}" ]] && readonly CONSTANTS_FILE="constants.inc.bash"
[[ -z "${CONSTANTS_PATH}" ]] && readonly CONSTANTS_PATH="${TOOLS_HOME}/${BOOTSTRAP_PATH}/${CONSTANTS_FILE}"
[[ -z "${TOOLCONFIG_PATH}" ]] && readonly TOOLCONFIG_PATH="${TOOLS_HOME}/config"
#
# Load constants
[[ -r "${CONSTANTS_PATH}" ]] || {
  echo "*  cannot find constants file ${CONSTANTS_PATH}; exiting"
  exit 1
}
# shellcheck source=constants.inc.bash
. "${CONSTANTS_PATH}"
#
# Load logger
# shellcheck source=logger.inc.bash
. "${TOOLS_HOME}/${BOOTSTRAP_LOGGER}"
#
# Load Utils
# shellcheck source=utils.inc.bash
. "${TOOLS_HOME}/${BOOTSTRAP_UTILS}"
#
# Set a flag to indicate we've bootstrapped
# shellcheck disable=SC2034
declare -ri __BOOTSTRAPPED=1
