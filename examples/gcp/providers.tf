terraform {
  required_version = ">= 1.0"

  required_providers {
    google = {
      source  = "hashicorp/google"
      version = "~> 4.0"
    }
    kubernetes = {
      source  = "hashicorp/kubernetes"
      version = "~> 2.0"
    }
    helm = {
      source  = "hashicorp/helm"
      version = "~> 2.0"
    }
  }
}

provider "google" {
  project = "your-project-id"
  region  = var.region
}

provider "kubernetes" {
  config_path = "~/.kube/config" # Or use cluster_ca_certificate and token
}

provider "helm" {
  kubernetes {
    config_path = "~/.kube/config" # Or use cluster_ca_certificate and token
  }
}
