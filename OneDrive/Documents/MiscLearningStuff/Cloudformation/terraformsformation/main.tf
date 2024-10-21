# Module: cfn-stack (cfn-stack/main.tf)

variable "stack_name" {
  type = string
}

variable "template_file" {
  type = string
}

variable "parameters" {
  type = map(string)
}

variable "capabilities" {
  type    = list(string)
  default = ["CAPABILITY_IAM", "CAPABILITY_NAMED_IAM"]
}

variable "tags" {
  type    = map(string)
  default = {}
}

resource "aws_cloudformation_stack" "this" {
  name = var.stack_name

  template_body = file(var.template_file)

  parameters = var.parameters

  capabilities = var.capabilities

  tags = var.tags
}

output "stack_id" {
  value = aws_cloudformation_stack.this.id
}

output "outputs" {
  value = aws_cloudformation_stack.this.outputs
}

# Root module: main.tf

provider "aws" {
  region = var.region
}

variable "region" {
  type = string
}

variable "stacks" {
  type = map(object({
    template_file = string
    parameters    = map(string)
    tags          = map(string)
  }))
}

module "cfn_stacks" {
  source   = "./cfn-stack"
  for_each = var.stacks

  stack_name    = each.key
  template_file = each.value.template_file
  parameters    = each.value.parameters
  tags          = each.value.tags
}

output "stack_ids" {
  value = { for k, v in module.cfn_stacks : k => v.stack_id }
}

output "stack_outputs" {
  value = { for k, v in module.cfn_stacks : k => v.outputs }
}

# terraform.tfvars

region = "eu-west-1"

stacks = {
  "ConfigureCloudTrail" = {
    template_file = "templates/ConfigureCloudTrail.yaml"
    parameters = {
      S3BucketName = "demo-cloudtrail-bucket-unsafe"
      TrailName    = "Nom-Cloud-trail-logs"
    }
    tags = {
      Environment = "Production"
      Project     = "CloudTrail Configuration"
    }
  },
  "AnotherStack" = {
    template_file = "templates/AnotherTemplate.yaml"
    parameters = {
      Param1 = "Value1"
      Param2 = "Value2"
    }
    tags = {
      Environment = "Staging"
      Project     = "Another Project"
    }
  }
  # Add more stacks as needed
}