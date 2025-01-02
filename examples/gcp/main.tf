# examples/gcp/main.tf

locals {
  encoded_endpoint = urlencode("https://storage.googleapis.com")
  encoded_secret   = urlencode(module.storage.hmac_secret)

  instances = [
    for instance in var.instance_configs : {
      name      = instance.name
      namespace = instance.namespace

      metadata_backend_url = format(
        "postgres://%s:%s@%s:5432/%s?sslmode=disable",
        instance.database_username,
        instance.database_password,
        instance.database_host,
        coalesce(instance.database_name, "${instance.name}_db")
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

module "materialize_operator" {
  source = "github.com/MaterializeInc/terraform-helm-materialize?ref=v0.1.0"

  namespace   = var.namespace
  environment = var.environment

  helm_values = {
    operator = {
      cloudProvider = {
        type   = "gcp"
        region = data.google_client_config.current.region
        providers = {
          gcp = {
            enabled   = true
            projectID = data.google_project.current.project_id
            workloadIdentity = {
              serviceAccount = var.gcp_service_account_email
            }
          }
        }
      }
    }
  }

  instances = local.instances
}

data "google_client_config" "current" {}
data "google_project" "current" {}
