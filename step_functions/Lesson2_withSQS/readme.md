{
  "Comment": "Trnasaction Processor StateMachine Using SQS",
  "StartAt": "ProcessTransaction",
  "States": {
    "ProcessTransaction": {
      "Type" : "Pass", -> empty pointer to the next state
      "Next" : "BroadcastToSqs"
    },
    "BroadcastToSqs": {
      "Type": "Task",
      "Resource": "arn:aws:states:::sqs:sendMessage",
      "Parameters": {
        "QueueUrl": "",
        "MessageBody" : { # message body is what is to be sent to sqs
          "TransactionId.$": "$.TransactionId",
          "Type.$": "$.Type"
        }
      },
      "End":true
    }
  }
}

input as JSON:
{
    "TransactionId" : "abc"
    "Type": "PURCHASE"
}

note on syntax "TransactionId.$": "$.TransactionId",
above is stating a key value pair where: 
"TransactionId.$" is the name of the key
"$.TransactionId" is the value of the input where in this case will be replaced with abc

the same structure follows for "Type.$": "$.Type" : 
where "Type.$" will be replaced with the input key Type
and  "$.Type" will be replacesd with "PURCHASE"