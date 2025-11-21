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

# echo -e "Enter MYSQL PASSWORD"
# read -s MYSQL_PASSWORD

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

dnf install mysql-server -y &>>$LOG_FILE
VALIDATION $? "Installing Mysql Server"

systemctl enable mysqld &>>$LOG_FILE
VALIDATION $? "Enabling Mysql service"

systemctl start mysqld &>>$LOG_FILE
VALIDATION $? "Starting Mysql service"

mysql_secure_installation --set-root-pass RoboShop@1 &>>$LOG_FILE
VALIDATION $? "Setting up Mysql password"

SCRIPT_END=$(date +%s)

SCRIPT_TOTAL_TIME=$(( $SCRIPT_END - $SCRIPT_START ))

echo -e "Total Execution Time For the Script To Run:: $Y $SCRIPT_TOTAL_TIME seconds $W" | tee -a $LOG_FILE