#!/bin/bash

# start java server and log files and keep running after execution

#nohup java -cp /home/ec2-user/SimpleServer/out/production/SimpleServer/ SimpleServer &

#nohup java -cp /home/ec2-user/SimpleServer/out/production/SimpleServer/ SimpleServer &

echo "Starting Java server..."
#nohup java -cp /home/ec2-user/SimpleServer/out/production/SimpleServer/ SimpleServer > /home/ec2-user/java_output.log 2>&1 &

#nohup java -jar /home/ec2-user/SimpleServer.jar /home/ec2-user/java_output.log 2>&1 &
nohup java -jar /home/ec2-user/SimpleServer.jar &


