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
read -s MYSQL_ROOT_PWD

VALIDATE() {
    if [ $1 -ne 0 ]
    then
        echo -e "$2 is failed...." | tee -a $LOG_FILE
        exit 1
    else
        echo -e "$2 is Successfull...." | tee -a $LOG_FILE
    fi
}

dnf install mysql-server -y &>>$LOG_FILE
VALIDATE $? "Mysql Installation"

systemctl enable mysqld &>>$LOG_FILE
VALIDATE $? "MYSQL Enabling"

systemctl start mysqld &>>$LOG_FILE
VALIDATE $? "MYSQL Starting"

mysql_secure_installation --set-root-pass $MYSQL_ROOT_PWD &>>$LOG_FILE
VALIDATE $? "Setting up the MYSQL root password"