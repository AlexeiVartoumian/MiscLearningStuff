from aws_cdk import (
    # Duration,
    Stack,
    # aws_sqs as sqs,
    aws_lambda as _lambda,
    aws_apigateway as apigateway
)
from constructs import Construct

class CdkHelloWorldStack(Stack):

    def __init__(self, scope: Construct, construct_id: str, **kwargs) -> None:
        super().__init__(scope, construct_id, **kwargs)

        # The code that defines your stack goes here

        # example resource
        # queue = sqs.Queue(
        #     self, "CdkHelloWorldQueue",
        #     visibility_timeout=Duration.seconds(300),
        # )
        hello_world_function = _lambda.Function(
            self,
            "HelloWorldFunction",
            runtime = _lambda.Runtime.NODEJS_20_X,
            code = _lambda.Code.from_asset("lambda"),
            handler = "hello.handler",
        )
        api = apigateway.LambdaRestApi(
            self, 
            "HelloWorldApi",
            handler = hello_world_function,
            proxy = False,
        )

        hello_resource = api.root.add_resource("hello")
        hello_resource.add_method("GET")

#https://zxxz6yp3k6.execute-api.eu-west-2.amazonaws.com/prod/