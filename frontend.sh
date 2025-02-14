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

mkdir -p $LOGS_FOLDER
echo "script started executing at : $TIMESTAMP" &>>$LOG_FILE_NAME

CHECK_ROOT

dnf install nginx -y &>>$LOG_FILE_NAME
validate $? "Installing Nginx Server"

systemctl enable nginx &>>$LOG_FILE_NAME
validate $? "Enabling Nginx server" 

systemctl start nginx &>>$LOG_FILE_NAME
validate $? "Starting Nginx Server" 

rm -rf /usr/share/nginx/html/* &>>$LOG_FILE_NAME
validate $? "Removing existing version of code"

curl -o /tmp/frontend.zip https://expense-builds.s3.us-east-1.amazonaws.com/expense-frontend-v2.zip  &>>$LOG_FILE_NAME
validate $? "Downloading Latest Code"

cd /usr/share/nginx/html
validate $? "Moving to HTML Directory"

unzip /tmp/frontend.zip  &>>$LOG_FILE_NAME
validate $? "unzipping the frontend code"

cp /home/ec2-user/expenseshell/expense.conf  /etc/nginx/default.d/expense.conf
validate $? "Copied expense config"

systemctl restart nginx  &>>$LOG_FILE_NAME
validate $? "Restarting nginx"

