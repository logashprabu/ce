terraform {
  # Here we configure the providers we need to run our configuration
  required_providers {
    google = {
      source = "hashicorp/google"
      version = "1.1.7"
    }
  }

  # With this backend configuration we are telling Terraform that the
  # created state should be saved in some Google Cloud Bucket with some prefix
  backend "gcs" {
    ## INSERT YOUR BUCKET HERE!!
    bucket = "jenkinstfbucket"
    prefix = "terraform/state"
    credentials = "https://storage.cloud.google.com/jenkinstfbucket/jenkins-gce.json"
  }
}

# We define the "google" provider with the project and the general region + zone
provider "google" {
  credentials = file("https://storage.cloud.google.com/jenkinstfbucket/jenkins-gce.json")
  ## INSERT YOUR PROJECT ID HERE!!
  project = "cis-training"
  region = "us-central1"
  zone = "us-central1-a"
}


# Enable the Compute Engine API
# Alternatively you can do this directly via the GCP GUI
resource "google_project_service" "compute" {
  ## INSERT YOUR PROJECT ID HERE!!
  project = "cis-training"
  service = "compute.googleapis.com"
  disable_on_destroy = false
}
# Enable the Cloud Resource Manager API
# Alternatively you can do this directly via the GCP GUI
resource "google_project_service" "cloudresourcemanager" {
  ## INSERT YOUR PROJECT ID HERE!!
  project = "cis-training"
  service = "cloudresourcemanager.googleapis.com"
  disable_on_destroy = false
}

# Here we define a very small compute instance
# The actual content of it isn't important its just here for show-case purposes
resource "google_compute_instance" "default" {
  name = "terraform-test-instance"
  machine_type = "e2-micro"
  zone = "us-central-a"

  boot_disk {
    initialize_params {
      image = "debian-cloud/debian-9"
    }
  }

  network_interface {
    network = "aditya-public-vpc-test"
  }

  # Before we can create a compute instance we have to enable the the Compute API
  depends_on = [
    google_project_service.cloudresourcemanager,
    google_project_service.compute]
}
