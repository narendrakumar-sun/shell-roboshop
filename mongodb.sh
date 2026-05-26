#!/bin/bash

##############################################
#
# Author : Narendrs
# Date : 24/5/2026
# Project : Roboshop
# Program : Creating Mongodb for data base
###############################################

USERID=$(id -u)
LOG_FOLDER="/var/log/shell_script"
LOG_FILE="$LOG_FOLder/$0.log"
R="\e[31m"
G="\e[32m"
Y="\e[33m"
N="\e[0m"

if [ $USERID -ne 0 ]; then
    echo -e " $R Pleas ru the script in ROOt user $N" | tee -a $LOG_FILE
    exit 1
fi

mkdir -p $LOG_FOLDER

VALIDATE(){
    if [ $1 -ne 0 ]; then
       echo -e " $2 .......... $R FAILURE $N" | tee -a $LOG_FILE
       exit 1
    else 
       echo -e "$2 ............... $G SUCCESS $N" | tee -a $LOG_FILE
    fi
}


cp mongo.repo /etc/yum.repos.d/mongo.repo
VALIDATE $? " Coping mongo repo"

dnf install mongodb-org -y &>>$LOG_FILE
VALIDATE $? "install mongodb-wserver"

systemctl enable mongod &>>$LOGS_FILE
VALIDATE $? "Enable MongoDB"

systemctl start mongod
VALIDATE $? "Start MongoDB"

sed -i 's/127.0.0.1/0.0.0.0/g' /etc/mongod.conf
VALIDATE $? "Allowing remote connections"

systemctl restart mongod
VALIDATE $? "Restarted MongoDB"