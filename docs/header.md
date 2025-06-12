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
    name                              = "mz-instance"
    namespace                         = "mz-ns"
    authenticator_kind                = "Password"
    external_login_password_mz_system = "your-secure-password"
    # other instance configurations
  }
]
```

If `authenticator_kind` is not set or set to `"None"`, password authentication is disabled and `external_login_password_mz_system` is ignored.
