Intended for users familiar with Terraform and why it is used.

Read the [Terragrunt Quickstart](https://terragrunt.gruntwork.io/docs/getting-started/quick-start/).

## TL;DR
Terragrunt is a wrapper for Terraform that simplifies:
  - keeping configs DRY (Don't Repeat Yourself)
  - managing multiple environments (dev, staging, prod)
  - managing dependencies and execution order
  - auto-running `terraform init` when needed

### Key Terragrunt concepts:
  - Unit: is a directory that contains a `terragrunt.hcl` file, and it represents a single piece of infrastructure. You can think of a unit as a single instance of an OpenTofu/Terraform module.
  - Stack: a collection of units that are managed together. You can think of a stack as a single environment, such as `dev`, `staging`, or `prod`, or an entire project.
  - Shared module: A reusable Terraform module that multiple units reference to avoid repeating code. Usually in the `modules` directory.
  ```hcl
  terraform {
    source = "..modules/shared_modules"
  }
  ```
  - Inputs: variables passed to a unit.
  ```hcl
  inputs = {
    content = "Hello from foo"
  }
  ```
  - Dependencies: how one unit can depend on outputs from another unit.
  ```hcl
  dependency "foo" {
    config_path = "../foo"
  }
  
  inputs = {
    content = "Foo content: ${dependency.foo.outputs.content}"
  }
  ```
