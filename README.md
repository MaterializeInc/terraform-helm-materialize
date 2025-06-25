# terraform-helm-materialize
Terraform module for installing the Materialize Helm chart

<!-- BEGIN_TF_DOCS -->
# Terraform module for installing the Materialize Helm Chart

This module installs the Materialize Helm chart into a Kubernetes cluster using Terraform.

> [!WARNING]
> This module is intended for demonstration/evaluation purposes as well as for serving as a template when building your own production deployment of Materialize.
>
> This module should not be directly relied upon for production deployments: **future releases of the module will contain breaking changes.** Instead, to use as a starting point for your own production deployment, either:
> - Fork this repo and pin to a specific version, or
> - Use the code as a reference when developing your own deployment.

## Instance Rollout Options

The module supports several rollout strategies for Materialize instances through the following configuration options:

### `in_place_rollout` (bool)
- When `false` (default): Performs a rolling upgrade by creating new instances before terminating old ones. This minimizes downtime but requires additional cluster resources during the transition.
- When `true`: Performs an in-place upgrade by directly replacing existing instances. This requires less resources but causes downtime.

### `request_rollout` (string)
- Triggers a rollout only when there are actual changes to the instance (e.g., image updates)
- Requires a valid UUID in the format `xxxxxxxx-xxxx-xxxx-xxxx-xxxxxxxxxxxx`
- Must be changed to a new UUID value for each rollout

### `force_rollout` (string)
- Triggers a rollout regardless of whether there are changes to the instance
- Useful for debugging or forcing a restart of instances
- Requires a valid UUID in the format `xxxxxxxx-xxxx-xxxx-xxxx-xxxxxxxxxxxx`
- Must be changed to a new UUID value for each rollout

To use these options, set the appropriate values in the `instances` input variable and when you want to rollout a new version of the instance, set the `request_rollout` or `force_rollout` value to a new UUID.

## Authentication Options

The module supports two authentication modes for Materialize instances:

### `authenticator_kind` (string)
- Determines how users authenticate with the Materialize instance.
- Valid values are:
  - `"None"` (default): No password authentication is enabled.
  - `"Password"`: Enables password authentication for the `mz_system` user. When set to `"Password"`, you **must** provide a value for `external_login_password_mz_system`.

### `external_login_password_mz_system` (string)
- The password to set for the `mz_system` user when `authenticator_kind` is `"Password"`.
- This value is stored securely in a Kubernetes Secret and used by the Materialize operator to configure authentication.
- **Required** if `authenticator_kind` is set to `"Password"`.

**Example:**
```hcl
instances = [
  {
    name                              = "materialize-instance"
    namespace                         = "materialize"
    authenticator_kind                = "Password"
    external_login_password_mz_system = "your-secure-password"
    # other instance configurations
  }
]
```

If `authenticator_kind` is not set or set to `"None"`, password authentication is disabled and `external_login_password_mz_system` is ignored.

## Requirements

