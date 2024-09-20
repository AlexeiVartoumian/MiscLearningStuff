
SELECT
eventtime,
useridenity.username
useridentity.type
useridentity.arn
eventsource
eventanme
from cloudtrail_logs_bucket
where
    eventsource LIKE 'rds.amazonaws.com'
ORDER BY
    eventtime DESC
LIMIT 10;

