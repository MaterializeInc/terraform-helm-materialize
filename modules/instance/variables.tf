variable "name" {
  description = "Name of the Materialize resource."
  type        = string
}

variable "namespace" {
  description = "Namespace for materialize resources."
  type        = string
}

variable "create_namespace" {
  description = "Whether to create the namespace for materialize resources."
  type        = bool
  default     = true
}

variable "metadata_backend_url" {
  description = "URL of CockroachDB of Postgresql metadata backend."
  type        = string
}

variable "persist_backend_url" {
  description = "URL of persistence blob storage backend."
  type        = string
}

variable "environmentd_version" {
  description = "Version of environmentd to install."
  type        = string
  default     = "v0.130.4"
}

variable "environmentd_cpu_request" {
  description = "Environmentd CPU resources to request."
  type        = string
  default     = "1"
}

variable "environmentd_memory_request" {
  description = "Environmentd memory resources to request."
  type        = string
  default     = "1Gi"
}

variable "environmentd_memory_limit" {
  description = "Environmentd memory resource limit. It is strongly recommended to match the request. If unset, it will match the request."
  type        = string
  default     = null
}

variable "balancerd_cpu_request" {
  description = "Balancerd CPU resources to request."
  type        = string
  default     = "100m"
}

variable "balancerd_memory_request" {
  description = "Balancerd memory resources to request."
  type        = string
  default     = "256Mi"
}

variable "balancerd_memory_limit" {
  description = "Balancerd memory resource limit. It is strongly recommended to match the request. If unset, it will match the request."
  type        = string
  default     = null
}

variable "in_place_rollout" {
  description = "Whether to replace Materialize pods in place."
  type        = bool
  default     = true
}

variable "request_rollout" {
  description = "UUID of a specific rollout of Materialize pods. Changing this will request a new rollout, but not start it. The specific value doesn't matter, just that it isn't all zeros and that it doesn't match prior rollouts."
  type        = string
  default     = "00000000-0000-0000-0000-000000000001"
  nullable    = false
  validation {
    condition     = can(regex("^[0-9a-fA-F]{8}-[0-9a-fA-F]{4}-[0-9a-fA-F]{4}-[0-9a-fA-F]{4}-[0-9a-fA-F]{12}$", var.request_rollout)) && var.request_rollout != "00000000-0000-0000-0000-000000000000"
    error_message = "Request rollout must be a valid UUID in the format xxxxxxxx-xxxx-xxxx-xxxx-xxxxxxxxxxxx, and not all zeros."
  }
}

variable "force_rollout" {
  description = "UUID of a requested rollout to begin rolling out."
  type        = string
  default     = "00000000-0000-0000-0000-000000000001"
  nullable    = false
  validation {
    condition     = can(regex("^[0-9a-fA-F]{8}-[0-9a-fA-F]{4}-[0-9a-fA-F]{4}-[0-9a-fA-F]{4}-[0-9a-fA-F]{12}$", var.force_rollout)) && var.force_rollout != "00000000-0000-0000-0000-000000000000"
    error_message = "Force rollout must be a valid UUID in the format xxxxxxxx-xxxx-xxxx-xxxx-xxxxxxxxxxxx, and not all zeros."
  }
}
