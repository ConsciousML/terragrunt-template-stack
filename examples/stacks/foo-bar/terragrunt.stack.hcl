locals {
  work_dir = get_terragrunt_dir()
}

unit "foo" {
    source = "../../units/foo"
    path = "foo"

    values = {
        output_dir = get_terragrunt_dir()
        content = "Hello from foo, Terragrunt!"
    }
}

unit "bar" {
    source = "../../units/bar"
    path = "bar"

    values = {
        output_dir = get_terragrunt_dir()
    }
}