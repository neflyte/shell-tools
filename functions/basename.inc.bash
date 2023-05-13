#!/usr/bin/env bash
#
# basename.inc.bash -- Pure-Bash version of basename
#
basename() {
    # Usage: basename "path" ["suffix"]
    local tmp
    local firstarg="${1}"
    local secarg="${2:-}"

    tmp=${firstarg%"${firstarg##*[!/]}"}
    tmp=${tmp##*/}
    tmp=${tmp%"${secarg/"$tmp"}"}

    printf '%s\n' "${tmp:-/}"
}
