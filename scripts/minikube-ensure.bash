#!/usr/bin/env bash
#
# minikube-ensure.bash -- download and install minikube; assumes amd64 arch
#
cleanup() {
  unset __MK_VERSION
  unset __MK_PRESENT
  unset __MK_PATH
  unset __HAS_CURL
  unset __HAS_WGET
}
trap cleanup EXIT
declare -r __MK_VERSION="v1.14.2"
declare -r __MK_URL_PREFIX="https://github.com/kubernetes/minikube/releases/download"
declare -r __MK_BIN_PREFIX="minikube"
declare -r __CURL_OPTIONS="--silent --fail --location --retry 3"
declare -r __WGET_OPTIONS="--progress=none --tries=3"
# shellcheck source=../bootstrap/bootstrap.bash
[ "${__BOOTSTRAPPED:-0}" -eq 1 ] || { . "${TOOLS_HOME}/bootstrap/bootstrap.bash" || exit 1; }
# STEP 1: is minikube present?
declare __MK_PATH
__MK_PATH=$(type -p minikube 2>&1) || __MK_PATH=""
[ -z "${__MK_PATH}" ] && {
  # No minikube so we need to download it
  logger_info "minikube not found in \$PATH; will try to download it"
  # first, find a tool to download with...
  declare -i __HAS_CURL=0
  tools_inPath curl && __HAS_CURL=1 && logger_debug "found cURL"
  declare -i __HAS_WGET=0
  tools_inPath wget && __HAS_WGET=1 && logger_debug "found wget"
  [ ${__HAS_CURL} -eq 0 ] && [ ${__HAS_WGET} -eq 0 ] && {
    logger_error "could not find a tool to download with; looking for cURL or wget"
    exit 1
  }
  declare __MK_OS
  case ${OSTYPE} in
    linux*)
      __MK_OS="linux"
      ;;
    darwin*)
      __MK_OS="darwin"
      ;;
  esac
  declare __MK_BIN_NAME="${__MK_BIN_PREFIX}_${__MK_OS}_amd64"
  declare __MK_URL="${__MK_URL_PREFIX}/${__MK_VERSION}/${__MK_BIN_NAME}"
  declare __MK_TMP_BIN="/tmp/${__MK_BIN_NAME}.$$"
  [ $__HAS_CURL -eq 1 ] && {
    echo "\$ curl ${__CURL_OPTIONS} ${__MK_URL} > ${__MK_TMP_BIN}"
    curl "${__CURL_OPTIONS}" "${__MK_URL}" > "${__MK_TMP_BIN}" || {
      logger_error "error downloading ${__MK_URL} with cURL"
      exit 1
    }
  }
  [ $__HAS_WGET -eq 1 ] && {
    echo "\$ wget ${__WGET_OPTIONS} ${__MK_URL} > ${__MK_TMP_BIN}"
    wget "${__WGET_OPTIONS}" "${__MK_URL}" > "${__MK_TMP_BIN}" || {
      logger_error "error downloading ${__MK_URL} with wget"
      exit 1
    }
  }

}
