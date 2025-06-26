#!/bin/sh

set -e

git config --global --add safe.directory /var/www

# Install dependencies
composer install \
    --no-interaction \
    --prefer-dist \
    --optimize-autoloader

# Generate application key
php artisan key:generate

echo "Menunggu PostgreSQL..."
while ! pg_isready -h postgres -p 5432 -q; do
  sleep 1
done
echo "PostgreSQL siap!"

# Jalankan migrasi
php artisan migrate:fresh
php artisan db:seed

php artisan config:cache
php artisan route:cache
php artisan view:cache

# Fix permission
chown -R $(id -u):$(id -g) storage bootstrap/cache
chmod -R 775 storage bootstrap/cache

chmod -R gu+w storage
chmod -R guo+w storage
php artisan cache:clear

# Start PHP-FPM
exec docker-php-entrypoint php-fpm