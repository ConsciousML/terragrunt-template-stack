stack "foobar" {
  source = "github.com/ConsciousML/terragrunt-template-stack//stacks/foo-bar?ref=v0.0.3"
  path   = "services"

  values = {
    output_dir = get_terragrunt_dir()
    content    = "Hello from foo, Terragrunt!"
  }
}