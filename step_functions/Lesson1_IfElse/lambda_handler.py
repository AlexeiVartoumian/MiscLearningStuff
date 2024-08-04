from __future__ import print_function

import json
import urllib
import boto3
import datetime

print( "loading function")

# using this placholder func for both purchase and refund. input
#{"TransactionType": "PURCHASE"}
#{"TransactionType": "REFUND"}
def process_purchase(message , context):

    

    print("receieved message from step functions")
    print(message)

    response = {}
    response["TransactionType"] = message["TransactionType"]
    response["Timestamp"] = datetime.datetime.now().strftime("%Y-%m-%d %H-%M-%S")

    response["Message"] = "hello from lamdba , we inside the processPurchase funciton"

    return response


#arn:aws:lambda:eu-west-2:390746273208:function:ProcessPurchase

#arn:aws:lambda:eu-west-2:390746273208:function:ProcessRefund