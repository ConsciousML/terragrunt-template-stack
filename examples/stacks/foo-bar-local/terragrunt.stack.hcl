locals {
  work_dir = get_terragrunt_dir()
}

unit "foo" {
  source = "${get_repo_root()}/examples/units/foo"
  path   = "foo"

  values = {
    output_dir = get_terragrunt_dir()
    content    = "Testing dummy units from examples stacks"
  }
}

unit "bar" {
  source = "${get_repo_root()}/examples/units/bar"
  path   = "bar"

  values = {
    output_dir = get_terragrunt_dir()
  }
}