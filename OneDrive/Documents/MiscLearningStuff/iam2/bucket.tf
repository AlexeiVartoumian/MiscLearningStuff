locals {
  ansible_output = jsondecode(file("/tmp/ansible_resource_output.json"))
  s3_resources   = { for resource in local.ansible_output.created_resources : resource.name => resource if resource.resource_type == "aws_s3_bucket" }
}

data "aws_s3_bucket" "ansible_created" {
  for_each = local.s3_resources
  bucket   = each.value.name
}

resource "aws_s3_bucket" "managed" {
  for_each = data.aws_s3_bucket.ansible_created

  bucket = each.value.id

  tags = {
    ManagedBy     = "Terraform"
    CreatedBy     = "Ansible"
    CreationTime  = local.s3_resources[each.key].creation_time
  }

  lifecycle {
    prevent_destroy = true
    ignore_changes  = [bucket]
  }
}

resource "aws_s3_bucket_versioning" "versioning" {
  for_each = aws_s3_bucket.managed

  bucket = each.value.id

  versioning_configuration {
    status = local.s3_resources[each.key].versioning ? "Enabled" : "Disabled"
  }
}

output "managed_s3_buckets" {
  value = { for k, v in aws_s3_bucket.managed : k => v.id }
}

output "s3_bucket_arns" {
  value = { for k, v in aws_s3_bucket.managed : k => v.arn }
}