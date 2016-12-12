#!/bin/bash

#basic concept of this script is to inform users about status of processing the file. During the file processing, log file is produced. 
#Log file is created every day and updates untill succesfull file pricessing. 
#This script is run by Cron job. It checks if there is a flag file and if it is created more thatn 1080 minues ago. If it is 
# script removes this flag file and checks the log file for the first time. If it notices specified line at the end of the file it does a specific acction.
# If file processing was successful script creates flag file so further runs for this day will not overwrite the execution of this script.
# else the script will continue to execute at specified time.
# Script sends the info email message to specified users [RECEIVERS]. 
set -x

echo "---------------------------------------------------------------------------------------------------------------"

date

PATH="[path to file]"
FILENAME=$PATH"[name of file to analyze]"
FLAG="[path to location where flag file will be created]"
MESSAGE=
RECEIVERS="[Receivers of email notification]"
DATE=

find /***/**/*** -name FLAG -mmin +1080 -exec rm {} \;

if [ -f $FLAG ]
then
        exit
fi

if [ -f $FILENAME* ]
then
        CZY=`grep -o "KPIU was successfully imported\|KPIU not imported" $FILENAME* | tail -1`
        if [ "$CZY" == "KPIU was successfully imported" ]
        then
                DATE=`grep "KPIU was successfully*" $FILENAME*  | grep -o -P '.{0,3}20.{0,18}'`
                MESSAGE="Data processed successfully"
                touch $FLAG
        elif  [ "$CZY" == "KPIU not imported" ]
        then
                DATE=`grep "KPIU not imported*" $FILENAME* | grep -o -P '.{0,3}20.{0,18}'`
                MESSAGE="Process ended with failure, check logs on [machine name} directory /**/***/files/processing."
        else
                DATE=`tail -10 $FILENAME* `
                MESSAGE="Processing file more that 4 hours, check logs on [machine name] directory /**/***/files/processing."
        fi
else
        MESSAGE="No file for processing"
        touch $FLAG
fi

mailx -s  "File processing status" $RECEIVERS -- -r  <<EOF1
$DATE
$MESSAGE
EOF1
