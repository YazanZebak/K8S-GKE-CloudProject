
# K8S-GKE-CloudProject

This project demonstrates deploying the "Online Boutique" demo application, a microservice-based application created by Google, on Google Kubernetes Engine (GKE). It also includes automated deployment of a load generator using Terraform and Ansible.



---

## Overview

The [**Online Boutique**](https://github.com/GoogleCloudPlatform/microservices-demo/) is a mock application simulating an online shop. It consists of 11 microservices, showcasing a cloud-native architecture. The application can be tested with a load generator to simulate real-world traffic.

---

## Prerequisites

1. **Google Cloud Platform (GCP)** account with a project set up.
2. **Tools**:
   - `gcloud` CLI
   - Terraform
   - Ansible
   - Docker
3. **SSH Key** for accessing the VM.

---

## Setup Instructions

### 1. Clone the Repository
```bash
git clone https://github.com/YazanZebak/K8S-GKE-CloudProject.git
cd K8S-GKE-CloudProject
```

### 2. Run the Setup Script
Specify your GCP project ID and region in the `setup.sh` script and execute it to configure the environment.
```bash
./setup.sh
```

### 3. Configure Terraform and Ansible
Update the following:

- **`terraform.main`**: Add your SSH key and username in the `user_keys` variable.
```hcl
variable "user_keys" {
  default = {
    your_username = "ssh-rsa AAAAB3.....YOUR_SSH_KEY"
  }
}

```

- **`inventory.ini`**: add new line with your useranme and key to your private key
```ini
{{LOAD_GENERATOR_IP}} ansible_user=your_username ansible_private_key_file=/path/to/ssh/private/key FRONTEND_ADDR={{FRONTEND_ADDR}}
```


### 4. Deploy the Application and Load Generator
Run the deployment script:
```bash
./deploy.sh
```

This script will:
- Deploy the Online Boutique application on GKE.
- Set up a load generator in a Google Compute Engine (GCE) VM.

---

## Testing the Deployment

### 1. Access the Application
- Use the IP address of the load balancer (`frontend-external`) to access the application in a web browser:
  ```
  http://<FRONTEND_IP>
  ```

### 2. Verify the Load Generator
- SSH into the VM:
  ```bash
  ssh -i /path/to/your/private-key <YOUR_USERNAME>@<LOAD_GENERATOR_IP>
  ```
- Check Docker logs to verify the load generator is running:
  ```bash
  docker logs <CONTAINER_ID>
  ```

### 3. Local Load Generator Deployment
- Use the provided Docker image to deploy the load generator locally make sure to specify the FRONTEND_ADDR so the load_generator works correctly.
```
docker run -d --name load-generator -e FRONTEND_ADDR="http://{{ frontend_addr }}" --network host yazanzk/loadgen_locust
```

---

## Clean-Up

To avoid incurring unnecessary costs, destroy the resources after completing your tests:
```bash
./destroy-all.sh
```

---

## Additional Notes

### Autopilot vs. Standard Mode in GKE
- **Autopilot Mode**: Simplifies resource management and ensures the cluster has sufficient resources for all workloads, but it is more expensive and less flexible.
- **Standard Mode**: Allows finer control over cluster resources. To deploy in standard mode, use the following node configuration:
  - Machine type: `e2-standard-2`
  - Number of nodes: `4`

---

## Technologies Used

- **GKE**: Hosts the Online Boutique application.
- **Terraform**: Provisions GCP resources.
- **Ansible**: Configures the load generator VM.
- **Docker**: Deploys the load generator.

---

## Results

- Access the Online Boutique via the frontend load balancer IP (Step 1: Deploying the original application in GKE).
- Test the load generator locally using Docker (Step 3: Deploying the load generator on a local machine).
- View logs and monitor the load generator on the VM (Step 4: Deploying automatically the load generator in Google Cloud).

