#!/usr/bin/env bash
#
# base_name.inc.bash -- Pure-Bash version of basename
#
base_name() {
    # Usage: base_name "path" ["suffix"]
    local tmp
    local firstarg="${1}"
    local secarg="${2:-}"

    tmp=${firstarg%"${firstarg##*[!/]}"}
    tmp=${tmp##*/}
    tmp=${tmp%"${secarg/"$tmp"}"}

    printf '%s\n' "${tmp:-/}"
}
