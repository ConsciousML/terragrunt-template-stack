unit "foo" {
    source = "git::git@github.com:ConsciousML/terragrunt-template-stack.git//units/foo"
    path = "service"

    values = {

        output_dir = values.output_dir
        content = values.content
    }
}

unit "bar" {
    source = "git::git@github.com:ConsciousML/terragrunt-template-stack.git//units/bar"
    path = "service"

    values = {
        output_dir = values.output_dir
    }
}