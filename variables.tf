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
  default     = "v0.127.1"
}

variable "helm_repository" {
  description = "Repository URL for the Materialize operator Helm chart"
  type        = string
  default     = "https://raw.githubusercontent.com/bobbyiliev/materialize/refs/heads/helm-chart-package/misc/helm-charts"
}

variable "helm_values" {
  description = "Values to pass to the Helm chart"
  type        = any
}

variable "cluster_endpoint" {
  description = "EKS cluster endpoint"
  type        = string
}

variable "cluster_ca_certificate" {
  description = "EKS cluster CA certificate"
  type        = string
}

variable "operator_namespace" {
  description = "Namespace for the Materialize operator"
  type        = string
  default     = "materialize"
}

variable "instances" {
  description = "Configuration for Materialize instances"
  type = list(object({
    name                 = string
    namespace            = optional(string)
    metadata_backend_url = string
    persist_backend_url  = string
    cpu_request         = optional(string, "1")
    memory_request      = optional(string, "1Gi")
    memory_limit        = optional(string, "1Gi")
  }))
  default = []
}

variable "postgres_version" {
  description = "Postgres version to use for the metadata backend"
  type        = string
  default     = "15"
}
