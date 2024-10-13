
terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 4.0"
    }
  }
}

provider "aws" {
  region = var.aws_region
}

resource "aws_cloudformation_stack" "example" {
  name = var.stack_name

  template_body = file(var.template_file_path)

  parameters = {
    EnvironmentType = var.environment
    InstanceType    = var.instance_type
    KeyName         = var.key_name
    # Add other parameters as needed
  }

  capabilities = ["CAPABILITY_IAM", "CAPABILITY_NAMED_IAM"]

  tags = var.stack_tags
}

# variables.tf

variable "aws_region" {
  description = "AWS region to deploy the stack"
  type        = string
  default     = "us-west-2"
}

variable "stack_name" {
  description = "Name of the CloudFormation stack"
  type        = string
}

variable "template_file_path" {
  description = "Path to the CloudFormation template file"
  type        = string
}

variable "environment" {
  description = "Deployment environment (e.g., dev, staging, prod)"
  type        = string
}

variable "instance_type" {
  description = "EC2 instance type"
  type        = string
  default     = "t2.micro"
}

variable "key_name" {
  description = "Name of the EC2 key pair"
  type        = string
}

variable "stack_tags" {
  description = "Tags to apply to the CloudFormation stack"
  type        = map(string)
  default     = {}
}

# outputs.tf

output "stack_id" {
  description = "ID of the CloudFormation stack"
  value       = aws_cloudformation_stack.example.id
}

output "stack_outputs" {
  description = "Outputs from the CloudFormation stack"
  value       = aws_cloudformation_stack.example.outputs
}