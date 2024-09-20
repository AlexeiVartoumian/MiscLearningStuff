

variable "vpc_cidr" {
    type = list(string)
    description = "list of public subnet CIDR blocks"
}

variable "availability_zones" {
    type = list(string)
    description = "List of availability zones"
}