#!/bin/bash

user_id=$(id -u)

R="\e[31m"
G="\e[32m"
Y="\e[33m"
W="\e[0m"

SCRIPT_PATH=/var/log/roboshop_log
SCRIPT_NAME=$(echo $0 | cut -d "." -f1)
LOG_FILE="$SCRIPT_PATH/$SCRIPT_NAME.log"
user_home=$PWD
mkdir -p $SCRIPT_PATH

echo "Script executed on:: $(date)"

if [ $user_id == 0 ]
then
    echo -e "$Y Your Running with Root User $W" | tee -a $LOG_FILE
else
    echo -e "$R ERROR:: Your Not Running with Root User $W" | tee -a $LOG_FILE
    exit 1
fi

VALIDATION(){
    if [ $1 == 0 ]
    then 
        echo -e "$G $2 is Successful $W" | tee -a $LOG_FILE
    else
        echo -e "$R $2 is Failed $W" | tee -a $LOG_FILE
        exit 1
    fi
}

dnf module disable redis -y &>>$LOG_FILE
VALIDATION $? "Disabled default redis version"

dnf module enable redis:7 -y &>>$LOG_FILE
VALIDATION $? "Enabled redis:7 Version" 

dnf install redis -y &>>$LOG_FILE
VALIDATION $? "Installing redis"

sed -i -e 's/127.0.01/0.0.0.0/g' -e '/protected-mode/ c protected-mode no ' /etc/redis/redis.conf &>>$LOG_FILE
VALIDATION $? "Editing Redis Conf"

systemctl enable redis &>>$LOG_FILE
systemctl start redis &>>$LOG_FILE
VALIDATION $? "Restarted redis service"