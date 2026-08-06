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
    --admin_user=$ADMIN_USER \
    --admin_password=$(/bin/bash -c "cat /run/secrets/wordpress_admin_password") \
    --admin_email=$ADMIN_EMAIL \
    --skip-email
  #Create admin user and wordpress site
  #Install the redis plugin
  wp --allow-root plugin install redis-cache
  wp --allow-root config set WP_REDIS_HOST "redis"
  wp --allow-root config set WP_REDIS_PORT "6379"
  #Give ownership of wordpress files to www-data user and group
  chown -R www-data:www-data $wp_dir
  chmod 755 $wp_dir
  wp --allow-root plugin activate redis-cache

#Exec PHP-FPM in foreground mode
exec "$@"

