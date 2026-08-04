#!/bin/bash

if [ ! -d "/var/lib/mysql/mysql" ]; then
  echo "First time running mariadb, initializing database"

  if ! mysql_install_db --user=mysql --ldata=/var/lib/mysql --skip-test-db; then
    echo "mysql_install_db failed" 
    exit 1
  fi

  #Launching a temporary MariaDB server in the background
  echo "starting mariadb temporarily"
  gosu mysql mariadbd --skip-networking --default-time-zone=SYSTEM --wsrep_on=OFF \
    --expire-logs-days=0 \
    --skip-slave-start \
    --loose-innodb_buffer_pool_load_at_startup=0 \
    &
  declare MARIADB_PID
  MARIADB_PID=$!

#Waiting mariadb to start
  attempts=0
  max_attempts=10
  while ! mariadb < /dev/null 2>/dev/null; do
    attempts=$((attempts + 1))
    if (($attempts > $max_attempts)); then
      echo "MariaDB takes too long to respond"
      exit 1
    fi
    echo "waiting on mariadb"
    sleep 1
  done

#Send SQL commands
  mariadb  << EOSQL
    ALTER USER 'root'@'localhost' IDENTIFIED BY '$(/bin/bash -c "cat /run/secrets/db_root_password")';
    CREATE DATABASE IF NOT EXISTS $DB_NAME;
    CREATE USER IF NOT EXISTS $DB_USER IDENTIFIED BY '$(/bin/bash -c "cat /run/secrets/db_password")';
    GRANT ALL PRIVILEGES ON $DB_NAME.* TO $DB_USER;
    FLUSH PRIVILEGES;
EOSQL
  kill "$MARIADB_PID"
  wait "$MARIADB_PID"
else
  echo "MariaDB already initialized"
fi

echo "starting mariadb"
#Exec MariaDB in foreground mode
exec gosu mysql "$@"
