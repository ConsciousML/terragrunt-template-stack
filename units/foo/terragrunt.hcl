terraform {
    source = "git::git@github.com:ConsciousML/terragrunt-template-stack.git//modules/dummy"
}

inputs = {
    content = values.content
    output_dir = values.output_dir
}