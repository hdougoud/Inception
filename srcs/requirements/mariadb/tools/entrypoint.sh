#!/bin/bash

if [ ! -d "/var/lib/mysql/mysql" ]; then
  mysql_install_db --user=mysql --ldata=/var/lib/mysql --skip-test-db
else
  echo "MariaDB already initialized"
fi

echo "starting mariadb"
#Exec MariaDB in foreground mode
exec gosu mysql "$@"
