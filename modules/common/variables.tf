variable "operator_version" {
  description = "Version of the Materialize operator to install"
  type        = string
  default     = "v25.1.2"
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
