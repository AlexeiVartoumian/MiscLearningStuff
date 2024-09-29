#!/bin/bash

# start java server and log files and keep running after execution

#nohup java -cp /home/ec2-user/SimpleServer/out/production/SimpleServer/ SimpleServer &

nohup java -cp /home/ec2-user/SimpleServer/out/production/SimpleServer/ SimpleServer > server.out 2> server.err &



#ec2-java-Server-Reboot.sh