#!/usr/bin/env bash
#
# trim_string.inc.bash -- Pure-Bash function to trim leading and trailing whitespace
#
trim_string() {
    # Usage: trim_string "   example   string    "
    : "${1#"${1%%[![:space:]]*}"}"
    : "${_%"${_##*[![:space:]]}"}"
    printf '%s\n' "$_"
}
