#!/usr/bin/env bash
#
# minikube-config.bash -- Minikube configuration script
#
cleanup() {
  unset __CONFIG_YAML
  unset __CPUS
  unset __SYSCTL_CPU
  unset __NCPUS
  unset __MEMORY
  unset __MEMSIZE
  unset __SYSCTL_MEM
}
trap cleanup EXIT
# shellcheck source=../bootstrap/bootstrap.bash
[ "${__BOOTSTRAPPED:-0}" -eq 1 ] || { . "${TOOLS_HOME}/bootstrap/bootstrap.bash" || exit 1; }
tools_inPath minikube || exit 1
tools_inPath sysctl || exit 1
tools_inPath jq || exit 1
tools_inPath yq || exit 1 # python-yq @ https://github.com/kislyuk/yq
# VM Driver
case "${OSTYPE}" in
  darwin*)
    __VM_DRIVER="hyperkit"
    ;;
  linux*)
    __VM_DRIVER="kvm2"
    ;;
  windows*)
    __VM_DRIVER="hyperv"
    ;;
  freebsd*)
    __VM_DRIVER="virtualbox"
    ;;
  *)
    logger_error "unknown OS ${OSTYPE}; defaulting to 'virtualbox' for 'vm-driver'"
    __VM_DRIVER="virtualbox"
    ;;
esac
logger_debug "__VM_DRIVER=${__VM_DRIVER}"
__CONFIG_YAML=$(minikube config view) || {
  logger_error "error reading minikube configuration"
  exit 1
}
# CPUs
__CPUS=$(echo -n "${__CONFIG_YAML}" | yq '.[] | select(.cpus) | .cpus') || __CPUS=""
[ -z "${__CPUS}" ] && {
  [[ $OSTYPE == linux* ]] && {
    __NCPUS=$(grep -ac processor /proc/cpuinfo) || __NCPUS=1
  }
  __SYSCTL_CPU=""
  case $OSTYPE in
    darwin*|freebsd*)
      __SYSCTL_CPU="hw.ncpu"
      ;;
  esac
  [ -n "${__SYSCTL_CPU}" ] && {
     __NCPUS=$(sysctl -n ${__SYSCTL_CPU}) || {
      logger_error "error reading sysctl ${__SYSCTL_CPU}"
      exit 1
    }
    logger_debug "__NCPUS=${__NCPUS}"
  }
  __CPUS=${__NCPUS}
  [ "${__NCPUS}" -gt 1 ] && __CPUS=$(( __NCPUS / 2 ))
}
logger_debug "__CPUS=${__CPUS}"
# Memory
__MEMORY=$(echo -n "${__CONFIG_YAML}" | yq '.[] | select(.memory) | .memory') || __MEMORY=""
[ -z "${__MEMORY}" ] && {
  [[ $OSTYPE == linux* ]] && {
    __MEMSIZE=$(grep -a MemTotal /proc/meminfo | sed -E -e 's/MemTotal:[ ]+([0-9]+) kB/\1/') || __MEMSIZE=0
    __MEMSIZE=$(( __MEMSIZE * 1000 ))
  }
  __SYSCTL_MEM=""
  case $OSTYPE in
    darwin*)
      __SYSCTL_MEM="hw.memsize"
      ;;
    freebsd*)
      __SYSCTL_MEM="hw.physmem"
      ;;
  esac
  [ -n "${__SYSCTL_MEM}" ] && {
    logger_debug "__SYSCTL_MEM=${__SYSCTL_MEM}"
    __MEMSIZE=$(sysctl -n ${__SYSCTL_MEM}) || {
      logger_error "error reading sysctl ${__SYSCTL_MEM}"
      exit 1
    }
  }
  # logger_debug "__MEMSIZE=${__MEMSIZE}"
  __MEMORY=$(( __MEMSIZE / 1000000 / 2 ))
}
logger_debug "__MEMORY=${__MEMORY}"
