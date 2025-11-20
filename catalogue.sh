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
    echo -e "$Y Your Running with root user $W"
else
    echo -e "$R ERROR:: Your not running with root user $W"
    exit 1
fi

VALIDATION(){
    if [ $1 == 0 ]
    then
        echo -e "$G $2 Installation is Successful $W"
    else
        echo -e "$R ERROR:: $2 Installation is failed $W"
    fi
}

dnf module disable nodejs -y
VALIDATION $? "Disabling Nodejs"

dnf module enable nodejs:20 -y
VALIDATION $? "Enabled Nodejs 20 Version"

dnf install nodejs -y
VALIDATION $? "Installing Nodejs "

useradd --system --home /app --shell /sbin/nologin --comment "roboshop system user" roboshop 
VALIDATION $? "Creating System User"

mkdir -p /app
VALIDATION $? "Created app Directory"

curl -o /tmp/catalogue.zip https://roboshop-artifacts.s3.amazonaws.com/catalogue-v3.zip
VALIDATION $? "Dowloading App Content"

cd /app
unzip /tmp/catalogue.zip
VALIDATION $? "Changed to /app and Unzipping Content"

npm install
VALIDATION $? "Installing Dependencies"

cp $user_home/catalogue.service /etc/systemd/system/catalogue.service
VALIDATION $? "Copying Catalogue Service File"

systemctl daemon-reload
systemctl enable catalogue 
systemctl restart catalogue
VALIDATION $? "Starting Catalogue Service"