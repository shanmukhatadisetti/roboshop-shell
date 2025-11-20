#!/bin/bash
userid=$(id -u)

R="\e[31m"
G="\e[32m"
Y="\e[33m"
W="\e[0m"

SCRIPT_PATH=/var/log/roboshop_logs
SCRIPT_NAME=$(echo $0 | cut -d "." -f1)
LOG_FILE="$SCRIPT_PATH/$SCRIPT_NAME.log"

mkdir -p $SCRIPT_PATH

echo "Script started executing at:: $(date)" | tee -a $LOG_FILE

if [ $userid == 0 ]
then
    echo -e "$Y Your running with root user $W" | tee -a $LOG_FILE
else
    echo -e "$R ERROR::You have to run with root user $W" | tee -a $LOG_FILE
    exit 1

VALIDATION(){
    if [ $1 != 0 ]
    then 
        echo -e "$R ERROR:: $2 has been failed $W" | tee -a $LOG_FILE
        exit 1
    else
        echo -e "$G  has been succesful" | tee -a $LOG_FILE
    fi
}


cp mongodb.repo /etc/yum.repos.d/mongo.repo &>>$LOG_FILE
VALIDATION $? "Copying mongodb.repo"

# dnf install mongodb-org -y &>>$LOG_FILE
# VALIDATION $? "installing mongodb"

# systemctl enable mongod &>>$LOG_FILE
# VALIDATION $? "enabling mongodb"


# systemctl start mongod &>>$LOG_FILE
# VALIDATION $? "starting mongodb"

# sed -i 's/127.0.0.1/0.0.0.0/g' /etc/mongod.conf &>>$LOG_FILE
# VALIDATION $? "changing mongod.conf file"

# systemctl restart mongod &>>$LOG_FILE
# VALIDATION $? "restarting mongodb"