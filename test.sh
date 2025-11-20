R="\e[31m"
G="\e[32m"
Y="\e[33m"
W="\e[0m"

VALIDATION(){
    if [ $1 != 0 ]
    then 
        echo -e "$R ERROR:: $2 has been failed $W" | tee -a $LOG_FILE
        exit 1
    else
        echo -e "$G  $2 has been succesful" | tee -a $LOG_FILE
    fi
}


dnf install mysql -y
VALIDATION $? "mysql"

