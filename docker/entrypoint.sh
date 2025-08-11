#!/bin/sh

set -e

cd /var/www/html

# Fix permission
sudo chown -R $(id -u):$(id -g) storage bootstrap/cache
sudo chmod -R 775 storage bootstrap/cache
sudo chown -R laravel:laravel /var/www/html
sudo chmod -R 775 storage bootstrap/cache public

sudo chmod -R gu+w storage
sudo chmod -R guo+w storage

# Copy .env if it doesn't exist
if [ -f "/var/www/html/.env.docker" ]; then
  echo "Using .env.docker"
  cp /var/www/html/.env.docker /var/www/html/.env
elif [ ! -f /var/www/html/.env ]; then
  echo "No .env found. Copying from .env.example"
  cp /var/www/html/.env.example /var/www/html/.env
else
  echo "Using existing .env"
fi

# Git safe directory (untuk container laravel user)
git config --global --add safe.directory /var/www/html

# Install dependencies
composer install \
    --no-interaction \
    --prefer-dist \
    --optimize-autoloader

# Generate APP_KEY if not set
if ! grep -q "^APP_KEY=" .env || [ -z "$(grep '^APP_KEY=' .env | cut -d '=' -f2)" ]; then
  php artisan key:generate
fi

# Tunggu PostgreSQL
echo "Menunggu PostgreSQL..."
while ! pg_isready -h postgres -p 5432 -q; do
  sleep 1
done
echo "PostgreSQL siap!"

# Migration dan seeding
php artisan migrate:fresh --force
php artisan db:seed --force

# Cache config, route, view
php artisan config:cache
php artisan route:cache
php artisan view:cache
php artisan cache:clear

echo "Starting supervisord..."
exec /usr/bin/supervisord -c /etc/supervisor/conf.d/supervisord.conf