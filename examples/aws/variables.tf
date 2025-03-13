variable "materialize_instance_name" {
  description = "Name of the Materialize instance"
  type        = string
}

variable "materialize_instance_namespace" {
  description = "Namespace of the Materialize instance"
  type        = string
}

variable "database_username" {
  description = "Username to authenticate with the metadata backend database."
  type        = string
}

variable "database_password" {
  description = "Password to authenticate with the metadata backend database."
  type        = string
}

variable "database_host" {
  description = "Host address of the metadata backend database."
  type        = string
}

variable "database_name" {
  description = "Name of the metadata backend database."
  type        = string
}

variable "iam_role_arn" {
  description = "IAM role ARN for Materialize S3 access"
  type        = string
}

variable "helm_values" {
  description = "Additional Helm values to merge with defaults"
  type        = any
  default     = {}
}
