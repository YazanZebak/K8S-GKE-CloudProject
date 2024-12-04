#!/bin/bash
set -e

export REGION="us-central1"

# Destroy Terraform Resources
cd terraform
terraform destroy -auto-approve

# Delete GKE Cluster
gcloud container clusters delete online-boutique --region=${REGION} --quiet
