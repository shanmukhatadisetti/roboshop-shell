#!/bin/bash
SCRIPT_START=$(date +%s)
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
    fi
}

dnf module disable nginx -y &>>$LOG_FILE
VALIDATION $? "Disabling Nginx Default Version"

dnf module enable nginx:1.24 -y &>>$LOG_FILE
VALIDATION $? "Enabling Nginx Version 1.24"

dnf install nginx -y &>>$LOG_FILE
VALIDATION $? "Installing Nginx"

systemctl enable nginx 
systemctl start nginx 
VALIDATION $? "Starting Nginx Service"

rm -rf /usr/share/nginx/html/* &>>$LOG_FILE
VALIDATION $? "Removing Default HTML Content"

curl -o /tmp/frontend.zip https://roboshop-artifacts.s3.amazonaws.com/frontend-v3.zip &>>$LOG_FILE
VALIDATION $? "Downloading App Content"

cd /usr/share/nginx/html 
unzip /tmp/frontend.zip &>>$LOG_FILE
VALIDATION $? "Changing Directory /usr/share/nginx/html and Unzipping Content"

cp $user_home/nginx.conf /etc/nginx/nginx.conf &>>$LOG_FILE /etc/nginx/nginx.conf
VALIDATION $? "Copying Nginx conf file"

systemctl restart nginx 
VALIDATION $? "Restarting Nginx Service"

SCRIPT_END=$(date +%s)

SCRIPT_TOTAL_TIME=$(( $SCRIPT_END - $SCRIPT_START ))

echo -e "Total Execution Time For the Script To Run:: $Y $SCRIPT_TOTAL_TIME $W" | tee -a $LOG_FILE