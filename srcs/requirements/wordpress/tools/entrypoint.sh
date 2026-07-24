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
    --path=$wp_dir

wp  --allow-root config create \
    --dbname="exampledb" \
    --dbuser="exampleuser" \
    --dbpass="examplepass" \
    --dbhost="mariadb:3306"

#Create admin user and wordpress site
wp  --allow-root core install \
    --url="http://localhost:8080" \
    --title="Inception" \
    --admin_user="hdougoud" \
    --admin_password="SecretPassword" \
    --admin_email="wpmail@wpcli.com" \
    --skip-email

#Exec PHP-FPM in foreground mode
#TODO: use exec @
exec /usr/sbin/php-fpm8.2 -F

