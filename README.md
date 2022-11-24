# Bartholomew Site Template

This repository is a template for creating new [Bartholomew](https://github.com/fermyon/bartholomew) websites.

## Directory Structure:

- `config/site.toml`: The main configuration file for your site. You should edit this.
- `content/`: Your markdown files go in here.
- `scripts/` (advanced): If you want to write your owh Rhai scripts, they go here.
- `spin.toml`: The configuration file for the Spin application.
- `static/`: Static assets like images, CSS, and downloads go in here.
- `templates/`: Your handlebars templates go here. 

## Installation of Spin

To use Bartholomew, you will need to install [Spin](https://spin.fermyon.dev).
Once you have Wagi installed, you can continue setting up Bartholomew.

To start your website, run the following command from this directory:

```console
$ spin up --follow-all
spin up --follow-all
Serving HTTP on address http://127.0.0.1:3000
Available Routes:
  bartholomew: http://127.0.0.1:3000 (wildcard)
  fileserver: http://127.0.0.1:3000/static (wildcard)
```

Now you can point your web browser to `http://localhost:3000/` and see your new Bartholomew site.


## Running using WASM Containerd Shim and K3D

This approach lets you run you Bartholomew site in Kubernetes. The [Containerd WASM Shims](https://github.com/deislabs/containerd-wasm-shims/tree/main) from Deis Labs
makes this possible. 

I have lightly adapted their [Quickstart](https://github.com/deislabs/containerd-wasm-shims/blob/main/containerd-shim-spin-v1/quickstart.md), if you get lost
check back there.

### Pre-requisites
Before you begin, you need to have the following installed:

- [Docker](https://docs.docker.com/install/) version 4.13.1 (90346) or later with [containerd enabled](https://docs.docker.com/desktop/containerd/)
- [k3d](https://k3d.io/v5.4.6/#installation)
- [kubectl](https://kubernetes.io/docs/tasks/tools/#kubectl)

### Start and configure a k3d cluster

Start a k3d cluster with the wasm shims already installed:

```bash
k3d cluster create wasm-cluster --image ghcr.io/deislabs/containerd-wasm-shims/examples/k3d:v0.3.3 -p "8080:80@loadbalancer" --agents 1 --registry-create mycluster-registry:12345
```

This also starts up a local container registry for the cluster to use. Docker can get to it at: `localhost:12345` and inside deployment YAML it is at: `mycluster-registry:12345`.

Apply RuntimeClass for spin applications to use the spin wasm shim:

```bash
kubectl apply -f https://raw.githubusercontent.com/deislabs/containerd-wasm-shims/main/deployments/workloads/runtime.yaml
```

### Create a container image for the Site

Use `docker` to build the container image and push it to the k3d registry:

```bash
docker buildx build --platform=wasi/wasm -t localhost:12345/bart-shim .
docker push localhost:12345/bart-shim:latest
```

*If you restart the cluster you will need to re-push the docker image back into the cluster. The registry that K3D sets up looks like it is temporary.*


### Deploy the application

Deploy the application and confirm it is running:

```bash
kubectl apply -f workloads/workload.yaml
```

### Clean up

Remove the sample application:

```bash
kubectl delete -f workloads/workload.yaml
```

Delete the cluster:

```bash
k3d cluster delete wasm-cluster
```

## Helpful debugging commands:

### Get all log events

`kubectl get events  --all-namespaces`

### Get all the Pods / Containers

`kubectl get pods --all-namespaces`

## About the License

This repository uses CC0. To the greatest extent possible, you are free to use this content however you want.
You may relicense the code in this repository to your own satisfaction, including proprietary licenses.
