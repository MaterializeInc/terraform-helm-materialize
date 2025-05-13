locals {
  name_prefix = "${var.namespace}-${var.environment}"

  format_env_vars = { for idx, instance in var.instances : instance.name =>
    length(lookup(instance, "environmentd_extra_env", [])) > 0 ? [
      {
        name = "MZ_SYSTEM_PARAMETER_DEFAULT"
        value = join(";", [
          for item in instance.environmentd_extra_env :
          "${item.name}=${item.value}"
        ])
      }
    ] : null
  }

  format_env_args = {
    for instance in var.instances : instance.name =>
    length(lookup(instance, "environmentd_extra_args", [])) > 0 ? [
      for item in instance.environmentd_extra_args :
      "--system-parameter-default=${item.name}=${item.value}"
    ] : null
  }
}

resource "kubernetes_namespace" "materialize" {
  metadata {
    name = var.operator_namespace
  }
}

resource "kubernetes_namespace" "monitoring" {
  metadata {
    name = var.monitoring_namespace
  }
}

resource "kubernetes_namespace" "instance_namespaces" {
  for_each = toset(compact([for instance in var.instances : instance.namespace if instance.namespace != null]))

  metadata {
    name = each.key
  }
}

resource "helm_release" "materialize_operator" {
  name      = local.name_prefix
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

resource "kubernetes_secret" "materialize_backends" {
  for_each = { for idx, instance in var.instances : instance.name => instance }

  metadata {
    name      = "${each.key}-materialize-backend"
    namespace = coalesce(each.value.namespace, var.operator_namespace)
  }

  data = {
    metadata_backend_url = each.value.metadata_backend_url
    persist_backend_url  = each.value.persist_backend_url
    license_key          = each.value.license_key == null ? "" : each.value.license_key
  }

  depends_on = [
    kubernetes_namespace.instance_namespaces,
    kubernetes_namespace.materialize,
  ]
}

# The kubernetes_manifest resource is used to create Materialize instances
# It currently has a few limitations:
# - It requires the Kubernetes cluster to be running, otherwise it will fail to connect
# - It requires the Materialize operator to be installed in the cluster, otherwise it will fail
# Tracking issue:
# https://github.com/hashicorp/terraform-provider-kubernetes/issues/1775
resource "kubernetes_manifest" "materialize_instances" {
  for_each = { for idx, instance in var.instances : instance.name => instance }
  field_manager {
    # force field manager conflicts to be overridden
    name            = "terraform"
    force_conflicts = true
  }

  manifest = {
    apiVersion = "materialize.cloud/v1alpha1"
    kind       = "Materialize"
    metadata = {
      name      = each.value.name
      namespace = coalesce(each.value.namespace, var.operator_namespace)
    }
    spec = {
      environmentdImageRef = "materialize/environmentd:${each.value.environmentd_version}"
      backendSecretName    = "${each.key}-materialize-backend"
      inPlaceRollout       = each.value.in_place_rollout
      requestRollout       = lookup(each.value, "request_rollout", null)
      forceRollout         = lookup(each.value, "force_rollout", null)

      environmentdExtraEnv  = lookup(local.format_env_vars, each.key, null)
      environmentdExtraArgs = lookup(local.format_env_args, each.key, null)

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
          memory = lookup(each.value, "balancer_memory_limit", "256Mi")
        }
        requests = {
          cpu    = lookup(each.value, "balancer_cpu_request", "100m")
          memory = lookup(each.value, "balancer_memory_request", "256Mi")
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
    helm_release.materialize_operator,
    kubernetes_secret.materialize_backends,
    kubernetes_namespace.instance_namespaces,
    kubernetes_job.db_init_job
  ]
}

data "kubernetes_resource" "materialize_instances" {
  for_each = { for idx, instance in var.instances : instance.name => instance }

  api_version = "materialize.cloud/v1alpha1"
  kind        = "Materialize"
  metadata {
    name      = each.value.name
    namespace = each.value.namespace
  }

  depends_on = [
    kubernetes_manifest.materialize_instances,
  ]
}

# Materialize does not currently create databases within the instances, so we need to create them ourselves
resource "kubernetes_job" "db_init_job" {
  for_each = { for idx, instance in var.instances : "${instance.name}-${instance.database_name}" => instance if lookup(instance, "create_database", true) }

  metadata {
    name      = replace("db-${each.value.database_name}", "_", "-")
    namespace = coalesce(each.value.namespace, var.operator_namespace)
  }

  spec {
    ttl_seconds_after_finished = 3600
    backoff_limit              = 5
    template {
      metadata {
        labels = {
          app = "init-db-${each.value.name}"
        }
      }
      spec {
        container {
          name  = "init-db"
          image = "postgres:${var.postgres_version}"

          command = [
            "/bin/sh",
            "-c",
            <<-EOT
            # Extract connection details and connect to postgres database
            export PGCONNECTION=$(echo $DATABASE_URL | sed 's|/[^/]*$|/postgres|')

            echo "Waiting for PostgreSQL to be ready..."
            until pg_isready -d $PGCONNECTION; do
              sleep 2
            done

            # Check if database exists
            if psql $PGCONNECTION -t -c "SELECT 1 FROM pg_database WHERE datname='${each.value.database_name}';" | grep -q 1; then
              echo "Database ${each.value.database_name} already exists."
            else
              echo "Creating database ${each.value.database_name}..."
              psql $PGCONNECTION -c "CREATE DATABASE ${each.value.database_name};"
              echo "Database ${each.value.database_name} created successfully."
            fi
            EOT
          ]

          env {
            name  = "DATABASE_URL"
            value = replace(each.value.metadata_backend_url, "/${basename(each.value.metadata_backend_url)}", "/postgres")
          }
          resources {
            limits = {
              cpu    = "200m"
              memory = "128Mi"
            }
            requests = {
              cpu    = "100m"
              memory = "64Mi"
            }
          }
        }

        restart_policy = "OnFailure"
      }
    }
  }

  wait_for_completion = true
}

# Install the metrics-server for monitoring
# Required for the Materialize Console to display cluster metrics
resource "helm_release" "metrics_server" {
  count = var.install_metrics_server ? 1 : 0

  name       = "${local.name_prefix}-metrics-server"
  namespace  = kubernetes_namespace.monitoring.metadata[0].name
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
