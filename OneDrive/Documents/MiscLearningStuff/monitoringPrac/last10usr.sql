SELECT 
    eventtime,
    eventname,
    useridentity.username,
    sourceipaddress
FROM 
    cloudtrail.cloudtrail_logs_adjusted
WHERE 
    organization = 'o-m9jr8f8hqe'
    AND account = '891377180089'
    AND region = 'eu-west-2'
    AND year = '2024'
    AND month = '08'
    AND eventsource = 'iam.amazonaws.com'
    AND useridentity.type = 'IAMUser'
ORDER BY 
    eventtime DESC
LIMIT 10;

partitioned table results
Completed
Time in queue:
91 ms
Run time:
758 ms
Data scanned:
1.93 MB

SELECT 
    eventtime,
    eventname,
    useridentity.username,
    sourceipaddress
FROM 
    cloudtrail.cloudtrail_events_standard
WHERE 
    recipientaccountid = '891377180089'
    AND eventsource = 'iam.amazonaws.com'
    AND useridentity.type = 'IAMUser'
ORDER BY 
    eventtime DESC
LIMIT 10;
Completed
Time in queue:
55 ms
Run time:
8.834 sec
Data scanned:
69.68 MB