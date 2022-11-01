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


install_pkgs && enable_n_start_service && tar_n_copy_logs
