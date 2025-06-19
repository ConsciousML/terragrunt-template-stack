module "dummy" {
  source = "../../../modules/dummy"

  content    = var.content
  output_dir = var.output_dir
}