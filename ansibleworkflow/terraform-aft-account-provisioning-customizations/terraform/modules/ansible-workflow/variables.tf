variable "vpc_id" {
  description = "ID of the VPC where resources will be created"
  type        = string
}

variable "subnet_id" {
  description = "ID of the subnet where the EC2 instance will be launched"
  type        = string
}

variable "ami_id" {
  description = "AMI ID for the EC2 instance"
  type        = string
}

variable "instance_type" {
  description = "EC2 instance type"
  type        = string
  default     = "t2.micro"
}

variable "associate_public_ip" {
  description = "Whether to associate a public IP to the instance"
  type        = bool
  default     = false
}

variable "ssh_public_key_path" {
  description = "Path to the SSH public key file"
  type        = string
}

variable "ansible_playbooks_s3_bucket_arn" {
  description = "ARN of the S3 bucket containing Ansible playbooks"
  type        = string
}

variable "ansible_playbooks_s3_bucket" {
  description = "Name of the S3 bucket containing Ansible playbooks"
  type        = string
}

variable "aws_ct_mgt_account_id" {
  description = "Control Tower Management Account Id"
  type        = string
  validation {
    condition     = can(regex("^\\d{12}$", var.aws_ct_mgt_account_id))
    error_message = "Variable var: aws_ct_mgt_account_id is not valid."
  }
}

variable "aws_ct_mgt_org_id" {
  description = "Control Tower Organization Id"
  type        = string
  validation {
    condition     = can(regex("^o-[a-z,0-9]{10}$", var.aws_ct_mgt_org_id))
    error_message = "Variable var: aws_ct_mgt_org_id is not valid."
  }
}

variable "cloudwatch_log_group_retention" {
  description = "Lambda CloudWatch log group retention period"
  type            = string
  default         = "0"
  validation {
    condition     = contains(["1", "3", "5", "7", "14", "30", "60", "90", "120", "150", "180", "365", "400", "545", "731", "1827", "3653", "0"], var.cloudwatch_log_group_retention)
    error_message = "Valid values for var: cloudwatch_log_group_retention are (1, 3, 5, 7, 14, 30, 60, 90, 120, 150, 180, 365, 400, 545, 731, 1827, 3653, and 0)."
  }
}