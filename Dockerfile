FROM ubuntu:17.10

ARG IMAGE_CREATE_DATE
ARG IMAGE_VERSION
ARG IMAGE_SOURCE_REVISION
ARG KUBECTL_VERSION=1.9.1
ARG KUBECTX_VERSION=0.4.0
ARG ISTIO_VERSION=0.4.0
ARG HELM_VERSION=2.7.2
ARG ARK_VERSION=0.6.0
ARG KUBE_PS1_VERSION=0.2.0 

# Metadata as defined in OCI image spec annotations - https://github.com/opencontainers/image-spec/blob/master/annotations.md
LABEL org.opencontainers.image.title="Kubernetes cli toolset" \
      org.opencontainers.image.description="Provides the following Kubernetes cli toolset - kubectl $KUBECTL_VERSION, kubectx/kubens $KUBECTX_VERSION, istioctl $ISTIO_VERSION, helm $HELM_VERSION, and ark $ARK_VERSION. Leverages kube-ps1 $KUBE_PS1_VERSION to provide the current Kubernetes context and namespace on the bash prompt." \
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
        jq \
        less \
        vim \
    && echo ". /etc/bash_completion" >> ~/.bashrc \
    && rm -rf /var/lib/apt/lists/* \
    && mkdir -p ~/k8s-prompt

WORKDIR /tmp/install-utils

# Install kubectl 
# License: Apache-2.0
RUN curl -LO https://storage.googleapis.com/kubernetes-release/release/v$KUBECTL_VERSION/bin/linux/amd64/kubectl \
    && chmod +x ./kubectl \
    && mv ./kubectl /usr/local/bin/kubectl \
    && echo "source <(kubectl completion bash)" >> ~/.bashrc

# Install kubectx/kubens
# License: Apache-2.0
RUN curl -L https://github.com/ahmetb/kubectx/archive/v$KUBECTX_VERSION.tar.gz | tar xz \
    && cd ./kubectx-$KUBECTX_VERSION \
    && mv kubectx kubens utils.bash /usr/local/bin/ \
    && chmod +x /usr/local/bin/kubectx \
    && chmod +x /usr/local/bin/kubens \
    && cat completion/kubectx.bash >> ~/.bashrc \
    && cat completion/kubens.bash >> ~/.bashrc \
    && cd ../ \
    && rm -fr ./kubectx-$KUBECTX_VERSION

# Install istioctl
# License: Apache-2.0
RUN curl -L https://github.com/istio/istio/releases/download/$ISTIO_VERSION/istio-$ISTIO_VERSION-linux.tar.gz | tar xz \
    && cd ./istio-$ISTIO_VERSION \
    && mv bin/istioctl /usr/local/bin/ \
    && chmod +x /usr/local/bin/istioctl \
    && cd ../ \
    && rm -fr ./istio-$ISTIO_VERSION \
    && echo "source <(istioctl completion)" >> ~/.bashrc

# Install helm
# License: Apache-2.0
RUN mkdir helm-$HELM_VERSION \
    && curl -L https://storage.googleapis.com/kubernetes-helm/helm-v$HELM_VERSION-linux-amd64.tar.gz | tar xz -C helm-$HELM_VERSION --strip-components 1 \
    && cd ./helm-$HELM_VERSION \
    && mv helm /usr/local/bin/ \
    && chmod +x /usr/local/bin/helm \
    && cd ../ \
    && rm -fr ./helm-$HELM_VERSION \
    && echo "source <(helm completion bash)" >> ~/.bashrc

# Install ark
# License: Apache-2.0
RUN mkdir ark-$ARK_VERSION \
    && curl -L https://github.com/heptio/ark/releases/download/v$ARK_VERSION/ark-v$ARK_VERSION-linux-amd64.tar.gz | tar xz \
    && mv ark /usr/local/bin/ \
    && chmod +x /usr/local/bin/ark

# Install kube-ps1
# License: Apache-2.0
COPY k8s-cli-ps1.sh /root/k8s-prompt/
RUN curl -L https://github.com/jonmosco/kube-ps1/archive/$KUBE_PS1_VERSION.tar.gz | tar xz \
    && cd ./kube-ps1-$KUBE_PS1_VERSION \
    && mv kube-ps1.sh ~/k8s-prompt/ \
    && chmod +x ~/k8s-prompt/*.sh \
    && rm -fr ./kube-ps1-$KUBE_PS1_VERSION \
    && echo "source ~/k8s-prompt/kube-ps1.sh" >> ~/.bashrc \
    && echo "source ~/k8s-prompt/k8s-cli-ps1.sh" >> ~/.bashrc \
    && echo "PROMPT_COMMAND=\"_kube_ps1_load && k8s_cli_ps1\"" >> ~/.bashrc 

RUN rm -fr /tmp/install-utils

WORKDIR /root
CMD bash