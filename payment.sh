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

dnf install python3 gcc python3-devel -y &>>$LOG_FILE
VALIDATE $? "Installing Python3"

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

curl -L -o /tmp/payment.zip https://roboshop-artifacts.s3.amazonaws.com/payment-v3.zip &>>$LOG_FILE
VALIDATE $? "Downloading payment Application"

rm -rf /app/* &>>$LOG_FILE
VALIDATE $? "Removing old payment Application files"

cd /app 
unzip /tmp/payment.zip &>>$LOG_FILE
VALIDATE $? "Unzipping payment Application"

pip3 install -r requirements.txt &>>$LOG_FILE
VALIDATE $? "Installing payment Application dependencies"

cp $SCRIPT_DIR/payment.service /etc/systemd/system/payment.service
VALIDATE $? "Copying payment service file"

systemctl daemon-reload &>>$LOG_FILE
VALIDATE $? "System Reloading"

systemctl enable payment &>>$LOG_FILE
VALIDATE $? "Enabling the cart service"

systemctl start payment &>>$LOG_FILE
VALIDATE $? "Starting cart service"