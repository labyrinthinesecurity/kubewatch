**kubewatch** is a Kubernetes watcher that publishes notification to available collaboration hubs/notification channels. Run it in your k8s cluster, and you will get event notifications through webhooks.

The reasons for this fork are aimed at software supply chain security. Here are the main drivers:
 - to dispense with non-essential images (bitnami's image is not used) and stick to vanilla Alpine Linux
 - to get rid of tarballs I don't trust (my images only contains Alpine packages, Go packages and the kubewatch compiled from source code)
 - to deploy kubewatch as a daemonset, i.e. to have one pod run on each of my Kubernetes cluster nodes
 - to pull the image from a private repository, not from docker hub

<p align="center">
  <img src="./docs/kubewatch-logo.jpeg">
</p>

<p align="center">
  <img src="https://img.shields.io/badge/License-Apache%202.0-blue.svg">
</p>

# Build


## Build the builder...

This will build **alpinego:latest**, an image that contains all necessary dev elements to compile the kubewatch agent.

```
git clone https://github.com/labyrinthinesecurity/kubewatch.git
cd kubewatch
docker build -f Dockerfile.builder -t alpinego:latest .
```

## Compile kubewatch from source

Based on **alpinego:latest**, the following command will compile the kubewatch agent and place it into **kubewatch:latest**

```
docker build -t kubewatch:latest .
```

## Push kubewatch:latest to your registry

Note: replace **myregistry.azurecr.io** with the name of your private registry

```
docker tag kubewatch:latest myregistry.azurecr.io/kubewatch:latest
docker push myregistry.azurecr.io/kubewatch:latest
```

# Run

## Prepare cluster

First things first, ensure your cluster has permissions to pull images from your private registry.

## Customize deployment files

### ConfigMap

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

### DeamonSet

Edit **02-kubewatch-daemonset.yaml** to set the name of your private registry and change the **imagePullPolicy** to your liking:

```
      containers:
      - image: myregistry.azurecr.io/kubewatch:latest
        imagePullPolicy: Always
```

## Apply configuration
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

