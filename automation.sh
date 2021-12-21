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

inventory_file="/var/www/html/inventory.html"

if ! [ -f $inventory_file ]
then
        touch $inventory_file
        echo "<h><b>Log Type &ensp;&ensp;  Date Created  &ensp;&ensp; Type &ensp;&ensp; Size" > $inventory_file
fi
size=$(ls -lh | grep "$fileName" | awk '{print $5}')
echo "<p>httpd-logs &ensp;&ensp; $timestamp &ensp;&ensp; tar &ensp;&ensp; $size</p>" >> $inventory_file

if  [ ! -f  /etc/cron.d/automation ]
then
	echo  "0 12 * * * \troot\t/root/Automation_Project/automation.sh" > /etc/cron.d/automation
fi
