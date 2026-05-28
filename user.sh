#!/bin/bash
#######################################
# Author : Narendra
# Date : 25/5/2026
# Project : Roboshop
# Program : Creatinng User
######################################

USERID=$(id -u)
LOG_FOLDER="/var/log/shell_script"
LOG_FILE="$LOG_FOLDER/$0.log"
R="\e[31m"
G="\e[32m"
Y="\e[33m"
N="\e[0m"
SCRIPT_DIR=$PWD

if [ $USERID -ne 0 ]; then
   echo -e "$R Please run the script in root User $N" | tee -a $LOG_FILE
   exit 1
fi
mkdir -p $LOG_FOLDER

VALIDATE(){
    if [ $1 -ne 0 ]; then
       echo -e "$2............$R FAILURE $N" | tee -a $LOG_FILE
       exit 1
    else
       echo -e "$2............$G SUCCESS $N" | tee -a $LOG_FILE
    fi
}

dnf module disable nodejs -y
dnf module enable nodejs:20 -y &>>$LOG_FOLDER
VALIDATE $? " Enable Nodejs"

dnf install nodejs -y &>>$LOG_FILE
VALIDATE $? " Install Nodejs"

id roboshop &>>$LOG_FILE
if [ $? -ne 0 ]; then
   useradd --system --home /app --shell /sbin/nologin --comment "roboshop system user" roboshop &>>$LOG_FILE
   VALIDATE $? "Creating system user"
else
   echo -e " Roboshop user already exist ........ $Y SKIPPING $N" 
fi

mkdir -p /app
VALIDATE $? " Creating app directory"

curl -L -o /tmp/user.zip https://roboshop-artifacts.s3.amazonaws.com/user-v3.zip &>>$LOG_FILE
VALIDATE $? " Download user code"

cd /app 
VALIDATE $? " Enter app directory"
rm -rf /app/*
VALIDATE $? "Deleting exist files"

unzip /tmp/user.zip &>>$LOG_FILE
VALIDATE $? " Unzip downloading code"

npm install &>>$LOG_FILE
VALIDATE $? "Installing dependies"

cp $SCRIPT_DIR/user.service /etc/systemd/system/user.service
VALIDATE $? "Creating systemctl server"

systemctl daemon-reload
systemctl enable user &>>$LOG_FILE 
systemctl start user
VALIDATE $? " Enable and start user"