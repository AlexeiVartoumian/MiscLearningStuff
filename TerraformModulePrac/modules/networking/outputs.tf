output "vpc_id" {
    value = aws_vpc.main.id
    description = "the id of the vpc"
}

output "public_subntet_ids" {
    value = aws_subnet.public[*].id
    description = "List of public subnet ids"
}

# output all the ids of created subnets
output "private_subnet_ids" {
    value = aws_subnet.private[*].id
    description = "List of private subnet ids"
}