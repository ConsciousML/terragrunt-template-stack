terraform {
  source = "../modules/dummy"
}

dependency "foo" {
 config_path = "../foo"

 mock_outputs = {
    content = "Mocked content from foo"
  }

  mock_outputs_allowed_terraform_commands = ["plan"]
}

inputs = {
  output_dir = get_terragrunt_dir()
  content = "Foo content: ${dependency.foo.outputs.content}"
}