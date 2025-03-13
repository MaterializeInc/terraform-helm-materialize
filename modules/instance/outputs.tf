output "resource_id" {
  description = "Resource ID of the created Materialize instance."
  value       = data.kubernetes_resource.materialize_instance.object.status.resourceId
}
