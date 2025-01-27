variable "namespace" {
  description = "Namespace prefix for all resources"
  type        = string
}

variable "environment" {
  description = "Environment name"
  type        = string
}

variable "operator_version" {
  description = "Version of the Materialize operator to install"
  type        = string
  default     = "v25.1.0"
}

variable "helm_repository" {
  description = "Repository URL for the Materialize operator Helm chart"
  type        = string
  default     = "https://materializeinc.github.io/materialize/"
}

variable "helm_values" {
  description = "Values to pass to the Helm chart"
  type        = any
}

variable "operator_namespace" {
  description = "Namespace for the Materialize operator"
  type        = string
  default     = "materialize"
}

variable "monitoring_namespace" {
  description = "Namespace for monitoring resources"
  type        = string
  default     = "monitoring"
}

variable "metrics_server_version" {
  description = "Version of metrics-server to install"
  type        = string
  default     = "3.12.2"
}

variable "install_metrics_server" {
  description = "Whether to install the metrics-server"
  type        = bool
  default     = true
}

variable "instances" {
  description = "Configuration for Materialize instances"
  type = list(object({
    name                 = string
    namespace            = optional(string)
    database_name        = string
    metadata_backend_url = string
    persist_backend_url  = string
    environmentd_version = optional(string, "v0.130.1")
    cpu_request          = optional(string, "1")
    memory_request       = optional(string, "1Gi")
    memory_limit         = optional(string, "1Gi")
  }))
  default = []
}

variable "postgres_version" {
  description = "Postgres version to use for the metadata backend"
  type        = string
  default     = "15"
}
