locals {
  default_helm_values = {
    observability = {
      podMetrics = {
        enabled = true
      }
    }
    operator = {
      image = var.orchestratord_version == null ? {} : {
        tag = var.orchestratord_version
      },
      cloudProvider = {
        type   = "aws"
        region = data.aws_region.current.name
        providers = {
          aws = {
            enabled   = true
            accountID = data.aws_caller_identity.current.account_id
            iam = {
              roles = {
                environment = var.iam_role_arn
              }
            }
          }
        }
      }
    }
  }

  merged_helm_values = merge(local.default_helm_values, var.helm_values)

  instances = [
    for instance in var.instance_configs : {
      name          = instance.name
      namespace     = instance.namespace
      database_name = instance.database_name

      metadata_backend_url = format(
        "postgres://%s:%s@%s/%s?sslmode=require",
        var.database_config.username,
        var.database_config.password,
        var.database_config.host,
        coalesce(instance.database_name, instance.name)
      )

      persist_backend_url = format(
        "s3://%s/%s-%s:serviceaccount:%s:%s",
        module.storage.bucket_name,
        var.environment,
        instance.name,
        coalesce(instance.namespace, var.operator_namespace),
        instance.name
      )

      cpu_request      = instance.cpu_request
      memory_request   = instance.memory_request
      memory_limit     = instance.memory_limit
      in_place_rollout = instance.in_place_rollout
      request_rollout  = instance.request_rollout
      force_rollout    = instance.force_rollout
      license_key      = instance.license_key
    }
  ]
}

module "operator" {
  source = "github.com/MaterializeInc/terraform-helm-materialize?ref=v0.1.1"

  depends_on = [
    module.eks,
    module.database,
    module.storage
  ]

  namespace          = var.namespace
  environment        = var.environment
  operator_version   = var.operator_version
  operator_namespace = var.operator_namespace

  helm_values = local.merged_helm_values
  instances   = local.instances

  providers = {
    kubernetes = kubernetes
    helm       = helm
  }
}

data "aws_region" "current" {}
data "aws_caller_identity" "current" {}
