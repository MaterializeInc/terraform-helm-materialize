resource "kubernetes_namespace" "materialize" {
  metadata {
    name = var.operator_namespace
  }
}

resource "helm_release" "materialize_operator" {
  name      = "materialize-operator"
  namespace = kubernetes_namespace.materialize.metadata[0].name

  // Use repository and chart name only if not using local chart
  repository = var.use_local_chart ? null : var.helm_repository
  chart      = var.helm_chart
  version    = var.use_local_chart ? null : var.operator_version

  values = [
    yamlencode(var.helm_values)
  ]

  depends_on = [kubernetes_namespace.materialize]
}

# Install the metrics-server for monitoring
# Required for the Materialize Console to display cluster metrics
resource "kubernetes_namespace" "monitoring" {
  count = var.install_metrics_server ? 1 : 0

  metadata {
    name = var.monitoring_namespace
  }
}

resource "helm_release" "metrics_server" {
  count = var.install_metrics_server ? 1 : 0

  name       = "metrics-server"
  namespace  = kubernetes_namespace.monitoring[0].metadata[0].name
  repository = "https://kubernetes-sigs.github.io/metrics-server/"
  chart      = "metrics-server"
  version    = var.metrics_server_version

  # Common configuration values
  set {
    name  = "args[0]"
    value = "--kubelet-insecure-tls"
  }

  set {
    name  = "metrics.enabled"
    value = "true"
  }

  depends_on = [kubernetes_namespace.monitoring]
}
