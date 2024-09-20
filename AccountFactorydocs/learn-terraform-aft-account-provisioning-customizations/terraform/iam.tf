import {
  to = aws_iam_role.aft_states
  id = "aft-account-provisioning-customizations-role"
}


resource "aws_iam_role" "aft_states" {
  name               = "aft-account-provisioning-customizations-role"
  assume_role_policy = templatefile("${path.module}/iam/trust-policies/trust-policy.tpl", {})
}

resource "aws_iam_role_policy" "aft_states" {
  name = "aft-account-provisioning-customizations-policy"
  role = aws_iam_role.aft_states.id

  policy = templatefile("${path.module}/iam/role-policies/iam-aft-states.tpl", {
    alternate_contacts_customizations_sfn_arn = module.alternate-contacts.aft_alternate_contacts_state_machine_arn
    data_aws_region                           = data.aws_region.aft_management_region.name
    data_aws_account_id                       = data.aws_caller_identity.aft_management_id.account_id
  })
}






# resource "aws_iam_role" "aft_states" {
#   name               = "aft-account-provisioning-customizations-role"
#   assume_role_policy = templatefile("${path.module}/iam/trust-policies/states.tpl", { none = "none" })
# }
# resource "aws_iam_role" "aft_states" {
#   name               = "aft-account-provisioning-customizations-role"
#   assume_role_policy = templatefile("${path.module}/iam/trust-policies/states.tpl", {
#     alternate_contacts_customizations_sfn_arn = module.alternate-contacts.aft_alternate_contacts_state_machine_arn
#   })
# }

# resource "aws_iam_role" "aft_states" {
#   name               = "aft-account-provisioning-customizations-role"
#   assume_role_policy = templatefile("${path.module}/iam/trust-policies/states.tpl", {
#     alternate_contacts_customizations_sfn_arn = module.alternate-contacts.aft_alternate_contacts_state_machine_arn
#     data_aws_region                           = data.aws_region.aft_management_region.name
#     data_aws_account_id                       = data.aws_caller_identity.aft_management_id.account_id
#   })
# }
 

# resource "aws_iam_role_policy" "aft_states" {
#   name = "aft-account-provisioning-customizations-policy"
#   role = aws_iam_role.aft_states.id

#   policy = templatefile("${path.module}/iam/role-policies/iam-aft-states.tpl", {
#     data_aws_region                             = data.aws_region.aft_management_region.name
#     data_aws_account_id                         = data.aws_caller_identity.aft_management_id.account_id
#     alternate_contacts_customizations_sfn_arn   = module.alternate-contacts.aft_alternate_contacts_state_machine_arn
#   })
# }


# resource "aws_iam_role" "aft_states" {
#   name               = "aft-account-provisioning-customizations-role"
#   assume_role_policy = templatefile("${path.module}/iam/trust-policies/states.tpl", { none = "none" })
# }

# resource "aws_iam_role_policy" "aft_states" {
#   name = "aft-account-provisioning-customizations-policy"
#   role = aws_iam_role.aft_states.id

#   policy = templatefile("${path.module}/iam/role-policies/iam-aft-states.tpl", {
#     account_provisioning_customizations_sfn_arn = aws_sfn_state_machine.aft_account_provisioning_customizations.arn
#   })
# }