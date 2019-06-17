FROM ubuntu:18.10

ARG IMAGE_CREATE_DATE
ARG IMAGE_VERSION
ARG IMAGE_SOURCE_REVISION
ARG KUBECTL_VERSION=1.14.3
ARG KUBECTX_VERSION=0.6.3
ARG ISTIO_VERSION=1.1.8
ARG LINKERD_VERSION=2.3.2
ARG HELM_VERSION=2.14.1
ARG KUBE_PS1_VERSION=0.7.0 

# Metadata as defined in OCI image spec annotations - https://github.com/opencontainers/image-spec/blob/master/annotations.md
LABEL org.opencontainers.image.title="Kubernetes cli toolset" \
      org.opencontainers.image.description="Provides the following Kubernetes cli toolset - kubectl $KUBECTL_VERSION, kubectx/kubens $KUBECTX_VERSION, istioctl $ISTIO_VERSION, linkerd $LINKERD_VERSION, and helm $HELM_VERSION. Leverages kube-ps1 $KUBE_PS1_VERSION to provide the current Kubernetes context and namespace on the bash prompt." \
      org.opencontainers.image.created=$IMAGE_CREATE_DATE \
      org.opencontainers.image.version=$IMAGE_VERSION \
      org.opencontainers.image.authors="Paul Bouwer" \
      org.opencontainers.image.url="https://hub.docker.com/r/paulbouwer/k8s-cli-toolset/" \
      org.opencontainers.image.documentation="https://github.com/paulbouwer/k8s-cli-toolset" \
      org.opencontainers.image.vendor="Paul Bouwer" \
      org.opencontainers.image.licenses="MIT" \
      org.opencontainers.image.source="https://github.com/paulbouwer/k8s-cli-toolset.git" \
      org.opencontainers.image.revision=$IMAGE_SOURCE_REVISION 

# Install dependencies and create dirs
RUN apt-get update && apt-get install -y --no-install-recommends \
        bash-completion \
        ca-certificates \
        curl \
        git \
        jq \
        less \
        vim \
    && echo ". /etc/bash_completion" >> ~/.bashrc \
    && rm -rf /var/lib/apt/lists/* \
    && mkdir -p ~/completions \
    && mkdir -p ~/k8s-prompt

WORKDIR /tmp/install-utils

# Install kubectl 
# License: Apache-2.0
RUN curl -LO https://storage.googleapis.com/kubernetes-release/release/v$KUBECTL_VERSION/bin/linux/amd64/kubectl \
    && chmod +x ./kubectl \
    && mv ./kubectl /usr/local/bin/kubectl \
    && kubectl completion bash > ~/completions/kubectl.completion \ 
    && echo "source ~/completions/kubectl.completion" >> ~/.bashrc

# Install kubectx/kubens
# License: Apache-2.0
RUN curl -L https://github.com/ahmetb/kubectx/archive/v$KUBECTX_VERSION.tar.gz | tar xz \
    && cd ./kubectx-$KUBECTX_VERSION \
    && mv kubectx kubens /usr/local/bin/ \
    && chmod +x /usr/local/bin/kubectx \
    && chmod +x /usr/local/bin/kubens \
    && cat completion/kubectx.bash >> ~/completions/kubectx.completion \
    && cat completion/kubens.bash >> ~/completions/kubens.completion \
    && echo "source ~/completions/kubectx.completion" >> ~/.bashrc \
    && echo "source ~/completions/kubens.completion" >> ~/.bashrc \
    && cd ../ \
    && rm -fr ./kubectx-$KUBECTX_VERSION

# Install linkerd
# License: Apache-2.0
RUN curl -LO https://github.com/linkerd/linkerd2/releases/download/stable-$LINKERD_VERSION/linkerd2-cli-stable-$LINKERD_VERSION-linux \
    && mv ./linkerd2-cli-stable-$LINKERD_VERSION-linux /usr/local/bin/linkerd \
    && chmod +x /usr/local/bin/linkerd

# Install istioctl
# License: Apache-2.0
RUN curl -L https://github.com/istio/istio/releases/download/$ISTIO_VERSION/istio-$ISTIO_VERSION-linux.tar.gz | tar xz \
    && cd ./istio-$ISTIO_VERSION \
    && mv bin/istioctl /usr/local/bin/ \
    && chmod +x /usr/local/bin/istioctl \
    && cd ../ \
    && rm -fr ./istio-$ISTIO_VERSION \
    && istioctl collateral --bash -o ~/completions \
    && mv ~/completions/istioctl.bash ~/completions/istioctl.completion \
    && echo "source ~/completions/istioctl.completion" >> ~/.bashrc
 
# Install helm
# License: Apache-2.0
RUN mkdir helm-$HELM_VERSION \
    && curl -L https://storage.googleapis.com/kubernetes-helm/helm-v$HELM_VERSION-linux-amd64.tar.gz | tar xz -C helm-$HELM_VERSION --strip-components 1 \
    && cd ./helm-$HELM_VERSION \
    && mv helm /usr/local/bin/ \
    && chmod +x /usr/local/bin/helm \
    && cd ../ \
    && rm -fr ./helm-$HELM_VERSION \
    && helm completion bash > ~/completions/helm.completion \
    && echo "source ~/completions/helm.completion" >> ~/.bashrc

# Install kube-ps1
# License: Apache-2.0
COPY k8s-cli-ps1.sh /root/k8s-prompt/
RUN curl -L https://github.com/jonmosco/kube-ps1/archive/v$KUBE_PS1_VERSION.tar.gz | tar xz \
    && cd ./kube-ps1-$KUBE_PS1_VERSION \
    && mv kube-ps1.sh ~/k8s-prompt/ \
    && chmod +x ~/k8s-prompt/*.sh \
    && rm -fr ./kube-ps1-$KUBE_PS1_VERSION \
    && echo "source ~/k8s-prompt/kube-ps1.sh" >> ~/.bashrc \
    && echo "source ~/k8s-prompt/k8s-cli-ps1.sh" >> ~/.bashrc \
    && echo "PROMPT_COMMAND=\"_kube_ps1_update_cache && k8s_cli_ps1\"" >> ~/.bashrc 

RUN rm -fr /tmp/install-utils \
    && echo "alias k=kubectl" >> ~/.bashrc \
    && echo "complete -o default -F __start_kubectl k" >> ~/.bashrc

WORKDIR /workspace
CMD bash