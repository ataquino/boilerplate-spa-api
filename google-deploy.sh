#!/bin/bash

set -e

codeship_google authenticate

echo "Setting default timezone $DEFAULT_ZONE"
gcloud config set compute/zone $DEFAULT_ZONE

echo "Setting default project"
gcloud config set project $GOOGLE_PROJECT_ID

gcloud container clusters get-credentials $KUBERNETES_APP_NAME

if ! gcloud container clusters list | grep $KUBERNETES_APP_NAME; then
  echo "Starting Cluster on GCE for $KUBERNETES_APP_NAME"
  gcloud container clusters create $$KUBERNETES_APP_NAME --num-nodes 3 --machine-type f1-micro;
fi

echo "Deploying"
kubectl apply -f $DEPLOYMENT_CONFIG

if ! kubectl get service | grep $SERVICE_NAME; then
  echo "Exposing ports"
  kubectl expose deployment $DEPLOYMENT_NAME --name=$SERVICE_NAME --type=LoadBalancer --port 80;
fi

echo "Listing services"
kubectl get service

echo "Listing pods"
kubectl get pods
