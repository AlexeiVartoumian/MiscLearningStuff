terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 4.0"
    }
  }
}

provider "aws" {
  region = "us-west-2"
}

resource "aws_cloudformation_stack" "example" {
  name = "example-stack"
  template_body = file("${path.module}/example-template.json")

  parameters = {
    ParameterName = var.parameter_value
  }

  capabilities = ["CAPABILITY_IAM"]

  # This will create a new stack if it doesn't exist,
  # or update the existing stack if it does
  on_failure = "ROLLBACK"
}

variable "parameter_value" {
  type    = string
  default = "default-value"
}

output "stack_id" {
  value = aws_cloudformation_stack.example.id
}

output "stack_outputs" {
  value = aws_cloudformation_stack.example.outputs
}