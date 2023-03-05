#!/usr/bin/env bash
#
# minikube-update-docker-context.bash -- Update Docker's context configuration for Minikube
#
cleanup() {
  unset __CTX_ARG
  unset __DKR_CERT_PATH
  unset __DKR_HOST
  unset __SKIP_TLS_VERIFY
  unset __DKR_TLS_VERIFY
  unset __MINIKUBE_CTX
  unset __MINIKUBE_DOCKER_ENV
  unset __MINIKUBE_PROFILE
  unset __CTX_OP
}
trap exit ERR
trap cleanup EXIT
# shellcheck source=../bootstrap/bootstrap.bash
[ "${__BOOTSTRAPPED:-0}" -eq 1 ] || { . "${TOOLS_HOME}/bootstrap/bootstrap.bash" || exit 1; }
tools_inPath minikube || exit 1
tools_inPath docker || exit 1
__MINIKUBE_PROFILE=$(minikube profile) || __MINIKUBE_PROFILE="minikube"
__MINIKUBE_CTX=$(docker context ls -q | grep "${__MINIKUBE_PROFILE}") || __MINIKUBE_CTX=""
[ -z "${__MINIKUBE_CTX}" ] && __CTX_OP="create"
[ -n "${__MINIKUBE_CTX}" ] && __CTX_OP="update"
__MINIKUBE_DOCKER_ENV=$(minikube --profile="${__MINIKUBE_PROFILE}" docker-env | grep -Ev "^#.*$" | sed -E -e "s/export //g" -e 's/"//g') || {
  logger_error "error reading minikube docker-env; cannot continue"
  exit 1
}
__DKR_TLS_VERIFY=$(echo -n "${__MINIKUBE_DOCKER_ENV}" | grep DOCKER_TLS_VERIFY | cut -d= -f2) || {
  logger_error "error parsing DOCKER_TLS_VERIFY; cannot continue"
  exit 1
}
__SKIP_TLS_VERIFY=1
[ "${__DKR_TLS_VERIFY}" == "1" ] && __SKIP_TLS_VERIFY=0
__DKR_HOST=$(echo -n "${__MINIKUBE_DOCKER_ENV}" | grep DOCKER_HOST | cut -d= -f2) || {
  logger_error "error parsing DOCKER_HOST; cannot continue"
  exit 1
}
__DKR_CERT_PATH=$(echo -n "${__MINIKUBE_DOCKER_ENV}" | grep DOCKER_CERT_PATH | cut -d= -f2) || {
  logger_error "error parsing DOCKER_CERT_PATH; cannot continue"
  exit 1
}
__CTX_ARG="host=${__DKR_HOST},cert=${__DKR_CERT_PATH}/cert.pem,key=${__DKR_CERT_PATH}/key.pem,ca=${__DKR_CERT_PATH}/ca.pem,skip-tls-verify=${__SKIP_TLS_VERIFY}"
docker context ${__CTX_OP} "${__MINIKUBE_PROFILE}" --docker "${__CTX_ARG}" --description "Minikube - profile ${__MINIKUBE_PROFILE}" || {
  logger_error "error updating docker context for ${__MINIKUBE_PROFILE}"
  exit 1
}
