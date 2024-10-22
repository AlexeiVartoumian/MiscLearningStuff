data "aws_availability_zones" "available" {
  provider = aws.account2
  state    = "available"
}

# 1. Transit Gateway in Account 1
resource "aws_ec2_transit_gateway" "tgw" {
  provider = aws.account1
  
  description = "Cross-account Transit Gateway"
  tags = {
    Name = "cross-account-tgw"
  }
}

# Share Transit Gateway with Account 2
resource "aws_ram_resource_share" "tgw_share" {
  provider = aws.account1
  name     = "tgw-share"
}

resource "aws_ram_resource_association" "tgw_share" {
  provider           = aws.account1
  resource_arn       = aws_ec2_transit_gateway.tgw.arn
  resource_share_arn = aws_ram_resource_share.tgw_share.arn
}

resource "aws_ram_principal_association" "tgw_share" {
  provider           = aws.account1
  principal          = var.account2_id
  resource_share_arn = aws_ram_resource_share.tgw_share.arn
}

# 2. VPC in Account 2
resource "aws_vpc" "vpc" {
  provider             = aws.account2
  cidr_block           = var.vpc_cidr
  enable_dns_hostnames = true
  enable_dns_support   = true
  
  tags = {
    Name = "tgw-vpc"
  }
}

# Private subnets for the VPC
resource "aws_subnet" "private" {
  provider = aws.account2
  count    = length(var.private_subnet_cidrs)
  
  vpc_id            = aws_vpc.vpc.id
  cidr_block        = var.private_subnet_cidrs[count.index]
  availability_zone = data.aws_availability_zones.available.names[count.index]
  
  tags = {
    Name = "private-subnet-${count.index + 1}"
  }
}

# 3. VPC Attachment in Account 2
resource "aws_ec2_transit_gateway_vpc_attachment" "attachment" {
  provider = aws.account2
  
  subnet_ids         = aws_subnet.private[*].id
  transit_gateway_id = aws_ec2_transit_gateway.tgw.id
  vpc_id            = aws_vpc.vpc.id
  
  tags = {
    Name = "tgw-attachment"
  }
  
  depends_on = [
    aws_ram_principal_association.tgw_share
  ]
}

# 4. Accepter in Account 1
resource "aws_ec2_transit_gateway_vpc_attachment_accepter" "accepter" {
  provider = aws.account1
  
  transit_gateway_attachment_id = aws_ec2_transit_gateway_vpc_attachment.attachment.id
  
  tags = {
    Name = "tgw-attachment-accepter"
  }
}

# 5. Route Propagation in Account 1
resource "aws_ec2_transit_gateway_route_table" "rt" {
  provider = aws.account1
  
  transit_gateway_id = aws_ec2_transit_gateway.tgw.id
  
  tags = {
    Name = "tgw-rt"
  }
}

resource "aws_ec2_transit_gateway_route_table_propagation" "propagation" {
  provider = aws.account1
  
  transit_gateway_attachment_id  = aws_ec2_transit_gateway_vpc_attachment.attachment.id
  transit_gateway_route_table_id = aws_ec2_transit_gateway_route_table.rt.id
}