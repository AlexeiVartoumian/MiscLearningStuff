#!/bin/bash

# Set these variables
BUCKET_NAME="your-central-cloudtrail-bucket-name"
ORGANIZATION_ID="o-xxxxxxxxxx"  # Replace with your AWS Organizations ID

# Create the bucket
aws s3api create-bucket --bucket $BUCKET_NAME --region us-east-1

# Create a bucket policy
cat <<EOF > bucket-policy.json
{
    "Version": "2012-10-17",
    "Statement": [
        {
            "Sid": "AWSCloudTrailAclCheck",
            "Effect": "Allow",
            "Principal": {
                "Service": "cloudtrail.amazonaws.com"
            },
            "Action": "s3:GetBucketAcl",
            "Resource": "arn:aws:s3:::$BUCKET_NAME"
        },
        {
            "Sid": "AWSCloudTrailWrite",
            "Effect": "Allow",
            "Principal": {
                "Service": "cloudtrail.amazonaws.com"
            },
            "Action": "s3:PutObject",
            "Resource": "arn:aws:s3:::$BUCKET_NAME/AWSLogs/*",
            "Condition": {
                "StringEquals": {
                    "s3:x-amz-acl": "bucket-owner-full-control",
                    "aws:PrincipalOrgID": "$ORGANIZATION_ID"
                }
            }
        }
    ]
}
EOF

# Apply the bucket policy
aws s3api put-bucket-policy --bucket $BUCKET_NAME --policy file://bucket-policy.json

echo "Bucket $BUCKET_NAME created and policy applied."

# Clean up
rm bucket-policy.json