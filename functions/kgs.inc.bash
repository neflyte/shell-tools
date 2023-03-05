#!/usr/bin/env bash
#
# kgs.inc.bash -- Kubernetes secret utility
#
kgs() {
  # shellcheck source=../bootstrap/bootstrap.bash
  [[ "${__BOOTSTRAPPED:-0}" == "1" ]] || { . "${TOOLS_HOME}/bootstrap/bootstrap.bash" || return 1; }
  tools_inPath "${KUBECTL:-kubectl}" || return 1
  tools_inPath base64 || return 1
  [[ -z "${1}" ]] && {
    ${KUBECTL:-kubectl} get secrets
    return 0
  }
  local DECODEDPASS
  local PASSKEY="postgres-password"
  local ENCODEDPASS
  if [[ -n "${2}" ]]; then
    PASSKEY="${2}"
  fi
  ENCODEDPASS="$(${KUBECTL:-kubectl} get secret "${1}" -o jsonpath="{.data.${PASSKEY}}")"
  if [[ $? -eq 0 ]] && [[ -n "${ENCODEDPASS}" ]]; then
    DECODEDPASS="$(echo "${ENCODEDPASS}" | base64 -d)"
    if [[ $? -eq 0 ]] && [[ -n "${DECODEDPASS}" ]]; then
      echo "${DECODEDPASS}"
      return 0
    fi
  fi
  # try postgresql-password
  PASSKEY="postgresql-password"
  ENCODEDPASS="$(${KUBECTL:-kubectl} get secret "${1}" -o jsonpath="{.data.${PASSKEY}}")"
  if [[ $? -eq 0 ]] && [[ -n "${ENCODEDPASS}" ]]; then
    DECODEDPASS="$(echo "${ENCODEDPASS}" | base64 -d)"
    if [[ $? -eq 0 ]] && [[ -n "${DECODEDPASS}" ]]; then
      echo "${DECODEDPASS}"
      return 0
    fi
  fi
  # give raw output in any other case
  ${KUBECTL:-kubectl} get secret "${1}" -o yaml
}
