#!/bin/sh
set -e

mkdir -p /var/www/html/storage/framework/views
mkdir -p /var/www/html/storage/framework/cache
mkdir -p /var/www/html/storage/framework/sessions
mkdir -p /var/www/html/storage/logs
mkdir -p /var/www/html/bootstrap/cache

chown -R www-data:www-data /var/www/html/storage /var/www/html/bootstrap/cache
chmod -R 775 /var/www/html/storage /var/www/html/bootstrap/cache

cd /var/www/html

if [ ! -d "vendor" ]; then
    echo "Installing composer dependencies..."
    composer install --no-interaction --prefer-dist --optimize-autoloader
fi

if [ ! -d "node_modules" ]; then
    echo "Installing npm dependencies..."
    npm ci || npm install
fi

if [ ! -f "public/build/manifest.json" ]; then
    echo "Building frontend assets..."
    npm run build
fi

echo "Waiting for database..."
until nc -z db 5432; do
    sleep 1
done
echo "Database is up!"

php artisan migrate --force

exec php-fpm
