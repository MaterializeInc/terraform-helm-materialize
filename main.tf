locals {
  name_prefix = "${var.namespace}-${var.environment}"
}

resource "kubernetes_namespace" "materialize" {
  metadata {
    name = var.operator_namespace
  }
}

resource "kubernetes_namespace" "instance_namespaces" {
  for_each = toset(compact([for instance in var.instances : instance.namespace if instance.namespace != null]))

  metadata {
    name = each.key
  }
}

resource "helm_release" "materialize_operator" {
  name       = local.name_prefix
  namespace  = kubernetes_namespace.materialize.metadata[0].name
  repository = var.helm_repository
  chart      = "materialize-operator"
  version    = var.operator_version

  values = [
    yamlencode(var.helm_values)
  ]

  depends_on = [kubernetes_namespace.materialize]
}

resource "kubernetes_secret" "materialize_backends" {
  for_each = { for idx, instance in var.instances : instance.name => instance }

  metadata {
    name      = "${each.key}-materialize-backend"
    namespace = coalesce(each.value.namespace, var.operator_namespace)
  }

  data = {
    metadata_backend_url = each.value.metadata_backend_url
    persist_backend_url  = each.value.persist_backend_url
  }
}

# The kubernetes_manifest resource is used to create Materialize instances
# It currently has a few limitations:
# - It requires the Kubernetes cluster to be running, otherwise it will fail to connect
# - It requires the Materialize operator to be installed in the cluster, otherwise it will fail
# Tracking issue:
# https://github.com/hashicorp/terraform-provider-kubernetes/issues/1775
resource "kubernetes_manifest" "materialize_instances" {
  for_each = { for idx, instance in var.instances : instance.name => instance }

  manifest = {
    apiVersion = "materialize.cloud/v1alpha1"
    kind       = "Materialize"
    metadata = {
      name      = each.value.name
      namespace = coalesce(each.value.namespace, var.operator_namespace)
    }
    spec = {
      environmentdImageRef = "materialize/environmentd:${var.operator_version}"
      backendSecretName    = "${each.key}-materialize-backend"
      environmentdResourceRequirements = {
        limits = {
          memory = each.value.memory_limit
        }
        requests = {
          cpu    = each.value.cpu_request
          memory = each.value.memory_request
        }
      }
      balancerdResourceRequirements = {
        limits = {
          memory = "256Mi"
        }
        requests = {
          cpu    = "100m"
          memory = "256Mi"
        }
      }
    }
  }

  depends_on = [
    helm_release.materialize_operator,
    kubernetes_secret.materialize_backends,
    kubernetes_namespace.instance_namespaces
  ]
}

# Materialize does not currently create databases within the instances, so we need to create them ourselves
resource "kubernetes_job" "db_init_job" {
  for_each = { for idx, instance in var.instances : instance.database_name => instance }

  metadata {
    name      = replace("create-db-${each.key}", "_", "-")
    namespace = coalesce(each.value.namespace, var.operator_namespace)
  }

  spec {
    backoff_limit = 3
    template {
      metadata {
        labels = {
          app = "init-db-${each.key}"
        }
      }
      spec {
        container {
          name  = "init-db"
          image = "postgres:${var.postgres_version}"

          command = [
            "/bin/sh",
            "-c",
            "psql $DATABASE_URL -c \"CREATE DATABASE ${each.key};\""
          ]

          env {
            name  = "DATABASE_URL"
            value = each.value.metadata_backend_url
          }
        }

        restart_policy = "OnFailure"
      }
    }
  }
}
