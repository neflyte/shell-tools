#!/usr/bin/env bash
#
# powerline.bash -- Powerline-like bash prompt; based on bash-powerline
#
POWERLINE_GIT=1    # git branch + status
POWERLINE_SVN=1    # svn revision + status
POWERLINE_MINIKUBE=0 # minikube profile
POWERLINE_KUBE=0   # active kubernetes context
POWERLINE_DOCKER=0 # active docker context
POWERLINE_TT=1     # timetracker status
__powerline() {
  # Colorscheme
  readonly RESET='\[\033[m\]'
  readonly COLOR_GREEN='\[\033[0;32m\]'     # green
  readonly COLOR_CWD='\[\033[0;94m\]'         # blue
  readonly COLOR_GIT='\[\033[0;36m\]'         # cyan
  readonly COLOR_SVN='\[\033[0;35m\]'         # magenta
  readonly COLOR_SUCCESS='\[\033[0;32m\]'     # green
  readonly COLOR_FAILURE='\[\033[0;31m\]'     # red
  readonly COLOR_BRIGHTBLACK='\[\033[0;90m\]' # bright black
  readonly COLOR_WHITE='\[\033[0;37m\]'       # white
  readonly COLOR_DKR='\[\033[0;37m\]'         # white
  readonly COLOR_KUBERNETES='\[\033[0;37m\]'  # white

  readonly SYMBOL_GIT_BRANCH=''
  readonly SYMBOL_GIT_MODIFIED='*'
  readonly SYMBOL_GIT_PUSH='↑'
  readonly SYMBOL_GIT_PULL='↓'

  if [[ -z "${PS_SYMBOL}" ]]; then
    case "${OSTYPE}" in
    darwin*)
      PS_SYMBOL=''
      if [[ -n "${XTERM_SHELL}" ]]; then
        PS_SYMBOL='$'
      fi
      ;;
    linux*|freebsd*)
      PS_SYMBOL='$'
      ;;
    *)
      PS_SYMBOL='%'
      ;;
    esac
    if [[ ${EUID} -eq 0 ]]; then
      PS_SYMBOL='#'
    fi
  fi

  __git_info() {
    if [[ ${POWERLINE_GIT} -eq 0 ]]; then
      return # disabled
    fi
    directoryinparent ".git" || return   # no .git directory in parent hierarchy
    hash git 2>/dev/null || return       # git not found
    local git_eng="env LANG=C git"       # force git output in English to make our work easier
    local ref

    # get current branch name
    ref="$(${git_eng} symbolic-ref --short HEAD 2>/dev/null)"

    if [[ -n "${ref}" ]]; then
      # prepend branch symbol
      ref="${SYMBOL_GIT_BRANCH}${ref}"
    else
      # get tag name or short unique hash
      ref="$(${git_eng} describe --tags --always 2>/dev/null)"
    fi

    if [[ -z "${ref}" ]]; then
      return # not a git repo
    fi

    local marks

    # scan first two lines of output from `git status`
    while IFS= read -r line; do
      if [[ ${line} =~ ^## ]]; then # header line
        [[ ${line} =~ ahead\ ([0-9]+) ]] && marks+=" ${SYMBOL_GIT_PUSH}${BASH_REMATCH[1]}"
        [[ ${line} =~ behind\ ([0-9]+) ]] && marks+=" ${SYMBOL_GIT_PULL}${BASH_REMATCH[1]}"
      else # branch is modified if output contains more lines after the header line
        marks="${SYMBOL_GIT_MODIFIED}${marks}"
        break
      fi
    done < <(${git_eng} status --porcelain --branch 2>/dev/null) # note the space between the two <

    # print the git branch segment without a trailing newline
    echo -n "${ref}${marks}"
  }

  __svn_info() {
    if [[ ${POWERLINE_SVN} -eq 0 ]]; then
      return # disabled
    fi
    directoryinparent ".svn" || return   # no .svn directory in parent hierarchy
    hash svn 2>/dev/null || return       # svn not found
    local svn_eng="env LANG=C svn"       # force svn output in English to make our work easier
    local svn_info
    local rev
    local relativeURL

    relativeURL="$(${svn_eng} info --show-item relative-url 2>/dev/null)"
    if [[ -n "${relativeURL}" ]]; then
      svn_info+="${relativeURL}"
      rev="$(${svn_eng} info --show-item revision 2>/dev/null)"
      if [[ -n "${rev}" ]]; then
        svn_info+="@${rev}"
      fi
      # look for changes
      local changectr=0
      while IFS= read -r line; do
        local changestat=${line:0:1}
        case ${changestat} in
        "A" | "C" | "D" | "M" | "R")
          changectr=$((changectr + 1))
          ;;
        esac
      done < <(${svn_eng} status -q 2>/dev/null)
      if [[ ${changectr} -gt 0 ]]; then
        svn_info+=" ${SYMBOL_GIT_MODIFIED}${changectr}"
      fi
    fi

    echo -n "${svn_info}"
  }

  __docker_info() {
    if [[ ${POWERLINE_DOCKER} -eq 0 ]]; then
      return
    fi
    hash docker 2>/dev/null || return # docker not found
    local dockercontext
    local ctxcount
    ctxcount=$(docker context ls -q | wc -l | tr -d ' ') || ctxcount=0
    if [[ ${ctxcount} -gt 0 ]]; then
      dockercontext="$(docker context ls --format '{{json .}}' | jq -Mr 'select(.Current == true) | .Name')" || dockercontext=""
    fi
    echo -n "${dockercontext}"
  }

  __kubernetes_info() {
    if [[ ${POWERLINE_KUBE} -eq 0 ]]; then
      return
    fi
    hash kubectl 2>/dev/null || return
    local kubectx=""
    local kubens=""
    if ! kubectx="$(kubectl config view -o jsonpath="{.current-context}")"; then
      kubectx=""
    fi
    if [[ -n "${kubectx}" ]]; then
      kubens=$(kubectl config view -o json | jq -Mr ".contexts[] | select(.name == \"${kubectx}\") | .context.namespace")
      if [[ "${kubens}" == "null" ]]; then
        kubens="(unset)"
      fi
      if [[ "${kubens}" != "" ]]; then
        kubectx+=" N:${kubens}"
      fi
    fi
    echo -n "${kubectx}"
  }

  __minikube_info() {
    if [[ ${POWERLINE_MINIKUBE} -eq 0 ]]; then
      return
    fi
    hash minikube 2>/dev/null || return
    local mkctx=""
    if ! mkctx="$(minikube profile)"; then
      mkctx=""
    fi
    echo -n "${mkctx}"
  }

  __timetracker_info() {
    if [[ ${POWERLINE_TT} -eq 0 ]]; then
      return
    fi
    hash timetracker 2>/dev/null || return
    local ttstatus
    ttstatus="$(timetracker s -s -o)"
    echo -n "${ttstatus}"
  }

  ps1() {
    # Check the exit code of the previous command and display different
    # colors in the prompt accordingly.
    local prevErrno=${?}
    local symbol="${COLOR_SUCCESS}"
    if [[ ${prevErrno} -ne 0 ]]; then
      symbol="${COLOR_FAILURE}"
    fi
    symbol+="${PS_SYMBOL}${RESET}"

    # Bash by default expands the content of PS1 unless promptvars is disabled.
    # We must use another layer of reference to prevent expanding any user
    # provided strings, which would cause security issues.
    # POC: https://github.com/njhartwell/pw3nage
    # Related fix in git-bash: https://github.com/git/git/blob/9d77b0405ce6b471cb5ce3a904368fc25e55643d/contrib/completion/git-prompt.sh#L324
    shopt -q promptvars
    local pvars=${?}

    local git
    __powerline_git_info="$(__git_info)"

    if [[ -z ${__powerline_git_info} ]]; then
      git=""
    else
      if [[ ${pvars} -eq 0 ]]; then
        git="${COLOR_GIT}\${__powerline_git_info}${RESET}"
      else
        git="${COLOR_GIT}${__powerline_git_info}${RESET}"
      fi
    fi

    local svn
    __powerline_svn_info="$(__svn_info)"
    if [[ -z ${__powerline_svn_info} ]]; then
      svn=""
    else
      if [[ ${pvars} -eq 0 ]]; then
        svn="${COLOR_SVN}\${__powerline_svn_info}${RESET}"
      else
        svn="${COLOR_SVN}${__powerline_svn_info}${RESET}"
      fi
    fi

    local dkr
    __powerline_docker_info="$(__docker_info)"
    if [[ -n "${__powerline_docker_info}" ]]; then
      if [[ ${pvars} -eq 0 ]]; then
        dkr="${COLOR_DKR}\${__powerline_docker_info}${RESET}"
      else
        dkr="${COLOR_DKR}${__powerline_docker_info}${RESET}"
      fi
    fi

    local kubectx
    __powerline_kube_info="$(__kubernetes_info)"
    if [[ -n "${__powerline_kube_info}" ]]; then
      if [[ ${pvars} -eq 0 ]]; then
        kubectx="${COLOR_WHITE}\${__powerline_kube_info}${RESET}"
      else
        kubectx="${COLOR_WHITE}${__powerline_kube_info}${RESET}"
      fi
    fi

    local minikubectx
    __powerline_minikube_info="$(__minikube_info)"
    if [[ -n "${__powerline_minikube_info}" ]]; then
      if [[ ${pvars} -eq 0 ]]; then
        minikubectx="${COLOR_WHITE}\${__powerline_minikube_info}${RESET}"
      else
        minikubectx="${COLOR_WHITE}${__powerline_minikube_info}${RESET}"
      fi
    fi

    local ttstatus
    __powerline_tt_info="$(__timetracker_info)"
    if [[ -n "${__powerline_tt_info}" ]]; then
      if [ ${pvars} -eq 0 ]; then
        ttstatus="\${__powerline_tt_info}${RESET}"
      else
        ttstatus="${__powerline_tt_info}${RESET}"
      fi
    fi

    local cwd="${COLOR_CWD}\w${RESET}"
    local userhost="${COLOR_BRIGHTBLACK}\u@\h${RESET}"

    local lineone
    if [[ -n "${VIRTUAL_ENV_PROMPT}" ]]; then
      lineone+="${COLOR_GREEN}${VIRTUAL_ENV_PROMPT}${RESET}"
    fi
    if [[ -n "${ttstatus}" ]]; then
      lineone+="T:${ttstatus} "
    fi
    if [[ -n "${dkr}" ]]; then
      lineone+="${COLOR_DKR}D:${dkr} "
    fi
    if [[ -n "${minikubectx}" ]]; then
      lineone+="${COLOR_KUBERNETES}M:${minikubectx} "
    fi
    if [[ -n "${kubectx}" ]]; then
      lineone+="${COLOR_KUBERNETES}K:${kubectx} "
    fi
    if [[ -n "${git}" ]]; then
      lineone+="${COLOR_GIT}G:${git} "
    fi
    if [[ -n "${svn}" ]]; then
      lineone+="${COLOR_SVN}S:${svn} "
    fi
    if [[ -n "${lineone}" ]]; then
      lineone+="\n"
    fi

    PS1="${RESET}${lineone}${userhost} ${cwd} ${symbol} "
  }

  PROMPT_COMMAND="ps1${PROMPT_COMMAND:+; $PROMPT_COMMAND}"
}
__powerline
unset __powerline
