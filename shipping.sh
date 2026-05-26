#!/bin/bash
###########################
# Author : Narendra
# Date : 25/5/2026
# Project : Roboshop
# Program : Creating Shipping 
##############################

USERID=$(id -u)
LOG_FOLDER="/var/log/shell_script"
LOG_FILE="$LOG_FOLDER/$0.log"
R="\e[31m"
G="\e[32m"
Y="\e[33m"
N="\e[0m"
SCRIPT_DIR=$pwd
MONGODB_HOST="mongodb.naren83.online"
MYSQL_HOST="mysql.naren83.online"

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

dnf install maven -y &>>$LOG_FILE
VALIDATE $? "INSTALING MAVEN"

id roboshop &>>$LOG_FILE
if [ $? -ne 0 ]; then
   useradd --system --home /app --shell /sbin/nologin --comment "roboshop system user" roboshop &>>$LOG_FILE
   VALIDATE $? "System user creating"
else
   echo -e "Roboshop already exist $Y SKIPPING $N"
fi

mkdir -p /app
VALIDATE $? "creating app directory"

mkdir -p /app 
VALIDATE $? "Creating app directory"

curl -o /tmp/shipping.zip https://roboshop-artifacts.s3.amazonaws.com/shipping-v3.zip  &>>$LOG_FILE
VALIDATE $? "Downloading shipping code"

cd /app
VALIDATE $? "Moving to app directory"

rm -rf /app/*
VALIDATE $? "Removing existing code"

unzip /tmp/shipping.zip &>>$LOG_FILE
VALIDATE $? "Uzip shipping code"

mvn clean package
VALIDATE $? "installing maven package"

mv target/shipping-1.0.jar shipping.jar 
VALIDATE $? "Moving and Renaming shipping"

cp /shipping.service /etc/systemd/system/shipping.service
VALIDATE $? "Created systemctl service"

dnf install mysql -y  &>>$LOG_FILE
VALIDATE $? "Install mysql client"

mysql -h $MYSQL_HOST -uroot -pRoboShop@1 -e 'use cities'
if [ $? -ne 0 ]; then
   mysql -h $MYSQL_HOST -uroot -pRoboShop@1 < /app/db/schema.sql &>>$LOG_FILE
   mysql -h $MYSQL_HOST -uroot -pRoboShop@1 < /app/db/app-user.sql &>>$LOG_FILE
   mysql -h $MYSQL_HOST -uroot -pRoboShop@1 < /app/db/master-data.sql &>>$LOG_FILE
   VALIDATE $? "Loaded data into mysql"
else
   echo -e " Data already loaded $Y SKIPPING $N"
fi

systemctl enable shipping &>>$LOG_FILE
systemctl start shipping
VALIDATE $? "Enabled and started shipping"