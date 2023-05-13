#!/usr/bin/env bash
#
# dir_name.inc.bash -- Pure-Bash version of dirname
#
dir_name() {
    # Usage: dir_name "path"
    local tmp=${1:-.}
    [[ $tmp != *[!/]* ]] && {
        printf '/\n'
        return
    }
    tmp=${tmp%%"${tmp##*[!/]}"}
    [[ $tmp != */* ]] && {
        printf '.\n'
        return
    }
    tmp=${tmp%/*}
    tmp=${tmp%%"${tmp##*[!/]}"}
    printf '%s\n' "${tmp:-/}"
}
