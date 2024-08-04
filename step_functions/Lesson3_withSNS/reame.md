{
  "Comment": "Trnasaction Processor state machine Using SNS",
  "StartAt": "ProcessTransaction",
  "States": {
    "ProcessTransaction": {
      "Type" : "Pass",
      "Next": "BroadcastToSns"
    },
    "BroadcastToSns" : {
      "Type": "Task",
      "Resource" : "arn:aws:states:::sns:publish",
      "Parameters": {
        "TopicArn" :"arn:aws:sns:eu-west-2:390746273208:stepfunctionSNS",
        "Message": {
          "TransactionId.$" : "$.TransactionId",
          "Type.$" : "$.Type",
          "Source" : "Step Function!"        
        }
      },
      "End" : true
    }
    
  }
  
}

input as JSON:
{
    "TransactionId" : "abc"
    "Type": "PURCHASE"
}

like lesson 2 only with sns . need arn and not url needed for sqs.
addiotnal value will be hardcoded key val source: step function