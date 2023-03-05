#!/usr/bin/env bash
#
# gco.inc.bash -- Git checkout utility
#
gco() {
  # shellcheck source=../bootstrap/bootstrap.bash
  [[ "${__BOOTSTRAPPED:-0}" == "1" ]] || { . "${TOOLS_HOME}/bootstrap/bootstrap.bash" || return 1; }
  tools_inPath git || return 1
  local CURRENTBR
  local NEWBRANCH
  # calculate current branch/tag
	CURRENTBR="$(git symbolic-ref --short HEAD 2>/dev/null)"
	# if no branch, try tag
	if [[ ${?} -ne 0 ]] || [[ -z "${CURRENTBR}" ]]; then
		CURRENTBR=$(git describe --tags --always 2>/dev/null)
	fi
	# if no tag, it's not a repo; quit
	if [[ ${?} -ne 0 ]] || [[ -z "${CURRENTBR}" ]]; then
		echo "*  could not find a git repo in the current directory!"
		return 1
	fi
	if [[ -z "${1}" ]]; then
		# display current branch/tag
		echo "o  current branch/tag: ${CURRENTBR}"
	elif [[ "${1}" == "-" ]]; then
		# change to the branch/tag we were previously on
		if [[ -z "${LASTGITBRANCH}" ]]; then
			echo "*  no previous git branch set; cannot switch back"
			return 1
		fi
		NEWBRANCH="${LASTGITBRANCH}"
		export LASTGITBRANCH="${CURRENTBR}"
		echo "o  ${CURRENTBR} --> ${NEWBRANCH}"
		git checkout "${NEWBRANCH}"
		return ${?}
	else
		# we want to change branch/tag; save the current value
		export LASTGITBRANCH="${CURRENTBR}"
		echo "o  ${CURRENTBR} --> ${1}"
		git checkout "${1}"
		return ${?}
	fi
}
