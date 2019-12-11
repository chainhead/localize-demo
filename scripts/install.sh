#!/bin/bash

# Create certificates and secrets
./certs.sh mutate sidecars

# Docker image for webhook server
docker build -t nsubrahm/webhook-server:0.0.0 ../webhook ../webhook/Dockerfile 
docker push nsubrahm/webhook-server:0.0.0

# Create k8s objects
# - Deployment and Service for webhook server
kubectl create -f ../yaml/webhook-deploy.yaml 
# - Webhook configuration
kubectl create -f ../yaml/mutatingWebhookConfiguration.yaml -n sidecars

kubectl label namespace sidecars webhook=enabled