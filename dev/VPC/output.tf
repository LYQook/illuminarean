output "vpc_id" {
  value = aws_vpc.narean.id
}

output "public_subnets" {
  value = aws_subnet.public.*.id
}

output "private_subnets" {
  value = aws_subnet.private.*.id
}

output "aws_security_group" {
  value = aws_security_group.narean_sg.id
}