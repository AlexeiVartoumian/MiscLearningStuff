
variable "vpc_id" {
  type        = string
  description = "The ID of the VPC"
}

variable "private_subnet_ids" {
  type        = list(string)
  description = "List of private subnet IDs"
}

variable "db_subnet_group_name" {
  type        = string
  description = "Name of the database subnet group"
}

variable "db_name" {
  type        = string
  description = "Name of the database"
}

variable "db_user" {
  type        = string
  description = "Master username for the database"
}

variable "db_password" {
  type        = string
  description = "Master password for the database"
}

variable "db_instance_class" {
  type        = string
  description = "Instance class for the database"
}

variable "db_sg_id" {
  type        = string
  description = "ID of the database security group"
}