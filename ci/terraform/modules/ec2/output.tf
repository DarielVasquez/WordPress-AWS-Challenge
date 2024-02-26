output "eip_address" {
  value = aws_eip.eip.public_ip
}

output "instance_id" {
  value = aws_instance.wordpress.id
}

output "public_dns" {
  value = aws_instance.wordpress.public_dns
}