| Name | Version |
|------|---------|
| <a name="requirement_terraform"></a> [terraform](#requirement\_terraform) | >= 1.0 |
| <a name="requirement_aws"></a> [aws](#requirement\_aws) | ~> 5.0 |
| <a name="requirement_helm"></a> [helm](#requirement\_helm) | ~> 2.0 |
| <a name="requirement_kubernetes"></a> [kubernetes](#requirement\_kubernetes) | ~> 2.0 |

## Providers

| Name | Version |
|------|---------|
| <a name="provider_helm"></a> [helm](#provider\_helm) | 2.17.0 |
| <a name="provider_kubernetes"></a> [kubernetes](#provider\_kubernetes) | 2.35.1 |

## Modules

No modules.

## Resources

| Name | Type |
|------|------|
| [helm_release.materialize_operator](https://registry.terraform.io/providers/hashicorp/helm/latest/docs/resources/release) | resource |
| [helm_release.metrics_server](https://registry.terraform.io/providers/hashicorp/helm/latest/docs/resources/release) | resource |
| [kubernetes_job.db_init_job](https://registry.terraform.io/providers/hashicorp/kubernetes/latest/docs/resources/job) | resource |
| [kubernetes_manifest.materialize_instances](https://registry.terraform.io/providers/hashicorp/kubernetes/latest/docs/resources/manifest) | resource |
| [kubernetes_namespace.instance_namespaces](https://registry.terraform.io/providers/hashicorp/kubernetes/latest/docs/resources/namespace) | resource |
| [kubernetes_namespace.materialize](https://registry.terraform.io/providers/hashicorp/kubernetes/latest/docs/resources/namespace) | resource |
| [kubernetes_namespace.monitoring](https://registry.terraform.io/providers/hashicorp/kubernetes/latest/docs/resources/namespace) | resource |
| [kubernetes_secret.materialize_backends](https://registry.terraform.io/providers/hashicorp/kubernetes/latest/docs/resources/secret) | resource |
| [kubernetes_resource.materialize_instances](https://registry.terraform.io/providers/hashicorp/kubernetes/latest/docs/data-sources/resource) | data source |

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| <a name="input_environment"></a> [environment](#input\_environment) | Environment name | `string` | n/a | yes |
| <a name="input_helm_chart"></a> [helm\_chart](#input\_helm\_chart) | Chart name from repository or local path to chart. For local charts, set the path to the chart directory. | `string` | `"materialize-operator"` | no |
| <a name="input_helm_repository"></a> [helm\_repository](#input\_helm\_repository) | Repository URL for the Materialize operator Helm chart. Leave empty if using local chart. | `string` | `"https://materializeinc.github.io/materialize/"` | no |
| <a name="input_helm_values"></a> [helm\_values](#input\_helm\_values) | Values to pass to the Helm chart | `any` | n/a | yes |
| <a name="input_install_metrics_server"></a> [install\_metrics\_server](#input\_install\_metrics\_server) | Whether to install the metrics-server | `bool` | `true` | no |
| <a name="input_instances"></a> [instances](#input\_instances) | Configuration for Materialize instances | <pre>list(object({<br/>    name                              = string<br/>    namespace                         = optional(string)<br/>    create_database                   = optional(bool, true)<br/>    database_name                     = string<br/>    metadata_backend_url              = string<br/>    persist_backend_url               = string<br/>    license_key                       = optional(string)<br/>    external_login_password_mz_system = optional(string)<br/>    authenticator_kind                = optional(string, "None")<br/>    environmentd_version              = optional(string, "v0.147.3") # META: mz version<br/>    environmentd_extra_env = optional(list(object({<br/>      name  = string<br/>      value = string<br/>    })), [])<br/>    environmentd_extra_args = optional(list(string), [])<br/>    cpu_request             = optional(string, "1")<br/>    memory_request          = optional(string, "1Gi")<br/>    memory_limit            = optional(string, "1Gi")<br/>    in_place_rollout        = optional(bool, true)<br/>    request_rollout         = optional(string, "00000000-0000-0000-0000-000000000001")<br/>    force_rollout           = optional(string, "00000000-0000-0000-0000-000000000001")<br/>    balancer_memory_request = optional(string, "256Mi")<br/>    balancer_memory_limit   = optional(string, "256Mi")<br/>    balancer_cpu_request    = optional(string, "100m")<br/>  }))</pre> | `[]` | no |
| <a name="input_metrics_server_version"></a> [metrics\_server\_version](#input\_metrics\_server\_version) | Version of metrics-server to install | `string` | `"3.12.2"` | no |
| <a name="input_monitoring_namespace"></a> [monitoring\_namespace](#input\_monitoring\_namespace) | Namespace for monitoring resources | `string` | `"monitoring"` | no |
| <a name="input_namespace"></a> [namespace](#input\_namespace) | Namespace prefix for all resources | `string` | n/a | yes |
| <a name="input_operator_namespace"></a> [operator\_namespace](#input\_operator\_namespace) | Namespace for the Materialize operator | `string` | `"materialize"` | no |
| <a name="input_operator_version"></a> [operator\_version](#input\_operator\_version) | Version of the Materialize operator to install | `string` | `"v25.2.2"` | no |
| <a name="input_postgres_version"></a> [postgres\_version](#input\_postgres\_version) | Postgres version to use for the metadata backend | `string` | `"15"` | no |
| <a name="input_use_local_chart"></a> [use\_local\_chart](#input\_use\_local\_chart) | Whether to use a local chart instead of one from a repository | `bool` | `false` | no |

## Outputs

| Name | Description |
|------|-------------|
| <a name="output_materialize_instance_resource_ids"></a> [materialize\_instance\_resource\_ids](#output\_materialize\_instance\_resource\_ids) | Resource IDs of created Materialize instances |
| <a name="output_materialize_instances"></a> [materialize\_instances](#output\_materialize\_instances) | Details of created Materialize instances |
| <a name="output_operator_namespace"></a> [operator\_namespace](#output\_operator\_namespace) | Namespace where the operator is installed |
| <a name="output_operator_release_name"></a> [operator\_release\_name](#output\_operator\_release\_name) | Helm release name of the operator |
| <a name="output_operator_release_status"></a> [operator\_release\_status](#output\_operator\_release\_status) | Status of the helm release |

## Chart Installation for Development

By default, the module installs the Materialize chart from a remote Helm repository, requiring no additional configuration.

For development and testing, you can use a local chart by specifying a local path:

```hcl
module "materialize" {
  # ... other configuration ...
  use_local_chart = true
  helm_chart      = "./path/to/local/chart"
}
```

This allows you to modify and test the chart locally before deploying it in a production environment.
<!-- END_TF_DOCS -->
