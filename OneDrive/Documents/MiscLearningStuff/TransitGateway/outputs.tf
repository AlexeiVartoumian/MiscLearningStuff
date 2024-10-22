output "transit_gateway_id" {
  value = aws_ec2_transit_gateway.tgw.id
}

output "vpc_id" {
  value = aws_vpc.vpc.id
}

output "tgw_attachment_id" {
  value = aws_ec2_transit_gateway_vpc_attachment.attachment.id
}

output "private_subnet_ids" {
  value = aws_subnet.private[*].id
}

