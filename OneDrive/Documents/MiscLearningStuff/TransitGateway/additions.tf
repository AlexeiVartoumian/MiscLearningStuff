# Add these to your main.tf

# VPC Route Table
resource "aws_route_table" "private" {
  provider = aws.account2
  vpc_id   = aws_vpc.vpc.id

  route {
    cidr_block         = "0.0.0.0/0"
    transit_gateway_id = aws_ec2_transit_gateway.tgw.id
  }

  tags = {
    Name = "private-rt"
  }
}

# Route Table Association for private subnets
resource "aws_route_table_association" "private" {
  provider = aws.account2
  count    = length(var.private_subnet_cidrs)

  subnet_id      = aws_subnet.private[count.index].id
  route_table_id = aws_route_table.private.id
}

# Transit Gateway Route Table Association
resource "aws_ec2_transit_gateway_route_table_association" "tgw_rt_association" {
  provider = aws.account1

  transit_gateway_attachment_id  = aws_ec2_transit_gateway_vpc_attachment.attachment.id
  transit_gateway_route_table_id = aws_ec2_transit_gateway_route_table.rt.id
}

# Optional: Add default route in Transit Gateway route table
resource "aws_ec2_transit_gateway_route" "default_route" {
  provider = aws.account1

  destination_cidr_block         = "0.0.0.0/0"
  transit_gateway_route_table_id = aws_ec2_transit_gateway_route_table.rt.id
  transit_gateway_attachment_id  = aws_ec2_transit_gateway_vpc_attachment.attachment.id
}

# Add these outputs
output "private_route_table_id" {
  value = aws_route_table.private.id
}

output "tgw_route_table_id" {
  value = aws_ec2_transit_gateway_route_table.rt.id
}

# Optional: Enable DNS support on the Transit Gateway Attachment
resource "aws_ec2_transit_gateway_vpc_attachment" "attachment" {
  # ... existing configuration ...
  dns_support = "enable"
}

# Optional: Add default route propagation
resource "aws_ec2_transit_gateway" "tgw" {
  # ... existing configuration ...
  default_route_table_association = "enable"
  default_route_table_propagation = "enable"
}