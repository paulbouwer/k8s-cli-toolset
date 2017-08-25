FROM ubuntu:17.10

ARG BUILD_DATE
ARG IMAGE_VERSION
ARG VCS_REF
ARG KUBECTL_VERSION=1.7.4
ARG KUBECTX_VERSION=0.3.1
ARG ISTIO_VERSION=0.1.6
ARG HELM_VERSION=2.6.0

# Metadata as defined at http://label-schema.org
LABEL maintainer="Paul Bouwer" \
      org.label-schema.schema-version="1.0" \
      org.label-schema.vendor="Paul Bouwer" \
      org.label-schema.name="Kubernetes CLI Toolset" \
      org.label-schema.version=$IMAGE_VERSION \
      org.label-schema.license="MIT" \
      org.label-schema.description="Provides the following Kubernetes cli toolset - kubectl $KUBECTL_VERSION (with command completion), kubectx/kubens $KUBECTX_VERSION, istioctl $ISTIO_VERSION, and helm $HELM_VERSION." \
      org.label-schema.build-date=$BUILD_DATE \
      org.label-schema.vcs-url="https://github.com/paulbouwer/k8s-cli-toolset.git" \
      org.label-schema.vcs-ref=$VCS_REF \ 
      org.label-schema.docker.cmd="docker run -it --rm -v \${HOME}/.kube:/root/.kube -v \${HOME}/.helm:/root/.helm paulbouwer/k8s-cli-toolset:$IMAGE_VERSION"

# Install dependencies
RUN apt-get update && apt-get install -y --no-install-recommends \
        bash-completion \
        ca-certificates \
        curl \
        less \
        vim \
    && echo ". /etc/bash_completion" >> ~/.bashrc \
    && rm -rf /var/lib/apt/lists/*

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

RUN rm -fr /tmp/install-utils

WORKDIR /root
CMD bash