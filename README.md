My reasons for this fork are aimed at software supply chain security. Here are the drivers:
 - to dispense with non-essential images (bitnami's image is not used) and stick to vanilla Ubuntu 20.04
 - to get rid of tarballs I don't trust (my Dockerfile only contains debian packages and the kubewatch compiled from source code)
 - to deploy kubewatch as a daemonset, i.e. to have one pod run on each of my Kubernetes cluster nodes
 - to pull the image from a private repository, not from docker hub

<p align="center">
  <img src="./docs/kubewatch-logo.jpeg">
</p>


[![Build Status](https://travis-ci.org/bitnami-labs/kubewatch.svg?branch=master)](https://travis-ci.org/bitnami-labs/kubewatch) [![Go Report Card](https://goreportcard.com/badge/github.com/bitnami-labs/kubewatch)](https://goreportcard.com/report/github.com/bitnami-labs/kubewatch) [![GoDoc](https://godoc.org/github.com/bitnami-labs/kubewatch?status.svg)](https://godoc.org/github.com/bitnami-labs/kubewatch) [![License](https://img.shields.io/badge/License-Apache%202.0-blue.svg)](https://github.com/bitnami-labs/kubewatch/blob/master/LICENSE)

**kubewatch** is a Kubernetes watcher that currently publishes notification to available collaboration hubs/notification channels. Run it in your k8s cluster, and you will get event notifications through webhooks.

# Build

## Go compiler and environment variables

```
sudo snap install go
export GOPATH=/usr/local/go/bin
export PATH="$PATH:/usr/local/go/bin"
```

## Compile kubewatch from sources
```
git clone https://github.com/labyrinthinesecurity/kubewatch.git
cd kubewatch
go build
```

## Build and push image 

Note: replace **myregistry.azurecr.io** with the name of your private registry

```
docker build -t kubewatch:latest .
docker tag kubewatch:latest myregistry.azurecr.io/kubewatch:latest
docker push myregistry.azurecr.io/kubewatch:latest
```

## Run kubewatch in cluster

### Customize deployment files

Edit **01-kubewatch-configmap.yaml** and toggle the resources you want to monitor. You will see that, by default, only pod events are being tracked:

```
    resource:
      deployment: false
      replicationcontroller: false
      replicaset: false
      daemonset: false
      services: false
      pod: true
      node: false
      job: false
      persistentvolume: false
      namespace: false
      secret: false
      ingress: false
```

Set the URL of the webhook to send events to (if necessary):

```
      webhook:
        url: "https://myazurefunction.azurewebsites.net/api/myEndpoint"
```

Edit **02-kubewatch-daemonset.yaml** to set the name of your private registry and change the **imagePullPolicy** to your liking:

```
      containers:
      - image: myregistry.azurecr.io/kubewatch:latest
        imagePullPolicy: Always
```

### apply configuration
create clusterwide readOnly service account and 'monitoring' namespace:
```
kubectl apply -f 00-kubewatch-service-account.yaml
```
ingest configMap data
```
kubectl apply -f 01-kubewatch-configmap.yaml
```
deploy kubewatch as a daemonset in the monitoring namespace
```
kubectl apply -f 02-kubewatch-daemonset.yaml
```

