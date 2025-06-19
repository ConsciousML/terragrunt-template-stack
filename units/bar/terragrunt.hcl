include "root" {
  path = find_in_parent_folders("root.hcl")
}

locals {
  environment_hcl = find_in_parent_folders("environment.hcl")
  environment     = read_terragrunt_config(local.environment_hcl).locals.environment
}

terraform {
  source = "git::git@github.com:ConsciousML/terragrunt-template-stack.git//modules/dummy?ref=v0.0.2"
}

dependency "foo" {
  config_path = "../foo"
  mock_outputs = {
    content = "Mocked content from foo"
  }
  mock_outputs_allowed_terraform_commands = ["plan"]
}

inputs = {
  content    = "Foo content: ${dependency.foo.outputs.content} (${local.environment})"
  output_dir = values.output_dir
}