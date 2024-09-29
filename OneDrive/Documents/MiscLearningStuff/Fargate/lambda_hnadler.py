import boto3
import os
import json

def lambda_handler(event, context):
    ecs_client = boto3.client('ecs')
    
    # Get the playbook name from the event, or use a default
    playbook_name = event.get('playbook', 'main.yml')
    
    cluster_name = os.environ['ECS_CLUSTER_NAME']
    task_definition = os.environ['ECS_TASK_DEFINITION']
    subnet_id = os.environ['SUBNET_ID']
    security_group_id = os.environ['SECURITY_GROUP_ID']
    
    response = ecs_client.run_task(
        cluster=cluster_name,
        taskDefinition=task_definition,
        launchType='FARGATE',
        networkConfiguration={
            'awsvpcConfiguration': {
                'subnets': [subnet_id],
                'securityGroups': [security_group_id],
                'assignPublicIp': 'ENABLED'
            }
        },
        overrides={
            'containerOverrides': [
                {
                    'name': 'ansible-container',
                    'environment': [
                        {
                            'name': 'PLAYBOOK_NAME',
                            'value': playbook_name
                        }
                    ]
                }
            ]
        }
    )
    
    return {
        'statusCode': 200,
        'body': json.dumps(f"Task ARN: {response['tasks'][0]['taskArn']}")
    }