FROM dunglas/frankenphp:php8.4

ENV SERVER_NAME="http://"

# Install dependencies
RUN apt-get update \
    && DEBIAN_FRONTEND=noninteractive apt-get install -y --no-install-recommends \
    git \
    curl \
    zip \
    unzip \
    postgresql-client \
    librabbitmq-dev \
    libpq-dev \
    supervisor \
    && rm -rf /var/lib/apt/lists/*

# Install PHP extensions
RUN install-php-extensions \
    pdo \
    pdo_pgsql \
    pgsql \
    mbstring \
    exif \
    pcntl \
    bcmath \
    gd \
    intl \
    zip \
    opcache

# Install Redis extension
RUN pecl install -o -f redis \
    && docker-php-ext-enable redis

# Install Composer
COPY --from=composer:latest /usr/bin/composer /usr/bin/composer

# Create user laravel
ARG UID=1000
ARG GID=1000
RUN groupadd -g ${GID} laravel && \
    useradd -u ${UID} -g laravel -s /bin/bash -m laravel && \
    mkdir -p /var/www/html && \
    chown -R laravel:laravel /var/www/html && \
    mkdir -p /data /config && \
    chown -R laravel:laravel /data /config

WORKDIR /var/www/html

# Copy project files
COPY . .

# Install PHP dependencies (di build stage, bukan runtime)
RUN composer install \
    --no-dev \
    --no-interaction \
    --prefer-dist \
    --optimize-autoloader

# Set permission
RUN mkdir -p public storage bootstrap/cache \
    && chown -R laravel:laravel /var/www/html \
    && chmod -R 775 storage bootstrap/cache public

# Copy supervisor config
COPY docker/etc/supervisor.d/supervisord.conf /etc/supervisor/conf.d/supervisord.conf

# Copy entrypoint
COPY docker/entrypoint.sh /usr/local/bin/entrypoint.sh
RUN chmod +x /usr/local/bin/entrypoint.sh

# Switch ke user laravel
USER laravel

# Expose port
EXPOSE 80 443

# Start entrypoint
ENTRYPOINT ["entrypoint.sh"]