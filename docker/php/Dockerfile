FROM php:8.4-fpm-alpine

# Install dependencies termasuk build tools
RUN apk update && apk add --no-cache \
    git \
    curl \
    libpng-dev \
    libwebp-dev \
    libjpeg-turbo-dev \
    freetype-dev \
    oniguruma-dev \
    libxml2-dev \
    zip \
    unzip \
    postgresql-dev \
    postgresql-client \
    libzip-dev \
    icu-dev \
    shadow \
    autoconf \
    build-base

# Install PHP extensions
RUN docker-php-ext-configure gd --with-freetype --with-jpeg --with-webp
RUN docker-php-ext-install -j$(nproc) \
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

# Install Redis extension (dengan phpize)
RUN pecl install -o -f redis \
    && docker-php-ext-enable redis

# Hapus build dependencies untuk mengurangi ukuran image
RUN apk del autoconf build-base

# Install Composer
COPY --from=composer:latest /usr/bin/composer /usr/bin/composer

# Buat user dan group untuk Laravel
ARG UID=1000
ARG GID=1000
RUN addgroup -g $GID laravel && \
    adduser -u $UID -G laravel -s /bin/sh -D laravel && \
    mkdir -p /var/www/storage/logs && \
    chown -R laravel:laravel /var/www

# Set working directory
WORKDIR /var/www

# Copy entrypoint script
COPY docker/entrypoint.sh /usr/local/bin/
RUN chmod +x /usr/local/bin/entrypoint.sh

# Fix permission issues
RUN chown -R laravel:laravel /var/www

# Switch to laravel user
USER laravel

ENTRYPOINT ["entrypoint.sh"]