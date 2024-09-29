data "aws_vpc" "existing" {
  id = var.vpc_id
}

data "aws_subnet" "existing" {
  id = var.subnet_id
}


data "aws_region" "current" {}

data "aws_caller_identity" "current" {}


resource "aws_security_group" "allow_ssm_ssh" {
  name        = "allow_ssm_ssh"
  description = "Allow SSM and SSH traffic"
  vpc_id      = data.aws_vpc.existing.id

  ingress {
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]  # Consider restricting this to specific IPs
  }
  ingress {
    from_port   = 443
    to_port     = 443
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
    description = "Allow HTTPS for SSM"
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name = "allow_ssm_ssh"
  }
}

resource "aws_key_pair" "ssh_key" {
  key_name   = "aft-ansible-ssh-key"
  public_key = file(var.ssh_public_key_path)
}

# resource "aws_instance" "aft_ansible_instance" {
#   ami           = var.ami_id
#   instance_type = var.instance_type

#   subnet_id                   = data.aws_subnet.existing.id
#   vpc_security_group_ids      = [aws_security_group.allow_ssm_ssh.id]
#   associate_public_ip_address = var.associate_public_ip

#   iam_instance_profile = aws_iam_instance_profile.ssm_profile.name
#   key_name             = aws_key_pair.ssh_key.key_name

#   user_data = base64encode(<<-EOF
#               #!/bin/bash
#               sudo dnf install python3 python3-pip -y
#               pip3 install --trusted-host pypi.org --trusted-host files.pythonhosted.org --no-cache-dir --cert="" ansible PyYAML paramiko botocore boto3
#               EOF
#   )

#   tags = {
#     Name = "AFT Ansible Instance"
#   }
# }

# # SSM VPC Endpoints
# resource "aws_vpc_endpoint" "ssm" {
#   vpc_id            = data.aws_vpc.existing.id
#   service_name      = "com.amazonaws.${data.aws_region.current.name}.ssm"
#   vpc_endpoint_type = "Interface"

#   security_group_ids = [aws_security_group.allow_ssm_ssh.id]
#   subnet_ids         = [data.aws_subnet.existing.id]

#   private_dns_enabled = true
# }

# resource "aws_vpc_endpoint" "ssmmessages" {
#   vpc_id            = data.aws_vpc.existing.id
#   service_name      = "com.amazonaws.${data.aws_region.current.name}.ssmmessages"
#   vpc_endpoint_type = "Interface"

#   security_group_ids = [aws_security_group.allow_ssm_ssh.id]
#   subnet_ids         = [data.aws_subnet.existing.id]

#   private_dns_enabled = true
# }

# resource "aws_vpc_endpoint" "ec2messages" {
#   vpc_id            = data.aws_vpc.existing.id
#   service_name      = "com.amazonaws.${data.aws_region.current.name}.ec2messages"
#   vpc_endpoint_type = "Interface"

#   security_group_ids = [aws_security_group.allow_ssm_ssh.id]
#   subnet_ids         = [data.aws_subnet.existing.id]

#   private_dns_enabled = true
# }


resource "aws_instance" "aft_ansible_instance" {
  ami           = var.ami_id
  instance_type = var.instance_type

  subnet_id                   = data.aws_subnet.existing.id
  vpc_security_group_ids      = [aws_security_group.allow_ssm_ssh.id]
  #associate_public_ip_address = var.associate_public_ip
  associate_public_ip_address = true
  iam_instance_profile = aws_iam_instance_profile.ssm_profile.name
  key_name             = aws_key_pair.ssh_key.key_name
 
  user_data = base64encode(<<-EOF
              #!/bin/bash
              sudo dnf install python3 python3-pip -y
              pip3 install --trusted-host pypi.org --trusted-host files.pythonhosted.org --no-cache-dir --cert="" ansible PyYAML paramiko botocore boto3
              sudo yum install -y https://s3.amazonaws.com/ec2-downloads-windows/SSMAgent/latest/linux_amd64/amazon-ssm-agent.rpm
              sudo systemctl enable amazon-ssm-agent
              sudo systemctl start amazon-ssm-agent
              EOF
  )

  tags = {
    Name = "AFT Ansible Instance"
  }
}

# SSM VPC Endpoints
resource "aws_vpc_endpoint" "ssm" {
  vpc_id            = data.aws_vpc.existing.id
  service_name      = "com.amazonaws.${data.aws_region.current.name}.ssm"
  vpc_endpoint_type = "Interface"

  security_group_ids = [aws_security_group.allow_ssm_ssh.id]
  subnet_ids         = [data.aws_subnet.existing.id]

  private_dns_enabled = true
}

resource "aws_vpc_endpoint" "ssmmessages" {
  vpc_id            = data.aws_vpc.existing.id
  service_name      = "com.amazonaws.${data.aws_region.current.name}.ssmmessages"
  vpc_endpoint_type = "Interface"

  security_group_ids = [aws_security_group.allow_ssm_ssh.id]
  subnet_ids         = [data.aws_subnet.existing.id]

  private_dns_enabled = true
}

resource "aws_vpc_endpoint" "ec2messages" {
  vpc_id            = data.aws_vpc.existing.id
  service_name      = "com.amazonaws.${data.aws_region.current.name}.ec2messages"
  vpc_endpoint_type = "Interface"

  security_group_ids = [aws_security_group.allow_ssm_ssh.id]
  subnet_ids         = [data.aws_subnet.existing.id]

  private_dns_enabled = true
}
output "instance_id" {
  value = aws_instance.aft_ansible_instance.id
}

output "instance_private_ip" {
  value = aws_instance.aft_ansible_instance.private_ip
}