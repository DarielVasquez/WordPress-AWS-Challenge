output "target_group" {
  value = aws_lb_target_group.target_group.arn
}

output "alb_dns_name" {
  value = aws_lb.load_balancer.dns_name
}

output "alb_zone_id" {
  value = aws_lb.load_balancer.zone_id
}

output "alb_listener" {
  value = aws_lb_listener.listener.arn
}

# output "public_dns" {
#   value = aws_lb.load_balancer.dns_name
# }