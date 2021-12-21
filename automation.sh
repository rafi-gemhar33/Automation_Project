#!/bin/bash

user_name="gemhar"
s3_bucket="upgrad-gemhar"

sudo apt update -y
isApacheInstalled=$(dpkg --get-selections | grep apache2| awk '{print $1}')
if [[ "$isApacheInstalled" =~ .*"apache2".* ]]; then
  echo "Apache Server installed...";
else
        echo "Installing apache 2..."
        apt-get install apache2 -y
fi

apacheServerConfig=$(systemctl list-unit-files | grep apache2.service | awk '{print $2}')
if [[ $apacheServerConfig = "enabled" ]];then
        echo "Service already configured..."
else
        systemctl start apache2.service
        echo "Service already enabled..."
fi
ServiceStatus="$(systemctl is-active apache2.service)"
if [ "${ServiceStatus}" != "active" ]; then
        sudo systemctl start apache2.service
fi
timestamp=$(date '+%d%m%Y-%H%M%S')


cd /var/log/apache2/
fileName=$user_name"-httpd-logs-"$timestamp
tar -cf ${fileName}.tar *.log
aws s3 cp ${fileName}.tar s3://${s3_bucket}/${fileName}.tar
