#!/bin/bash

lsof /var/bin/log/bad.log #-> get who has open and pid prcoess identifer

sudo kill 


#or 

ps aux | grep python # find open procs if and get pid from there