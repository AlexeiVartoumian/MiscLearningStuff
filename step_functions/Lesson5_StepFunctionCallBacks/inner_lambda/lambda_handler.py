import json

def result_handler(event, context):

    print(event)
    return {
        "result" : "PURCHASE_PROCESSED_SUCCESS"
    }



#{"type": "PURCHASE"}