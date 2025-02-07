# Terraform module for installing the Materialize Helm Chart

This module installs the Materialize Helm chart into a Kubernetes cluster using Terraform.

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
