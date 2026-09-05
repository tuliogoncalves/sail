#!/bin/sh
set -e

git config --system --add safe.directory /var/www 2>/dev/null || true

if [ ! -f vendor/autoload.php ]; then
    composer install --no-interaction
fi

if [ ! -f .env ] && [ -f .env.example ]; then
    cp .env.example .env
fi

php artisan storage:link || true

exec "$@"
