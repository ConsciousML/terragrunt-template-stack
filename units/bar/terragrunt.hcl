terraform {
    source = "git::git@github.com:ConsciousML/terragrunt-template-stack.git//modules/dummy"
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
    output_dir = values.output_dir
}