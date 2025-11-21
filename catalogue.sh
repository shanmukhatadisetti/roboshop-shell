#!/bin/bash
SCRIPT_START=$(date +%s)
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
        echo -e "$G $2  is Successful $W" | tee -a $LOG_FILE
    else
        echo -e "$R ERROR:: $2  is failed $W" | tee -a $LOG_FILE
    fi 
}

dnf module disable nodejs -y &>>$LOG_FILE
VALIDATION $? "Disabling Nodejs"

dnf module enable nodejs:20 -y &>>$LOG_FILE
VALIDATION $? "Enabled Nodejs 20 Version"

dnf install nodejs -y &>>$LOG_FILE
VALIDATION $? "Installing Nodejs "

id roboshop &>>$LOG_FILE
if [ $? != 0 ]
then 
    useradd --system --home /app --shell /sbin/nologin --comment "roboshop system user" roboshop &>>$LOG_FILE
    VALIDATION $? "Creating System User"
else
    echo -e "System User already Created...$Y Skipping $W"
fi

rm -rf /app/*

mkdir -p /app &>>$LOG_FILE
VALIDATION $? "Created app Directory"

curl -o /tmp/catalogue.zip https://roboshop-artifacts.s3.amazonaws.com/catalogue-v3.zip &>>$LOG_FILE
VALIDATION $? "Dowloading App Content"

cd /app
unzip /tmp/catalogue.zip &>>$LOG_FILE
VALIDATION $? "Changed to /app and Unzipping Content"

npm install &>>$LOG_FILE
VALIDATION $? "Installing Dependencies"

cp $user_home/catalogue.service /etc/systemd/system/catalogue.service &>>$LOG_FILE
VALIDATION $? "Copying Catalogue Service File"

systemctl daemon-reload
systemctl enable catalogue &>>$LOG_FILE
systemctl restart catalogue
VALIDATION $? "Starting Catalogue Service"

cp $user_home/mongodb.repo /etc/yum.repos.d/mongo.repo &>>$LOG_FILE
VALIDATION $? "Copying mongo repo"

dnf install mongodb-mongosh -y &>>$LOG_FILE
VALIDATION $? "Installing Mongodb Client"

mongodb_check=$(mongosh --host mongodb.autonagar.in --eval 'db.getMongo().getDBNames().indexOf("catalogue")')
if [ $mongodb_check -lt 0 ]
then
    mongosh --host mongodb.autonagar.in </app/db/master-data.js &>>$LOG_FILE
    VALIDATION $? "Loading Data into Mongodb server"
else
    echo -e "Catalogue Data already loaded...$Y Skipping $W"
fi

SCRIPT_END=$(date +%s)

SCRIPT_TOTAL_TIME=$(( $SCRIPT_END - $SCRIPT_START ))

echo -e "Total Execution Time For the Script To Run:: $Y $SCRIPT_TOTAL_TIME seconds $W" | tee -a $LOG_FILE