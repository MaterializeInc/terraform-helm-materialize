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

variable "iam_role_arn" {
  description = "IAM role ARN for Materialize S3 access"
  type        = string
}
