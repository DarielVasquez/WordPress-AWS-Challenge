resource "aws_instance" "wordpress" {
  ami           = var.ami_id  
  instance_type = var.instance_type 
  key_name      = var.key_pair
  security_groups = [ aws_security_group.security_group.name ]

  user_data = base64encode(templatefile("${path.module}/ec2_config.sh", {
    NAME = "${var.name_prefix}-wordpress"
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

resource "aws_security_group" "security_group" {
  name        = "${var.name_prefix}-security-group"
  description = "Security group for ${var.name_prefix}-wordpress"

  ingress {
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    "Name"        = "${var.name_prefix}-wordpress"
    "DevOps"      = var.devops_tag
    "Project"     = var.project_tag
    "Environment" = var.env_tag
  }
}