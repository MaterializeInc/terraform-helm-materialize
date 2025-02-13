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
