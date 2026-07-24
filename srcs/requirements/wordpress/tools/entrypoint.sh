#!/bin/bash

#Import GPG key and verify signature
curl -sSO https://raw.githubusercontent.com/wp-cli/builds/gh-pages/phar/wp-cli.phar.asc
curl -sSL https://raw.githubusercontent.com/wp-cli/builds/gh-pages/wp-cli.pgp | gpg --import -q
if ! gpg --verify wp-cli.phar.asc wp-cli.phar >/dev/null 2>&1; then
  echo "GPG signature verification failed. Exiting."
  exit 1
fi
rm -rf wp-cli.phar.asc
chmod +x wp-cli.phar
mv wp-cli.phar /usr/local/bin/wp

#Install wordpress and Database configuration
wp_version="7.0.2"
wp_dir=/var/www/wordpress

wp  --allow-root core download \
    --version=$wp_version \
    --path=$wp_dir \

wp  --allow-root config create \
    --dbname=$WORDPRESS_DB_NAME\
    --dbuser=$WORDPRESS_DB_USER \
    --dbpass=$WORDPRESS_DB_PASSWORD \
    --dbhost=$WORDPRESS_DB_HOST

#Create admin user and wordpress site
wp  --allow-root core install \
    --url=$WORDPRESS_URL \
    --title=$WORDPRESS_SITE_TITLE \
    --admin_user=$ADMIN_USER \
    --admin_password=$ADMIN_PASSWORD \
    --admin_email=$ADMIN_EMAIL \
    --skip-email

#Exec PHP-FPM in foreground mode
#TODO: use exec @
exec /usr/sbin/php-fpm8.2 -F

