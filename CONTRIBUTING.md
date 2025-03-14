# Contributing to terraform-helm-materialize

We want to make contributing to `terraform-helm-materialize` as easy and transparent as possible, whether it's:

- Reporting a bug
- Discussing the current state of the code
- Submitting a fix
- Proposing new features
- Becoming a maintainer

## We Develop with Github
We use GitHub to host Terraform module, to track issues and feature requests, as well as accept pull requests.

## Pull Requests
Pull requests are the best way to propose changes to the codebase. We actively welcome your pull requests:

1. Fork the repo on GitHub by clicking the 'Fork' button at the top right.
2. Clone your fork and create your branch from `main`.
3. If you've added code that should be tested, add tests.
4. If you've changed APIs, update the documentation.
5. Ensure the test suite passes.
6. Make sure your code lints.
7. Issue that pull request!

## Core Module Usage

This Helm module is used as a core component in the following cloud-specific modules:

- [terraform-aws-materialize](https://github.com/MaterializeInc/terraform-aws-materialize)
- [terraform-azurerm-materialize](https://github.com/MaterializeInc/terraform-azurerm-materialize)
- [terraform-google-materialize](https://github.com/MaterializeInc/terraform-google-materialize)

When making changes, consider how they might impact these dependent modules.

## Generating Documentation

This module uses [terraform-docs](https://terraform-docs.io/user-guide/introduction/) to generate documentation. To generate the documentation, run the following command from the root of the repository:

```bash
terraform-docs --config .terraform-docs.yml .
```

## Development Process

1. Fork the repository on GitHub
2. Clone your fork
```bash
git clone https://github.com/YOUR-USERNAME/terraform-helm-materialize.git
```

3. Create a new branch
```bash
git checkout -b feature/your-feature-name
```

4. Make your changes and test them.

5. Before committing, run these commands from the root of the repository:
```bash
# Run the linter with recursive and compact format
tflint --recursive --format compact

# Format the Terraform code
terraform fmt -recursive

# Generate updated documentation
terraform-docs --config .terraform-docs.yml .
```

6. Commit your changes
```bash
git commit -m "Add your meaningful commit message"
```

7. Push to your fork and submit a pull request

## Testing with Cloud-Specific Modules

Since this module is a core component used by cloud-specific modules, it's important to test your changes with at least one of these modules:

1. Clone one of the cloud-specific modules:
```bash
git clone https://github.com/MaterializeInc/terraform-aws-materialize.git
# OR
git clone https://github.com/MaterializeInc/terraform-azurerm-materialize.git
# OR
git clone https://github.com/MaterializeInc/terraform-google-materialize.git
```

2. Update the module source in the cloud-specific module to point to your local copy:
```hcl
module "operator" {
  source = "/path/to/your/cloned/terraform-helm-materialize"
  # Instead of the usual:
  # source = "github.com/MaterializeInc/terraform-helm-materialize?ref=v0.1.8"

  # Rest of the configuration...
}
```

3. Run terraform initialization and planning to verify that your changes work correctly with the cloud-specific module:

```bash
terraform init
terraform plan
```

4. If possible, test a full deployment to verify that your changes work as expected in a real environment

## Versioning

We follow [Semantic Versioning](https://semver.org/). For version numbers:

- MAJOR version for incompatible API changes
- MINOR version for added functionality in a backwards compatible manner
- PATCH version for backwards compatible bug fixes

## Cutting a new release

Perform a manual test of the latest code on `main`. See prior section. Then run:

```bash
git tag -a vX.Y.Z -m vX.Y.Z
git push origin vX.Y.Z
```

## References

- [Terraform Documentation](https://www.terraform.io/docs)
- [Kubernetes Documentation](https://kubernetes.io/docs/home/)
- [Helm Documentation](https://helm.sh/docs/)
- [Materialize Documentation](https://materialize.com/docs)
