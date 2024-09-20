
pipeline practise. here setup a vpc secruity group and ec2 instance
ported it over to gitlab. set up some stages where each stage
is basically defined by some terraform scripting. put a lock on the tf statefile into an s3 bucket with dynamodb in the backend.tf file so only one person can modify 