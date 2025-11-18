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
  default     = "v26.0.0" # META: helm-chart version
  nullable    = false
}

variable "helm_repository" {
  description = "Repository URL for the Materialize operator Helm chart. Leave empty if using local chart."
  type        = string
  default     = "https://materializeinc.github.io/materialize/"
}

variable "helm_chart" {
  description = "Chart name from repository or local path to chart. For local charts, set the path to the chart directory."
  type        = string
  default     = "materialize-operator"
}

variable "use_local_chart" {
  description = "Whether to use a local chart instead of one from a repository"
  type        = bool
  default     = false
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
    name                              = string
    namespace                         = optional(string)
    create_database                   = optional(bool, true)
    database_name                     = string
    metadata_backend_url              = string
    persist_backend_url               = string
    license_key                       = optional(string)
    external_login_password_mz_system = optional(string)
    authenticator_kind                = optional(string, "None")
    environmentd_version              = optional(string, "v26.0.0") # META: mz version
    environmentd_extra_env = optional(list(object({
      name  = string
      value = string
    })), [])
    environmentd_extra_args = optional(list(string), [])
    cpu_request             = optional(string, "1")
    memory_request          = optional(string, "1Gi")
    memory_limit            = optional(string, "1Gi")
    in_place_rollout        = optional(bool, true)
    request_rollout         = optional(string, "00000000-0000-0000-0000-000000000001")
    force_rollout           = optional(string, "00000000-0000-0000-0000-000000000001")
    balancer_memory_request = optional(string, "256Mi")
    balancer_memory_limit   = optional(string, "256Mi")
    balancer_cpu_request    = optional(string, "100m")
  }))
  default = []

  validation {
    condition = alltrue([
      for instance in var.instances :
      instance.request_rollout == null ||
      can(regex("^[0-9a-fA-F]{8}-[0-9a-fA-F]{4}-[0-9a-fA-F]{4}-[0-9a-fA-F]{4}-[0-9a-fA-F]{12}$", instance.request_rollout))
    ])
    error_message = "Request rollout must be a valid UUID in the format xxxxxxxx-xxxx-xxxx-xxxx-xxxxxxxxxxxx"
  }

  validation {
    condition = alltrue([
      for instance in var.instances :
      instance.force_rollout == null ||
      can(regex("^[0-9a-fA-F]{8}-[0-9a-fA-F]{4}-[0-9a-fA-F]{4}-[0-9a-fA-F]{4}-[0-9a-fA-F]{12}$", instance.force_rollout))
    ])
    error_message = "Force rollout must be a valid UUID in the format xxxxxxxx-xxxx-xxxx-xxxx-xxxxxxxxxxxx"
  }

  validation {
    condition = alltrue([
      for instance in var.instances :
      contains(["Password", "None"], instance.authenticator_kind)
    ])
    error_message = "Authenticator kind must be either 'Password' or 'None'"
  }

  validation {
    condition = alltrue([
      for instance in var.instances :
      (instance.authenticator_kind == "Password" && instance.external_login_password_mz_system != null)
      || (instance.authenticator_kind == "None" && instance.external_login_password_mz_system == null)
    ])
    error_message = "When authenticator_kind is 'Password', external_login_password_mz_system must be provided"
  }
}

variable "postgres_version" {
  description = "Postgres version to use for the metadata backend"
  type        = string
  default     = "15"
}
