#!/bin/bash

if ! id "$FTP_USER" &>/dev/null; then
  echo creating user $FTP_USER
  useradd -d /var/www/wordpress $FTP_USER
  echo "$FTP_USER:$(cat /run/secrets/ftp_password)" | chpasswd
  echo "$FTP_USER:$(cat /run/secrets/ftp_password)"
else
  echo "user $FTP_USER already exists"
fi

echo "Starting vsftpd"
exec "$@"
