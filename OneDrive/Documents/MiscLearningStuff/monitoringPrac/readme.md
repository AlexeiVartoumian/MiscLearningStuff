create table by going to cloud trail logs with option for table there
athena table query for last 10 users of db.

todo : find a way to partition , current method keeps erroring out with a weird error

line 1:8: mismatched input 'EXTERNAL'. EXPECTING: 'MATERIALIZED' , 'MULTI', 'OR' , 'PROTECTED' , 'ROLE' , 'SCHEMA' , 'TABLE' , 'VIEW' ATHENA

dont know the cause of error but always happends when i try to partition and works just fine when i remove the Partioned stuff..


source of truth: https://repost.aws/knowledge-center/athena-cloudtrail-data-timeout
a few things
-make sure in athena settings there is an output bucket and a database to attach the table to.
need to go to glue to create that db pointing tot he cloud trail bucket.

creating standard table can be done by going cloudtrail - events create athena table , copy response into the query editor.

to partition pay attentiton to bucket structure and make sure it in table properties it matches.
my bucket was made really recently so data ranges and account nums should reflect that.
my bucket strucuture has is like so

Amazon S3
Buckets
aws-controltower-logs-654654622351-eu-west-2
o-m9jr8f8hqe/
AWSLogs/
o-m9jr8f8hqe/
891377180089/
CloudTrail/
eu-west-2/
2024/
08/
19/

working partitioned table
CREATE EXTERNAL TABLE cloudtrail.cloudtrail_logs_adjusted (
  eventversion STRING,
  useridentity STRUCT<
    type: STRING,
    principalid: STRING,
    arn: STRING,
    accountid: STRING,
    invokedby: STRING,
    accesskeyid: STRING,
    username: STRING,
    sessioncontext: STRUCT<
      attributes: STRUCT<
        mfaauthenticated: STRING,
        creationdate: STRING>,
      sessionissuer: STRUCT<
        type: STRING,
        principalid: STRING,
        arn: STRING,
        accountid: STRING,
        username: STRING>>>,
  eventtime STRING,
  eventsource STRING,
  eventname STRING,
  awsregion STRING,
  sourceipaddress STRING,
  useragent STRING,
  errorcode STRING,
  errormessage STRING,
  requestparameters STRING,
  responseelements STRING,
  additionaleventdata STRING,
  requestid STRING,
  eventid STRING,
  resources ARRAY<STRUCT<arn: STRING, accountid: STRING, type: STRING>>,
  eventtype STRING,
  apiversion STRING,
  readonly STRING,
  recipientaccountid STRING,
  serviceeventdetails STRING,
  sharedeventid STRING,
  vpcendpointid STRING
)
PARTITIONED BY (
  organization STRING,
  account STRING,
  region STRING,
  year STRING,
  month STRING,
  day STRING
)
ROW FORMAT SERDE 'com.amazon.emr.hive.serde.CloudTrailSerde'
STORED AS INPUTFORMAT 'com.amazon.emr.cloudtrail.CloudTrailInputFormat'
OUTPUTFORMAT 'org.apache.hadoop.hive.ql.io.HiveIgnoreKeyTextOutputFormat'
LOCATION 's3://aws-controltower-logs-654654622351-eu-west-2/o-m9jr8f8hqe/AWSLogs/'
TBLPROPERTIES (
  'projection.enabled'='true',
  'projection.organization.type'='enum',
  'projection.organization.values'='o-m9jr8f8hqe',
  'projection.account.type'='enum',
  'projection.account.values'='891377180089',
  'projection.region.type'='enum',
  'projection.region.values'='eu-west-2',
  'projection.year.type'='enum',
  'projection.year.values'='2024',
  'projection.month.type'='integer',
  'projection.month.range'='1,12',
  'projection.month.digits'='2',
  'projection.day.type'='integer',
  'projection.day.range'='1,31',
  'projection.day.digits'='2',
  'storage.location.template'='s3://aws-controltower-logs-654654622351-eu-west-2/o-m9jr8f8hqe/AWSLogs/${organization}/${account}/CloudTrail/${region}/${year}/${month}/${day}/'
)