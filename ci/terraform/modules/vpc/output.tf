output "public_subnet" {
    value = aws_subnet.public_subnet.id
}

output "public_subnet_2" {
    value = aws_subnet.public_subnet_2.id
}

output "vpc" {
    value = aws_vpc.vpc.id
}

output "security_group" {
    value = aws_security_group.security_group.id
}