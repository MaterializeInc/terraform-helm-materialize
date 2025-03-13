locals {
  default_helm_values = {
    observability = {
      podMetrics = {
        enabled = true
      }
    }
    operator = {
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
}

module "materialize_operator" {
  source = "github.com/MaterializeInc/terraform-helm-materialize//modules/common?ref=separate_materialize_cr"

  depends_on = [
    module.eks,
  ]

  helm_values = local.merged_helm_values

  providers = {
    kubernetes = kubernetes
    helm       = helm
  }
}

module "materialize_instance" {
  source = "github.com/MaterializeInc/terraform-helm-materialize//modules/instance?ref=separate_materialize_cr"

  depends_on = [
    module.eks,
    module.database,
    module.storage
  ]

  name      = var.materialize_instance_namespace,
  namespace = var.materialize_instance_name,

  metadata_backend_url = format(
    "postgres://%s:%s@%s/%s?sslmode=require",
    var.database_username,
    var.database_password,
    var.database_host,
    var.database_name,
  )

  persist_backend_url = format(
    "s3://%s/system:serviceaccount:%s:%s",
    module.storage.bucket_name,
    var.materialize_instance_namespace,
    var.materialize_instance_name,
  )

  providers = {
    kubernetes = kubernetes
  }
}

data "aws_region" "current" {}
data "aws_caller_identity" "current" {}
