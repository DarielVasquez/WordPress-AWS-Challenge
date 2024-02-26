resource "aws_lb" "load_balancer" {
  name               = "${var.name_prefix}-load-balancer"
  internal           = false
  load_balancer_type = "application"
  security_groups    = [var.security_group]
  subnets            = [var.public_subnet, var.public_subnet_2]
  tags = {
    "Name"        = "${var.name_prefix}-wordpress"
    "DevOps"      = var.devops_tag
    "Project"     = var.project_tag
    "Environment" = var.env_tag
  }
}

resource "aws_lb_target_group" "target_group" {
  name        = "${var.name_prefix}-target-group"
  port        = 80
  protocol    = "HTTP"
  vpc_id      = var.vpc
  target_type = "ip"
  health_check {
    enabled             = true
    path                = "/"
    port                = 80
    matcher             = 200
    interval            = 10
    timeout             = 5
    healthy_threshold   = 2
    unhealthy_threshold = 3
  }
  tags = {
    "Name"        = "${var.name_prefix}-wordpress"
    "DevOps"      = var.devops_tag
    "Project"     = var.project_tag
    "Environment" = var.env_tag
  }
}

# resource "aws_lb_target_group_attachment" "register_instance" {
#   target_group_arn = aws_lb_target_group.target_group.arn
#   target_id        = var.instance_id
# }

# resource "aws_autoscaling_attachment" "asg_attachment_elb" {
#   autoscaling_group_name = var.asg_name
#   lb_target_group_arn    = aws_lb_target_group.target_group.arn
# }

resource "aws_lb_listener" "listener" {
  load_balancer_arn = aws_lb.load_balancer.arn
  port              = 443
  protocol          = "HTTPS"
  certificate_arn = var.certificate_arn
  ssl_policy        = "ELBSecurityPolicy-2016-08"

  default_action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.target_group.arn
  }
}
