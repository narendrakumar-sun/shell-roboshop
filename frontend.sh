#!/bin/bash
################################################
# Author : Narendra
# Date : 24/5/2026
# Project : Roboshop
# Programe : frontend instance creation 
################################################

USERID=$(id -u)
LOG_FOLDER="/var/log/shell_script"
LOG_FILE="$LOG_FOLDER/$0.log"
R="\e[31m"
G="\e[32m"
Y="\e[33m"
N="\e[0m"
SCRIPT_DIR=$pwd
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

dnf module disable nginx -y &>>$LOG_FILE
dnf module enable nginx:1.24 -y &>>$LOG_FILE
dnf install nginx -y &>>$LOG_FILE
VALIDATE $? "Enable and Start nginx"

systemctl enable nginx &>>$LOG_FILE 
systemctl start nginx  
VALIDATE $? "Enable and start Nginx"

rm -rf /usr/share/nginx/html/* 
VALIDATE $? "Removing existing files"

curl -o /tmp/frontend.zip https://roboshop-artifacts.s3.amazonaws.com/frontend-v3.zip &>>$LOG_FILE
VALIDATE $? "Downloaded frontend code"

cd /usr/share/nginx/html 
unzip /tmp/frontend.zip
VALIDATE $? "Unzip frontend code"

cp $SCRIPT_DIR/nginx.conf /etc/nginx/nginx.conf 
VALIDATE $? "change configurations of nginx"

systemctl restart nginx 
VALIDATE $? "Restart nginx"
