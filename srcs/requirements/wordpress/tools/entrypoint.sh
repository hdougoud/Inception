#!/bin/bash

#Exit the script if a command fails or an environment variable has not been initialised
set -eo pipefail

#Install wordpress and Database configuration
wp_version="7.0.2"
wp_dir=/var/www/wordpress

wp  --allow-root core download \
    --version=$wp_version \
    --path=$wp_dir \

#Create wp-config.php file with database credentials
wp  --allow-root config create \
    --dbname=$DB_NAME \
    --dbuser=$DB_USER \
    --dbpass=$(/bin/bash -c "cat /run/secrets/db_password") \
    --dbhost=$WORDPRESS_DB_HOST

#Create admin user and wordpress site
wp  --allow-root core install \
    --url=$DOMAIN_NAME\
    --title=$WORDPRESS_SITE_TITLE\
    --admin_user=$WP_ADMIN_USER \
    --admin_password=$(/bin/bash -c "cat /run/secrets/wordpress_admin_password") \
    --admin_email=$WP_ADMIN_EMAIL \
    --skip-email

wp  --allow-root user create $WP_USER $WP_EMAIL \
    --role=author \
    --user_pass=$(/bin/bash -c "cat /run/secrets/wordpress_user_password")

#Exec PHP-FPM in foreground mode
exec "$@"

