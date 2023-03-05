# shellcheck disable=SC2034
#
# constants.inc.bash -- Constants
#
[[ -z "${BOOTSTRAP_PATH}" ]] && { echo "*  this script needs to be bootstrapped"; exit 1; }
[[ -z "${BOOTSTRAP_LOGGER}" ]] && readonly BOOTSTRAP_LOGGER="${BOOTSTRAP_PATH}/logger.inc.bash"
[[ -z "${BOOTSTRAP_UTILS}" ]] && readonly BOOTSTRAP_UTILS="${BOOTSTRAP_PATH}/utils.inc.bash"
#
# Installation constants
[[ -z "${TOOLS_INSTALL_SIG}" ]] && readonly TOOLS_INSTALL_SIG="# Tools Init"
[[ -z "${TOOLS_INSTALL_SIG_REGEX}" ]] && readonly TOOLS_INSTALL_SIG_REGEX='^.*# Tools Init$'
[[ -z "${TOOLS_INSTALL_PROMPT_SIG}" ]] && readonly TOOLS_INSTALL_PROMPT_SIG="# Tools powerline prompt"
[[ -z "${TOOLS_INSTALL_PROMPT_SIG_REGEX}" ]] && readonly TOOLS_INSTALL_PROMPT_SIG_REGEX='^.*# Tools powerline prompt$'
#
declare -ri __CONSTANTS_DEFINED=1
