
resource "aws_sfn_state_machine" "aft_account_provisioning_customisations" {
    name = "aft-account-provisioning-customizations"
    role_arn = aws_iam_role.aft_states.arn

    # definition = templatefile("${path.module}/states/customizations.asl.json", {
    #     data_aft_ansible_workflow = module.ansible_workflow.aft_ansible_workflow_state_machine_arn
    # })
    definition = templatefile("${path.module}/states/customizations.asl.json", {
    data_aft_ansible_workflow_state = module.ansible_workflow.state_machine_arn
    })

    depends_on = [
        aws_iam_role_policy.aft_states
    ]

}

# resource "aws_sfn_state_machine" "aft_account_provisioning_customisations" {
#   name     = "aft-account-provisioning-customizations"
#   role_arn = aws_iam_role.aft_states.arn

#   definition = templatefile("${path.module}/states/customizations.asl.json", {
#     data_aft_ansible_workflow = module.ansible_workflow.state_machine_arn
#   })
# }