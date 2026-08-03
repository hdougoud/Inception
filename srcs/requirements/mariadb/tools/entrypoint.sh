#!/bin/bash

if [ ! -d "/var/lib/mysql/mysql" ]; then
  echo "First time running mariadb, initializing database"

  mysql_install_db --user=mysql --ldata=/var/lib/mysql --skip-test-db

  echo "starting mariadb temporarily"
  gosu mysql mariadbd --skip-networking --default-time-zone=SYSTEM --wsrep_on=OFF \
    --expire-logs-days=0 \
    --skip-slave-start \
    --loose-innodb_buffer_pool_load_at_startup=0 \
    &
  declare MARIADB_PID
  MARIADB_PID=$!

#Waiting mariadb to start
  sleep 2
  mariadb  <<-EOSQL
    CREATE DATABASE IF NOT EXISTS $DB_NAME;
    CREATE USER IF NOT EXISTS $DB_USER IDENTIFIED BY '$(/bin/bash -c "cat /run/secrets/db_password")';
    GRANT ALL PRIVILEGES ON $DB_NAME.* TO '$DB_USER';
EOSQL
  kill "$MARIADB_PID"
  wait "$MARIADB_PID"
else
  echo "MariaDB already initialized"
fi


#Starting mariadb in background to create wordpress database
echo "starting mariadb"
#Exec MariaDB in foreground mode
exec gosu mysql "$@"
