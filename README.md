# K8S-GKE-CloudProject

## Step 1: Deploying the Original Application in GKE

Deployed the demo application in GKE Autopilot mode for ease of setup and automatic resource management. Verified application functionality using a web browser and logs from the load generator.

### **Steps**

1. **Cloned Repository**:
   ```bash
   git clone --depth 1 --branch v0 https://github.com/GoogleCloudPlatform/microservices-demo.git
   ```

2. **Set Up Environment**:
   ```bash
   export PROJECT_ID=i-hexagon-438514-g4
   export REGION=us-central1
   gcloud services enable container.googleapis.com
   ```

3. **Created Cluster**:
   ```bash
   gcloud container clusters create-auto online-boutique \
     --project=${PROJECT_ID} --region=${REGION}
   ```

4. **Deployed Application**:
   ```bash
   kubectl apply -f ./release/kubernetes-manifests.yaml
   ```

5. **Verified Deployment**:
   Checked pod statuses:
   ```bash
   kubectl get pods
   ```
   Retrieved external IP:
   ```bash
   kubectl get service frontend-external | awk '{print $4}'
   ```
   Monitored logs:
   ```bash
   kubectl logs -f loadgenerator-5865cffc45-rl8jd
   ```

6. **Accessed Application**:
   Confirmed availability at `http://34.70.128.103/` after all pods transitioned to `Running`.

7. **Cleaned Up**:
   Deleted the cluster:
   ```bash
   gcloud container clusters delete online-boutique \
     --project=${PROJECT_ID} --region=${REGION}
   ```

## Step 3: Deploying the Load Generator on a Local Machine

Deployed the load generator as a Docker container on a local machine to avoid consuming Kubernetes cluster resources. Encountered issues with failed requests due to incorrect configuration, which were resolved by updating the `FRONTEND_ADDR`.

### **Steps**

1. **Prepare Docker Image**:
   - Navigated to the `loadgenerator` directory.
   - Used the provided `Dockerfile` to build the image:
     ```bash
     docker build -t load-generator .
     ```

2. **Configure `FRONTEND_ADDR`**:
   - Updated the environment variable `FRONTEND_ADDR` in the Dockerfile to point to the external IP of the frontend service (`34.70.128.103` from Step 1).

3. **Run the Load Generator**:
   - Deployed the container:
     ```bash
     docker run -d --name load-generator load-generator
     ```

4. **Check Logs**:
   - Verified the container’s output:
     ```bash
     docker logs -f load-generator
     ```

## Step 4: Deploying the Load Generator Automatically in Google Cloud

### **Summary**

Deployed the load generator on a Google Compute Engine (GCE) virtual machine using Terraform for provisioning and Ansible for configuration, enabling automated and repeatable deployment.

### **Steps**

1. **Terraform Configuration**:
   - Defined a GCE instance in `main.tf`:
     ```hcl
     provider "google" {
       project = "i-hexagon-438514-g4"
       region  = "us-central1"
       zone    = "us-central1-a"
     }

     resource "google_compute_instance" "load_generator" {
       name         = "load-generator-vm"
       machine_type = "e2-medium"

       boot_disk {
         initialize_params {
           image = "projects/cos-cloud/global/images/family/cos-stable"
         }
       }

       network_interface {
         network = "default"
         access_config {}
       }

       tags = ["http-server", "https-server"]

       provisioner "local-exec" {
         command = "ansible-playbook -i inventory.ini playbook.yml"
       }
     }

     output "instance_ip" {
       value = google_compute_instance.load_generator.network_interface[0].access_config[0].nat_ip
     }
     ```
   - Ran Terraform commands:
     ```bash
     terraform init
     terraform plan
     terraform apply
     ```

2. **Ansible Configuration**:
   - Created an `inventory.ini` file:
     ```
     [load_generator]
     35.202.77.10 ansible_user=alzebak_yazan ansible_private_key_file=/home/r/.ssh/my-new-key
     ```
   - Wrote a playbook (`playbook.yml`):
     ```yaml
     - name: Configure and deploy the load generator
       hosts: load_generator
       become: true
       tasks:
         - name: Start Docker service
           service:
             name: docker
             state: started
             enabled: yes

         - name: Pull load generator Docker image
           command: docker pull yazanzk/load-generator

         - name: Run load generator container
           command: >
             docker run -d --name load-generator
             --network host
             yazanzk/load-generator
     ```
   - Ran the playbook:
     ```bash
     ansible-playbook -i inventory.ini playbook.yml
     ```

3. **Verified Deployment**:
   - Retrieved the external IP from Terraform output.
   - Confirmed load generator functionality via logs.
