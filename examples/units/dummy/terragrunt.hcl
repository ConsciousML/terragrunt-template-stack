include "root" {
  path = find_in_parent_folders("root.hcl")
}

terraform {
    source = "../../.././/modules/dummy"
}

inputs = {
    content = "Testing dummy unit from examples directory"
    output_dir = get_terragrunt_dir()
}