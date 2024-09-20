{
    "Version": "2012-10-17",
    "Statement": [
      {
        "Effect": "Allow",
        "Action": "states:Start*",
        "Resource": [
          "${alternate_contacts_customizations_sfn_arn}"
        ]
      },
      {
        "Effect": "Allow",
        "Action": [
          "events:PutTargets",
          "events:PutRule",
          "events:DescribeRule",
          "events:DeleteRule",
          "events:RemoveTargets",
          "events:ListTargetsByRule",
          "events:ListRuleNamesByTarget"
        ],
        "Resource": [
          "arn:aws:events:${data_aws_region}:${data_aws_account_id}:rule/StepFunctionsGetEventsForStepFunctionsExecutionRule",
          "arn:aws:events:${data_aws_region}:${data_aws_account_id}:rule/aft-*"
        ]
      },
      {
        "Effect": "Allow",
        "Action": [
          "states:DescribeExecution",
          "states:StopExecution"
        ],
        "Resource": "*"
      }
    ]
  }