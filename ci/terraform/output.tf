# output "eip_address" {
#   value = var.hosted_zone_name
# }

# output "public_dns" {
#   value = module.ec2.public_dns
# }

# output "eip_address" {
#   value = module.ec2.eip_address
# }

output "ecr_repository_url" {
  value = module.ecr.ecr_repository_url
}

output "ecr_repository_name" {
  value = module.ecr.ecr_repository_name
}

# output "cloudmap_dns_name" {
#   value = module.ecs.cloudmap_dns_name
# }