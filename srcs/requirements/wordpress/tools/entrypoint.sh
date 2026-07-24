#!/bin/bash

#install wordpress
wordpress_version="7.0.2"

wget https://wordpress.org/wordpress-$wordpress_version.tar.gz
tar xvfz wordpress-$wordpress_version.tar.gz
rm -rf wordpress-$wordpress_version.tar.gz
chown -R www-data:www-data /var/www/html/wordpress



#TODO: Configure wordpress


#Exec PHP-FPM in foreground mode
exec /usr/sbin/php-fpm8.2 -F

