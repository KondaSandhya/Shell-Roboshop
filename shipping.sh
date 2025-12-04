#!/bin/bash

USERID=$(id -u)
R="\e[31m"
G="\e[32m"
Y="\e[33m"
N="\e[0m"
LOGS_FOLDER="/var/logs/roboshop-logs"
SCRIPT_NAME="$(echo $0 | cut -d '.' -f1)"
LOG_FILE="$LOGS_FOLDER/$SCRIPT_NAME.log"
SCRIPT_DIR=$(pwd)

mkdir -p $LOGS_FOLDER
echo "Script started executing at: $(date)" | tee -a $LOG_FILE

if [ $USERID -ne 0 ]
then
    echo -e "$R ERROR: You are running with non root user, Please use root user $N" | tee -a $LOG_FILE
    exit 1
else 
    echo -e "$G You are running with root user...$N" | tee -a $LOG_FILE
fi

VALIDATE() {
    if [ $1 -ne 0 ]
    then
        echo -e "$2 is failed...." | tee -a $LOG_FILE
        exit 1
    else
        echo -e "$2 is Successfull...." | tee -a $LOG_FILE
    fi
}

dnf install maven -y &>>$LOG_FILE
VALIDATE $? "Maven Installation"

id roboshop 
if [ $? -ne 0 ]
then
    useradd --system --home /app --shell /sbin/nologin --comment "roboshop system user" roboshop &>>$LOG_FILE
    VALIDATE $? "Adding roboshop user"
else
    echo -e "$G roboshop user already exists, Skipping the user creation $N" | tee -a $LOG_FILE
fi

mkdir -p /app
VALIDATE $? "Creating the App directory"

curl -L -o /tmp/shipping.zip https://roboshop-artifacts.s3.amazonaws.com/shipping-v3.zip  &>>$LOG_FILE
VALIDATE $? "Downloading the Shipping Application"

rm -rf /app/* &>>$LOG_FILE
VALIDATE $? "Removing old catalogue Application files"

cd /app 

unzip /tmp/shipping.zip &>>$LOG_FILE
VALIDATE $? "Unzipping the Shipping Application"

cd /app
mvn clean package &>>$LOG_FILE
VALIDATE$? "Building the shipping application"sys

mv target/shipping-1.0.jar shipping.jar &>>$LOG_FILE
VALIDATE $? "Renaming the shipping jar file"

cp $SCRIPT_DIR/shipping.service /etc/systemd/system/shipping.service $>>$LOG_FILE
VALIDATE $? "Copying shipping service file"

systemctl daemon-reload &>>$LOG_FILE
VALIDATE $? "System Reloading"

systemctl enable shipping &>>$LOG_FILE
syatemctl start  shipping &>>$LOG_FILE
VALIDATE $? "Starting shipping service"

mysql -h mysql.devops84s.shop -uroot -pRoboShop@1 < /app/db/schema.sql

mysql -h mysql.devops84s.shop -uroot -pRoboShop@1 < /app/db/app-user.sql 

mysql -h mysql.devops84s.shop -uroot -pRoboShop@1 < /app/db/master-data.sql

systemctl restart shipping
