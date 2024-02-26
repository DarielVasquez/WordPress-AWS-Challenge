resource "aws_ecr_repository" "ecr" {
  name                 = "${var.name_prefix}-wordpress-ecr"
  image_tag_mutability = "MUTABLE"
  force_delete = "true"

  tags = {
    "Name"        = "${var.name_prefix}-wordpress"
    "DevOps"      = var.devops_tag
    "Project"     = var.project_tag
    "Environment" = var.env_tag
  }
}