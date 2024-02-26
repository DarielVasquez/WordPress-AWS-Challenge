output "asg_name" {
  value = aws_autoscaling_group.ecs_autoscaling_group.id
}

output "asg_arn" {
  value = aws_autoscaling_group.ecs_autoscaling_group.arn
}