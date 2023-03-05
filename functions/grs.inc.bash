#!/usr/bin/env bash
#
# grs.inc.bash -- Git reset utility
#
grs() {
  # shellcheck source=../bootstrap/bootstrap.bash
  [[ "${__BOOTSTRAPPED:-0}" == "1" ]] || { . "${TOOLS_HOME}/bootstrap/bootstrap.bash" || return 1; }
  tools_inPath git || return 1
  local GITBR
  GITBR="$(gbr)" || return 1
  if [[ -z "${GITBR}" ]]; then
    return 1
  fi
	echo "o  hard resetting to origin/${GITBR}"
	git reset --hard "origin/${GITBR}"
}
