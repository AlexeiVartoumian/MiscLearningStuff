import boto3

dynamodb = boto3.client("dynamodb", region_name="eu-west-2")
#resp= dynamodb.execute_statement(Statement= 'SELECT * FROM Books WHERE Author = \'Antje Barth\' AND Title = \'Data Science on AWS\'')

resp= dynamodb.execute_statement(Statement = 'SELECT * FROM Books')
print(resp['Items'])