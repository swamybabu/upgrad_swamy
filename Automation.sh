#!/bin/bash

install_pkgs () {

  sudo apt-get update -y
  sudo apt install awscli
  sudo apt-get install apache2 -y
  
}


enable_n_start_service () {
  if [ `service apache2 status | grep enabled | wc -l` == 1 ]
  then
	  echo "Apache2 is enabled"
  else
	  echo "Apache2 is not enabled"
	  echo "Enabling apache2"
	  sudo systemctl enable apache2
  fi
  
  if [ `service apache2 status | grep running | wc -l` == 1 ]
  then
	  echo "Apache2 is running"
  else
	  echo "Apache2 is not running"
	  echo "Starting apache2"
	  sudo service apache2 start 

  fi

}

tar_n_copy_logs () {

  echo "Tar bundle the logs and storing into /tmp"
  name="swamy"
  timestamp=$(date '+%d%m%Y-%H%M%S')
  s3_bucket="upgrad-venkataswamybabub/var/logs"
  cd /var/log/apache2/
  tar -cvf /tmp/httpd-logs-${timestamp}.tar *.log
  echo "Copying logs to s3"
  aws s3 cp /tmp/${name}-httpd-logs-${timestamp}.tar s3://${s3_bucket}/${name}-httpd-logs-${timestamp}.tar

}

check_inventory_html () {

  if [ -e /var/www/html/inventory.html ]
  then
        echo "Inventory exists"
  else
        touch /var/www/html/inventory.html
        echo "<b>Log Type &nbsp;&nbsp;&nbsp;&nbsp;&nbsp; Date Created &nbsp;&nbsp;&nbsp;&nbsp;&nbsp; Type &nbsp;&nbsp;&nbsp;&nbsp;&nbsp; Size</b>" >> /var/www/html/inventory.html
  fi

  echo "<br>httpd-logs &nbsp;&nbsp;&nbsp;&nbsp; ${timestamp} &nbsp;&nbsp;&nbsp;&nbsp; tar &nbsp;&nbsp;&nbsp;&nbsp; `du -h /tmp/${myname}-httpd-logs-${timestamp}.tar | awk '{print $1}'`" >> /var/www/html/inventory.html
}

create_cron_job () {
  if [ -e /etc/cron.d/automation ]
  then
        echo "Cron job exists"
  else
        touch /etc/cron.d/automation
        echo "0 0 * * * root /root/upgrad_swamy/Automation.sh" > /etc/cron.d/automation
        echo "Cron job added"
  fi
}

install_pkgs && enable_n_start_service && tar_n_copy_logs && check_inventory_html && create_cron_job
