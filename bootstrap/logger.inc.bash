#
# logger.inc.bash -- Logger configuration
#
[[ -d "${TOOLS_HOME}" ]] || { echo "*  \$TOOLS_HOME not defined; cannot bootstrap"; exit 1; }
[[ "${__CONSTANTS_DEFINED:-0}" -eq 1 ]] || { echo "*  this script must be bootstrapped"; exit 1; }
[[ -z "${LOGGER_LIB}" ]] && readonly LOGGER_LIB="${TOOLS_HOME}/${BOOTSTRAP_PATH}/log4sh.inc.sh"
[[ -r "${LOGGER_LIB}" ]] || {
  echo "*  cannot find ${LOGGER_LIB}; unable to configure logging"
  return 1
}
# shellcheck source=log4sh.inc.sh
LOG4SH_CONFIGURATION='none' . "${LOGGER_LIB}"
log4sh_resetConfiguration
logger_setLevel DEBUG
logger_addAppender stdout
appender_setType stdout ConsoleAppender
appender_setLayout stdout PatternLayout
appender_setPattern stdout "%d [%p] %m"
appender_activateOptions stdout
