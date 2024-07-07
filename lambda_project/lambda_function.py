import requests
import json
import boto3
from datetime import datetime


sns_client = boto3.client('sns')

SNS_TOPIC_ARN = "your SNS ADDRESS RESOLution NAME "
def lambda_handler(event , context):
    
    res = requests.get("https://api.tfl.gov.uk/line/mode/tube/status")


    #print(res.text)

    print(type(res))
    print(type(res.text))

    thing = json.loads(res.text)

    print(type(thing))
    def happyclappy(time):

        minutes = int(time/60)
        seconds = time % 60
        timetaken = f'{minutes} minutes & { seconds} seconds '
        return timetaken
    for tubes in thing:
        # print(tubes)
        # print("/n")
        if tubes["id"] == "central" :

            #print(tubes)
            #['statusSeverityDescription']
            #print(tubes["lineStatuses"])
            #print(len(tubes["lineStatuses"]))
            # for state , status in tubes["lineStatuses"][0].items():
                
            #     print(state , ": " , status)
            state =  tubes["lineStatuses"][0]["statusSeverityDescription"]
            
            if state == "Good Service" or "Minor Delays":

                now = datetime.now()
                current_time = now.strftime("%H:%M:%S")
                multilinestring = "Current Time = " +  current_time
                multilinestring += "\n"


                if state == "Minor Delays":
                    multilinestring += tubes["lineStatuses"][0]["statusSeverityDescription"] 
                    multilinestring += tubes["lineStatuses"][0]["reason"]
                    multilinestring+= "\n"
                    multilinestring += "\n"

                station_id = "940GZZLUQWY" 
                url = f'https://api.tfl.gov.uk/StopPoint/{station_id}/Arrivals?app_id'
                response = requests.get(url)
                arrivals = response.json()
                
                records = {}
                order = []
                for arrival  in arrivals:
                    if arrival["platformName"]== "Eastbound - Platform 2":
                        seconds = arrival['timeToStation']
                        timetostation = happyclappy(arrival['timeToStation'] )
                        #print(f"Line: {arrival['lineName']}, Destination: {arrival['destinationName']}, Time to Station: {arrival['timeToStation']} seconds")
                        value =  f"Line: {arrival['lineName']}, Destination: {arrival['destinationName']}, Time to Station: {timetostation}"
                        records[seconds] = value
                        order.append(seconds)
                order.sort()
                
                for i in order:
                    #print(records[i])
                    multilinestring+= records[i] 
                    multilinestring += "\n"
                    multilinestring += "\n"
                print(multilinestring)
                sns_response = sns_client.publish(
                TopicArn=SNS_TOPIC_ARN,
                Message=multilinestring,
                Subject='Lambda Function Result'
                )
                return sns_response
                
            else:
               
                    
                result = "MAIN TRANSPORTATION DOWN! FLEE FOR YOUR LIFE!"
                result += tubes["lineStatuses"][0]["statusSeverityDescription"] 
                result += tubes["lineStatuses"][0]["reason"]
                #result += "MAIN TRANSPORTATION DOWN! SEEK HELP"

                sns_response = sns_client.publish(
                TopicArn=SNS_TOPIC_ARN,
                Message=result,
                Subject='Lambda Function Result'
                )
                return sns_response
                #return "MAIN TRANSPORTATION DOWN! SEEK HELP"




#test conn below
# import json
# #import requests

# def lambda_handler(event, context):
#     try:
#         import requests
#         response = requests.get('https://api.example.com')
#         return {
#             'statusCode': 200,
#             'body': json.dumps('Hello from Lambda! Requests is working.')
#         }
#     except ImportError as e:
#         return {
#             'statusCode': 500,
#             'body': json.dumps(f'Error importing requests: {str(e)}')
#         }
#     except Exception as e:
#         return {
#             'statusCode': 500,
#             'body': json.dumps(f'Unexpected error: {str(e)}')
#         }
