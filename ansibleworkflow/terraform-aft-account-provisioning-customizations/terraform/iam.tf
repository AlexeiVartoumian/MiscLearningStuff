# import {
#     to = aws_iam_role.aft_states
#     id = "aft-account-provisioning-customizations-role"
# }

# resource "aws_iam_role" "aft_states" {
#     name = "aft-account-provisioning-customizations-role"
#     assume_role_policy = templatefile("${path.module}/iam/trust-policies/trust-policy.tpl", {})
# }

# resource "aws_iam_policy" "aft_states" {
#     name = "aft-account-provisioning-customizations-policy"
#     role = aws_iam_role.aft_states.id

#     policy = templatefile("${path.module}/iam/role-policies/iam-aft-states.tpl", {
#         ansible_workflow_sfn_arn = module.ansible_workflow.aft_ansible_workflow_state_machine_arn
#         data_aws_region = data.aws_region.aft_management_region.name
#         data_aws_account_id = data.aws_caller_identity.aft_management_id.account_id
#     })
# }
data "aws_caller_identity" "current" {}
data "aws_region" "current" {}

# resource "aws_iam_role" "aft_states" {
#   name               = "aft-account-provisioning-customizations-role"
#   assume_role_policy = templatefile("${path.module}/iam/trust-policies/trust-policy.tpl", {})
# }

# resource "aws_iam_role_policy" "aft_states" {
#   name = "aft-account-provisioning-customizations-policy"
#   role = aws_iam_role.aft_states.id

#   policy = templatefile("${path.module}/iam/role-policies/iam-aft-states.tpl", {
#     ansible_workflow_sfn_arn = module.ansible_workflow.aft_ansible_workflow_state_machine_arn
#     data_aws_region          = data.aws_region.current.name
#     data_aws_account_id      = data.aws_caller_identity.current.account_id
#   })
# }
resource "aws_iam_role" "aft_states" {
  name = "aft-account-provisioning-customizations-role"
  assume_role_policy = templatefile("${path.module}/iam/trust-policies/trust-policy.tpl", {})
}

resource "aws_iam_role_policy" "aft_states" {
  name = "aft-account-provisioning-customizations-policy"
  role = aws_iam_role.aft_states.id

  policy = templatefile("${path.module}/iam/role-policies/iam-aft-states.tpl", {
    ansible_workflow_customizations_sfn_arn = module.ansible_workflow.state_machine_arn
    data_aws_region          = data.aws_region.current.name
    data_aws_account_id      = data.aws_caller_identity.current.account_id
  })
}
