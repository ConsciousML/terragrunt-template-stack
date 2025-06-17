include "root" {
  path = find_in_parent_folders("root.hcl")
}

terraform {
    source = "${get_path_to_repo_root()}//modules/dummy"
}

dependency "foo" {
  config_path = "../foo"
  mock_outputs = {
    content = "Mocked content from foo"
  }
  mock_outputs_allowed_terraform_commands = ["plan"]
}

inputs = {
    content = "Foo content: ${dependency.foo.outputs.content}"
    output_dir = get_terragrunt_dir()
}