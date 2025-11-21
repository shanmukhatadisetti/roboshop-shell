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

echo -e "$Y Enter Mysql Passowrd $W"
read -s MYSQL_PASSWORD

VALIDATION(){
    if [ $1 == 0 ]
    then
        echo -e "$G $2  is Successful $W" | tee -a $LOG_FILE
    else
        echo -e "$R ERROR:: $2  is failed $W" | tee -a $LOG_FILE
    fi 
}

dnf install maven -y -y &>>$LOG_FILE
VALIDATION $? "Installing Maven"

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

curl -o /tmp/shipping.zip https://roboshop-artifacts.s3.amazonaws.com/shipping-v3.zip &>>$LOG_FILE
VALIDATION $? "Dowloading App Content"

cd /app
unzip /tmp/shipping.zip &>>$LOG_FILE
VALIDATION $? "Changed to /app and Unzipping Content"

 mvn clean package &>>$LOG_FILE
VALIDATION $? "Installing Dependencies"

mv target/shipping-1.0.jar shipping.jar &>>$LOG_FILE
VALIDATION $? "Moving target/shipping-1.0.jar to /app"

cp $user_home/shipping.service /etc/systemd/system/shipping.service &>>$LOG_FILE
VALIDATION $? "Copying cart Service File"

systemctl daemon-reload &>>$LOG_FILE
systemctl enable shipping &>>$LOG_FILE
systemctl restart shipping &>>$LOG_FILE
VALIDATION $? "Starting cart Service"

dnf install mysql -y &>>$LOG_FILE
VALIDATION $? "Installing Mysql Client"

mysql -h mysql.autonagar.in -uroot -p$MYSQL_PASSWORD < /app/db/schema.sql &>>$LOG_FILE
mysql -h mysql.autonagar.in -uroot -p$MYSQL_PASSWORD < /app/db/app-user.sql &>>$LOG_FILE
mysql -h mysql.autonagar.in -uroot -p$MYSQL_PASSWORD < /app/db/master-data.sql &>>$LOG_FILE
VALIDATION $? "Loading Data into Mysql"

SCRIPT_END=$(date +%s)

SCRIPT_TOTAL_TIME=$(( $SCRIPT_END - $SCRIPT_START ))

echo -e "Total Execution Time For the Script To Run:: $Y $SCRIPT_TOTAL_TIME seconds $W" | tee -a $LOG_FILE