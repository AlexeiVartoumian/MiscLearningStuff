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