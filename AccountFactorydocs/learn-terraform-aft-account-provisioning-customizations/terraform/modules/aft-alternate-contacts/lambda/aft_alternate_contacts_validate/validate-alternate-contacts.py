'''
Copyright Amazon.com, Inc. or its affiliates. All Rights Reserved.

Permission is hereby granted, free of charge, to any person obtaining a copy of
this software and associated documentation files (the "Software"), to deal in
the Software without restriction, including without limitation the rights to
use, copy, modify, merge, publish, distribute, sublicense, and/or sell copies of
the Software, and to permit persons to whom the Software is furnished to do so.

THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY, FITNESS
FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR
COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER
IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN
CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.
'''
import sys
import os
import json
import logging
import boto3

logger = logging.getLogger()
logger.setLevel(logging.INFO)

logger.info(f"Python version: {sys.version}")
logger.info(f"Initial sys.path: {sys.path}")
logger.info(f"Contents of /var/task: {os.listdir('/var/task')}")
logger.info(f"Contents of /opt: {os.listdir('/opt')}")

# Add the Lambda layer to the Python path
sys.path.append('/opt')
sys.path.append('/opt/python')

logger.info(f"Updated sys.path: {sys.path}")


try:
    import jsonschema
    logger.info(f"Successfully imported jsonschema version: {jsonschema.__version__}")
    
    # Instead of importing rpds directly, let's check its location
    import importlib.util
    rpds_spec = importlib.util.find_spec("rpds")
    if rpds_spec is not None:
        logger.info(f"rpds module found at: {rpds_spec.origin}")
    else:
        logger.error("rpds module not found")
    
    # Let's also check for rpds_py
    rpds_py_spec = importlib.util.find_spec("rpds_py")
    if rpds_py_spec is not None:
        logger.info(f"rpds_py module found at: {rpds_py_spec.origin}")
    else:
        logger.error("rpds_py module not found")

except ImportError as e:
    logger.error(f"Failed to import: {e}")
    # If import fails, let's check the contents of the directories in sys.path
    for path in sys.path:
        if os.path.exists(path):
            logger.info(f"Contents of {path}: {os.listdir(path)}")
        else:
            logger.info(f"Path does not exist: {path}")
    raise

session = boto3.Session()
logger = logging.getLogger()

if 'log_level' in os.environ:
    logger.setLevel(os.environ['log_level'])
    logger.info("Log level set to %s" % logger.getEffectiveLevel())
else:
    logger.setLevel(logging.INFO)

# Adapted from aft_commons - account_provisioning_framework.py
def validate_request(payload):
    logger.info("Function Start - validate_request")
    current_dir = os.path.dirname(__file__)
    logger.info(f"Current directory: {current_dir}")
    logger.info(f"Current directory contents: {os.listdir(current_dir)}")
    
    schemas_dir = os.path.join(current_dir, "schemas")
    if os.path.exists(schemas_dir):
        logger.info(f"Schemas directory contents: {os.listdir(schemas_dir)}")
    else:
        logger.error(f"Schemas directory not found at {schemas_dir}")
    
    schema_path = os.path.join(current_dir, "schemas", "valid_alternate_contact_schema.json")
    logger.info(f"Schema path: {schema_path}")
    
    if not os.path.exists(schema_path):
        logger.error(f"Schema file not found at {schema_path}")
        raise FileNotFoundError(f"Schema file not found at {schema_path}")
    
    try:
        with open(schema_path) as schema_file:
            schema_object = json.load(schema_file)
        logger.info("Schema Loaded:" + json.dumps(schema_object))
        jsonschema.validate(payload, schema_object)
        logger.info("Request Validated")
        return True
    except json.JSONDecodeError as e:
        logger.error(f"Error decoding JSON schema: {e}")
        raise
    except jsonschema.exceptions.ValidationError as e:
        logger.error(f"JSON Schema validation error: {e}")
        raise
    except Exception as e:
        logger.error(f"Unexpected error in validate_request: {e}")
        raise

def lambda_handler(event, context):
    try:
        logger.info("AFT Account Alternate Contact - Handler Start")
        logger.info(json.dumps(event))
        payload = event
        action = event.get("action")
        logger.info(f"{action} - {payload}")

        if action == "validate":
            request_validated = validate_request(payload)
            return request_validated
        else:
            raise Exception(
                f"Incorrect Command Passed to Lambda Function. Input: {action}. Expected: 'validate'"
            )
      
    except Exception as e:
        logger.exception(f"Error on AFT Account Alternate contact - {e}")
        raise




# '''
# Copyright Amazon.com, Inc. or its affiliates. All Rights Reserved.

# Permission is hereby granted, free of charge, to any person obtaining a copy of
# this software and associated documentation files (the "Software"), to deal in
# the Software without restriction, including without limitation the rights to
# use, copy, modify, merge, publish, distribute, sublicense, and/or sell copies of
# the Software, and to permit persons to whom the Software is furnished to do so.

# THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
# IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY, FITNESS
# FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR
# COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER
# IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN
# CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.
# '''
# import sys
# import os
# sys.path.append('/opt/python')
# import json
# import logging
# import os
# import boto3
# import jsonschema

# session = boto3.Session()
# logger = logging.getLogger()


# if 'log_level' in os.environ:
#     logger.setLevel(os.environ['log_level'])
#     logger.info("Log level set to %s" % logger.getEffectiveLevel())
# else:
#     logger.setLevel(logging.INFO)

   


# # Adapted from aft_commons - account_provisioning_framework.py
# def validate_request(payload):
#     logger.info("Function Start - validate_request")
#     schema_path = os.path.join(
#         os.path.dirname(__file__), "schemas/valid_alternate_contact_schema.json"
#     )
#     with open(schema_path) as schema_file:
#         schema_object = json.load(schema_file)
#     logger.info("Schema Loaded:" + json.dumps(schema_object))
#     validated = jsonschema.validate(payload, schema_object)
#     if validated is None:
#         logger.info("Request Validated")
#         return True
#     else:
#         raise Exception("Failure validating request.\n{validated}")


# def lambda_handler(event, context):
#   try:
#       logger.info("AFT Account Alternate Contact - Handler Start")
#       logger.debug(json.dumps(event))
#       payload = event
#       action = event["action"]
#       logger.debug("{} - {}".format(action, payload))

#       if action == "validate":
#           request_validated = validate_request(payload)
#           return request_validated
#       else:
#           raise Exception(
#               "Incorrect Command Passed to Lambda Function. Input: {action}. Expected: 'validate'"
#           )
      
#   except Exception as e:
#       logger.exception("Error on AFT Acount Alternate contact - {}".format(e))
#       raise
