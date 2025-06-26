#!/bin/sh
set -e

# Check if $UID and $GID are set
USER_ID=${UID:-1000}
GROUP_ID=${GID:-1000}

# Fix permissions
echo "Fixing file permissions with UID=${USER_ID} and GID=${GROUP_ID}..."
find /var/www -type d -exec chmod 775 {} \;
find /var/www -type f -exec chmod 664 {} \;
chown -R ${USER_ID}:${GROUP_ID} /var/www || echo "Some files could not be changed"

# 2. Create .env from .env.docker if doesn't exist
if [ ! -f "/var/www/.env" ]; then
    echo "Creating .env from .env.docker..."
    cp /var/www/.env.docker /var/www/.env
fi

# 3. Generate APP_KEY
php artisan key:generate

# 4. Clear cache
php artisan config:clear
php artisan route:clear
php artisan view:clear

exec "$@"