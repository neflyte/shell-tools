#!/usr/bin/env bash
#
# install.bash - Scripts/Tools Installer
#
banner() {
  echo -e "${0} -- Scripts/Tools Installer\n--"
}
errhandler() {
  echo "*  error ${?}; exiting"
}
cleanup() {
  unset __TOOLS_HOME_WAS_SET
  unset BOOTSTRAP
  unset __TOOLS_WERE_INSTALLED
  unset __TOOLS_INIT_LINE
  unset __TOOLS_PROMPT_INIT_LINE
}
trap errhandler ERR
trap cleanup EXIT
#
# CONSTANTS
BOOTSTRAP="bootstrap/bootstrap.bash"
#
# MAIN PROGRAM
banner
[[ -r "${BOOTSTRAP}" ]] || {
  echo "*  cannot read ${BOOTSTRAP}; exiting"
  exit 1
}
__TOOLS_HOME_WAS_SET=0
[[ -z "${TOOLS_HOME}" ]] && TOOLS_HOME="${PWD}" && __TOOLS_HOME_WAS_SET=1
# shellcheck source=bootstrap/bootstrap.bash
. "${BOOTSTRAP}" || {
  echo "*  unable to bootstrap; cannot install tools"
  exit 1
}
[[ "${__TOOLS_HOME_WAS_SET}" -eq 1 ]] && unset TOOLS_HOME
# Look for tools we'll need to make this all work
tools_inPath grep || exit 1
# Check that we're running in Bash v4+
[[ "${BASH_VERSINFO[0]:-0}" -lt 4 ]] && {
  logger_error "tools require bash v4 or newer"
  exit 1
}
__TOOLS_WERE_INSTALLED=0
# Look for our init code in ${HOME}/.bashrc
[[ ! -r "${HOME}/.bashrc" ]] && {
  logger_error "cannot find ${HOME}/.bashrc"
  exit 1
}
__TOOLS_INIT_LINE="$(grep -E -a "${TOOLS_INSTALL_SIG_REGEX}" "${HOME}/.bashrc")" || __TOOLS_INIT_LINE=""
[[ -n "${__TOOLS_INIT_LINE}" ]] && {
  logger_info "tools are already installed in ${HOME}/.bashrc"
}
[[ -z "${__TOOLS_INIT_LINE}" ]] && {
  # Construct the init line
  # shellcheck disable=SC2089
  __TOOLS_INIT_LINE="[ -r \"${PWD}/init.bash\" ] && . \"${PWD}/init.bash\" \"${PWD}\" ${TOOLS_INSTALL_SIG}"
  # Append the init line to the end of .bashrc
  echo -e "\n${__TOOLS_INIT_LINE}" >>"${HOME}/.bashrc" || {
    logger_error "error writing tools init command to ${HOME}/.bashrc"
    exit 1
  }
  __TOOLS_WERE_INSTALLED=1
  logger_info "installed tools init command into ${HOME}/.bashrc"
}
# Ensure scripts are executable
[[ -d "${PWD}/scripts" ]] && find "${PWD}/scripts" -type f -name "*.bash" -exec chmod +x {} \;
# Check for and install the powerline prompt if desired
[[ -n "${1}" ]] && [[ "${1}" == "prompt" ]] && {
  # Check for the powerline prompt
  __TOOLS_PROMPT_INIT_LINE=$(grep -E -a "${TOOLS_INSTALL_PROMPT_SIG_REGEX}" "${HOME}/.bashrc") || __TOOLS_PROMPT_INIT_LINE=""
  [[ -n "${__TOOLS_PROMPT_INIT_LINE}" ]] && {
    logger_info "powerline prompt is already installed in ${HOME}/.bashrc"
  }
  [[ -z "${__TOOLS_PROMPT_INIT_LINE}" ]] && {
    # Construct the init line
    # shellcheck disable=SC2089
    __TOOLS_PROMPT_INIT_LINE="[ -n \"\${TOOLS_HOME}\" ] && [ -r \"\${TOOLS_HOME}/shellext/powerline.bash\" ] && . \"\${TOOLS_HOME}/shellext/powerline.bash\" # Tools powerline prompt"
    # Append the init line to the end of .bashrc
    echo -e "\n${__TOOLS_PROMPT_INIT_LINE}" >>"${HOME}/.bashrc" || {
      logger_error "error writing tools powerline prompt command to ${HOME}/.bashrc"
      exit 1
    }
    __TOOLS_WERE_INSTALLED=1
    logger_info "installed tools powerline prompt command into ${HOME}/.bashrc"
  }
}
# Tell the user to reload the shell if we installed anything
[[ "${__TOOLS_WERE_INSTALLED}" -eq 1 ]] && logger_info "** Please start a new shell to use the tools **"
# done.
echo "done."
