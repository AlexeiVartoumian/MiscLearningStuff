
# resource "aws_sfn_state_machine" "aft_ansible_workflow_state" {

#     name = "aft-ansible-workflow"
#     role_arn = aws_iam_role.aft_ansible_workflow_state_role.arn
#     definition = templatefile("${path.module}/states/ansible-workflow.asl.json", {})
# }

resource "aws_sfn_state_machine" "aft_ansible_workflow_state" {
  name     = "aft-ansible-workflow"
  role_arn = aws_iam_role.aft_ansible_workflow_state_role.arn
  definition = templatefile("${path.module}/states/ansible-workflow.asl.json", {
    AFTInstanceId         = aws_instance.aft_ansible_instance.id
    AnsiblePlaybooksS3Path = "s3://${var.ansible_playbooks_s3_bucket}/playbooks.zip"
  })
}