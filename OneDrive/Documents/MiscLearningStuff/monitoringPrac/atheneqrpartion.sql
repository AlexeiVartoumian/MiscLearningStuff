SELECT
  eventtime,
  useridentity.username AS username,
  useridentity.type AS user_type,
  useridentity.arn AS user_arn,
  eventsource,
  eventname,
  sourceipaddress,
  requestparameters
FROM
  cloudtrail_logs
WHERE
  region = 'eu-west-2'
  AND year = '2024'
  AND month = '08'
  AND day >= '01'
  AND eventsource LIKE '%rds%'
  AND eventname IN (
    'ConnectToInstance',
    'Connect',
    'Login',
    'StartDBInstance',
    'ModifyDBInstance'
  )
  AND (
    requestparameters LIKE '%"db-test"%'
  )
ORDER BY
  eventtime DESC
LIMIT 10;