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

#Create wp-config.php file with database credentials
wp  --allow-root config create \
    --dbname=$WORDPRESS_DB_NAME\
    --dbuser=$WORDPRESS_DB_USER \
    --dbpass=$(/bin/bash -c "cat /run/secrets/db_password") \
    --dbhost=$WORDPRESS_DB_HOST

#Create admin user and wordpress site
wp  --allow-root core install \
    --url=$DOMAIN_NAME\
    --title=$WORDPRESS_SITE_TITLE\
    --admin_user=$ADMIN_USER \
    --admin_password=$(/bin/bash -c "cat /run/secrets/wordpress_admin_password") \
    --admin_email=$ADMIN_EMAIL \
    --skip-email

#Exec PHP-FPM in foreground mode
exec "$@"

