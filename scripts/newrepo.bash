#!/usr/bin/env bash
cleanup() {
  unset REPOURL
}
trap exit ERR
trap cleanup EXIT
# shellcheck source=../bootstrap/bootstrap.bash
[[ "${__BOOTSTRAPPED:-0}" -eq 1 ]] || { . "${TOOLS_HOME}/bootstrap/bootstrap.bash" || exit 1; }
tools_inPath svn || exit 1
REPOURL="svn://amy.ethereal.cc"
if [[ -z "${1}" ]]; then
	logger_error "no repo name specified"
	exit 1
fi
svn mkdir "${REPOURL}/${1}" -m "create repo root '${1}'"
svn mkdir "${REPOURL}/${1}/trunk" -m "create repo trunk '${1}/trunk'"
svn mkdir "${REPOURL}/${1}/branches" -m "create repo branches '${1}/branches'"
svn mkdir "${REPOURL}/${1}/tags" -m "create repo tags '${1}/tags'"
logger_info "done."
