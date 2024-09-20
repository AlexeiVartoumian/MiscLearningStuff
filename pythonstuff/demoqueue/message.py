import boto3
import json
import time
sqs = boto3.resource("sqs")

queue = sqs.create_queue(QueueName = "test", Attributes = {"DelaySeconds": '5'})

print(queue.url)

print(queue.attributes.get("DelaySeconds"))

insert = sqs.get_queue_by_name(QueueName = "test")
# response = queue.send_message(MessageBody = "hello world")

# print(response.get("MessageId"))
# print(response.get("MD5OfMessageBody"))



FixMessage = """
{ "8" : "FIX.4.4", 
 "9":"148" ,"35": "D","34":"1080" ,"49":"TESTBUY1" ,"52": "20180920-18:14:19.508" ,"56":"TESTSELL1", "11":"636730640278898634" ,"15":"USD" ,"21":"2" ,"38":"7000" ,"40":"1","54":"1" ,"55":"MSFT", "60":"20180920-18:14:19.492", "10":"092" }
"""
#somestring =  json.loads(FixMessage)
demo = queue.send_messages(Entries=[
    {"Id": "1",
     "MessageBody": "lets go"},
     {
      "Id" : "2",
      "MessageBody": "boto3",
      "MessageAttributes": {
        "Messagevalue": {
            "StringValue": "buy",
            "DataType": "1000"
        }
      }
     }
])
time.sleep(5)
queue.send_message(MessageBody = FixMessage)
#print(somestring)
#if author exists
for message in insert.receive_messages(MessageAttributeNames =['Author'], MaxNumberOfMessages =10 ):
    authortext = ""
    if message.message_attributes is not None:
        author_name = message.message_attributes.get("Author").get("StringValue")
        if author_name:
            author_text = ' ({0})'.format(author_name)
    
    print("MEssage Recieved {0}!{1}".format(message.body, authortext))
    message.delete()