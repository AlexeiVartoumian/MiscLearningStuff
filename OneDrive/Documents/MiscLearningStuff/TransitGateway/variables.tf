variable "region" {
  type        = string
  description = "AWS Region for all resources"
  default     = "eu-west-2"
}

variable "account1_id" {
  type        = string
  description = "AWS Account ID for Transit Gateway (Account 1)"
}

variable "account2_id" {
  type        = string
  description = "AWS Account ID for VPC (Account 2)"
}

variable "vpc_cidr" {
  type        = string
  description = "CIDR block for VPC in account 2"
  default     = "10.0.0.0/16"
}

variable "private_subnet_cidrs" {
  type        = list(string)
  description = "CIDR blocks for private subnets"
  default     = ["10.0.1.0/24", "10.0.2.0/24"]
}