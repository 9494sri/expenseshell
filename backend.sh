#!/bin/bash

USERID=$(id -u)

R="\e[31m"
G="\e[32m"
Y="\e[33m"
N="\e[0m"
LOGS_FOLDER="/var/log/expense-logs"

LOG_FILE=$(echo $0 | cut -d "." -f1)

TIMESTAMP=$(date +%y-%m-%d-%H-%M-%S)

LOG_FILE_NAME="$LOGS_FOLDER/$LOG_FILE-$TIMESTAMP.log"

validate (){                                                                # function to validate the installation
      if [ $1 -ne 0 ]                                                       # if condition to check the installation status
    then                                                                    # if condition to check the installation status
        echo -e "$2 ... $R failure $N"                                               # echo statement to print the output
        exit 1                                                              # exit status other than 0
    else                                                                    # else condition to check the installation status
        echo -e "$2... $G success $N"                                                # echo statement to print the output
    fi                                                                      # end of if condition

}               

CHECK_ROOT(){

    if [ $USERID -ne 0 ]                                                          # if condition to check the user id
then 
    echo "ERROR : YOU MUST HAVE SUDO ACCESS TO EXCUTE THIS SCRIPT"            # echo statement to print the output
    exit 1 # other than 0 s                                                   # exit status other than 0
fi  

}  

echo "script started executing at : $TIMESTAMP" &>>$LOG_FILE_NAME

CHECK_ROOT


dnf module disable nodejs -y &>>$LOG_FILE_NAME
validate $? "Disabling Existing Nodejs "

dnf module enable nodejs:20 -y &>>$LOG_FILE_NAME
validate $? " Enabling nodejs:20 " 

dnf install nodejs -y &>>$LOG_FILE_NAME
validate $? "Installing nodejs" 

useradd expense  &>>$LOG_FILE_NAME
validate $? " Adding expenss user" 

mkdir /app  &>>$LOG_FILE_NAME
validate $? "Creating app directory"

curl -o /tmp/backend.zip https://expense-builds.s3.us-east-1.amazonaws.com/expense-backend-v2.zip &>>$LOG_FILE_NAME
validate $? "Downloading Backend"

cd /app


unzip /tmp/backend.zip  &>>$LOG_FILE_NAME
validate $? "Unzippingthe backend file " 

npm install  &>>$LOG_FILE_NAME
validate $? "Installing Denpencies" 

cp /Users/srishiva/Documents/test/expenseshell/backend.service  /etc/systemd/system/backend.service


# prepare MySQL Schema

dnf install mysql -y &>>$LOG_FILE_NAME
validate $? "Installing MySQL Client"

mysql -h <MYSQL-SERVER-IPADDRESS> -uroot -pExpenseApp@1 < /app/schema/backend.sql  &>>$LOG_FILE_NAME
validate $? "Setting up the transactions schema and table"

systemctl daemon-reload  &>>$LOG_FILE_NAME
validate $? "Daemon Reload"

systemctl enable backend  &>>$LOG_FILE_NAME
validate $? "Enabling backend"

systemctl start backend  &>>$LOG_FILE_NAME
validate $? "Starting Backend"
