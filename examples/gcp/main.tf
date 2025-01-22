locals {
  encoded_endpoint = urlencode("https://storage.googleapis.com")
  encoded_secret   = urlencode(module.storage.hmac_secret)

  instances = [
    for instance in var.instance_configs : {
      name          = instance.name
      namespace     = instance.namespace
      database_name = instance.database_name

      metadata_backend_url = format(
        "postgres://%s:%s@%s:5432/%s?sslmode=disable",
        var.database_config.username,
        var.database_config.password,
        module.database.private_ip,
        coalesce(instance.database_name, instance.name)
      )

      persist_backend_url = format(
        "s3://%s:%s@%s/materialize?endpoint=%s&region=%s",
        module.storage.hmac_access_id,
        local.encoded_secret,
        module.storage.bucket_name,
        local.encoded_endpoint,
        var.region
      )

      cpu_request    = instance.cpu_request
      memory_request = instance.memory_request
      memory_limit   = instance.memory_limit
    }
  ]
}

module "operator" {
  source = "github.com/MaterializeInc/terraform-helm-materialize?ref=v0.1.1"

  depends_on = [
    module.gke,
    module.database,
    module.storage
  ]

  namespace          = var.namespace
  environment        = var.environment
  operator_version   = var.operator_version
  operator_namespace = var.operator_namespace

  helm_values = {
    image = {
      tag = var.orchestratord_version
    }
    operator = {
      cloudProvider = {
        type   = "gcp"
        region = data.google_client_config.current.region
        providers = {
          gcp = {
            enabled = true
          }
        }
      }
    }
  }

  instances = local.instances

  providers = {
    kubernetes = kubernetes
    helm       = helm
  }
}

data "google_client_config" "current" {}
