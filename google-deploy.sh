#!/bin/bash

set -e

codeship_google authenticate

echo "Setting default timezone $DEFAULT_ZONE"
gcloud config set compute/zone $DEFAULT_ZONE

echo "Setting default project"
gcloud config set project $GOOGLE_PROJECT_ID

if ! gcloud container clusters list | grep $KUBERNETES_APP_NAME; then
  echo "Starting Cluster on GCE for $KUBERNETES_APP_NAME"
  gcloud container clusters create $KUBERNETES_APP_NAME \
    --num-nodes 3 \
    --machine-type f1-micro;
else
  gcloud container clusters get-credentials $KUBERNETES_APP_NAME
fi

echo "Creating configurations"
if kubectl get configmap | grep 'api-config'; then
  kubectl delete configmap api-config;
fi

kubectl create configmap api-config \
  --from-literal=NODE_ENV=$NODE_ENV \
  --from-literal=PORT=$PORT;

if kubectl get secret | grep 'api-secrets'; then
  kubectl delete secret api-secrets;
fi

kubectl create secret generic api-secrets \
  --from-literal=TOKEN_SECRET=$TOKEN_SECRET

echo "Deploying"
kubectl apply -f $DEPLOYMENT_CONFIG

if ! kubectl get service | grep $SERVICE_NAME; then
  echo "Exposing ports"
  kubectl expose deployment $DEPLOYMENT_NAME \
    --name=$SERVICE_NAME \
    --type=LoadBalancer \
    --port=80 \
    --target-port=$PORT;
fi

echo "Listing services"
kubectl get service

echo "Listing pods"
kubectl get pods

echo "Teardown"
#gcloud container clusters delete $KUBERNETES_APP_NAME --quiet
