VALIDATION(){
    if [ $1 != 0 ]
    then 
        echo -e "$R ERROR:: $2 has been failed $W" | tee -a $LOG_FILE
        exit 1
    else
        echo -e "$G  has been succesful" | tee -a $LOG_FILE
}


dnf install mysql -y
VALIDATION $? "mysql"

