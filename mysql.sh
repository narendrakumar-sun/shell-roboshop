#!/bin/bash
#################################
# Author : Narendra
# Date : 25/5/2026
# Project : Roboshop
# Program : Mysql creation
################################

USERID=$(id -u)
LOG_FOLDER="var/log/shell_script"
LOG_FILE="$LOG_FOLDER/$0.log"
SCRIPT_DIR=$PWD
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

dnf install mysql-server -y &>>$LOG_FILE
VALIDATE $? "Installing mysql server"

systemctl enable mysqld &>>$LOG_FILE
systemctl start mysqld  
VALIDATE $? "Enable and Start mysql"

mysql_secure_installation --set-root-pass RoboShop@1
VALIDATE $? "Creating Password for mysql"