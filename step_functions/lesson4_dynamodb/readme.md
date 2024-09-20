{
    "Comment": "A description of my state machine",
    "StartAt": "ProcessTransaction",
    "States": {
      "ProcessTransaction":{
        "Type" : "Pass",
        "Next" : "StoreHistory"
      },
      "StoreHistory": {
        "Type":"Task",
        "Resource": "arn:aws:states:::dynamodb:putItem",
        "Parameters":{
          "TableName": "TransactionTable",
          "Item": {
            "TransactionId": {
               "S.$": "$.TransactionId"
            }
          }
        },
        "Retry":[
          {
            "ErrorEquals": [
              "States.ALL"
            ],
            "IntervalSeconds": 1,
            "MaxAttempts":3
          }
        ],
        "End" :true,
         "ResultPath": "$.DynamoDB"
      }
    }
  }

note on  "ResultPath": "$.DynamoDB" :
typically this means we expect to pass the value into the next state.

{
  "TransactionId": "093+22"
}

TransactionId": {
               "S.$": "$.TransactionId"
            }
take into account dynamodb sensitivity "S.$": "$.TransactionId" means the value will be of type string.


aws dynamodb scan --table-name TransactionTable will return 

{
    "Items": [
        {
            "TransactionId": {
                "S": "093+22"
            }
        }
    ],
    "Count": 1,
    "ScannedCount": 1,
    "ConsumedCapacity": null
}

Okay I have AWS control tower enabled with a dummy organisation.
I have to test scenarios for an enterprise setting where a multi account architecture  will eventually be enlisted into control tower.
there may be situations where accounts inside this org have resources spanning different regions.
I primarily need to know how governed regions vs non-governed regions interact with each other and how deny-region will affect accounts under control tower.
As such I need to come up with a variety of test scenarios primarily revolving around moving the exisiting state into control tower.
for example. suppose I have control tower enabled , where the governed regions are eu-west-1 and eu-west-2. 
further to this deny region is not enabled. 
I want to know what happens when resources are deployed to us-east-1. Does AWS Config pick up on this resource being deployed in another region?
Testing capabilities of centralised governance.

another scenario: 
Suppose control tower is enabled where and OU's are yet to be registered.In OU there is an account with reources in eu-west-1 and eu-west-2. 
IN control tower there is a deny region on eu-west-1.  
wwhat happens when registering OU ?

I need you to provide me a suite of testing scenarios based on OU , Deny region ,vs no-deny region and other scenarios that might arise with exisiting accounts, exisitng org,
enabling control tower and gerneally testing behaviour.


        {
            "arn": "arn:aws:controltower:eu-west-2:390746273208:enabledcontrol/8OPJLTEK1S4TOJ99",
            "controlIdentifier": "arn:aws:controltower:eu-west-2::control/AWS-GR_REGION_DENY",
            "driftStatusSummary": {
                "driftStatus": "NOT_CHECKING"
            },
            "statusSummary": {
                "status": "SUCCEEDED"
            },
            "targetIdentifier": "arn:aws:organizations::390746273208:ou/o-m9jr8f8hqe/ou-aklj-fx1x0u5p"
        },
    
org/wholesale/developmentacc
o-m9jr8f8hqe/ou-aklj-xul3y0i3/ou-aklj-5ybhenyi
aws controltower enable-control \
    --target-identifier arn:aws:organizations::01234567890:ou/o-EXAMPLE/ou-zzxx-zzx0zzz2 \
    --control-identifier arn:aws:controltower:eu-west-2::control/EXAMPLE_NAME \
    --parameters '[{"key":"AllowedRegions","value":["eu-west-1","eu-west-2"]},{"key":"ExemptedPrincipalArns","value":["arn:aws:iam::*:role/ReadOnly","arn:aws:sts::*:assumed-role/ReadOnly/*"]},{"key":"ExemptedActions","value":["logs:DescribeLogGroups","logs:StartQuery","logs:GetQueryResults"]}]'


aws controltower enable-control \
    --target-identifier arn:aws:organizations::390746273208:ou/o-m9jr8f8hqe/ou-aklj-xul3y0i3/ou-aklj-5ybhenyi \
    --control-identifier arn:aws:controltower:eu-west-2::control/EXAMPLE_NAME \
    --parameters '[{"key":"AllowedRegions","value":["eu-west-1","eu-west-2"]},{"key":"ExemptedPrincipalArns","value":["arn:aws:iam::*:role/ReadOnly","arn:aws:sts::*:assumed-role/ReadOnly/*"]},{"key":"ExemptedActions","value":["logs:DescribeLogGroups","logs:StartQuery","logs:GetQueryResults"]}]'