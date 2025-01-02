terraform {
  required_version = ">= 1.0"

  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.0"
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

provider "aws" {
  region = "us-west-2" # Change to your desired region
}

provider "kubernetes" {
  config_path = "~/.kube/config" # Or use cluster_ca_certificate and token
}

provider "helm" {
  kubernetes {
    config_path = "~/.kube/config" # Or use cluster_ca_certificate and token
  }
}
