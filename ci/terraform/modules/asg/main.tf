resource "aws_launch_template" "ecs_launch_template" {
  name_prefix            = "${var.name_prefix}-ecs-launch-"
  image_id               = var.ami_id
  instance_type          = var.instance_type
  key_name               = var.key_pair
  vpc_security_group_ids = [var.security_group]

  user_data = base64encode(templatefile("${path.module}/ecs_config.sh", {
    LOG_FILE="/var/log/user_data.log"
    ECS_CLUSTER = var.name_prefix
  }))

  iam_instance_profile {
    name = "ecsInstanceRole"
  }

  lifecycle {
    create_before_destroy = true
  }

  tags = {
    "Name"        = "${var.name_prefix}-wordpress"
    "DevOps"      = var.devops_tag
    "Project"     = var.project_tag
    "Environment" = var.env_tag
  }

  tag_specifications {
    resource_type = "instance"
    tags = {
        "Name"        = "${var.name_prefix}-wordpress"
        "DevOps"      = var.devops_tag
        "Project"     = var.project_tag
        "Environment" = var.env_tag
    }
  }
}

resource "aws_autoscaling_group" "ecs_autoscaling_group" {
  name              = "${var.name_prefix}-ecs-autoscaling-group"
  max_size          = 1
  min_size          = 1
  desired_capacity  = 1
  health_check_type = "EC2"
  force_delete      = true
  launch_template {
    id      = aws_launch_template.ecs_launch_template.id
    version = aws_launch_template.ecs_launch_template.latest_version
  }
  vpc_zone_identifier = [var.public_subnet, var.public_subnet_2]
  tag {
    key                 = "AmazonECSManaged"
    value               = true
    propagate_at_launch = true
  }
  tag {
    key                 = "Name"
    value               = "${var.name_prefix}-ecs-autoscaling-group"
    propagate_at_launch = true
  }
  # target_group_arns   = [aws_alb_target_group.target_group.arn]
}