resource "kubernetes_namespace" "materialize" {
  count = var.create_namespace ? 1 : 0

  metadata {
    name = var.namespace
  }
}

resource "kubernetes_secret" "metadata_backend" {
  metadata {
    name      = "${var.name}-materialize-backend"
    namespace = var.namespace
  }

  data = {
    metadata_backend_url = var.metadata_backend_url
    persist_backend_url  = var.persist_backend_url
  }

  depends_on = [
    kubernetes_namespace.materialize,
  ]
}

# The kubernetes_manifest resource is used to create Materialize instances
# It currently has a few limitations:
# - It requires the Kubernetes cluster to be running, otherwise it will fail to connect
# - It requires the Materialize operator to be installed in the cluster, otherwise it will fail
# Tracking issue:
# https://github.com/hashicorp/terraform-provider-kubernetes/issues/1775
resource "kubernetes_manifest" "materialize_instance" {
  field_manager {
    # force field manager conflicts to be overridden
    name            = "terraform"
    force_conflicts = true
  }

  manifest = {
    apiVersion = "materialize.cloud/v1alpha1"
    kind       = "Materialize"
    metadata = {
      name      = var.name
      namespace = var.namespace
    }
    spec = {
      environmentdImageRef = "materialize/environmentd:${var.environmentd_version}"
      backendSecretName    = kubernetes_secret.metadata_backend.metadata[0].name
      inPlaceRollout       = var.in_place_rollout
      requestRollout       = var.request_rollout
      forceRollout         = var.force_rollout
      environmentdResourceRequirements = {
        limits = {
          memory = coalesce(var.environmentd_memory_limit, var.environmentd_memory_request)
        }
        requests = {
          cpu    = var.environmentd_cpu_request
          memory = var.environmentd_memory_request
        }
      }
      balancerdResourceRequirements = {
        limits = {
          memory = coalesce(var.balancerd_memory_limit, var.balancerd_memory_request)
        }
        requests = {
          cpu    = var.balancerd_cpu_request
          memory = var.balancerd_memory_request
        }
      }
    }
  }

  wait {
    fields = {
      "status.resourceId" = ".*"
    }
  }

  depends_on = [
    kubernetes_secret.metadata_backend,
    kubernetes_namespace.materialize,
  ]
}

data "kubernetes_resource" "materialize_instance" {
  api_version = "materialize.cloud/v1alpha1"
  kind        = "Materialize"
  metadata {
    name      = var.name
    namespace = var.namespace
  }

  depends_on = [
    kubernetes_manifest.materialize_instance,
  ]
}
