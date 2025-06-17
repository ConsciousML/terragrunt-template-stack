unit "foo" {
    source = "../../../units/dummy"
    path = "service"

    values = {

        output_dir = get_terragrunt_dir()
        content = "Hello from foo, Terragrunt!"
    }
}