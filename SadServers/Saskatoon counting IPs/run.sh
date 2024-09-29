#!/bin/bash

#since file is separated could use awk to iterate
#by first column which is denoted with $1 and use an associateve / key/val pair to count in memory.



awk '{ip=$1; count[ip]++} END {max=0; for (ip in count) {if (count[ip] > max) {max=count[ip]; maxip=ip}}} END {print maxip}' /home/admin/access.log > /home/admin/highestip.txt


# could also break this down into steps and log in seprate files

awk '{print $1}' /home/admin/access.log > /home/admin/ips.txt # grab the first column of the file append to text

sort ips.txt | uniq -c > /home/admin/countedips.txt  # sort the ips alphabetticaly , uniq filters through consecutive ines and -c counts them should be done after sort . store count ip in txt file



sort -nr /home/admin/counted_ips.txt | head -n 1 > home/admin/top_ip.txt 

awk '{print $2}' /home/admin/top_ip.txt > /home/admin/highestip.txt 
# grab seconf col which is ip store in file