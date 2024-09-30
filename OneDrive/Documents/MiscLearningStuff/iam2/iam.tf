resource "aws_iam_role" "aft_ansible_workflow_state_role" {
  name = "aft-ansible-workflow-state-role"
  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Action = "sts:AssumeRole"
        Effect = "Allow"
        Principal = {
          Service = "states.amazonaws.com"
        }
      }
    ]
  })
}

resource "aws_iam_role_policy" "aft_ansible_workflow_state_policy" {
  name = "aft-ansible-workflow-state-policy"
  role = aws_iam_role.aft_ansible_workflow_state_role.id

  policy = templatefile("${path.module}/iam/role-policies/state-aft-ansible-workflow-role-policy.tpl", {
    s3_bucket_arn = var.ansible_playbooks_s3_bucket_arn
    account_id    = data.aws_caller_identity.current.account_id
    region        = data.aws_region.current.name
  })
}

# Add permission to assume the cross-account role
resource "aws_iam_role_policy" "assume_cross_account_role" {
  name = "assume-cross-account-role"
  role = aws_iam_role.aft_ansible_workflow_state_role.id

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect = "Allow"
        Action = "sts:AssumeRole"
        Resource = "arn:aws:iam::*:role/AFT-CrossAccountAnsibleRole"
      }
    ]
  })
}

# Cross-Account Role (to be created in each target account)
resource "aws_iam_role" "cross_account_ansible_role" {
  name = "AFT-CrossAccountAnsibleRole"
  
  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Action = "sts:AssumeRole"
        Effect = "Allow"
        Principal = {
          AWS = "arn:aws:iam::${var.aft_management_account_id}:root"
        }
      }
    ]
  })
}

resource "aws_iam_role_policy" "cross_account_ansible_policy" {
  name = "CrossAccountAnsiblePolicy"
  role = aws_iam_role.cross_account_ansible_role.id

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect = "Allow"
        Action = [
          "ec2:DescribeInstanceStatus",
          "ssm:SendCommand",
          "ssm:GetCommandInvocation"
        ]
        Resource = "*"
      }
    ]
  })
}

resource "aws_iam_role" "ssm_role" {
  name = "aft-ansible-ssm-role"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Action = "sts:AssumeRole"
        Effect = "Allow"
        Principal = {
            Service = ["ec2.amazonaws.com", "ssm.amazonaws.com"]
        }
      }
    ]
  })
}

resource "aws_iam_role_policy_attachment" "ssm_core" {
  policy_arn = "arn:aws:iam::aws:policy/AmazonSSMManagedInstanceCore"
  role       = aws_iam_role.ssm_role.name
}

resource "aws_iam_role_policy_attachment" "s3_access" {
  policy_arn = "arn:aws:iam::aws:policy/AmazonS3FullAccess"
  role       = aws_iam_role.ssm_role.name
}

resource "aws_iam_role_policy_attachment" "ssm_patch" {
  policy_arn = "arn:aws:iam::aws:policy/AmazonSSMPatchAssociation"
  role       = aws_iam_role.ssm_role.name
}

resource "aws_iam_instance_profile" "ssm_profile" {
  name = "aft-ansible-ssm-profile"
  role = aws_iam_role.ssm_role.name
}

resource "aws_iam_role_policy_attachment" "ec2_role_for_ssm" {
  policy_arn = "arn:aws:iam::aws:policy/service-role/AmazonEC2RoleforSSM"
  role       = aws_iam_role.ssm_role.name
}