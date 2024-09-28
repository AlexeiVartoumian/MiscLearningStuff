output "state_machine_arn" {
  value       = aws_sfn_state_machine.aft_ansible_workflow_state.arn
  description = "ARN of the AFT Ansible Workflow State Machine"
}

