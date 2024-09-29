import boto3

dynamodb = boto3.client('dynamodb', region_name = "eu-west-2")

resp = dynamodb.execute_statement(Statement = 'Update Books Set Formats.Audiobook = \'JCV555\' Where Author = \'Antje Barth\' AND Title = \'Data Science on AWS\'')

print(resp['Items'])