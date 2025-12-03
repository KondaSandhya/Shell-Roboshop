#!/bin/bash

USERID=$(id -u)
R="\e[31m"
G="\e[32m"
Y="\e[33m"
N="\e[0m"
LOGS_FOLDER="/var/logs/roboshop-logs"
SCRIPT_NAME="$(echo $0 | cut -d '.' -f1)"
LOG_FILE="$LOGS_FOLDER/$SCRIPT_NAME"

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

dnf module disable nodejs -y &>>$LOG_FILE
VALIDATE $? "Disabling Nodejs"

dnf module enable nodejs:20 -y &>>$LOG_FILE
VALIDATE $? "Enabling Nodejs"

dnf module install nodejs -y &>>$LOG_FILE
VALIDATE $? "Nodejs Installation"

useradd --system --home /app --shell /sbin/nologin --comment "roboshop system user" roboshop &>>$LOG_FILE
VALIDATE $? "Adding roboshop user"

mkdir -p /app 
VALIDATE $? "Creating the App directory"

curl -o /tmp/catalogue.zip https://roboshop-artifacts.s3.amazonaws.com/catalogue-v3.zip  &>>$LOG_FILE
VALIDATE $? "Downloading catalogue Application"

cd /app 

unzip /tmp/catalogue.zip &>>$LOG_FILE
VALIDATE $? "Unzipping catalogue Application"

npm install &>>$LOG_FILE
VALIDATE $? "Installing Nodejs Dependencies"

cp catalogue.service /etc/systemd/system/catalogue.service
VALIDATE $? "Copying catalogue service file"

systemctl daemon-reload &>>$LOG_FILE
systemctl enable catalogue &>>$LOG_FILE
systemctl start catalogue &>>$LOG_FILE
VALIDATE $? "Starting catalogue service"

dnf install mongodb-mongosh -y &>>$LOG_FILE
VALIDATE $? "Mongosh Installation"

mongosh --host mongodb.devops84s.shop </app/db/master-data.js>
VALIDATE $? "Loading the catalogue data to Mongodb"

