# Kubernetes CLI Toolset

Provides the following [Kubernetes](https://kubernetes.io/) cli toolset:

- kubectl **1.7.4** (with command completion)
- kubectx/kubens **0.3.1** (with command completion)
- istioctl **0.1.6** (with command completion)
- helm **2.6.0** (with command completion)

And the following utilities/tools:

- curl
- jq
- less
- vim

## Toolset

### kubectl

[Kubernetes](https://kubernetes.io/docs/concepts/overview/what-is-kubernetes/) is an open-source platform for automating deployment, scaling, and operations of application containers across clusters of hosts, providing container-centric infrastructure. Kubernetes is:

- **Portable**: public, private, hybrid, multi-cloud
- **Extensible**: modular, pluggable, hookable, composable
- **Self-healing**: auto-placement, auto-restart, auto-replication, auto-scaling

> [kubectl](https://kubernetes.io/docs/user-guide/kubectl-overview/) is a command line utility for running [commands](https://kubernetes.io/docs/user-guide/kubectl/v1.7/) against Kubernetes clusters. kubectl is configured with [command completion](https://kubernetes.io/docs/tasks/tools/install-kubectl/#on-linux-using-bash).

### kubectx/kubens

A kubectl [context](https://kubernetes.io/docs/tasks/access-application-cluster/authenticate-across-clusters-kubeconfig/) defines a named **cluster**, **user**, **namespace** tuple which is used to send requests to the specified cluster using the provided authentication info and namespace. Each of the three is optional; it is valid to specify a context with only one of **cluster**, **user**, **namespace**, or to specify none. Unspecified values, or named values that don’t have corresponding entries in the loaded kubeconfig will be replaced with the default.

> [kubectx](https://github.com/ahmetb/kubectx) is a command line utility to make it easier to work with kubectl contexts when managing multiple Kubernetes clusters. 

Kubernetes supports multiple virtual clusters backed by the same physical cluster. These virtual clusters are called [namespaces](https://kubernetes.io/docs/concepts/overview/working-with-objects/namespaces/).

> [kubens](https://github.com/ahmetb/kubectx) is a command line utility to make it easier to switch between Kubernetes namespaces.

### istioctl

[Istio](https://istio.io) is an open platform that provides a uniform way to connect, manage, and secure microservices. Istio supports managing traffic flows between microservices, enforcing access policies, and aggregating telemetry data, all without requiring changes to the microservice code. Istio gives you:

- Automatic load balancing for HTTP, gRPC, and TCP traffic.
- Fine-grained control of traffic behavior with rich routing rules, retries, failovers, and fault injection.
- A pluggable policy layer and configuration API supporting access controls, rate limits and quotas.
- Automatic metrics, logs, and traces for all traffic within a cluster, including cluster ingress and egress.
- Secure service-to-service authentication with strong identity assertions between services in a cluster.

> [istioctl](https://istio.io/docs/reference/commands/istioctl.html) is a command line utility to create, list, modify, and delete configuration resources in the [Istio](https://istio.io/) system. 

### helm

[Helm](https://docs.helm.sh/) is the package manager for Kubernetes. It is a tool that streamlines installing and managing Kubernetes applications. Think of it like apt/yum/homebrew for Kubernetes. 

> [helm](https://github.com/kubernetes/helm) is a tool for managing Helm Charts. Helm Charts are packages of pre-configured Kubernetes resources. Only the helm client is installed. You will need to install the tiller component into your Kubernetes cluster using `helm init`.

## Docker images

The Docker image is built on top of the `Ubuntu 17.10` base image to provide a full weight environment. It is available on DockerHub as:

- [paulbouwer/k8s-cli-toolset:0.3](https://hub.docker.com/r/paulbouwer/k8s-cli-toolset/)

### Run

Run the image as follows. Ensure that you mount your ~/.kube and ~/.helm folders on your host into the Docker container for the utilities to operate correctly.

Windows
```
PS> docker run -it --rm -v ${HOME}/.kube:/root/.kube -v ${HOME}/.helm:/root/.helm paulbouwer/k8s-cli-toolset:0.3
```

Linux/MacOS
```
$ docker run -it --rm -v ${HOME}/.kube:/root/.kube -v ${HOME}/.helm:/root/.helm paulbouwer/k8s-cli-toolset:0.3
```

### Build

If you'd like to build the image yourself, then you can do so as follows. The `build-arg` parameters provide values to the Docker image labels which follow the [Label Schema](http://label-schema.org/rc1/) convention.

Powershell
```
PS> docker build --no-cache --build-arg IMAGE_VERSION="0.3" --build-arg BUILD_DATE="$(Get-Date((Get-Date).ToUniversalTime()) -UFormat '%Y-%m-%dT%H:%M:%SZ')" --build-arg VCS_REF="$(git rev-parse HEAD)" -f Dockerfile -t "k8s-cli-toolset" .
```

Bash
```
$ docker build --no-cache --build-arg IMAGE_VERSION="0.3" --build-arg BUILD_DATE="`date -u +"%Y-%m-%dT%H:%M:%SZ"`" --build-arg VCS_REF="`git rev-parse HEAD`" -f Dockerfile -t "k8s-cli-toolset" .
```