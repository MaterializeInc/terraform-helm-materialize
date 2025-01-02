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
    name              = string
    namespace         = optional(string)
    database_name     = optional(string)
    database_username = string
    database_password = string
    database_host     = string
    cpu_request       = optional(string, "1")
    memory_request    = optional(string, "1Gi")
    memory_limit      = optional(string, "1Gi")
  }))
}

variable "gcp_service_account_email" {
  description = "Email of the GCP service account for workload identity"
  type        = string
}
