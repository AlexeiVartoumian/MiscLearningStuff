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

#------------------------------

#!/bin/bash

# Set these variables
BUCKET_NAME="your-central-cloudtrail-bucket-name"
ORGANIZATION_ID="o-xxxxxxxxxx"  # Replace with your AWS Organizations ID
REGION="us-east-1"  # Replace with your desired region

# Create the bucket
echo "Creating S3 bucket: $BUCKET_NAME in region $REGION"
if [ "$REGION" = "us-east-1" ]; then
    aws s3api create-bucket --bucket $BUCKET_NAME --region $REGION
else
    aws s3api create-bucket --bucket $BUCKET_NAME --region $REGION --create-bucket-configuration LocationConstraint=$REGION
fi

# Enable versioning on the bucket
echo "Enabling versioning on the bucket"
aws s3api put-bucket-versioning --bucket $BUCKET_NAME --versioning-configuration Status=Enabled

# Create a bucket policy
echo "Creating bucket policy"
POLICY=$(cat <<EOF
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
            "Resource": "arn:aws:s3:::$BUCKET_NAME",
            "Condition": {
                "StringEquals": {
                    "aws:PrincipalOrgID": "$ORGANIZATION_ID"
                }
            }
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
)

# Apply the bucket policy
echo "Applying bucket policy"
aws s3api put-bucket-policy --bucket $BUCKET_NAME --policy "$POLICY"

echo "Bucket $BUCKET_NAME created and configured successfully."

# Verify the bucket policy
echo "Verifying bucket policy:"
aws s3api get-bucket-policy --bucket $BUCKET_NAME --query Policy --output text | jq .

echo "Setup complete. You can now use this bucket ($BUCKET_NAME) for CloudTrail in your CloudFormation template."