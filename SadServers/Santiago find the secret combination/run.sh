#!/bin/bash


cd /home/admin

alice_count=$grep( -rc Alice *.txt | awk -F '{sum += $2} END {print sum}')

echo -n "$alice_count" > /home/admin/solution

alice_file=$(grep -rc Alice *.txt | awk -F: '$2 == 1 {print $1}')


second_number=$(grep Alice -A 1 "$alice_file" | tail -n 1 | grep -o '[0-9]\+')

echo "$second_number" >> /home/admin/solution


[cloudshell-user@ip-10-132-13-29 ~]$ aws controltower list-landing-zones 
{
    "landingZones": [
        {
            "arn": "arn:aws:controltower:eu-west-2:390746273208:landingzone/133MC4TJ406RS2G5"
        }
    ]
}

