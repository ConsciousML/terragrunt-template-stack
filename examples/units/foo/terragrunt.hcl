include "root" {
  path = find_in_parent_folders("root.hcl")
}

terraform {
    source = "${get_path_to_repo_root()}//modules/dummy"
}

inputs = {
    content = "Testing dummy unit from examples directory"
    output_dir = get_terragrunt_dir()
}