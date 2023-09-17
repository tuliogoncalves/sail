#!/usr/bin/env bash

set -e

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

echo
echo "----------------------------"
echo "--- Entreypoint Finished ---"
echo "----------------------------"
echo

exec /usr/bin/supervisord -c /etc/supervisor/conf.d/supervisord.conf
