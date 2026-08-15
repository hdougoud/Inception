#!/bin/bash

useradd -d /var/www/wordpress myuser 
echo 'myuser:mypass' | chpasswd

exec "$@"
