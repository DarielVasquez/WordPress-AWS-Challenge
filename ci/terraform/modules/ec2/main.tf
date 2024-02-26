resource "aws_instance" "wordpress" {
  ami           = var.ami_id  
  instance_type = var.instance_type 
  key_name      = var.key_pair
  subnet_id = var.subnet_id
  vpc_security_group_ids = [ var.security_group ]
  iam_instance_profile = aws_iam_instance_profile.ec2_profile.name

  user_data = base64encode(templatefile("${path.module}/ec2_config.sh", {
    AWS_REGION = var.aws_region
    ECR_REPOSITORY_URL = var.ecr_repository_url
    ECR_REPOSITORY_NAME = var.ecr_repository_name
    DOCKER_IMAGE_TAG = var.docker_image_tag
  }))

  tags = {
    "Name"        = "${var.name_prefix}-wordpress"
    "DevOps"      = var.devops_tag
    "Project"     = var.project_tag
    "Environment" = var.env_tag
  }
}

resource "aws_eip" "eip" {
  instance = aws_instance.wordpress.id

  tags = {
    "Name"        = "${var.name_prefix}-wordpress"
    "DevOps"      = var.devops_tag
    "Project"     = var.project_tag
    "Environment" = var.env_tag
  }
}

resource "aws_iam_instance_profile" "ec2_profile" {
  name = "${var.name_prefix}-instance-profile"
  role = "${aws_iam_role.ecr_full_access_role.name}"
}

resource "aws_iam_role" "ecr_full_access_role" {
  name = "${var.name_prefix}-ecr-access-role"

  assume_role_policy = jsonencode({
    Version = "2012-10-17",
    Statement = [
      {
        Action = "sts:AssumeRole",
        Effect = "Allow",
        Principal = {
          Service = "ec2.amazonaws.com"
        }
      }
    ]
  })

  tags = {
    "Name"        = "${var.name_prefix}-wordpress"
    "DevOps"      = var.devops_tag
    "Project"     = var.project_tag
    "Environment" = var.env_tag
  }
}

resource "aws_iam_role_policy_attachment" "ecr_full_access_attachment" {
  policy_arn = "arn:aws:iam::aws:policy/AmazonEC2ContainerRegistryFullAccess"
  role       = aws_iam_role.ecr_full_access_role.name
}