#!/bin/bash
set -e

DB_PASSWORD="$(cat /run/secrets/db_password)"
. /run/secrets/credentials


mkdir -p /var/www/html
cd /var/www/html


if [ ! -f wp-config.php ]; then

    if [ ! -f index.php ]; then
        wp core download --allow-root
    fi

    wp config create \
        --allow-root \
        --dbname="$DB_NAME" \
        --dbuser="$DB_USER" \
        --dbpass="$DB_PASSWORD" \
        --dbhost="$DB_HOST:$DB_PORT"

    wp core install \
        --allow-root \
        --url="https://$WP_HOST" \
        --title="$WP_TITLE" \
        --admin_user="$WP_ADMIN_USER" \
        --admin_password="$(cat /run/secrets/wp_admin_password)" \
        --admin_email="$WP_ADMIN_EMAIL" \
        --skip-email

    wp user create \
        --allow-root \
        "$WP_USER" "$WP_USER_EMAIL" \
        --role=editor \
        --user_pass="$(cat /run/secrets/wp_user_password)"
fi

exec php-fpm8.2 -F
