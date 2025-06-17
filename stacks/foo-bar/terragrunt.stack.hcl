unit "foo" {
    source = "git::git@github.com:ConsciousML/terragrunt-template-stack.git//units/dummy"
    path = "service"

    values = {

        output_dir = values.output_dir
        content = values.content
    }
}