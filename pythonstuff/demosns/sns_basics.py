
import json 
import logging 
import time 
import boto3
from botocore.exceptions import ClientError

logger = logging.getLogger(__name__)

class SnsWrapper:

    def __init__(self, sns_resource):
        self.sns_resource = sns_resource
    
    def create_topic(self, name):

        try:
            topic = self.sns_resource.create_topic(Name = name)
            logger.info("created topic %s with ARN %s." , name , topic.arn)
        
        except ClientError:
            logger.exception("Could not create topic %s", name)
        
            raise
        else:
            return topic
    
    def list_topics(self):
        
        try:
            topics_iter = self.sns_resource.topics
            logger.info("topics got that")
        except ClientError:
            logger.exception("failed acquisition of topics")
        else:
            return topics_iter
    @staticmethod
    def delete_topic(topic):
        try:
            topic.delete()
        except ClientError:
            logger.exception("couldnt delete topis %s", topic.arn)
            raise
    

    @staticmethod
    def subscribe(topic , protocol , endpoint):

        try:
            subscription = topic.subscribe(
                Protocol=protocol, Endpoint=endpoint, ReturnSubscriptionArn=True
            )
            logger.info("Subscribed %s %s to topic %s." , protocol, endpoint, topic.arn)
        except ClientError:
            logger.exception("Could not subscribe %s %s to topic %s." , protocol, endpoint, topic.arn )
            raise
        else:
            return subscription
        
    
    def list_subscription(self , topic = None):

        try:
            if topic is None:
                subs_iter = self.sns_resource.subscription.all()
            else:
                subs_iter = topic.subscriptions.all()
            logger.info("got subscriptions")
        except ClientError:
            logger.exception("couldnt get subscriptions.")
            raise
        else:
            return subs_iter
    
    @staticmethod
    def add_subscription_filter(subscription , attributes):
        try:
            att_policy = {key:[value] for key, value in attributes.items()}
            subscription.set_attributes(
                AttributeName = "FilterPolicy", AttributeValue = json.dumps(att_policy)
            )
            logger.info("Added filter to subscription %s.", subscription.arn)
        except ClientError:
            logger.exception(
                "Couldnt add filter to subsceription %s", subscription.arn
            )
            raise
    @staticmethod
    def delete_subscription(subscription):
        try:
            subscription.delete()
            logger.info("delete subscription %s", subscription.arn)
        except ClientError:
            logger.exception("couldnt delete subscription %s" , subscription.arn)
            raise
    
    def publish_text_message(self, phone_number, message):

        try:
            response = self.sns_resource.meta.client.publish(
                PhoneNumber = phone_number , Message = message 
            )
            message_id = response["MessageId"]
            logger.info("published message to %s", phone_number)
        except ClientError:
            logger.exception("couldnt publish message %s " , phone_number)
        
        else:
            return message_id
    
    @staticmethod
    def publish_message(topic , message , attributes):

        try:
            att_dict = {}
            for key, value in attributes.items():
                if isinstance(value, str):
                    att_dict[key] = {"DataType": "String", "StringValue": value}
                elif isinstance(value , bytes):
                    att_dict[key] = {"DataType": "Binary", "BinaryValue": value}
            response = topic.publish(Message = message, MessageAttributes = att_dict)
            message_id = response["MessageId"]

            logger.info(
                "Published message with attributes %s to topic %s"
                , attributes , topic.arn,
            )
        except ClientError:
            logger.exception("couldnt publish message to topic %s", topic.arn)
            raise
        else:
            return message_id
    @staticmethod
    def publish_multi_message( topic , subject , default_message , sms_message,email_message):
        
        try:
            message = {
                "default": default_message,
                "sms": sms_message,
                "email": email_message
            }
            response = topic.publish(
                Message = json.dumps(message),
                Subject = subject,
                MessageStructure = "json"
            )
            message_id = response["MessageId"]
            logger.info("Published multi format message to topic %s", topic.arn)
        except ClientError:
            logger.exception("Couldnt publish message to topic %s", topic.arn)
            raise
        else:
            return message_id

def usage_demo():
    print("-" * 88)
    print("SNS demo lets go")
    print("-" * 88)

    logging.basicConfig(level = logging.INFO, format = "%(levelname)s: %(message)s")
    sns_wrapper = SnsWrapper(boto3.resource("sns"))
    topic_name = f"demo-basis-topic-{time.time_ns()}"

    print(f"Creating topic {topic_name}")
    topic = sns_wrapper.create_topic(topic_name)

    phone_number = input(" enter a num in + country code then number format")

    if phone_number != "":
        print(f"Sending an sms message from sns to {phone_number}")
        sns_wrapper.publish_text_message(phone_number, "hello from SNS demo!")
    
        email = input(
        f"Enter an email address to subscribe to {topic_name} and receive "
        f"a message: "
    )

    if email != "":
        print(f"Subscribing {email} to {topic_name}.")
        email_sub = sns_wrapper.subscribe(topic, "email", email)
        answer = input(
            f"Confirmation email sent to {email}. To receive SNS messages, "
            f"follow the instructions in the email. When confirmed, press "
            f"Enter to continue."
        )
        while (
            email_sub.attributes["PendingConfirmation"] == "true"
            and answer.lower() != "s"
        ):
            answer = input(
                f"Email address {email} is not confirmed. Follow the "
                f"instructions in the email to confirm and receive SNS messages. "
                f"Press Enter when confirmed or enter 's' to skip. "
            )
            email_sub.reload()

    phone_sub = None
    if phone_number != "":
        print(
            f"Subscribing {phone_number} to {topic_name}. Phone numbers do not "
            f"require confirmation."
        )
        phone_sub = sns_wrapper.subscribe(topic, "sms", phone_number)

    if phone_number != "" or email != "":
        print(
            f"Publishing a multi-format message to {topic_name}. Multi-format "
            f"messages contain different messages for different kinds of endpoints."
        )
        sns_wrapper.publish_multi_message(
            topic,
            "SNS multi-format demo",
            "This is the default message.",
            "This is the SMS version of the message.",
            "This is the email version of the message.",
        )

    if phone_sub is not None:
        mobile_key = "mobile"
        friendly = "friendly"
        print(
            f"Adding a filter policy to the {phone_number} subscription to send "
            f"only messages with a '{mobile_key}' attribute of '{friendly}'."
        )
        sns_wrapper.add_subscription_filter(phone_sub, {mobile_key: friendly})
        print(f"Publishing a message with a {mobile_key}: {friendly} attribute.")
        sns_wrapper.publish_message(
            topic, "Hello! This message is mobile friendly.", {mobile_key: friendly}
        )
        not_friendly = "not-friendly"
        print(f"Publishing a message with a {mobile_key}: {not_friendly} attribute.")
        sns_wrapper.publish_message(
            topic,
            "Hey. This message is not mobile friendly, so you shouldn't get "
            "it on your phone.",
            {mobile_key: not_friendly},
        )

    print(f"Getting subscriptions to {topic_name}.")
    topic_subs = sns_wrapper.list_subscription(topic)
    for sub in topic_subs:
        print(f"{sub.arn}")

    print(f"Deleting subscriptions and {topic_name}.")
    for sub in topic_subs:
        if sub.arn != "PendingConfirmation":
            sns_wrapper.delete_subscription(sub)
    sns_wrapper.delete_topic(topic)

    print("Thanks for watching!")
    print("-" * 88)


    



if __name__ == "__main__":
    usage_demo()