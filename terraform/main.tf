# Configure the Google Cloud provider
provider "google" {
  project = "i-hexagon-438514-g4"
  region  = "us-central1"
  zone    = "us-central1-a"
}

variable "user_keys" {
  default = {
    alzebak_yazan = "ssh-rsa AAAAB3NzaC1yc2EAAAADAQABAAABAQDp/OgWGETEErcNgeOOxDkSx3hcBUaLKYLQihB0G/lK1VIeMB3by9Xe7U1uc3Th3XAbdc0vGkKzV/o7UNM1R7oMN+R9L2ghgFtewQPAucOKrFcOTaB/9cXkWAsQuczP2DSIRdsPpalP2gd0vcrDLXQxfNcVPh6c/PznLxsIdDw4JgTt1memifrC0MYZhxG3QrhGXj2UMCMCjMHCy9aTp6YATiRiIR2rVJvY6WdBHz1xIg81TTEJ5k98/wR0+V4HSkW29JNZKu4YqYYEu4VHY+lImYVH89gvU5TyL80RvDAhQzEyXiQBWqk5kPlI8Sv6VtqEZBh+dr3GwzqSI0Mq0fhD r@LAPTOP-HFH5PB12"
  }
}

# Define a GCE instance
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
    access_config {
      # This gives the VM an external IP
    }
  }


  metadata = {
    "ssh-keys" = join("\n", [for user, key in var.user_keys : "${user}:${key}"])
  }

  tags = ["http-server", "https-server"]
}


# Output the instance's external IP
output "instance_ip" {
  value = google_compute_instance.load_generator.network_interface[0].access_config[0].nat_ip
}


