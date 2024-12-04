#!/bin/bash
set -e

# Deploy Application
kubectl apply -f ./k8s/kubernetes-manifests.yaml

# Wait for pods to be ready
echo "Waiting for pods to be ready..."
kubectl wait --for=condition=ready pod --all --timeout=600s

# Retrieve External IP
FRONTEND_IP=$(kubectl get service frontend-external -o jsonpath='{.status.loadBalancer.ingress[0].ip}')
echo "Application available at: http://${FRONTEND_IP}"

if [[ -z "${FRONTEND_IP}" ]]; then
    echo "Error: Unable to retrieve FRONTEND_IP."
    exit 1
fi

# Run Terraform for Load Generator VM
cd terraform
terraform init
terraform apply -auto-approve

# Fetch VM IP dynamically
LOAD_GENERATOR_IP=$(gcloud compute instances describe load-generator-vm \
    --zone us-central1-a \
    --format="get(networkInterfaces[0].accessConfigs[0].natIP)")

if [[ -z "${LOAD_GENERATOR_IP}" ]]; then
    echo "Error: Unable to retrieve LOAD_GENERATOR_IP."
    exit 1
fi


# Update inventory.ini
cd ../
sed "s/{{LOAD_GENERATOR_IP}}/${LOAD_GENERATOR_IP}/g" ./ansible/inventory.ini  > ./ansible/inventory_temp.ini
sed -i "s/{{FRONTEND_ADDR}}/${FRONTEND_IP}/g" ./ansible/inventory_temp.ini

# Run the Ansible playbook
ansible-playbook -i ./ansible/inventory_temp.ini ./ansible/playbook.yml
