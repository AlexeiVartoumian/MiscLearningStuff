provider "aws" {
    region = "eu-west-2"
}
module "ansible_workflow" {
  source = "./modules/ansible-workflow"

  vpc_id                         = "vpc-0b17276edbeed6724"
  subnet_id                      = "subnet-05806a01860749cc7"
  ami_id                         = "ami-0b45ae66668865cd6"
  instance_type                  = "t2.micro"
  associate_public_ip            = false
  ssh_public_key_path            = "C:/Users/alexv/OneDrive/Documents/Conn/Try.pem.pub"
  ansible_playbooks_s3_bucket_arn = "arn:aws:s3:::somebuckethaha"
  ansible_playbooks_s3_bucket     = "somebuckethaha"
  aws_ct_mgt_account_id = "390746273208"
  aws_ct_mgt_org_id = "o-m9jr8f8hqe"
}


# resource "aws_sfn_state_machine" "aft_account_provisioning_customizations" {
#   name     = "aft-account-provisioning-customizations"
#   role_arn = aws_iam_role.aft_states.arn

#   definition = jsonencode({
#     Comment = "AFT Account Provisioning Customizations Workflow",
#     StartAt = "ExecuteAnsibleWorkflow",
#     States = {
#       ExecuteAnsibleWorkflow = {
#         Type     = "Task",
#         Resource = module.ansible_workflow.state_machine_arn,
#         End      = true
#       }
#     }
#   })
# }
resource "aws_sfn_state_machine" "aft_account_provisioning_customizations" {
  name     = "aft-account-provisioning-customizations"
  role_arn = aws_iam_role.aft_states.arn

  definition = templatefile("${path.module}/states/customizations.asl.json", {
    data_aft_ansible_workflow_state = module.ansible_workflow.state_machine_arn
  })
}

output "aft_account_provisioning_customizations_arn" {
  value       = aws_sfn_state_machine.aft_account_provisioning_customizations.arn
  description = "ARN of the AFT Account Provisioning Customizations State Machine"
}

output "aft_ansible_workflow_arn" {
  value       = module.ansible_workflow.state_machine_arn
  description = "ARN of the AFT Ansible Workflow State Machine"
}

output "aft_ansible_instance_id" {
  value       = module.ansible_workflow.instance_id
  description = "ID of the EC2 instance created for Ansible execution"
}