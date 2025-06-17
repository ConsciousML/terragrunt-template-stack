unit "foo" {
    source = "git::git@github.com:ConsciousML/terragrunt-template-stack.git//units/foo"
    path = "foo"

    values = {

        output_dir = values.output_dir
        content = values.content
    }
}

unit "bar" {
    source = "git::git@github.com:ConsciousML/terragrunt-template-stack.git//units/bar"
    path = "bar"

    values = {
        output_dir = values.output_dir
    }
}