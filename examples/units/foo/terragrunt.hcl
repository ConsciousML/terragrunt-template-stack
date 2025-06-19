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

inputs = {
  #content = "Testing dummy unit from examples directory (${local.environment})"
  content    = "${values.content} (${local.environment})"
  output_dir = get_terragrunt_dir()
}