#!/bin/bash

log_folder="/var/log/roboshop"
sudo mkdir -p $log_folder
sudo chown -R ec2-user:ec2-user $log_folder
sudo chmod -R 755 $log_folder 
logfile="$log_folder/$0.log"

userid=$(id -u)
R="\e[31m"
G="\e[32m"
Y="\e[33m"
N="\e[0m"

if [ $userid -ne 0 ]; then
echo -e " $R please login with root $N " | tee -a $logfile
exit 1
fi

cp mongo.repo /etc/yum.repos.d/mongo.repo
