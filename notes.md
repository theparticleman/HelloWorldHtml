# Prerequisites:
- k3d cli installed ([can be installed with brew](https://formulae.brew.sh/formula/k3d))
- kubectl installed (probably installed as part of [sc-dev](https://github.com/samcart/sc-dev))

# Initial Setup

## Create a new cluster:
`k3d cluster create staging`

## Ensure cluster was created successfully:
`k3d cluster list`
(the `staging` cluster should be in the list)

## Map host port 1234 to port 30001 inside k8s:
`k3d node edit k3d-staging-serverlb --port-add 1234:30001`

## Verify `kubectl` is using the correct context:
`kubectl config get-contexts`
(the `k3d-staging` cluster should have an * next to it)

# Simple Deployment and YAML Service Hello World

## Create a simple hello world deployment:
`kubectl create deployment hello-world --image=ghcr.io/theparticleman/helloworldhtml:main`

(Based on [this](https://k3d.io/v5.0.1/usage/exposing_services/))

## Create a service to map port 30001 inside k8s to port 80 on the deployment:
`kubectl apply -f hello-world-simple-service.yaml`

``` hello-world-simple-service.yaml
apiVersion: v1
kind: Service
metadata:
  labels:
    app: hello-world
  name: hello-world
spec:
  ports:
  - port: 80
    targetPort: 80
    nodePort: 30001
  type: NodePort
  selector:
    app: hello-world
```

## Verify deployment and service are working
`curl localhost:1234`

## Clean up
`kubectl delete -f hello-world-simple-service.yaml`

`kubectl delete deployment/hello-world`


# YAML Deployment and Service Hello World

## Create the deployment and service
`kubectl apply -f hello-world.yaml`

``` hello-world.yaml
apiVersion: apps/v1
kind: Deployment
metadata:
  name: hello-world
  namespace: default
spec:
  replicas: 1
  selector:
    matchLabels:
      hello-world: web
  template:
    metadata: 
      labels:
        hello-world: web
    spec:
      containers:
      - name: hello-world
        image: ghcr.io/theparticleman/helloworldhtml:main
        ports:
        - containerPort: 80
---
apiVersion: v1
kind: Service
metadata:
  name: hello-world-entrypoint
  namespace: default
spec:
  type: NodePort
  selector:
    hello-world: web
  ports:
  - port: 80
    targetPort: 80
    nodePort: 30001
```

## Verify deployment and service are working
`curl localhost:1234`

## Clean up
`kubectl delete -f hello-world.yaml`