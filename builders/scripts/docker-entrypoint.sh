#!/bin/bash
set -e

# We'll say that we are by default in dev
if [ -d /etc/php/current ]; then
    sed -i 's/^display_errors\s*=.*/display_errors = On/g' /etc/php/current/fpm/conf.d/30-custom-php.ini
    sed -i 's/^max_execution_time\s*=.*/max_execution_time = -1/g' /etc/php/current/fpm/conf.d/30-custom-php.ini
fi

if [ -d storage ]; then
    cd storage
    mkdir -p logs
    mkdir -p framework
    mkdir -p framework/cache
    mkdir -p framework/cache/data
    mkdir -p framework/sessions
    mkdir -p framework/testing
    mkdir -p framework/views
    cd ..

    chmod -R 777 storage bootstrap
fi

echo
echo "----------------------------"
echo "--- Entreypoint Finished ---"
echo "----------------------------"
echo

exec /usr/bin/supervisord -c /etc/supervisor/conf.d/supervisord.conf

if [ -f /start.sh ]; then
    echo
    echo "--- Start custom script ---"
    echo

    exec /start.sh
fi
