output "ecs_cluster" {
    value = aws_ecs_cluster.cluster.name
}

output "ecs_service" {
    value = aws_ecs_service.wordpress
}

# output "cloudmap_dns_name" {
#   value = "${aws_service_discovery_service.mysql_service.name}.${aws_service_discovery_private_dns_namespace.namespace.name}"
# }