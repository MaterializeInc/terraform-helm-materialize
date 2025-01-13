# terraform-helm-materialize
Terraform module for installing the Materialize Helm chart

<!-- BEGIN_TF_DOCS -->
# Terraform module for installing the Materialize Helm Chart

This module installs the Materialize Helm chart into a Kubernetes cluster using Terraform.

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
| [kubernetes_job.db_init_job](https://registry.terraform.io/providers/hashicorp/kubernetes/latest/docs/resources/job) | resource |
| [kubernetes_manifest.materialize_instances](https://registry.terraform.io/providers/hashicorp/kubernetes/latest/docs/resources/manifest) | resource |
| [kubernetes_namespace.instance_namespaces](https://registry.terraform.io/providers/hashicorp/kubernetes/latest/docs/resources/namespace) | resource |
| [kubernetes_namespace.materialize](https://registry.terraform.io/providers/hashicorp/kubernetes/latest/docs/resources/namespace) | resource |
| [kubernetes_secret.materialize_backends](https://registry.terraform.io/providers/hashicorp/kubernetes/latest/docs/resources/secret) | resource |

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| <a name="input_environment"></a> [environment](#input\_environment) | Environment name | `string` | n/a | yes |
| <a name="input_helm_repository"></a> [helm\_repository](#input\_helm\_repository) | Repository URL for the Materialize operator Helm chart | `string` | `"https://raw.githubusercontent.com/bobbyiliev/materialize/refs/heads/helm-chart-package/misc/helm-charts"` | no |
| <a name="input_helm_values"></a> [helm\_values](#input\_helm\_values) | Values to pass to the Helm chart | `any` | n/a | yes |
| <a name="input_instances"></a> [instances](#input\_instances) | Configuration for Materialize instances | <pre>list(object({<br/>    name                 = string<br/>    namespace            = optional(string)<br/>    metadata_backend_url = string<br/>    persist_backend_url  = string<br/>    cpu_request          = optional(string, "1")<br/>    memory_request       = optional(string, "1Gi")<br/>    memory_limit         = optional(string, "1Gi")<br/>  }))</pre> | `[]` | no |
| <a name="input_namespace"></a> [namespace](#input\_namespace) | Namespace prefix for all resources | `string` | n/a | yes |
| <a name="input_operator_namespace"></a> [operator\_namespace](#input\_operator\_namespace) | Namespace for the Materialize operator | `string` | `"materialize"` | no |
| <a name="input_operator_version"></a> [operator\_version](#input\_operator\_version) | Version of the Materialize operator to install | `string` | `"v25.1.0-beta.1"` | no |
| <a name="input_postgres_version"></a> [postgres\_version](#input\_postgres\_version) | Postgres version to use for the metadata backend | `string` | `"15"` | no |

## Outputs

| Name | Description |
|------|-------------|
| <a name="output_materialize_instances"></a> [materialize\_instances](#output\_materialize\_instances) | Details of created Materialize instances |
| <a name="output_operator_namespace"></a> [operator\_namespace](#output\_operator\_namespace) | Namespace where the operator is installed |
| <a name="output_operator_release_name"></a> [operator\_release\_name](#output\_operator\_release\_name) | Helm release name of the operator |
| <a name="output_operator_release_status"></a> [operator\_release\_status](#output\_operator\_release\_status) | Status of the helm release |
<!-- END_TF_DOCS -->