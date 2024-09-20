
variable "vpc_id" {
    type = string
    description = "The if of the vpc"
}

variable "public_subnet_ids" {
    type = list(string)
    description = "the id of the vpc"
} 

variable "public_subnet_ids" {
    type = list(string)
    description = "list of public subnet ids"
}

variable "web_server_sg_id" {
  type        = string
  description = "ID of the web server security group"
}

variable "instance_type" {
  type        = string
  description = "EC2 instance type"
}

variable "key_name" {
  type        = string
  description = "Name of the EC2 key pair"
}

variable "max_size" {
  type        = number
  description = "Maximum size of the Auto Scaling Group"
}

variable "min_size" {
  type        = number
  description = "Minimum size of the Auto Scaling Group"
}

variable "desired_capacity" {
  type        = number
  description = "Desired capacity of the Auto Scaling Group"
}

variable "health_check_grace_period" {
  type        = number
  description = "Health check grace period for the Auto Scaling Group"
  default     = 300
}