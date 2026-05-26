#!/bin/bash
############################
# Author : Narendra
# Date : 25/5/2026
# Project : Roboshop
# Program : Create Cart 
############################

USERID=$(id -u)
LOG_FOLDER="/var/log/shell_script"
LOG_FILE="$LOG_FOLDER/$0.log"
SCRIPT_DIR=$PWD
MONGODB_HOST="mongodb.naren83.online"
R="\e[31m"
G="\e[32m"
Y="\e[33m"
N="\e[0m"

if [ $USERID -ne 0 ]; then
   echo -e " $R Please run the script in ROOT user $N" | tee -a $LOF_FILE
   exit 1
fi

mkdir -p $LOG_FOLDER

VALIDATE(){
    if [ $1 -ne 0 ]; then
       echo -e " $2 ........... $R FAILURE $N" | tee -a $LOF_FILE
       exit 1
    else
       echo -e " $2........... $G SUCCESS $N " | tee -a $LOF_FILE
    fi
}

dnf module disable nodejs -y
dnf module enable nodejs:20 -y &>>$LOG_FILE
VALIDATE $? " Enable nodejs "

dnf install nodejs -y &>>$LOG_FILE
VALIDATE $? "Install NODEJS"

id roboshop &>>$LOG_FILE
if [ $? -ne 0 ]; then
   useradd --system --home /app --shell /sbin/nologin --comment "roboshop system user" roboshop &>>$LOG_FILE
   VALIDATE $? "System user creted"
else
   echo -e " Roboshop already existed .... $Y SKIPPED $N" 
fi

mkdir -p /app 
VALIDATE $? "Creating app directory"

curl -L -o /tmp/cart.zip https://roboshop-artifacts.s3.amazonaws.com/cart-v3.zip &>>$LOG_FILE
VALIDATE $? " Download cart code"

cd /app 
VALIDATE $? "Change directory"

rm -rf /app/*
VALIDATE $? " Removing previous files"

unzip /tmp/cart.zip
VALIDATE $? "Unzip cart code"

npm install
VALIDATE $? "Installing Dependencies"

cp $SCRIPT_DIR/cart.service /etc/systemd/system/cart.service &>>$LOG_FILE
VALIDATE $? "Creating systemctl services"

systemctl daemon-reload
systemctl enable cart  &>>$LOG_FILE
systemctl start cart
VALIDATE $? "Enable and start cart services"