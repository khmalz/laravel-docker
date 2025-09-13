#!/bin/sh

set -e
cd /var/www/html

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

# Git safe directory
git config --global --add safe.directory /var/www/html

# if vendor folder doesn't exist
if [ ! -d "vendor" ]; then
  echo "📦 Running composer install (vendor missing)..."
  composer install --no-interaction --prefer-dist --optimize-autoloader
fi

# Generate APP_KEY if not set
if ! grep -q "^APP_KEY=" .env || [ -z "$(grep '^APP_KEY=' .env | cut -d '=' -f2)" ]; then
  php artisan key:generate
fi

# Tunggu PostgreSQL
echo "Menunggu PostgreSQL..."
while ! pg_isready -h postgres -p 5432 -q; do
  sleep 1
done
echo "PostgreSQL siap dijalankan!"

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