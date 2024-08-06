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
there may be scenarios where accounts inside this org have resources spanning different regions.
As such I need to come up with a variety of test scenarios primarily revolving around moving the exisiting state into control tower.
for example. suppose I have control tower enabled , where the governed regions are eu-west-1 and eu-west-2. 
further to this deny region is not enabled. 
I want to know what happens when resources are deployed to us-east-1. Does AWS Config pick up on this resource being deployed in another region?
Testing capabilities of centralised governance.

I need you to provide me a suite of testing scenarios based on OU , Deny region ,vs no-deny region and other scenarios that might arise with exisiting accounts, exisitng org,
enabling control tower and gerneally testing behaviour.