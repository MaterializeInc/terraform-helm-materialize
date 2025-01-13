variable "namespace" {
  description = "Namespace prefix for all resources"
  type        = string
  default     = "myapp"
}

variable "environment" {
  description = "Environment name"
  type        = string
  default     = "prod"
}

variable "region" {
  description = "GCP region"
  type        = string
  default     = "us-central1"
}

variable "instance_configs" {
  description = "Configuration for Materialize instances"
  type = list(object({
    name                 = string
    namespace            = optional(string)
    database_name        = string
    metadata_backend_url = string
    persist_backend_url  = string
    cpu_request          = optional(string, "1")
    memory_request       = optional(string, "1Gi")
    memory_limit         = optional(string, "1Gi")
  }))
}

variable "gcp_service_account_email" {
  description = "Email of the GCP service account for workload identity"
  type        = string
}
