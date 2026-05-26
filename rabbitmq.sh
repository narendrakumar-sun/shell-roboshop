#!/bin/bash
#####################################
# Author : narendra
# Date : 25/5/2026
# Project : Robodhop
# Program : Create Redis Database
#####################################

USERID=$(id -u)
LOG_FOLDER="/var/log/shell_script"
LOF_FILE="$LOG_FOLDER/$0.log"
SCRIPT_DIR=$pwd
R="\e[31m"
G="\e[32m"
Y="\e[33m"
N="\e[0m"

if [ $USERID -ne 0 ]; then
   echo -e "$R Please run the script in ROOT user $N" | tee -a $LOF_FILE
   exit 1
fi
mkdir -p $LOG_FOLDER

VALIDATE(){
    if [ $1 -ne 0 ]; then
       echo -e "$2...........$R FAILURE $N" | tee -a $LOF_FILE
       exit 1
    else
       echo -e "$2..........$G SUCCESS $N" | tee -a $LOF_FILE
    fi
}

cp $SCRIPT_DIR/rabbitmq.repo /etc/yum.repos.d/rabbitmq.repo &>>$LOG_FILE
VALIDATE $? "Copy Rabbitmq server"

dnf install rabbitmq-server -y &>>$LOG_FILE
VALIDATE $? "install Rabbitmq server"

systemctl enable rabbitmq-server &>>$LOG_FILE
systemctl start rabbitmq-server
VALIDATE $? " Enable and start rabbitmq"

rabbitmqctl add_user roboshop roboshop123
rabbitmqctl set_permissions -p / roboshop ".*" ".*" ".*"
VALIDATE $? "create user and permissions in roboshop"
