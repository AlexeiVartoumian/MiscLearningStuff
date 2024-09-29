# Demo Jinja Template

# Timestamp: 20240712190623
# Provider Region: us-west-2
# Terraform Distribution Type: oss
# Terraform Organization Name: public-cloud
# Terraform Workspace Name: my-workspace
# AFT Admin Role ARN: arn:aws:iam::123456789012:role/aft-execution-role

resource "demo_resource" "example" {
  name = "Example Resource"
  org  = "public-cloud"
}

output "org_name" {
  value = "public-cloud"
}
