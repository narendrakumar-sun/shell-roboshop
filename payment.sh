#!/bin/bash
################################################
# Author : Narendra
# Date : 24/5/2026
# Project : Roboshop
# Programe : Payment instance creation 
################################################

USERID=$(id -u)
LOG_FOLDER="/var/log/shell_script"
LOG_FILE="$LOG_FOLDER/$0.log"
R="\e[31m"
G="\e[32m"
Y="\e[33m"
N="\e[0m"
SCRIPT_DIR=$PWD
MONGODB_HOST="mongodb.naren83.online"

if [ $USERID -ne 0 ]; then
   echo -e "$R Please Run the script in Root User $N" | tee -a $LOG_FILE
   exit 1
fi

mkdir -p $LOG_FOLDER

VALIDATE(){
    if [ $1 -ne 0 ]; then
       echo -e " $2 ...... $Y FAILURE $N " | tee -a $LOG_FILE
       exit 1
    else 
       echo -e " $2 ........ $G SUCCESS $N" | tee -a $LOG_FILE
    fi
}

dnf install python3 gcc python3-devel -y &>>$LOG_FILE
VALIDATE $? "python installed"

id roboshop &>>$LOG_FILE

if [ $? -ne 0 ]; then
    useradd --system --home /app --shell /sbin/nologin --comment "roboshop system user" roboshop &>>$LOG_FILE
    VALIDATE $? "Creating system user"
else
    echo -e "Roboshop user already exist ... $Y SKIPPING $N"
fi

mkdir -p /app 
VALIDATE $? " Creating app directory"

curl -o /tmp/payment.zip https://roboshop-artifacts.s3.amazonaws.com/payment-v3.zip &>>$LOG_FILE
VALIDATE $? "Dowload payment code"

cd /app
VALIDATE $? " Enter to app directory"

rm -rf /app/*
VALIDATE $? "Removing existing code"

unzip /tmp/payment.zip
VALIDATE $? "unzip payment code"

systemctl daemon-reload
systemctl enable payment &>>$LOG_FILE
systemctl start payment
VALIDATE $? "Enable and start payment"
