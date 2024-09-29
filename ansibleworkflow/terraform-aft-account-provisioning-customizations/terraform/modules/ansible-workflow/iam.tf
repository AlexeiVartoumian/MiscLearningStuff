

#ansible-workflow role
# resource "aws_iam_role" "aft_alternate_contacts_state_role" {

#     name = "aft-ansible-workflow-state-role"
#     assume_role_policy = templatefile("${path.module}/iam")
# }

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