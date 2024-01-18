#!/bin/sh

# Test FPM CGI
if [ -f /use_fpm ]; then

  export SCRIPT_NAME=/opt/kimai/public/index.php
  export SCRIPT_FILENAME=/opt/kimai/public/index.php
  export REQUEST_METHOD=GET
  export SERVER_ADDR=localhost

  COUNT=0
  until cgi-fcgi -bind -connect 127.0.0.1:9000 &> /dev/null
  do
    COUNT=$((COUNT+1))
    echo "Waiting for FPM Server to start (${COUNT})"
    sleep 3
    if [ "$COUNT" -gt 5 ]; then
      echo "FPM Failed to start."
      exit 1
    fi
  done

fi

# Test Apache/httpd
if [ -f /use_apache ]; then
  export APACHE_RUN_USER=www-data
  export APACHE_RUN_GROUP=www-data
  export APACHE_PID_FILE=/var/run/apache2/apache2.pid
  export APACHE_RUN_DIR=/var/run/apache2
  export APACHE_LOCK_DIR=/var/lock/apache2
  export APACHE_LOG_DIR=/var/log/apache2
  export LANG=C
  /usr/sbin/apache2

  COUNT=0
  until curl -s -o /dev/null http://localhost:8001
  do
    COUNT=$((COUNT+1))
    echo "Waiting for Apache/HTTP to start (${COUNT})" &> /dev/null
    sleep 3
    if [ "$COUNT" -gt 5 ]; then
      echo "Apache/HTTP failed to start."
      exit 1
    fi
  done

  kill $(cat $APACHE_PID_FILE)
fi

# Test PHP/Kimai
export DATABASE_URL="sqlite:///:memory:"
/opt/kimai/bin/console kimai:version
if [ $? != 0 ]; then
  echo "PHP/Kimai not responding"
  exit 1
fi


