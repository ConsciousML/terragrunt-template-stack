include "root" {
  path = find_in_parent_folders("root.hcl")
}

locals {
  environment_hcl = find_in_parent_folders("environment.hcl")
  environment     = read_terragrunt_config(local.environment_hcl).locals.environment
}

terraform {
  source = "${get_path_to_repo_root()}//modules/dummy"
}

dependency "foo" {
  config_path = "../foo"
  mock_outputs = {
    content = "Mocked content from foo"
  }
  mock_outputs_allowed_terraform_commands = ["plan", "validate"]
}

inputs = {
  content    = "Foo content: ${dependency.foo.outputs.content} (${local.environment})"
  output_dir = get_terragrunt_dir()
}