#!/usr/bin/env bash
#
# gbr.inc.bash -- Git branch utility
#
gbr() {
  # shellcheck source=../bootstrap/bootstrap.bash
  [[ "${__BOOTSTRAPPED:-0}" == "1" ]] || { . "${TOOLS_HOME}/bootstrap/bootstrap.bash" || return 1; }
  tools_inPath git || return 1
  # get current branch name
  local ref
  ref="$(git symbolic-ref --short HEAD 2>/dev/null)"
  # get tag name or short unique hash
  [[ -z "${ref}" ]] && ref="$(git describe --tags --always 2>/dev/null)"
  [[ -n "${ref}" ]] || return 1 # not a git repo
  echo -n "${ref}"
}
