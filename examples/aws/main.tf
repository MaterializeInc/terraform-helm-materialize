locals {
  instances = [
    for instance in var.instance_configs : {
      name      = instance.name
      namespace = instance.namespace

      metadata_backend_url = format(
        "postgres://%s:%s@%s/%s?sslmode=require",
        instance.database_username,
        instance.database_password,
        instance.database_host,
        coalesce(instance.database_name, "${instance.name}_db")
      )

      persist_backend_url = format(
        "s3://%s/%s:serviceaccount:%s:%s",
        module.storage.bucket_name,
        var.environment,
        coalesce(instance.namespace, "materialize"),
        instance.name
      )

      cpu_request    = instance.cpu_request
      memory_request = instance.memory_request
      memory_limit   = instance.memory_limit
    }
  ]
}

module "materialize_operator" {
  source = "github.com/your-org/terraform-materialize-operator"

  namespace   = var.namespace
  environment = var.environment

  helm_values = {
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

  instances = local.instances
}

data "aws_region" "current" {}
data "aws_caller_identity" "current" {}
