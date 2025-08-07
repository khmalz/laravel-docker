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
    supervisor

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

RUN docker-php-ext-enable zip

# Install Redis extension (dengan phpize)
RUN pecl install -o -f redis \
    && docker-php-ext-enable redis

# Delete build dependencies to reduce image size
RUN apt-get purge -y autoconf build-essential && \
    apt-get autoremove -y && \
    rm -rf /var/lib/apt/lists/*

# Install Composer
COPY --from=composer:latest /usr/bin/composer /usr/bin/composer

# Create user and group laravel
ARG UID=1000
ARG GID=1000
RUN groupadd -g ${GID} laravel && \
    useradd -u ${UID} -g laravel -s /bin/bash -m laravel && \
    mkdir -p /var/www/html && \
    chown -R laravel:laravel /var/www/html && \
    mkdir -p /data /config && \
    chown -R laravel:laravel /data /config

# Set working directory
WORKDIR /var/www/html

# Set permissions
RUN mkdir -p public \
    && mkdir -p storage/app storage/framework/cache storage/framework/sessions storage/framework/views storage/logs bootstrap/cache \
    && chown -R laravel:laravel storage bootstrap/cache public

RUN chown -R laravel:laravel /var/www/html/public \
    && chown -R laravel:laravel /var/www/html/storage \
    && chown -R laravel:laravel /var/www/html/bootstrap/cache

COPY docker/etc/supervisor.d/supervisord.conf /etc/supervisor/conf.d/supervisord.conf

# Copy entrypoint script dan beri permission
COPY docker/entrypoint.sh /usr/local/bin/entrypoint.sh
RUN chmod +x /usr/local/bin/entrypoint.sh
    
# Switch ke user laravel
USER laravel

# Expose port
EXPOSE 80 443

# Start entrypoint
ENTRYPOINT ["entrypoint.sh"]