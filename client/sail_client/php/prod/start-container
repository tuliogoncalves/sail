#!/usr/bin/env bash

if [ ! -z "$WWWUSER" ]; then
    usermod -u $WWWUSER sail
fi

set -e

cp ./sail_client/php/local/env.local .env

composer update

php artisan cache:clear

chmod -R 777 storage bootstrap

php artisan migrate --seed --force

php artisan jwt:secret

php artisan key:generate --force

php artisan optimize

echo
echo "----------------------------"
echo "--- Entreypoint Finished ---"
echo "----------------------------"
echo

exec /usr/bin/supervisord -c /etc/supervisor/conf.d/supervisord.conf
