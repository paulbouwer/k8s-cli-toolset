k8s_cli_ps1() {
  [ -f "${KUBE_PS1_DISABLE_PATH}" ] && return

  local CLI="\[\033[0;37;100m\]"
  local CONTEXT="\[\033[0;37;44m\]"
  local DEFAULT="\[\033[0;39m\]"

  export PS1="\n${CLI} k8s-cli ${CONTEXT} ${KUBE_PS1_CONTEXT}/${KUBE_PS1_NAMESPACE} ${DEFAULT} \w\n$ "
}
