#!/bin/bash
set -e

export PROJECT_ID="i-hexagon-438514-g4"
export REGION="us-central1"

echo "Enabling required services..."
gcloud services enable container.googleapis.com compute.googleapis.com

echo "Setting up GKE Cluster..."
gcloud container clusters create-auto online-boutique \
  --project=${PROJECT_ID} --region=${REGION}