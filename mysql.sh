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

dnf install mysql-server -y &>>$LOG_FILE_NAME
validate $? "Installing MySql Server"

systemctl enable mysqld &>>$LOG_FILE_NAME
validate $? "Enabling MySql Server" 

systemctl start mysqld  &>>$LOG_FILE_NAME
validate $? "Starting MySql Server"

mysql -h mysql.hungerhippo.store -u root -pExpenseApp@1 -e 'show databases;' &>>$LOG_FILE_NAME

if [ $? ne 0 ]
then 
   echo "MySQL Root Password not setup" &>>$LOG_FILE_NAME
   mysql_secure_installation --set-root-pass ExpenseApp@1
   validate $? "Setting Root Password"

   else 

   echo -e "MySQL Root Password Already Setup... $Y Skipping $N"

 fi   
