#!/bin/sh
set -ex

namespace=testing
cluster=cluster

kubectl create -f ./manifests/crd.yaml || kubectl replace -f ./manifests/crd.yaml
kubectl delete --force namespace $namespace || true
kubectl create namespace $namespace

if [ -n "$1" ]; then
	make operator-docker
	minikube image rm operator:latest
	minikube image load operator:latest
fi

helm install operator ./charts/tidb-operator/ -n testing --set "operatorImage=operator:latest"
kubectl apply -f ./basic.yaml -n testing
#kubectl apply -f ./ap.yaml --namespace testing
