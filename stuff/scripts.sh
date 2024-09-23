aws ssm send-command \
--document-name "AWS-ApplyAnsiblePlaybooks" \
--instance-ids "i-1234567890abcdef0" \
--parameters '{
  "SourceType": ["S3"],
  "SourceInfo": ["{\"path\": \"https://s3.amazonaws.com/your-bucket-name/ansible/\"}"],
  "PlaybookFile": ["your-playbook.yml"],
  "ExtraVariables": ["SSM=True"],
  "Check": ["False"],
  "Verbose": ["-v"]
}' \
--output-s3-bucket-name "your-output-bucket-name" \
--output-s3-key-prefix "ansible-outputs/"