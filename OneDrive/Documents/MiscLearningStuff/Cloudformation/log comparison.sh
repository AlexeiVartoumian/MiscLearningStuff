aws s3 ls s3://aws-controltower-logs-<account-id>-<region>/ --recursive | awk '{print $4}' | sort > controltower_structure.txt
b. For your existing bucket:
bashCopyaws s3 ls s3://your-existing-bucket/ --recursive | awk '{print $4}' | sort > existing_structure.txt
c. Compare the files:
bashCopydiff controltower_structure.txt existing_structure.txt

Comparing log file structures:
To compare the actual log files, you'll need to download a sample from each bucket and compare their contents. Here's a step-by-step approach:
a. Download a sample log from each bucket:
bashCopyaws s3 cp s3://aws-controltower-logs-<account-id>-<region>/<path-to-log> controltower_sample.json.gz
aws s3 cp s3://your-existing-bucket/<path-to-log> existing_sample.json.gz
b. Decompress the files:
bashCopygunzip controltower_sample.json.gz
gunzip existing_sample.json.gz
c. Compare the JSON structures:
bashCopyjq -S '.' controltower_sample.json > controltower_formatted.json
jq -S '.' existing_sample.json > existing_formatted.json
diff controltower_formatted.json existing_formatted.json
The jq -S '.' command sorts the JSON keys, making it easier to compare the structures even if the order of fields is different.
For a more detailed comparison:
If you want to compare specific fields or structures within the JSON, you can use jq to extract and compare particular elements. For example:
bashCopyjq '.Records[0] | keys' controltower_sample.json > controltower_keys.txt
jq '.Records[0] | keys' existing_sample.json > existing_keys.txt
diff controltower_keys.txt existing_keys.txt