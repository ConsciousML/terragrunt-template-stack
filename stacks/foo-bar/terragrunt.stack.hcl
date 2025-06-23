unit "foo" {
  source = "git::git@github.com:ConsciousML/terragrunt-template-stack.git//units/foo?ref=v0.0.4"
  path   = "foo"

  values = {
    output_dir = values.output_dir
    content    = values.content
  }
}

unit "bar" {
  source = "git::git@github.com:ConsciousML/terragrunt-template-stack.git//units/bar?ref=v0.0.4"
  path   = "bar"

  values = {
    output_dir = values.output_dir
  }
}