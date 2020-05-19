output "vpc" {
  value = aws_vpc.main
}

output "subnets" {
  value = aws_subnet.main
}

output "secgroup" {
  value = aws_security_group.main
}
