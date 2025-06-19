include "root" {
  path = find_in_parent_folders("root.hcl")
}

locals {
  environment_hcl = find_in_parent_folders("environment.hcl")
  environment     = read_terragrunt_config(local.environment_hcl).locals.environment
}

terraform {
  source = "git::git@github.com:ConsciousML/terragrunt-template-stack.git//modules/dummy?ref=v0.0.3"
}

inputs = {
  content    = "${values.content} (${local.environment})"
  output_dir = values.output_dir
}