terraform {
  source = "../modules/dummy"
}

inputs = {
  output_dir = get_terragrunt_dir()
  content = "Hello from prod, Terragrunt!"
}