#
# utils.inc.bash -- Utility functions
#
[ "${__CONSTANTS_DEFINED:-0}" -eq 1 ] || { echo "*  this script must be bootstrapped"; exit 1; }
tools_inPath() {
  if [[ -z "${1}" ]]; then
    return 1
  fi
  type -p "${1}" &>/dev/null || {
    logger_error "did not find '${1}' in the \$PATH"
    return 1
  }
}
