#!/bin/bash

USERID=$(id -u)
R="\e[31m"
G="\e[32m"
Y="\e[33m"
N="\e[0m"
LOGS_FOLDER="/var/logs/roboshop-logs"
SCRIPT_NAME="$(echo $0 | cut -d '.' -f1)"
LOG_FILE="$LOGS_FOLDER/$SCRIPT_NAME.log"

mkdir -p $LOGS_FOLDER
echo "Script started executing at: $(date)" | tee -a $LOG_FILE

if [ $USERID -ne 0 ]
then
    echo -e "$R ERROR: You are running with non root user, Please use root user $N" | tee -a $LOG_FILE
    exit 1
else 
    echo -e "$G You are running with root user...$N" | tee -a $LOG_FILE
fi

echo "Enter password for MySQL root user:"
read -s RABBITMQ_PWD

VALIDATE() {
    if [ $1 -ne 0 ]
    then
        echo -e "$2 is failed...." | tee -a $LOG_FILE
        exit 1
    else
        echo -e "$2 is Successfull...." | tee -a $LOG_FILE
    fi
}

cp $SCRIPT_DIR/rabbitmq.repo /etc/yum.repos.d/rabbitmq.repo
VALIDATE $? "Copying RabbitMQ Repo file"

dnf install rabbitmq-server -y &>>$LOG_FILE
VALIDATE $? "RabbitMQ Installation"

systemctl enable rabbitmq-server &>>$LOG_FILE
VALIDATE $? "Enabling RabbitMQ service"

systemctl start rabbitmq-server &>>$LOG_FILE
VALIDATE $? "Starting RabbitMQ service"

rabbitmqctl add_user roboshop $RABBITMQ_PWD
rabbitmqctl set_permissions -p / roboshop ".*" ".*" ".*"
VALIDATE $? "Creating Application User in RabbitMQ"