account1_id = "891377180089"  # Replace with Transit Gateway Account ID
account2_id = "381492108300"  # Replace with VPC Account ID

# Region
region = "eu-west-2"

# VPC CIDR - Using a /16 block gives you 65,536 IP addresses
vpc_cidr = "10.1.0.0/16"

# Private subnet CIDRs - Using /24 blocks gives you 256 IP addresses per subnet
# These are spread across different AZs for high availability
private_subnet_cidrs = [
  "10.1.1.0/24",  # AZ 1
  "10.1.2.0/24"   # AZ 2
]