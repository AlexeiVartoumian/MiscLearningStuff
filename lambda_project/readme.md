
Push station updates to personal email and ideally sms but expensive. use lambda to be triggered by event bridge with cron job and sns topic subscribed. Use ARN to hit the topic endpoint. just for fun

-------------------------------------demo output for email and sms----------------------------------------
Current Time = 15:20:24
Minor DelaysCentral Line: Minor delays between Leytonstone and Hainault via Newbury Park due to train cancellations. GOOD SERVICE on the rest of the line.

Line: Central, Destination: Epping Underground Station, Time to Station: 0 minutes & 47 seconds

Line: Central, Destination: Epping Underground Station, Time to Station: 6 minutes & 47 seconds

Line: Central, Destination: Epping Underground Station, Time to Station: 7 minutes & 48 seconds

Line: Central, Destination: Epping Underground Station, Time to Station: 12 minutes & 48 seconds

Line: Central, Destination: Hainault Underground Station, Time to Station: 15 minutes & 48 seconds

Line: Central, Destination: Epping Underground Station, Time to Station: 18 minutes & 48 seconds

Line: Central, Destination: Epping Underground Station, Time to Station: 26 minutes & 48 seconds

-------------------------------------------------------------------------------------------------

useful links for tfl line status stuff

live update for my train station
https://tfl.gov.uk/tube/stop/940GZZLUQWY/queensway-underground-station/?Input=Queensway+Underground+Station

naptan ids for all underground stations. useful for getting live updates of arrivals on a given underground.
https://github.com/ZackaryH8/tube-naptan/blob/master/data/naptan.csv

demo eg on this live updates api end point:
station_id = "940GZZLUQWY" 
url = f'https://api.tfl.gov.uk/StopPoint/{station_id}/Arrivals?app_id'


stuff for lambda

setup virtual environment to install required packages for given project that lmabda will need .

py .\.venv\Scripts\activate
python -m pip install -r requirements.txt  -> once env setup install dependencies inside of venv to avoid global package conflicts

pip install requests -t ./package  -> for lambda put all imports that lambda cannot read natively into packages folder mkdir package beforehand

useful command for zip compression on windows had a weird issue where only the lambda function would zip and none of the dependencies
in the virtual env or packages would be included that were needed for the lambda

Compress-Archive -Path lambda_function.py -DestinationPath lambda_function.zip -Force
Compress-Archive -Path package/* -Update -DestinationPath lambda_function.zip