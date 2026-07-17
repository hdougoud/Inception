#!/bin/bash


#FIX:
touch /var/log/php-fpm8.access.log
sed -i 's|;access.log = .*|access.log = /var/log/php-fpm8.access.log|' /etc/php/8.2/fpm/pool.d/www.conf

#Replace the listen arguments in php-fpm config file
#WARN: Check that external connections cannot access php-fpm
sed -i 's|listen = .*|listen = 9000|' /etc/php/8.2/fpm/pool.d/www.conf

#TODO: Configure wordpress


#Exec PHP-FPM in foreground mode
exec /usr/sbin/php-fpm8.2 -F

