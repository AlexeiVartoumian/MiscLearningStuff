

resource "local_file" "template" {
  content = jsonencode({
    Parameters = {
      VPCCidr = {
        Type = "String"
        Default = "10.0.0.0/16"
        Description = "Enter CIDR block"
      }
    }
    Resources = {
      myVpc = {
        Type = "AWS::EC2::VPC"
        Properties = {
          CidrBlock = { Ref = "VPCCidr" }
          Tags = [
            {
              Key = "Name"
              Value = "Primate_CF_VPC"
            }
          ]
        }
      }
    }
  })
  filename = "${path.module}/template.json"
}

output "template_content" {
  value = local_file.template.content
}

output "template_path" {
  value = local_file.template.filename
}