#!/bin/bash

userid=$(id -u)

R="\e[31m"
G="\e[32m"
Y="\e[33m"
W="\e[0m"



SCRIPT_PATH=/var/log/roboshop_logs
SCRIPT_NAME=$(echo $0 | cut -d "." -f1)
LOG_FILE="$SCRIPT_PATH/$SCRIPT_NAME.log"

user_home=$PWD

mkdir -p $SCRIPT_PATH

echo -e "Script started on $(date)"

if [ $userid == 0 ]
then
    echo -e "$Y Your Running with root user $W" | tee -a $LOG_FILE
else
    echo -e "$R ERROR:: Your not running with root user $W" | tee -a $LOG_FILE
    exit 1
fi

VALIDATION(){
    if [ $1 == 0 ]
    then
        echo -e "$G $2 Installation is Successful $W" | tee -a $LOG_FILE
    else
        echo -e "$R ERROR:: $2 Installation is failed $W" | tee -a $LOG_FILE
    fi 
}

dnf module disable nodejs -y &>>$LOG_FILE
VALIDATION $? "Disabling Nodejs"

dnf module enable nodejs:20 -y &>>$LOG_FILE
VALIDATION $? "Enabled Nodejs 20 Version"

dnf install nodejs -y &>>$LOG_FILE
VALIDATION $? "Installing Nodejs "

useradd --system --home /app --shell /sbin/nologin --comment "roboshop system user" roboshop &>>$LOG_FILE
VALIDATION $? "Creating System User"

mkdir -p /app &>>$LOG_FILE
VALIDATION $? "Created app Directory"

curl -o /tmp/catalogue.zip https://roboshop-artifacts.s3.amazonaws.com/catalogue-v3.zip &>>$LOG_FILE
VALIDATION $? "Dowloading App Content"

cd /app
unzip /tmp/catalogue.zip &>>$LOG_FILE
VALIDATION $? "Changed to /app and Unzipping Content"

npm install &>>$LOG_FILE
VALIDATION $? "Installing Dependencies"

cp $user_home/catalogue.service /etc/systemd/system/catalogue.service
VALIDATION $? "Copying Catalogue Service File"

systemctl daemon-reload
systemctl enable catalogue 
systemctl restart catalogue
VALIDATION $? "Starting Catalogue Service"