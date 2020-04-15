k8s_cli_ps1() {
  [ -f "${KUBE_PS1_DISABLE_PATH}" ] && return

  export PS1=$'\n\e[0;37;100m k8s-cli \e[0;90;43m\UE0B0\e[0;90;43m ${KUBE_PS1_CONTEXT}/${KUBE_PS1_NAMESPACE} \e[0;33;44m\UE0B0\e[0;37;44m \w \e[0;34;40m\UE0B0\e[0;39m\n$ '
}
